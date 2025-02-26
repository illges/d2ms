---@diagnostic disable: undefined-global, lowercase-global

local automation = include 'lib/context_automation'

local context = setmetatable({}, {__index = automation})
context.__index = context

function context.new(name, machine_context)
    local self = setmetatable(automation.new(), context)
    self.name = name
    self.machine_context = machine_context
    self.input = machine_context.input
    self.area = 2
    self.selected_input = 1
    self.copy_buffer_scene_number = nil
    return self
end

function context:enc_one(d)
    self:enc(d)
end

function context:enc_two(d)
    self:enc(d)
end

function context:enc_three(d)
    self:enc(d)
end

function context:enc(d)
    local prob = self.input[self.selected_input].machine[self.input[self.selected_input].sel_machine_layer]:get_probability(self.machine_context.scene_lane.position)
    self.input[self.selected_input].machine[self.input[self.selected_input].sel_machine_layer]:set_probability(prob + d, self.machine_context.scene_lane.position)
end

function context:draw_screen()
    screen.level(4)
    screen.move(5, 20)
    screen.text("input: "..self.selected_input)

    screen.level(4)
    screen.move(5, 30)
    screen.text("layer: "..self.input[self.selected_input].sel_machine_layer)

    screen.level(15)
    screen.move(5, 40)
    screen.text("prob: "..self.input[self.selected_input].machine[self.input[self.selected_input].sel_machine_layer]:get_probability(self.machine_context.scene_lane.position).."%")

    screen.level(4)
    screen.move(5, 50)
    screen.text("scene: "..self.machine_context.scene_lane.position)
end

function context:draw_grid()
    self:draw_grid_automation_override()
    self:draw_grid_base()
    self:draw_grid_main()
end

function context:draw_grid_automation_override()
    g:led(4, 5, active_indicator(
        self.invert_direction,
        self.machine_context.scene_lane:direction() == -1
    ))
    g:led(5, 5, active_indicator(
        self.invert_ping_pong,
        self.machine_context.scene_lane:ping_pong() == 1
    ))
    g:led(6, 5, active_indicator(
        self.invert_ping_pong_2,
        self.machine_context.scene_lane:ping_pong_2() == 1
    ))
    g:led(7, 5, active_indicator(
        self.invert_random_step,
        self.machine_context.scene_lane:random_step() == 1
    ))
    g:led(3, 5, active_indicator(
        self.invert_b_section,
        self.machine_context.scene_lane.b_section == 1
    ))

    --g:led(7, 7, basic_lighting(self.fill_clear))

    g:led(9, 6, basic_lighting(self.clear_step))

    g:led(1, 6, negative_lighting(self.copy))
    g:led(2, 6, negative_lighting(self.paste))
end

function context:draw_grid_main()
    local light
    local layer_light
    for i=2,self.area do
        local min = self.machine_context.scene_lane:range_min()
        local max = self.machine_context.scene_lane:range_max()
        local current = self.machine_context.scene_lane.position
        for j=1, 16 do
            light = 8
            light = (j >= min and j <= max) and light or 3
            light = self.machine_context.scene_lane:check_play_step(j) and light or (j >= min and j <= max) and 1 or 0
            light = j == current and 15 or light
            g:led(j, 2, light)
        end
    end
    for i=1,2 do
        for j=1,8 do
            local current = (j + (8 * (i - 1)))
            local light = 3
            g:led(j, i+6, self.selected_input == (j + (8 * (i - 1))) and 15 or light)
            if j == 1 or j == 5 then light = 8 end
            if self.selected_input == (j + (8 * (i - 1))) then light = 15 end
            light = self.machine_context.input_visual[current] > 0 and self.machine_context.input_visual[current] or light
            g:led(j, i+6, light)
        end
    end
    for layer=1,5 do
        layer_light = self:get_layer_lighting(layer)
        g:led(layer+3, 6, layer_light)
    end
end

function context:get_layer_lighting(layer_num)
    local input = self.selected_input
    local layer = self.input[input].sel_machine_layer

    local light = (self.input[input].machine[layer_num]:get_probability(self.machine_context.scene_lane.position) > 0 and self.input[input].machine[layer_num].type ~= "EMPTY") and 9 or 5
    light = layer == layer_num and 15 or light
    light = self.machine_context.layer_visual[layer_num] > 0 and self.machine_context.layer_visual[layer_num] or light
    return light
end

function context:set_scene_num(x)
    self.machine_context.scene_lane.position = x
    if x < self.machine_context.scene_lane:range_min() or
        x > self.machine_context.scene_lane:range_max() then
            self.machine_context.scene_lane:set_range_data(x, x)
    end
end

function context:grid_patching(x,y,z)
    self.focus = 1
    if self.audition then
        self:set_scene_num(x)
    elseif self.advance_sequence then
        self.machine_context.scene_lane:adv_lane_position()
    elseif self.copy then self:copy_lane(x)
    elseif self.paste then self:paste_lane(x)
    else
        self:grid_patching_automation_override(x,y)
    end
