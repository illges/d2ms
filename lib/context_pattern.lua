---@diagnostic disable: undefined-global, lowercase-global

local automation = include 'lib/context_automation'
local automation_lane = include 'lib/automation_lane_pattern'

local context_pattern = setmetatable({}, {__index = automation})
context_pattern.__index = context_pattern

function context_pattern.new(piano, note_lane)
    local self = setmetatable(automation.new(), context_pattern)
    self.name = "pattern"
    self.type = "notes"
    self.piano = piano
    self.piano_mute = false
    self.note_lane = note_lane
    self.fill_narrow = false
    self.fill_spiral = false
    self.pattern_chaining_ind = false
    self.live_record_mode_pressed = false
    self.link_machine_int_pressed = false

    for i=1,16 do
        table.insert(self.lane, self.note_lane[i].pattern_lane)
        self.lane[i]:add_params()
        self.lane[i]:set_range_data(1, 1)
        self.position = self.note_lane[i].active_pattern
    end
    return self
end

function context_pattern:all_ascending()
    for i=1,16 do
        self.note_lane[self.focus].pattern[i]:ascending(table.move(self.piano.keyboard, 1, 16, 1, {}))
    end
end

function context_pattern:all_descending()
    for i=1,16 do
        self.note_lane[self.focus].pattern[i]:descending(table.move(self.piano.keyboard, 1, 16, 1, {}))
    end
end

function context_pattern:all_scatter_asc()
    for i=1,16 do
        self.note_lane[self.focus].pattern[i]:scatter_asc(table.move(self.piano.keyboard, 1, 15, 1, {}))
    end
end

function context_pattern:all_scatter_desc()
    for i=1,16 do
        self.note_lane[self.focus].pattern[i]:scatter_desc(table.move(self.piano.keyboard, 1, 15, 1, {}))
    end
end

function context_pattern:all_triangle_asc()
    for i=1,16 do
        self.note_lane[self.focus].pattern[i]:triangle_asc(table.move(self.piano.keyboard, 1, 15, 1, {}))
    end
end

function context_pattern:all_triangle_desc()
    for i=1,16 do
        self.note_lane[self.focus].pattern[i]:triangle_desc(table.move(self.piano.keyboard, 1, 15, 1, {}))
    end
end

function context_pattern:all_random()
    for i=1,16 do
        self.note_lane[self.focus].pattern[i]:random(table.move(self.piano.keyboard, 1, 15, 1, {}))
    end
end

function context_pattern:enc_one(d)

end

function context_pattern:enc_two(d)
    local step = self:upper_grid_pressed()
    if step == 0 then
        self.piano:enc_two(d)
    elseif step > 0 then
        for i=1,16 do
            self.note_lane[self.focus]:set_step_data(i, self.note_lane[self.focus]:data(i) + d)
        end
    end
end

function context_pattern:enc_three(d)
    local step = self:upper_grid_pressed()
    if step == 0 then
        self.piano:enc_three(d)
    elseif step > 0 then
        if d > 0 then
            for i=1,16 do
                self.note_lane[self.focus]:octave_up(i)
            end
        else
            for i=1,16 do
                self.note_lane[self.focus]:octave_down(i)
            end
        end
    end
end

function context_pattern:draw_screen()
    --context banner
    screen.level(0)
    screen.move(15, 7)
    screen.text(string.upper(current_context.name))

    --lane.step.pattern
    local strum = notes_context.lane[notes_context.focus].active_pattern==notes_context.lane[notes_context.focus].strum_pattern and "" or "*"
    self:draw_header_top_right(notes_context.focus.."."..notes_context.focus_x.."."..notes_context.lane[notes_context.focus].strum_pattern..strum)

    screen.level(15)
    screen.move(0, 18)
    screen.text(self.piano:current_scale())

    notes_context:draw_screen_seq(notes_context.lane[notes_context.focus], notes_context.display)

    self.piano:draw_screen()
end

