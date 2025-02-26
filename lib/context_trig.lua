---@diagnostic disable: undefined-global, lowercase-global

local base = include 'lib/context_routing_base'
local tp = include 'lib/transport'

local context = setmetatable({}, {__index = base})
context.__index = context

function context.new(io)
    local self = setmetatable(base.new("trig"), context)
    self.transport = tp
    self.name = "trig"
    self.type = "routing"
    self.input = io
    self.selected_input = 1
    self.selected_ui = 1
    self.selected_machine_input = 1
    self.selected_machine_layer = 1
    self.trig_type_next = false
    self.trig_type_previous = false
    self.pass_vel_toggle = false
    self.meta_shift_pressed = false
    self.gear_step_toggle_pressed = false
    return self
end

function context:draw_screen()
    local input = self.selected_input
    local layer = self.input[input].sel_trig_layer
    local trig_type = self.input[input].trig[layer].type
    local trig_type_display = TRIGS[trig_type]:draw_secondary_mode(self.input[input].trig[layer])

    -- context banner
    screen.level(0)
    screen.move(15, 7)
    screen.text(string.upper(current_context.name).." : "..string.upper(trig_type)..string.upper(trig_type_display))

    --trig.layer
    self:draw_header_top_right(input.."."..layer)

    self:draw_generic()

    TRIGS[trig_type]:draw_screen(self.input[input].trig[layer], self.transport)
end

function context:enc_one(d)
    self:enc_two(d)
end

function context:enc_two(d)
    self.selected_ui = util.wrap(self.selected_ui + d, 1,
            self.input[self.selected_input]
                .trig[self.input[self.selected_input].sel_trig_layer].ui_clamp)
end

function context:enc_three(d)
    local input = self.selected_input
    local layer = self.input[input].sel_trig_layer

    if self.selected_ui == 1 then
        local note = self.input[input].note
        self.input[input]:set_note(util.clamp(note + d, 1, 127))
    elseif self.selected_ui == 2 then
        local channel = self.input[input].channel
        self.input[input]:set_channel(util.clamp(channel + d, 1, 16))
    elseif self.selected_ui == 3 then
        local prob = self.input[input].trig[layer]:get_probability(self.scene_lane.position)
        self.input[input].trig[layer]:set_probability(prob + d, self.scene_lane.position)
    elseif self.selected_ui == 4 then
        local low_thresh = self.input[input].trig[layer].low_thresh
        self.input[input]:set_low_thresh("trig", layer, util.clamp(low_thresh + d, 0, 127))
    elseif self.selected_ui == 5 then
        local high_thresh = self.input[input].trig[layer].high_thresh
        self.input[input]:set_high_thresh("trig", layer, util.clamp(high_thresh + d, 0, 127))
    elseif self.selected_ui == 6 then
        local flr = self.input[input]:get_vel_floor()
        self.input[input]:set_velocity_floor(util.clamp(flr + d, 0, 127))
    elseif self.selected_ui == 7 then
        local ceil = self.input[input]:get_vel_ceiling()
        self.input[input]:set_velocity_ceiling(util.clamp(ceil + d, 0, 127))
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
    
    g:led(1, 6, negative_lighting(self.trig_type_previous))
    g:led(2, 6, negative_lighting(self.trig_type_next))
    g:led(16, 8, negative_lighting(self.tap_tempo_pressed or tap_tempo_light==1))
    g:led(13, 8, negative_lighting(self.meta_shift_pressed))
end

function context:draw_grid_main()
    local input = self.selected_input
    local layer = self.input[input].sel_trig_layer
    local trig_type = self.input[input].trig[layer].type

    if TRIGS[trig_type].draw_machine_grid or
       self.input[input].trig[layer]:check_reset_meta() then
        self:draw_grid_machine(input, layer)
    elseif TRIGS[trig_type].draw_upper_grid then
        for i=1,self.area do
            local mod_val = i + (4 * (self.active_page - 1))
            for j=1,16 do
                local light = 3
                light = self.input[input].trig[layer].lane_send[mod_val] == 1 and 6 or light
                light = self.lane_visual[i] > 0 and self.lane_visual[i] or light
                g:led(j, i, light)
            end
        end
    else
        TRIGS[trig_type]:draw_grid_extended(self.input[input].trig[layer], self.momentary)
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
        local light = (self.input[input].trig[i]:get_probability(self.scene_lane.position) > 0 and self.input[input].trig[i].type ~= "EMPTY") and 9 or 5
        light = layer == i and 15 or light
        light = self.layer_visual[i] > 0 and self.layer_visual[i] or light
        g:led(i+3, 6, light)
    end

    TRIGS[trig_type]:draw_grid(self.input[input].trig[layer], self.momentary)
end

