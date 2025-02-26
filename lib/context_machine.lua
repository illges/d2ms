---@diagnostic disable: undefined-global, lowercase-global

local base = include 'lib/context_routing_base'

local context = setmetatable({}, {__index = base})
context.__index = context

function context.new(io)
    local self = setmetatable(base.new("machine"), context)
    self.name = "machine"
    self.type = "routing"
    self.input = io
    self.selected_input = 1
    self.selected_ui = 1
    self.machine_type_next = false
    self.machine_type_previous = false
    self.pass_vel_toggle = false
    self.monophonic_toggle = false
    self.fixed_note_visual = 1
    self.follow_offset_pressed = false
    self.leader_pointer_pressed = false
    --self.riff_pointer_pressed = false
    self.notes_send_pressed = false
    self.cc_send_pressed = false
    self.hold_time_set = false
    self.meta_shift_pressed = false
    self.note_lane_held = false
    self.meta_step_pressed = 0
    return self
end

function context:get_current_layer()
    local input = self.selected_input
    local sel_machine_layer = self.input[input].sel_machine_layer
    return self.input[input].machine[sel_machine_layer]
end

function context:draw_screen()
    local input = self.selected_input
    local layer = self.input[input].sel_machine_layer
    local machine_type = self.input[input].machine[layer].type

    -- context banner
    screen.level(0)
    screen.move(15, 7)
    screen.text(string.upper(current_context.name).." : "..string.upper(machine_type))

    --input.layer.patch
    self:draw_header_top_right(input.."."..layer.."."..self.pattern_lane.position)

    if layout_v2==1 then
        if self.note_lane_held then
            self:draw_lane_date()
        else
            self:draw_screen_machine(input, layer, machine_type)
        end
    else
        self:draw_screen_machine(input, layer, machine_type)
    end
end

function context:draw_lane_date()
    local lane = notes_context.lane[self.focus]
    screen.level(15)
    screen.move(0, 18)
    screen.text("lane "..self.focus.." data")

    notes_context:draw_screen_seq(lane, notes_context.STEP)
end

function context:draw_screen_machine(input, layer, machine_type)
    self:draw_generic()

    local hold = self.input[input].machine[layer]:get_hold_time()
    if hold == 0 then hold = "inf" end
    local text = self.input[input].machine[layer].hold_time_toggle == 1 and "sus2:" or "sus1:"
    self:get_param_screen_level(8)
    screen.move(127, 30)
    screen.text_right(text..hold)

    MACHINES[machine_type]:draw_screen(self.input[input].machine[layer])
end

function context:enc_one(d)
    self:enc_two(d)
end

function context:enc_two(d)
    self.selected_ui = util.wrap(self.selected_ui + d, 1,
            self.input[self.selected_input]
                .machine[self.input[self.selected_input].sel_machine_layer].ui_clamp)
end

function context:enc_three(d)
    local input = self.selected_input
    local layer = self.input[input].sel_machine_layer

    if self.selected_ui == 1 then
        local note = self.input[input].note
        self.input[input]:set_note(util.clamp(note + d, 1, 127))
    elseif self.selected_ui == 2 then
        local channel = self.input[input].channel
        self.input[input]:set_channel(util.clamp(channel + d, 1, 16))
    elseif self.selected_ui == 3 then
        local prob = self.input[input].machine[layer]:get_probability(self.scene_lane.position)
        self.input[input].machine[layer]:set_probability(prob + d, self.scene_lane.position)
    elseif self.selected_ui == 4 then
        local low_thresh = self.input[input].machine[layer].low_thresh
        self.input[input]:set_low_thresh("machine", layer, util.clamp(low_thresh + d, 0, 127))
    elseif self.selected_ui == 5 then
        local high_thresh = self.input[input].machine[layer].high_thresh
        self.input[input]:set_high_thresh("machine", layer, util.clamp(high_thresh + d, 0, 127))
    elseif self.selected_ui == 6 then
        local flr = self.input[input]:get_vel_floor()
        self.input[input]:set_velocity_floor(util.clamp(flr + d, 0, 127))
    elseif self.selected_ui == 7 then
        local ceil = self.input[input]:get_vel_ceiling()
        self.input[input]:set_velocity_ceiling(util.clamp(ceil + d, 0, 127))
    elseif self.selected_ui == 8 then
        if self.input[input].machine[layer].hold_time_toggle == 0 or
           self.input[input].machine[layer].hold_inf == 0 then
            self.input[input].machine[layer]:set_hold_time(d)
        end
    end
