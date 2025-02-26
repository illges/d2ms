---@diagnostic disable: undefined-global, lowercase-global

local base = include 'lib/context_base'

local context = setmetatable({}, {__index = base})
context.__index = context

function context.new()
	local self = setmetatable(base.new(), context)
    self.name = "play"
    self.type = "play"
    self.next_page = 0
    self.next_page_pressed = false
    self.toggle_page_hold_pressed = false
    self.toggle_page_hold = 1
    self.vel = {127,112,96,80,64,48,32,16}
    self.midi_learn_vel_low = false
    self.midi_learn_vel_high = false
    self.clear_velocity = false
    self.midi_learn_vel_floor = false
    self.midi_learn_vel_ceiling = false
    self.machine_type_next = false
    self.machine_type_previous = false
	return self
end

function context:draw_screen()
    local inputs = self:get_io_page()==1 and "9-16" or "1-8"
    local input = machine_context.selected_input
    local layer = machine_context.input[input].sel_machine_layer
    local machine_type = machine_context.input[input].machine[layer].type

    screen.level(0)
    screen.move(15, 7)
    screen.text(string.upper(current_context.name).." : "..string.upper(machine_type).." : "..inputs)

    --input.layer.patch
    self:draw_header_top_right(input.."."..layer.."."..machine_context.pattern_lane.position)

    machine_context:draw_screen_machine(input, layer, machine_type)
end

function context:draw_grid()
    g:led(15, 4, basic_lighting(self.machine_type_previous))
    g:led(16, 4, basic_lighting(self.machine_type_next))
    g:led(11, 1, negative_lighting(self.clear_velocity))
    g:led(11, 2, negative_lighting(self.midi_learn_vel_high))
    g:led(11, 8, basic_lighting(self.next_page==1 or self.next_page_pressed))
    g:led(12, 8, basic_lighting(self.toggle_page_hold==1))
    g:led(16, 8, negative_lighting(self.tap_tempo_pressed or tap_tempo_light==1))

    local light
    local light_one_five
    for i=1,8 do
        for k=1,8 do
            light_one_five = ((i==1 or i==5) and k==8) and 8 or math.floor(15/k)
            light = self.momentary[i+2][k] == 1 and 0 or light_one_five
            --for neotrellis setups
            if (k==4 or k==6) then light = light + 1 end
            g:led(i+2, k, light)
        end
    end
    for i=1,5 do
        light = machine_context:get_layer_lighting(i)
        g:led(i+11, 2, light)
    end
end

function context:get_io_page()
    if self.toggle_page_hold == 1 then
        return self.next_page_pressed and 1 or 0
    else
        return self.next_page
    end
end