function context:draw_grid_machine(input, layer)
    local trig = self.input[input].trig[layer]
    local trig_type = self.input[input].trig[layer].type

    for i=1,2 do
        for j=1,8 do
            local current = (j + (8 * (i - 1)))
            local light = 3
            if trig.input_machine[current].active then light = 8 end
            if self.selected_machine_input == current then light = 15 end
            light = machine_context.input_visual[current] > 0 and machine_context.input_visual[current] or light
            g:led(j, i+1, light)
        end
    end
    for i=1,5 do
        local light = TRIGS[trig_type]:draw_grid_machine_layers(trig, self.input, self.selected_machine_input, i)
        if light==nil then
            light = trig.input_machine[self.selected_machine_input].layer[i] == 1 and 8 or 3
        end
        light = self.machine_layer_visual[i] > 0 and self.machine_layer_visual[i] or light
        g:led(i+3, 1, light)
    end
end

function context:grid_key_machine(input, layer)
    local trig = self.input[input].trig[layer]
    
    for i=1,2 do
        for j=1,8 do
            local selected = (j + (8 * (i - 1)))
            --local sel = self.input[self.selected_input].sel_trig_layer -- get previous selected layer
            trig.input_machine[selected].momentary = self.momentary[j][i+1] == 1 and true or false
            if trig.input_machine[selected].momentary then
                self.selected_machine_input = selected
            end
            --self.input[self.selected_input].sel_trig_layer = sel -- set selected layer same as previous
        end
    end
end

function context:handle_tracks_internal(trig)
    local trig_type = trig.type
    return TRIGS[trig_type].handle_tracks_internal
end

function context:UpperGrid(trig)
    local trig_type = trig.type
    return TRIGS[trig_type].draw_upper_grid
end

function context:IsAutoTrig(trig)
    local trig_type = trig.type
    if TRIGS[trig_type].auto_trig or
       trig:check_reset_meta() then return true
    else return false end
end

function context:grid_patching(x,y,z) -- y is mod val
    local input = self.selected_input
    local sel_trig_layer = self.input[input].sel_trig_layer
    local trig = self.input[input].trig[sel_trig_layer]
    local trig_type = trig.type
    if self:IsAutoTrig(trig) == false and self:UpperGrid(trig) then
        if self.midi_learn_vel_low then
            trig:set_lane_send_data(y)
        else
            --self:set_output_data(sel_trig_layer, y, x)
        end
        self.focus = y
    elseif TRIGS[trig_type].draw_machine_grid or trig:check_reset_meta() then
        if (y==1 or y==5 or y==9 or y==13) and (x>=4 and x<=8) then
            trig:set_trig_to_machine_layer_routing(self.selected_machine_input, x-3)
        end
    end
end

function context:copy_velocity(sel, input_trig) -- currently only from low layer to high layer
    for i=1,5 do
        if i ~= sel then
            if input_trig.trig[i].momentary then
                input_trig.trig[sel]:set_low_thresh(input_trig.trig[i].high_thresh+1)
            end
        end
    end
end

function context:grid_key(x,y,on)
    for i=1,2 do
        for j=1,8 do
            local selected = (j + (8 * (i - 1)))
            local sel = self.input[self.selected_input].sel_trig_layer -- get previous selected layer
            self.input[selected].momentary = self.momentary[j][i+6] == 1 and true or false
            --self.selected_input = self.input[selected].momentary and selected or self.selected_input
            if self.input[selected].momentary then
                self.selected_input = selected
                self:set_layer_visual(self.selected_input)
            end
            self.input[self.selected_input].sel_trig_layer = sel -- set selected layer same as previous
        end
    end

    local input = self.selected_input
    local input_trig = self.input[input]
    local layer = input_trig.sel_trig_layer
    local trig_type = input_trig.trig[layer].type

    input_trig.trig[1].momentary = self.momentary[4][6] == 1 and true or false
    input_trig.trig[2].momentary = self.momentary[5][6] == 1 and true or false
    input_trig.trig[3].momentary = self.momentary[6][6] == 1 and true or false
    input_trig.trig[4].momentary = self.momentary[7][6] == 1 and true or false
    input_trig.trig[5].momentary = self.momentary[8][6] == 1 and true or false

    self.midi_learn =  input_trig.momentary and true or false
    self.midi_learn_vel_high = self.momentary[3][6] == 1 and true or false
    self.midi_learn_vel_low = (input_trig.trig[1].momentary or
                               input_trig.trig[2].momentary or
                               input_trig.trig[3].momentary or
                               input_trig.trig[4].momentary or
                               input_trig.trig[5].momentary) and true or false

    if self.midi_learn_vel_low then
        local sel = input_trig.sel_trig_layer
        if input_trig.trig[5].momentary then sel = 5
            self:copy_velocity(sel, input_trig)
        elseif input_trig.trig[4].momentary then sel = 4
            self:copy_velocity(sel, input_trig)
        elseif input_trig.trig[3].momentary then sel = 3
            self:copy_velocity(sel, input_trig)
        elseif input_trig.trig[2].momentary then sel = 2
            self:copy_velocity(sel, input_trig)
        elseif input_trig.trig[1].momentary then sel = 1
            self:copy_velocity(sel, input_trig)
        end
        input_trig.sel_trig_layer = sel
    end

    if self.midi_learn and input_trig.trig[1].momentary then
        input_trig.trig[1]:invert_probability(self.scene_lane.position)
    elseif self.midi_learn and input_trig.trig[2].momentary then
        input_trig.trig[2]:invert_probability(self.scene_lane.position)
    elseif self.midi_learn and input_trig.trig[3].momentary then
        input_trig.trig[3]:invert_probability(self.scene_lane.position)
    elseif self.midi_learn and input_trig.trig[4].momentary then
        input_trig.trig[4]:invert_probability(self.scene_lane.position)
    elseif self.midi_learn and input_trig.trig[5].momentary then
        input_trig.trig[5]:invert_probability(self.scene_lane.position)
    end

    self.trig_type_next = self.momentary[2][6] == 1 and true or false
    self.trig_type_previous = self.momentary[1][6] == 1 and true or false
    self.meta_shift_pressed = self.momentary[13][8] == 1 and true or false

    if self.trig_type_next then
        input_trig.trig[layer]:set_trig_type(1)
    end

    if self.trig_type_previous then
        input_trig.trig[layer]:set_trig_type(-1)
    end

    TRIGS[trig_type]:grid_key(input_trig.trig[layer], self.momentary, x, y, on)

    if trig_type=="gears" then
        self.gear_step_toggle_pressed = self.momentary[10][8] == 1 and true or false
    end

    self.tap_tempo_pressed = self.momentary[16][8] == 1 and true or false

    self:grid_key_base(layer)

    if TRIGS[trig_type].draw_machine_grid or
       input_trig.trig[layer]:check_reset_meta() then
        self:grid_key_machine(input, layer)
    end