function context_pattern:draw_grid()
    if self.piano.live_record_mode and use_med_piano==1 then
        self:draw_grid_main()
        g:led(10, 5, basic_lighting(self.piano.live_record_mode))
        self.piano:draw_med_keyboard()
    else
        self:draw_grid_automation()
        self:override_lane_actions_layout()
        self:draw_grid_main()
        g:led(10, 5, basic_lighting(self.piano.live_record_mode))
        g:led(3, 6, negative_lighting(self.piano.link_machine_interval==1))
        g:led(16, 8, negative_lighting(self.tap_tempo_pressed or tap_tempo_light==1))
        self.piano:draw_grid(false,0)
    end
end

function context_pattern:override_lane_actions_layout()
    g:led(8, 5, active_indicator(
        self.pattern_chaining_ind,
        self.note_lane[self.focus].pattern_chaining == 1
    ))
    g:led(6, 6, basic_lighting(self.fill_narrow))
    g:led(6, 7, basic_lighting(self.fill_spiral))

    g:led(7, 6, basic_lighting(self.fill_scatter_asc))
    g:led(7, 7, basic_lighting(self.fill_scatter_desc))

    g:led(8, 6, basic_lighting(self.fill_random))
    g:led(8, 7, basic_lighting(self.fill_clear))

    g:led(9, 6, negative_lighting(self.clear_step))
    g:led(9, 7, negative_lighting(self.shift))
end

function context_pattern:override_gesture_indicators()
    self.pattern_chaining_ind = self.momentary[8][5] == 1 and true or false
    self.fill_narrow = self.momentary[6][6] == 1 and true or false
    self.fill_spiral = self.momentary[6][7] == 1 and true or false
    self.fill_scatter_asc = self.momentary[7][6] == 1 and true or false
    self.fill_scatter_desc = self.momentary[7][7] == 1 and true or false
    self.fill_random = self.momentary[8][6] == 1 and true or false
    self.fill_clear = self.momentary[8][7] == 1 and true or false
    self.clear_step = self.momentary[9][6] == 1 and true or false
    self.shift = self.momentary[9][7] == 1 and true or false
end

function context_pattern:draw_grid_main()
    local light
    for i=1,self.area do
        local mod_val = self:get_mod_val(i)
        local min = self.lane[mod_val]:range_min()
        local max = self.lane[mod_val]:range_max()
        local current = self.lane[mod_val].position
        local strum = self.note_lane[mod_val].strum_pattern
        for j=1, 16 do
            light = 8
            light = (j >= min and j <= max) and light or 3
            light = self.lane[mod_val]:check_play_step(j) and light or (j >= min and j <= max) and 1 or 0
            light = j == current and 15 or light
            light = j == strum and 12 or light
            g:led(j, i, light)
        end
    end
end

function context_pattern:grid_patching(x,y,z)
    self.focus = y
    notes_context.focus = y
    self.focus_x = x
    local pattern = self.note_lane[y].pattern[x]
    if self.audition then self.note_lane[y]:update_active_pattern(x)
    elseif self.advance_sequence then self.note_lane[y]:advance_pattern_seq()
    elseif self.piano:key_pressed() > 0 then
        local chord_buffer = self.piano.chord_buffer
        if self.fill_ascending then pattern:ascending(chord_buffer)
        elseif self.fill_descending then pattern:descending(chord_buffer)
        elseif self.fill_scatter_asc then pattern:piano_scatter_asc(chord_buffer)
        elseif self.fill_scatter_desc then pattern:piano_scatter_desc(chord_buffer)
        elseif self.fill_triangle_asc then pattern:piano_triangle(chord_buffer, "up")
        elseif self.fill_triangle_desc then pattern:piano_triangle(chord_buffer, "down")
        elseif self.fill_random then pattern:random(chord_buffer)
        end
    elseif self.fill_triangle_asc then pattern:triangle_asc(table.move(self.piano.keyboard, 1, 15, 1, {}))
    elseif self.fill_triangle_desc then pattern:triangle_desc(table.move(self.piano.keyboard, 1, 15, 1, {}))
    elseif self.fill_ascending then pattern:ascending(table.move(self.piano.keyboard, 1, 16, 1, {}))
    elseif self.fill_descending then pattern:descending(table.move(self.piano.keyboard, 1, 16, 1, {}))
    elseif self.fill_scatter_asc then pattern:scatter_asc(table.move(self.piano.keyboard, 1, 15, 1, {}))
    elseif self.fill_scatter_desc then pattern:scatter_desc(table.move(self.piano.keyboard, 1, 15, 1, {}))
    elseif self.fill_narrow then pattern:random(table.move(self.piano.keyboard, 5, 11, 1, {}))
    elseif self.fill_spiral then pattern:spiral(table.move(self.piano.keyboard, 1, 15, 1, {}))
    elseif self.fill_random then pattern:random(self.piano.keyboard)
    --elseif self.fill_clear then pattern:static()
    elseif self.copy then self:copy_lane(x,y)
    elseif self.paste then self:paste_lane(x,y)
    else
        self:grid_patching_automation(x,y)
    end