end

function context:check_input_held()
    for i=1,2 do
        for j=1,8 do
            if self.momentary[j][i+6] == 1 then
                return true
            end
        end
    end
    return false
end

function context:draw_grid()
    self:draw_grid_base()
    self:draw_grid_main()
    self:draw_grid_base_override()
    g:led(1, 6, negative_lighting(self.machine_type_previous))
    g:led(2, 6, negative_lighting(self.machine_type_next))
    g:led(13, 8, basic_lighting(self.meta_shift_pressed))
    g:led(16, 8, negative_lighting(self.tap_tempo_pressed or tap_tempo_light==1))
end

function context:draw_grid_base_override()
    local input = self.selected_input
    local layer = self.input[input].sel_machine_layer
    g:led(1, 5, basic_lighting(self.notes_send_pressed or self.input[input].machine[layer].notes_send == 1))
    g:led(2, 5, basic_lighting(self.cc_send_pressed or self.input[input].machine[layer].cc_send == 1))
end

function context:draw_upper_v1(input, layer)
    for i=1,self.area do
        local mod_val = i + (4 * (self.active_page - 1))
        for j=1,16 do
            local light = 3
            if self.leader_pointer_pressed then
                light = self.input[input].machine[layer].leader_pointer[mod_val] == 1 and 6 or light
            -- elseif self.riff_pointer_pressed then
            --     light = self.input[input].machine[layer].riff_pointer[mod_val] == 1 and 6 or light
            else
                light = self.input[input].machine[layer].lane_send[mod_val] == 1 and 6 or light
            end
            for k=1,#self.layer_routing[layer].output_list[mod_val] do
                if self.layer_routing[layer].output_list[mod_val][k] == j then
                    light = 15
                    break
                end
            end
            light = self.lane_visual[i] > 0 and self.lane_visual[i] or light
            g:led(j, i, light)
        end
    end
end


function context:draw_upper_v2(input, layer)
    for i=1,self.area do
        local mod_val = i + (4 * (self.active_page - 1))
        local light = 3
        local min = notes_context.lane[mod_val]:range_min(notes_context.lane[mod_val].strum_pattern)
        local max = notes_context.lane[mod_val]:range_max(notes_context.lane[mod_val].strum_pattern)
        for j=1, 16 do
            light = 3
            if self.leader_pointer_pressed then
                light = self.input[input].machine[layer].leader_pointer[mod_val] == 1 and 6 or light
            -- elseif self.riff_pointer_pressed then
            --     light = self.input[input].machine[layer].riff_pointer[mod_val] == 1 and 6 or light
            else
                light = self.input[input].machine[layer].lane_send[mod_val] == 1 and 6 or light
            end
            if self.notes_send_pressed or self.leader_pointer_pressed or self.midi_learn_vel_low then
                for k=1,#self.layer_routing[layer].output_list[mod_val] do
                    if self.layer_routing[layer].output_list[mod_val][k] == j then
                        light = 15
                        break
                    end
                end
            else
                light = notes_context.lane[mod_val]:check_play_step(j) and light or 0
                light = (j == notes_context.lane[mod_val].position or j == notes_context.lane[mod_val].strum_light) and 14 or light
                light = notes_context.step_visual[mod_val][j] > 0 and notes_context.step_visual[mod_val][j] or light
                if notes_context.note_lighting then
                    if notes_context.lane[mod_val]:riff_lane() then
                        light = notes_context.note_visual[mod_val][j] > 0 and notes_context.note_visual[mod_val][j] or 3
                    else
                        light = notes_context.note_visual[mod_val][j] > 0 and notes_context.note_visual[mod_val][j] or notes_context:get_notes_lighting(notes_context.lane[mod_val]:data(j))
                    end
                else
                    light = notes_context.note_visual[mod_val][j] > 0 and notes_context.note_visual[mod_val][j] or light
                end
                light = notes_context.riff_visual[mod_val][j] > 0 and notes_context.riff_visual[mod_val][j] or light
            end

            light = ((j>=min and j<=max) or light==15) and light or 0 -- steps outside of the sequence length are zero unless displaying channel routings
            g:led(j, i, light)
        end
    end