end

function context:get_current_gesture()
    local input = self.selected_input
    local input_trig = self.input[input]
    local layer = input_trig.sel_trig_layer
    local trig_type = self.input[input].trig[layer].type
    local gesture = TRIGS[trig_type]:get_current_gesture()
    if gesture then self.gesture = gesture return end

    if self.trig_type_next then gesture = "next trig"
    elseif self.trig_type_previous then gesture = "previous trig"
    elseif self.gears_retrig_pressed then gesture = "gears retrig"
    elseif self.trig_pointer_pressed then gesture = "trig pointer"
    elseif self.gear_step_toggle_pressed then gesture = "gear step"
    elseif self.meta_shift_pressed then gesture = "shift"
    else gesture = self:get_current_gesture_routing_base()
    end
    self.gesture = gesture
end

function context:set_layer_visual(input)
    self.layer_visual = self:init_visual(5)
    self.page_visual = self:init_visual(4)
    self.lane_visual = self:init_visual(4)

    local input_trig = self.input[input]
    local default = 8
    local mod = 1

    for k=1,5 do
        for i=1,16 do
            if input_trig.trig[k].lane_send[i] == 1 then
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
                mod = i%4 ~= 0 and i%4 or 4
                self.lane_visual[mod] = default
            end
        end
    end
end

function context:set_machine_routing_layer_visual(events)
    self.machine_layer_visual = self:init_visual(5)

    local default = 8
    for i=1,#events do
        self.machine_layer_visual[events[i].layer_num] = default
    end
end

function context:range_update(x,y,z,mod)
    local input = self.selected_input
    local layer = self.input[input].sel_trig_layer
    local input_trig = self.input[input].trig[layer]
    if z==1 and self.held then self.heldmax = 0 end
    self.held = self.held + (z*2-1)
    if self.held > self.heldmax then self.heldmax = self.held end

    if not self:range_update_ok(x,y) then return
    elseif z == 1 then
        if self.held==1 then
            if y == 6 then self.first = x-8
            elseif y == 7 then self.first = x-4
            end
            min = self.first
            max = self.first
            input_trig:set_range_data(min, max)
            input_trig.position = min
        elseif self.held==2 then
            if y == 6 then self.second = x-8
            elseif y == 7 then self.second = x-4
            end
            local min
            local max
            if self.first > 0 and self.second < self.first then
                min = self.second
                max = self.second
                input_trig:set_range_data(min, max)
            else
                min = math.min(self.first,self.second)
                max = math.max(self.first,self.second)
                input_trig:set_range_data(min, max)
            end

            input_trig:clamp_position()

            grid_dirty = true
            screen_dirty = true
        end
    end
end

function context:range_update_ok(x,y)
    local input = self.selected_input
    local input_trig = self.input[input]
    local layer = input_trig.sel_trig_layer
    if self.gear_step_toggle_pressed then return false end
    if input_trig.trig[layer].type == "gears" or
       input_trig.trig[layer].type == "root" or
       input_trig.trig[layer].type == "scale" or
       input_trig.trig[layer].type == "auto" then
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
        local layer = io[input].sel_trig_layer
        io[input]:set_high_thresh("trig", layer, util.clamp(event.vel, 1, 127))
        screen_dirty = true
    elseif self.midi_learn_vel_low then
        local layer = io[input].sel_trig_layer
        io[input]:set_low_thresh("trig", layer, util.clamp(event.vel, 1, 127))
        screen_dirty = true
    else
        return false
    end
    return true
end

return context