end

function context_pattern:copy_lane(x,y)
    for key,value in pairs(self.note_lane[y].pattern[x].data) do
        self.copy_buffer[key] = value
    end
end

function context_pattern:paste_lane(x,y)
    for i=1,16 do
        notes_context.lane[y].pattern[x]:set_step_data(i, self.copy_buffer[i])
    end
end

function context_pattern:grid_key()
    self:gesture_indicators_automation()
    self:override_gesture_indicators()
    self:all_lane_gestures_automation()
    self:piano_gestures()
    self.piano:check_chord_buffer()
    self.tap_tempo_pressed = self.momentary[16][8] == 1 and true or false
end

function context_pattern:piano_gestures()
    self.piano_mute = self.momentary[3][7] == 1 and true or false
    self.piano:gestures(self.octave_down, self.octave_up, self.piano_mute)

    self.live_record_mode_pressed = self.momentary[10][5] == 1 and true or false
    if self.live_record_mode_pressed then
        self.piano:invert_live_record_mode()
    end

    if self.piano.live_record_mode then
        if self.clear_step then
            local track = self.note_lane[self.focus]
            track:set_step_mute(track.position, 1)
            track.position = track.position + track:direction()
            track:clamp_position_chaining()
        end
    end

    self.link_machine_int_pressed = self.momentary[3][6] == 1 and true or false
    if self.link_machine_int_pressed then self.piano:invert_link_machine_int() end
end

function context_pattern:get_current_gesture()
    local gesture
    if self.audition then gesture = "select pattern"
    elseif self.advance_sequence then gesture = "adv pattern"
    elseif self.octave_up then gesture = "ocatve up"
    elseif self.octave_down then gesture = "octave down"
    elseif self.piano_mute then gesture = "piano mute"
    elseif self.fill_narrow then gesture = "fill narrow"
    elseif self.fill_spiral then gesture = "fill spiral"
    elseif self.fill_clear then gesture = "clear lane mutes"
    elseif self.clear_step then gesture = "mute pattern"
    elseif self.shift then gesture = "shift"
    elseif self.pattern_chaining_ind then gesture = "pattern chaining ind"
    elseif self.live_record_mode_pressed then gesture = "piano live record mode"
    elseif self.link_machine_int_pressed then gesture = "link machine int"
    else gesture = self:get_current_gesture_automation()
    end
    self.gesture = gesture
end

function context_pattern:range_update_ok(y)
    local safe = true
    for i=1,#self.momentary do
        for j=5,#self.momentary[i] do
            if self.momentary[i][j] == 1 then
                safe = false
                break
            end
        end
    end
    return y <= self.area and safe
end

function context_pattern:range_update(x,y,z,lane)
    local track = self.lane[lane]
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

            if y<=self.area and self.held[y]==1 then
                self.first[y] = x
                -- allow single press to reset active pattern
                track:set_range_data(x, x)
                self.note_lane[self.focus]:set_pattern_chaining(0)
                self.note_lane[self.focus]:update_active_pattern(x)
                -- allow single press to unmute pattern
                track:unmute_step(x)
            elseif y<=self.area and self.held[y]==2 then
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
                    self.note_lane[self.focus]:set_pattern_chaining(0)
                    self.note_lane[self.focus]:update_active_pattern(min)
                else
                    min = math.min(self.first[y],self.second[y])
                    max = math.max(self.first[y],self.second[y])
                    self.note_lane[self.focus]:set_pattern_chaining(1)
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

return context_pattern