end

function context:draw_grid_main()
    local input = self.selected_input
    local layer = self.input[input].sel_machine_layer
    local machine_type = self.input[input].machine[layer].type

    if MACHINES[machine_type].draw_upper_grid then
        if self.meta_step_pressed>0 then
            MACHINES[machine_type]:draw_interval_player()
        elseif layout_v2==1 then
            self:draw_upper_v2(input, layer)
        else
            self:draw_upper_v1(input, layer)
        end
    end
    for i=1,2 do
        for j=1,8 do
            local current = (j + (8 * (i - 1)))
            local light = 3
            g:led(j, i+6, self.selected_input == (j + (8 * (i - 1))) and 15 or light)
            if j == 1 or j == 5 then light = 8 end
            if self.selected_input == (j + (8 * (i - 1))) then light = 15 end
            light = self.input_visual[current] > 0 and self.input_visual[current] or light
            g:led(j, i+6, light)
        end
    end
    for i=1,5 do
        light = self:get_layer_lighting(i)
        g:led(i+3, 6, light)
    end

    g:led(4, 5, negative_lighting(self.input[input].machine[layer].pass_vel == 1))
    g:led(5, 5, negative_lighting(self.input[input].machine[layer].monophonic == 1))
    g:led(6, 5, negative_lighting(self.input[input].machine[layer].hold_time_toggle == 1))
    g:led(7, 5, negative_lighting(self.input[input].machine[layer].follow_offset == 1))
    if #self.input[input].machine[layer].leader_routing > 0 then
        g:led(8, 5, high_lighting(self.leader_pointer_pressed))
    else
        g:led(8, 5, basic_lighting(self.leader_pointer_pressed))
    end

    MACHINES[machine_type]:draw_grid(self.input[input].machine[layer], self.momentary)
end

function context:get_layer_lighting(layer_num)
    local input = self.selected_input
    local layer = self.input[input].sel_machine_layer

    local light = (self.input[input].machine[layer_num]:get_probability(self.scene_lane.position) > 0 and self.input[input].machine[layer_num].type ~= "EMPTY") and 9 or 5
    light = layer == layer_num and 15 or light
    light = self.layer_visual[layer_num] > 0 and self.layer_visual[layer_num] or light
    return light
end

function context:grid_patching(x,y,z)
    local input = self.selected_input
    local sel_machine_layer = self.input[input].sel_machine_layer
    local layer = self.input[input].machine[sel_machine_layer]

    if self.midi_learn_vel_low then
        layer:set_lane_send_data(y)
    elseif self.leader_pointer_pressed then
        layer:set_leader_pointer_data(y)
    -- elseif self.riff_pointer_pressed then
    --     layer:set_riff_pointer_data(y)
    elseif self.meta_step_pressed>0 then
        MACHINES[layer.type]:set_meta_and_play(x,y,layer,sel_machine_layer)
    else
        if layout_v2==1 then
            if self.notes_send_pressed then
                self:set_output_data(sel_machine_layer, y, x)
            else
                self.note_lane_held = true
                pattern_context.focus = y
                notes_context.focus = y
            end
        else
            self:set_output_data(sel_machine_layer, y, x)
        end
    end
    self.focus = y
    if layout_v2==1 then notes_context.focus_x = x end