function context:grid_key(x,y,on)
    self.tap_tempo_pressed = self.momentary[16][8] == 1 and true or false

    self.toggle_page_hold_pressed = self.momentary[12][8] == 1 and true or false
    if self.toggle_page_hold_pressed then
        self.toggle_page_hold = 1 - self.toggle_page_hold
        if self.toggle_page_hold == 1 then self.next_page = 0 end
    end

    self.next_page_pressed = self.momentary[11][8] == 1 and true or false
    if self.next_page_pressed then
        if self.toggle_page_hold==0 then
            self.next_page = 1 - self.next_page
        end
    end

    local num = machine_context.selected_input
    local layer = machine_context.input[num].sel_machine_layer

    if x>=3 and x<=10 then
        if on then
            machine_context.selected_input = self:get_io_page()==0 and x-2 or x+6
            local vel = self.vel[y]
            num = machine_context.selected_input
            layer = machine_context.input[num].sel_machine_layer
            --print(num, vel)
            if self.midi_learn_vel_low then
                machine_context.input[num]:set_low_thresh("machine", layer, util.clamp(vel, 1, 127))
                screen_dirty = true
            elseif self.midi_learn_vel_high then
                machine_context.input[num]:set_high_thresh("machine", layer, util.clamp(vel, 1, 127))
                screen_dirty = true
            elseif self.midi_learn_vel_ceiling then
                machine_context.input[num]:set_velocity_ceiling(util.clamp(vel, 1, 127))
                screen_dirty = true
            elseif self.midi_learn_vel_floor then
                machine_context.input[num]:set_velocity_floor(util.clamp(vel, 1, 127))
                screen_dirty = true
            else
                local data = {
                    type = "note_on",
                    note = machine_context.input[num].note,
                    ch = machine_context.input[num].channel,
                    vel = vel
                }
                process_midi_event(data)
            end
        end
    end

    for i=1,5 do
        if x==i+11 and y<=3 then
            machine_context.input[num].sel_machine_layer = i
        end
    end
    self.midi_learn_vel_high = self.momentary[11][2] == 1 and true or false

    self.midi_learn_vel_low = (self.momentary[12][2] == 1 or
                               self.momentary[13][2] == 1 or
                               self.momentary[14][2] == 1 or
                               self.momentary[15][2] == 1 or
                               self.momentary[16][2] == 1) and true or false

    self.midi_learn_vel_floor = (self.momentary[12][3] == 1 or
                               self.momentary[13][3] == 1 or
                               self.momentary[14][3] == 1 or
                               self.momentary[15][3] == 1 or
                               self.momentary[16][3] == 1) and true or false

    self.midi_learn_vel_ceiling = (self.momentary[12][1] == 1 or
                               self.momentary[13][1] == 1 or
                               self.momentary[14][1] == 1 or
                               self.momentary[15][1] == 1 or
                               self.momentary[16][1] == 1) and true or false

    self.clear_velocity = self.momentary[11][1] == 1 and true or false
    if self.clear_velocity then
        if self.midi_learn_vel_low then
            machine_context.input[num]:set_low_thresh("machine", layer, 0)
            machine_context.input[num]:set_high_thresh("machine", layer, 127)
        elseif self.midi_learn_vel_floor then
            machine_context.input[num]:set_velocity_floor(0)
        elseif self.midi_learn_vel_ceiling then
            machine_context.input[num]:set_velocity_ceiling(127)
        end
    end

    self.machine_type_next = self.momentary[16][4] == 1 and true or false
    self.machine_type_previous = self.momentary[15][4] == 1 and true or false
    if self.machine_type_next then
        machine_context.input[num].machine[layer]:set_machine_type(1)
    end
    if self.machine_type_previous then
        machine_context.input[num].machine[layer]:set_machine_type(-1)
    end
end

function context:check_velocity_learn(io,event,num)
    local input = machine_context.selected_input
    if lock_midi_learn == 1 then
        return false
    elseif input ~= num then
        return false
    elseif self.midi_learn_vel_high and self.midi_learn then
        io[input]:set_velocity_ceiling(event.vel)
    elseif self.midi_learn_vel_low and self.midi_learn then
        io[input]:set_velocity_floor(event.vel)
    elseif self.midi_learn_vel_high then
        local layer = io[input].sel_machine_layer
        io[input]:set_high_thresh("machine", layer, util.clamp(event.vel, 1, 127))
        screen_dirty = true
    elseif self.midi_learn_vel_low then
        local layer = io[input].sel_machine_layer
        io[input]:set_low_thresh("machine", layer, util.clamp(event.vel, 1, 127))
        screen_dirty = true
    else
        return false
    end
    return true
end

function context:enc_one(d)
    machine_context:enc_one(d)
end

function context:enc_two(d)
    machine_context:enc_two(d)
end

function context:enc_three(d)
    machine_context:enc_three(d)
end

function context:get_current_gesture()
    local gesture
    if self.next_page_pressed then gesture = "change inputs"
    elseif self.toggle_page_hold_pressed then gesture = "page latch"
    elseif self.midi_learn_vel_low then gesture = "midi learn vel low"
    elseif self.midi_learn_vel_high then gesture = "midi learn vel high"
    elseif self.machine_type_next then gesture = "next machine"
    elseif self.machine_type_previous then gesture = "previous machine"
    elseif self.clear_velocity then gesture = "clear velocity"
    elseif self.midi_learn_vel_ceiling then gesture = "midi learn vel ceiling"
    elseif self.midi_learn_vel_floor then gesture = "midi learn vel floor"
    else gesture = "" end
    self.gesture = gesture
end

return context