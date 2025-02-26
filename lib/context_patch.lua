---@diagnostic disable: undefined-global, lowercase-global

local automation = include 'lib/context_automation'

local context_patch = setmetatable({}, {__index = automation})
context_patch.__index = context_patch

function context_patch.new(name, context)
    local self = setmetatable(automation.new(), context_patch)
    self.name = name
    self.machine_context = context
    self.area = 8
    self.selected_layer = 1
    return self
end

function context_patch:enc_one(d)

end

function context_patch:enc_two(d)

end

function context_patch:enc_three(d)

end

function context_patch:draw_screen()
    screen.level(4)
    screen.move(5, 30)
    screen.text("layer: "..self.selected_layer)

    screen.level(4)
    screen.move(5, 40)
    screen.text("patch: "..self.machine_context.pattern_lane.position)
end

function context_patch:draw_grid()
    self:draw_grid_automation_override()
    self:draw_grid_base()
    self:draw_grid_main()
end

function context_patch:draw_grid_automation_override()
    self:draw_grid_base()

    g:led(4, 5, active_indicator(
        self.invert_direction,
        self.machine_context.pattern_lane:direction() == -1
    ))
    g:led(5, 5, active_indicator(
        self.invert_ping_pong,
        self.machine_context.pattern_lane:ping_pong() == 1
    ))
    g:led(6, 5, active_indicator(
        self.invert_ping_pong_2,
        self.machine_context.pattern_lane:ping_pong_2() == 1
    ))
    g:led(7, 5, active_indicator(
        self.invert_random_step,
        self.machine_context.pattern_lane:random_step() == 1
    ))
    g:led(3, 5, active_indicator(
        self.invert_b_section,
        self.machine_context.pattern_lane.b_section == 1
    ))

    --g:led(7, 7, basic_lighting(self.fill_clear))

    g:led(9, 6, basic_lighting(self.clear_step))

    g:led(1, 6, negative_lighting(self.copy))
    g:led(2, 6, negative_lighting(self.paste))
end

function context_patch:draw_grid_main()
    local light
    local layer_light
    local channel_light
    for i=8,self.area do
        local min = self.machine_context.pattern_lane:range_min()
        local max = self.machine_context.pattern_lane:range_max()
        local current = self.machine_context.pattern_lane.position
        --local strum = self.machine_context.note_lane.strum_pattern
        for j=1, 16 do
            light = 8
            light = (j >= min and j <= max) and light or 3
            light = self.machine_context.pattern_lane:check_play_step(j) and light or (j >= min and j <= max) and 1 or 0
            light = j == current and 15 or light
            --light = j == strum and 12 or light
            g:led(j, i, light)
        end
    end
    for layer=1,5 do
        layer_light = 3
        if self.selected_layer == layer then layer_light = 8 end
        g:led(layer, 7, layer_light)
    end
    for i=1,4 do
        local mod_val = i + (4 * (self.active_page - 1))
        for j=1,16 do
            channel_light = 2
            for k=1,#self.machine_context.layer_routing[self.selected_layer].output_list[mod_val] do
                if self.machine_context.layer_routing[self.selected_layer].output_list[mod_val][k] == j then
                    channel_light = 8
                    break
                end
            end
            channel_light = self.machine_context.lane_visual[i] > 0 and self.machine_context.lane_visual[i] or channel_light
            g:led(j, i, channel_light)
        end
    end
end

function context_patch:set_patch_num(x)
    self.machine_context.pattern_lane.position = x
    if x < self.machine_context.pattern_lane:range_min() or
        x > self.machine_context.pattern_lane:range_max() then
            self.machine_context.pattern_lane:set_range_data(x, x)
    end
end

function context_patch:grid_patching_override(x,y,z)
    self.focus = 1
    if self.audition then
        self:set_patch_num(x)
        self.machine_context:update_output_channel_data()
    elseif self.advance_sequence then
        self.machine_context.pattern_lane:adv_lane_position()
        self.machine_context:update_output_channel_data()
    elseif self.copy then self:copy_lane(x)
    elseif self.paste then self:paste_lane(x)
    else
        self:grid_patching_automation_override(x,y)
    end
end

function context_patch:grid_patching(x,y,z)
    self.machine_context:set_output_data(self.selected_layer, y, x)
end

function context_patch:grid_patching_automation_override(x,y)
    local track = machine_context.pattern_lane

    if self.invert_direction then track:invert_direction()
    elseif self.invert_ping_pong then track:invert_ping_pong()
    elseif self.invert_ping_pong_2 then track:invert_ping_pong_2()
    elseif self.invert_random_step then track:invert_random_step()
    elseif self.invert_b_section then track:invert_b_section()
    --elseif self.fill_clear then track:static()
    elseif self.clear_step then track:clear_step(x)
    end
end

function context_patch:copy_lane(patch)
    self.copy_buffer = {}
    for layer=1,5 do
        table.insert(self.copy_buffer, {})
        for lane=1,16 do
            table.insert(self.copy_buffer[layer], {})
            for channel=1,16 do
                table.insert(self.copy_buffer[layer][lane], self.machine_context.layer_routing[layer].patch[patch].routing[lane][channel])
            end
        end
    end
end

function context_patch:paste_lane(patch)
    for layer=1,5 do
        for lane=1,16 do
            for channel=1,16 do
                self.machine_context:set_output_data_val(layer, patch, lane, channel, self.copy_buffer[layer][lane][channel])
            end
        end
    end
end

function context_patch:grid_key()
    for i=1,5 do
        if self.momentary[i][7] == 1 then
            self.selected_layer = i
        end
    end

    self:gesture_indicators_automation_override()
    self:all_lane_gestures_automation()
end

function context_patch:gesture_indicators_automation_override()
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

function context_patch:get_current_gesture()
    local gesture
    if self.audition then gesture = "select patch"
    elseif self.advance_sequence then gesture = "adv patch"
    --elseif self.fill_clear then gesture = "clear patch mutes"
    elseif self.clear_step then gesture = "mute patch/shift"
    elseif self.copy then gesture = "COPY patch data"
    elseif self.paste then gesture = "PASTE patch data"
    else gesture = self:get_current_gesture_automation()
    end
    self.gesture = gesture
end

function context_patch:range_update_ok(y)
    local safe = true
    for i=1,#self.momentary do
        for j=1,7 do
            if self.momentary[i][j] == 1 then
                safe = false
                break
            end
        end
    end
    return y == self.area and safe
end

function context_patch:range_update(x,y,z,lane)
    local track = self.machine_context.pattern_lane
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
                self.machine_context:update_output_channel_data()
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

return context_patch