end

function context:grid_patching_off(x,y,z)
    self.note_lane_held = false
end

function context:copy_velocity(sel, input_machine) -- currently only from low layer to high layer
    for i=1,5 do
        if i ~= sel then
            if input_machine.machine[i].momentary then
                input_machine.machine[sel]:set_low_thresh(input_machine.machine[i].high_thresh+1)
            end
        end
    end
end

function context:grid_key(x,y,on)
    for i=1,2 do
        for j=1,8 do
            local selected = (j + (8 * (i - 1)))
            local sel = self.input[self.selected_input].sel_machine_layer -- get previous selected layer
            self.input[selected].momentary = self.momentary[j][i+6] == 1 and true or false
            --self.selected_input = self.input[selected].momentary and selected or self.selected_input
            if self.input[selected].momentary then
                self.selected_input = selected
                self:set_layer_visual(self.selected_input)
            end
            self.input[self.selected_input].sel_machine_layer = sel -- set selected layer same as previous
        end
    end

    local input = self.selected_input
    local input_machine = self.input[input]
    local layer = input_machine.sel_machine_layer
    local machine_type = self.input[input].machine[layer].type

    input_machine.machine[1].momentary = self.momentary[4][6] == 1 and true or false
    input_machine.machine[2].momentary = self.momentary[5][6] == 1 and true or false
    input_machine.machine[3].momentary = self.momentary[6][6] == 1 and true or false
    input_machine.machine[4].momentary = self.momentary[7][6] == 1 and true or false
    input_machine.machine[5].momentary = self.momentary[8][6] == 1 and true or false

    self.midi_learn =  input_machine.momentary and true or false
    self.midi_learn_vel_high = self.momentary[3][6] == 1 and true or false
    self.midi_learn_vel_low = (input_machine.machine[1].momentary or
                               input_machine.machine[2].momentary or
                               input_machine.machine[3].momentary or
                               input_machine.machine[4].momentary or
                               input_machine.machine[5].momentary) and true or false

    if self.midi_learn_vel_low then
        local sel = input_machine.sel_machine_layer
        if input_machine.machine[5].momentary then sel = 5
            self:copy_velocity(sel, input_machine)
        elseif input_machine.machine[4].momentary then sel = 4
            self:copy_velocity(sel, input_machine)
        elseif input_machine.machine[3].momentary then sel = 3
            self:copy_velocity(sel, input_machine)
        elseif input_machine.machine[2].momentary then sel = 2
            self:copy_velocity(sel, input_machine)
        elseif input_machine.machine[1].momentary then sel = 1
            self:copy_velocity(sel, input_machine)
        end
        input_machine.sel_machine_layer = sel
    end

    if self.midi_learn and input_machine.machine[1].momentary then
        input_machine.machine[1]:invert_probability(self.scene_lane.position)
    elseif self.midi_learn and input_machine.machine[2].momentary then
        input_machine.machine[2]:invert_probability(self.scene_lane.position)
    elseif self.midi_learn and input_machine.machine[3].momentary then
        input_machine.machine[3]:invert_probability(self.scene_lane.position)
    elseif self.midi_learn and input_machine.machine[4].momentary then
        input_machine.machine[4]:invert_probability(self.scene_lane.position)
    elseif self.midi_learn and input_machine.machine[5].momentary then
        input_machine.machine[5]:invert_probability(self.scene_lane.position)
    end

    self.pass_vel_toggle = self.momentary[4][5] == 1 and true or false
    if self.pass_vel_toggle then input_machine.machine[layer]:invert_pass_velocity() end

    self.monophonic_toggle = self.momentary[5][5] == 1 and true or false
    if self.monophonic_toggle then input_machine.machine[layer]:set_monophonic_toggle() end

    self.machine_type_next = self.momentary[2][6] == 1 and true or false
    self.machine_type_previous = self.momentary[1][6] == 1 and true or false
    self.meta_shift_pressed = self.momentary[13][8] == 1 and true or false

    if self.machine_type_next and not self.meta_shift_pressed then
        input_machine.machine[layer]:set_machine_type(1)
    end

    if self.machine_type_previous and not self.meta_shift_pressed then
        input_machine.machine[layer]:set_machine_type(-1)
    end

    if self.machine_type_next and self.meta_shift_pressed then
        self.pattern_lane:adv_lane_position(1)
        self:update_output_channel_data()
        grid_redraw()
    end
    if self.machine_type_previous and self.meta_shift_pressed then
        self.pattern_lane:adv_lane_position(-1)
        self:update_output_channel_data()
        grid_redraw()
    end

    -- self.riff_pointer_pressed = self.momentary[9][5] == 1 and true or false

    MACHINES[machine_type]:grid_key(self.input[input].machine[layer], self.momentary)

    self.notes_send_pressed = self.momentary[1][5] == 1 and true or false
    self.cc_send_pressed = self.momentary[2][5] == 1 and true or false
    if layout_v2==1 then
        if self.notes_send_pressed and self.midi_learn_vel_low then input_machine.machine[layer]:invert_notes_send() end
        if self.cc_send_pressed and self.midi_learn_vel_low then input_machine.machine[layer]:invert_cc_send() end
    else
        if self.notes_send_pressed then input_machine.machine[layer]:invert_notes_send() end
        if self.cc_send_pressed then input_machine.machine[layer]:invert_cc_send() end
    end

    self.follow_offset_pressed = self.momentary[7][5] == 1 and true or false
    if self.follow_offset_pressed then input_machine.machine[layer]:set_follow_offset() end
    self.leader_pointer_pressed = self.momentary[8][5] == 1 and true or false

    self.hold_time_set = self.momentary[6][5] == 1 and true or false
    if self.hold_time_set then input_machine.machine[layer]:set_hold_toggle() end

    self.tap_tempo_pressed = self.momentary[16][8] == 1 and true or false

    self:grid_key_base(layer)

    self.meta_step_pressed = (MACHINES[machine_type].meta_step_pressed and MACHINES[machine_type].meta_step_pressed>0)
        and MACHINES[machine_type].meta_step_pressed or 0