end

function context:grid_patching_automation_override(x,y)
    local track = machine_context.scene_lane

    if self.invert_direction then track:invert_direction()
    elseif self.invert_ping_pong then track:invert_ping_pong()
    elseif self.invert_ping_pong_2 then track:invert_ping_pong_2()
    elseif self.invert_random_step then track:invert_random_step()
    elseif self.invert_b_section then track:invert_b_section()
    elseif self.clear_step then track:clear_step(x)
    end
end

function context:copy_lane(patch)
    self.copy_buffer_scene_number = patch
end

function context:paste_lane(patch)
    if self.copy_buffer_scene_number ~= nil then
        for i=1,16 do
            for j=1,5 do
                local prob = self.input[i].machine[j]:get_probability(self.copy_buffer_scene_number)
                self.input[i].machine[j]:set_probability(prob, patch)
            end
        end
    end
end

function context:grid_key()
    for i=1,2 do
        for j=1,8 do
            local selected = (j + (8 * (i - 1)))
            local sel = self.input[self.selected_input].sel_machine_layer -- get previous selected layer
            self.input[selected].momentary = self.momentary[j][i+6] == 1 and true or false
            if self.input[selected].momentary then
                self.selected_input = selected
            end
            self.input[self.selected_input].sel_machine_layer = sel -- set selected layer same as previous
        end
    end
    for i=1,5 do
        if self.momentary[i+3][6] == 1 then
            self.input[self.selected_input].sel_machine_layer = i
            if self.input[self.selected_input].momentary then
                self.input[self.selected_input].machine[i]:invert_probability(self.machine_context.scene_lane.position)
            end
        end
    end

    self:gesture_indicators_automation_override()
    self:all_lane_gestures_automation()
end

function context:gesture_indicators_automation_override()
    self:gesture_indicators_base()

    self.copy = self.momentary[1][6] == 1 and true or false
    self.paste = self.momentary[2][6] == 1 and true or false

    self.invert_direction = self.momentary[4][5] == 1 and true or false
    self.invert_ping_pong = self.momentary[5][5] == 1 and true or false
    self.invert_ping_pong_2 = self.momentary[6][5] == 1 and true or false
    self.invert_random_step = self.momentary[7][5] == 1 and true or false
    self.invert_b_section = self.momentary[3][5] == 1 and true or false

    --self.fill_clear = self.momentary[7][7] == 1 and true or false
    self.clear_step = self.momentary[9][6] == 1 and true or false
end

function context:get_current_gesture()
    local gesture
    if self.audition then gesture = "select scene"
    elseif self.advance_sequence then gesture = "adv scene"
    --elseif self.fill_clear then gesture = "clear patch mutes"
    elseif self.clear_step then gesture = "mute scene/shift"
    elseif self.copy then gesture = "COPY scene data"
    elseif self.paste then gesture = "PASTE scene data"
    else gesture = self:get_current_gesture_automation()
    end
    self.gesture = gesture
end

function context:range_update_ok(y)
    local safe = true
    for i=1,#current_context.momentary do
        for j=5,#current_context.momentary[i] do
            if current_context.momentary[i][j] == 1 then
                safe = false
                break
            end
        end
    end
    return y == self.area and safe
end

function context:range_update(x,y,z,lane)
    local track = self.machine_context.scene_lane
    if z==1 and self.held[y] then self.heldmax[y] = 0 end
    self.held[y] = self.held[y] + (z*2-1)
    if self.held[y] > self.heldmax[y] then self.heldmax[y] = self.held[y] end
    --print(self.held[y]) tab.print(self.held)

    if not self:range_update_ok(y) then return
    else
        if z == 1 then
            if self.focus ~= lane then
                self.focus = lane
                screen_dirty = true
            end

            if y==self.area and self.held[y]==1 then
                self.first[y] = x
                -- allow single press to reset active patch
                track:set_range_data(x, x)
                track.position = x
                -- allow single press to unmute patch
                track:unmute_step(x)
            elseif y==self.area and self.held[y]==2 then
                self.second[y] = x
                local direction
                if self.second[y] < self.first[y] then
                    direction = -1
                    track:set_direction(direction)
                else
                    direction = 1
                    track:set_direction(direction)
                end

                local min
                local max
                if self.first[y] > 0 and self.second[y] == self.first[y] - 1 then
                    min = self.second[y]
                    max = self.second[y]
                    track.position = min
                else
                    min = math.min(self.first[y],self.second[y])
                    max = math.max(self.first[y],self.second[y])
                end
                track:set_range_data(min, max)
                for step=min,max do
                    track:unmute_step(step)
                end

                track:clamp_position()

                grid_dirty = true
                screen_dirty = true
            end
        end
    end
end

return context