end

function context:get_current_gesture()
    local input = self.selected_input
    local input_machine = self.input[input]
    local layer = input_machine.sel_machine_layer
    local machine_type = self.input[input].machine[layer].type
    local gesture = MACHINES[machine_type]:get_current_gesture()
    if gesture then self.gesture = gesture return end

    if self.machine_type_next and not self.meta_shift_pressed then gesture = "next machine"
    elseif self.machine_type_previous and not self.meta_shift_pressed then gesture = "previous machine"
    elseif (self.machine_type_next or self.machine_type_previous) and self.meta_shift_pressed then gesture = "+/- patch"
    elseif self.pass_vel_toggle then gesture = "velocity pass toggle"
    elseif self.monophonic_toggle then gesture = "monophonic toggle"
    elseif self.notes_send_pressed then
        if layout_v2==1 then
            if self.midi_learn_vel_low then
                gesture = "notes send"
            else
                gesture = "midi channel routing"
            end
        else
            gesture = "notes send"
        end
    elseif self.cc_send_pressed then gesture = "cc send"
    elseif self.offset_decrease or self.offset_increase then gesture = "change offset"
    elseif self.hold_time_set then gesture = "sustain time toggle"
    elseif self.leader_pointer_pressed then gesture = "leader pointer"
    --elseif self.riff_pointer_pressed then gesture = "riff pointer"
    elseif self.follow_offset_pressed then gesture = "follow offset"
    elseif self.meta_shift_pressed then gesture = "shift"
    elseif self.note_lane_held then gesture = "view lane data"
    elseif self.meta_step_pressed>0 then gesture = "meta step"
    else gesture = self:get_current_gesture_routing_base()
    end
    self.gesture = gesture
end

function context:set_layer_visual(input)
    if grid_light_pulse~=1 then return end
    
    self.layer_visual = self:init_visual(5)
    self.page_visual = self:init_visual(4)
    --self.lane_visual = self:init_visual(4)

    local input_machine = self.input[input]
    local default = 8
    local mod = 1

    for k=1,5 do
        for i=1,16 do
            if input_machine.machine[k].lane_send[i] == 1 then
                self.layer_visual[k] = default
                if i <= 4 then
                    self.page_visual[1] = default
                elseif i <= 8 then
                    self.page_visual[2] = default
                elseif i <= 12 then
                    self.page_visual[3] = default
                elseif i <= 16 then
                    self.page_visual[4] = default
                end
                -- mod = i%4 ~= 0 and i%4 or 4
                -- self.lane_visual[mod] = default
            end
        end
    end
end

function context:range_update(x,y,z,mod)
    if layout_v2==1 and self.notes_send_pressed==false and notes_context:range_update_ok(y) then
        notes_context:range_update(x,y,z,mod)
        return
    end
    if y<=4 then return end
    local input = self.selected_input
    local layer = self.input[input].sel_machine_layer
    local input_machine = self.input[input].machine[layer]
    --if z==1 and self.held then self.heldmax = 0 end
    self.held = self.held + (z*2-1)
    --if self.held > self.heldmax then self.heldmax = self.held end

    if not self:range_update_ok(x,y,z) then self.held = 0 return
    elseif z == 1 then
        if self.held==1 then
            if y == 6 then self.first = x-8
            elseif y == 7 then self.first = x-4
            end
            min = self.first
            max = self.first
            input_machine:set_range_data(min, max)
            input_machine.position = min
        elseif self.held==2 then
            if y == 6 then self.second = x-8
            elseif y == 7 then self.second = x-4
            end
            local min
            local max
            if self.first > 0 and self.second < self.first then
                min = self.second
                max = self.second
                input_machine:set_range_data(min, max)
            else
                min = math.min(self.first,self.second)
                max = math.max(self.first,self.second)
                input_machine:set_range_data(min, max)
            end

            input_machine:clamp_position()

            grid_dirty = true
            screen_dirty = true
        end
    end
end

function context:range_update_ok(x,y,z)
    local input = self.selected_input
    local input_machine = self.input[input]
    local layer = input_machine.sel_machine_layer
    if self.meta_shift_pressed then
        if input_machine.machine[layer].type == "fixed" or
            input_machine.machine[layer].type == "riff" or
            input_machine.machine[layer].type == "prog" or
            input_machine.machine[layer].type == "stack" or
            input_machine.machine[layer].type == "chord" then
                if x >= 9 and x <= 12 and y >= 6 and y <= 7 and z==1 then
                    local step
                    if y==6 then step = x - 8
                    elseif y==7 then step = x - 4
                    else return false
                    end
                    input_machine.machine[layer]:set_meta_seq_step_mute(step)
                end
        end
        return false
    end
    if input_machine.machine[layer].type == "fixed" or
       input_machine.machine[layer].type == "riff" or
       input_machine.machine[layer].type == "prog" or
       input_machine.machine[layer].type == "stack" or
       input_machine.machine[layer].type == "chord" or
       input_machine.machine[layer].type == "gears" then
        if x >= 9 and x <= 12 and y >= 6 and y <= 7 then
            return true
        end
    end
    return false
end

function context:check_velocity_learn(io,event,num)
    local input = self.selected_input
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

return context