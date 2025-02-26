---@diagnostic disable: undefined-global, lowercase-global

local automation = include 'lib/context_automation'
local automation_lane_note = include 'lib/automation_lane_note'

local context = setmetatable({}, {__index = automation})
context.__index = context

function context.new(piano)
    local self = setmetatable(automation.new(), context)
    self.name = "notes"
    self.type = "notes"
    self.held_chord_name = ""
    self.held_chord = 0
    self.focus_x_held = 0

    self.piano = piano
    self.note_lighting = false
    self.note_lighting_pressed = false
    self.live_record_mode_pressed = false
    self.preserve_density_pressed = false
    self.lock_step_pressed = false
    self.piano_mute = false
    self.fill_narrow = false
    self.fill_spiral = false
    self.link_machine_int_pressed = false
    self.pattern_chaining_ind = false
    self.change_seq_type_pressed = false
    self.pattern_inc = false
    self.pattern_dec = false
    self.interval_inc = false
    self.interval_dec = false
    self.interval_inc_7 = false
    self.interval_dec_7 = false

    self.step_octave_down = false
    self.step_octave_up = false

    params:add_separator("note lane params")
    for i=1,16 do
        local page = math.ceil(i/4)
        table.insert(self.lane, automation_lane_note.new(i, page, self.piano.keyboard))
    end

    self.note_visual = self:init_note_visual()
    self.riff_visual = self:init_note_visual()
    self.grid_refresh=metro.init()
    self.grid_refresh.count=-1
    self.grid_refresh.time=0.1
    self.grid_refresh.event=function()
        self:get_visuals()
        if tap_tempo_set_counter>0 then
            tap_tempo_set_counter=tap_tempo_set_counter-1
        end
    end
    self.grid_refresh:start()
    return self
end

function context:init_note_visual()
    local visual = {}
    for i=1,16 do
        visual[i] = {}
        for j=1,16 do
            visual[i][j] = 0
        end
    end
    return visual
end

function context:get_note_visuals()
    for i=1,16 do
        for j =1,16 do
            if self.note_visual[i][j]>0 then
                self.note_visual[i][j]=self.note_visual[i][j]-1
                grid_redraw()
            end
        end
    end
end

function context:get_visuals()
    for lane=1,16 do
        for step=1,16 do
            local draw = false
            if self.step_visual[lane][step]>0 then
                self.step_visual[lane][step]=self.step_visual[lane][step]-1
                draw = true
            end
            if self.step_visual[lane][step]<0 then
                self.step_visual[lane][step]=0
                draw = true
            end
            if self.note_visual[lane][step]>0 then
                self.note_visual[lane][step]=self.note_visual[lane][step]-1
                draw = true
            end
            if self.riff_visual[lane][step]>0 then
                self.riff_visual[lane][step]=self.riff_visual[lane][step]-1
                draw = true
            end
            if draw then grid_redraw() end
        end
    end
end

function context:set_note_visual(row, n)
    --self.note_visual = self:init_visual()
    self.note_visual[row][n] = 8
end

function context:set_riff_visual(row, n)
    --self.note_visual = self:init_visual()
    self.riff_visual[row][n] = 8
end

function context:all_ascending()
    for i=1,16 do
        self.lane[i]:ascending(table.move(self.piano.keyboard, 1, 8, 1, {}))
    end
end

function context:all_descending()
    for i=1,16 do
        self.lane[i]:descending(table.move(self.piano.keyboard, 1, 8, 1, {}))
    end
end

function context:all_scatter_asc()
    for i=1,16 do
        self.lane[i]:scatter_asc(table.move(self.piano.keyboard, 1, 15, 1, {}))
    end
end

function context:all_scatter_desc()
    for i=1,16 do
        self.lane[i]:scatter_desc(table.move(self.piano.keyboard, 1, 15, 1, {}))
    end
end

function context:all_triangle_asc()
    for i=1,16 do
        self.lane[i]:triangle_asc(table.move(self.piano.keyboard, 1, 15, 1, {}))
    end
end

function context:all_triangle_desc()
    for i=1,16 do
        self.lane[i]:triangle_desc(table.move(self.piano.keyboard, 1, 15, 1, {}))
    end
end

function context:all_random()
    for i=1,16 do
        self.lane[i]:random(self.piano.keyboard)
    end
end

function context:all_static()
    for i=1,16 do
        self.lane[i]:static()
    end
end

function context:all_octave_down()
    for i=1,16 do
        self.lane[i]:octave_down()
    end
end

function context:all_octave_up()
    for i=1,16 do
        self.lane[i]:octave_up()
    end
end

function context:draw_screen()
    local lane = self.lane[self.focus]
    --context banner
    screen.level(0)
    screen.move(15, 7)
    local title = processing_v2==1 and ": "..lane.seq_type or ""
    screen.text(string.upper(current_context.name).." "..title)
    -- screen.text(string.upper(current_context.name)
    --             .." : "..music.note_num_to_name(self.piano.root)
    --             ..self.piano.octave.." "..music.SCALES[self.piano.scale_choice].name)

    --lane.step.pattern
    local strum = lane.active_pattern==lane.strum_pattern and "" or "*"
    self:draw_header_top_right(self.focus.."."..self.focus_x.."."..lane.strum_pattern..strum)

    screen.level(15)
    screen.move(0, 18)
    screen.text(self.piano:current_scale())

    -- local step_data = lane:data(self.focus_x)
    -- local midi_note = self.piano.scale[step_data]
    -- local muted = lane:step_mute(self.focus_x) == 1 and "*" or ""
    -- if lane:riff_lane() then
    --     screen.text("interval: "..step_data.."  "..muted)
    -- elseif midi_note == nil then
    --     screen.text("note:empty")
    -- else
    --     screen.text("note:"..midi_note.."-"..music.note_num_to_name(midi_note, true)..muted)
    -- end

    -- screen.move(65,18)
    -- screen.text("vel<="..self:calc_vel_step_thresh(self.focus_x - self.lane[self.focus]:range_min() + 1))

    self:draw_screen_seq(lane, self.display)

    self.piano:draw_screen()
end

function context:draw_screen_seq(lane, display)
    local ui_offset = 7
    for j=1,2 do
        screen.level(6)
        screen.rect(0, (15*j)+ui_offset, 128, 15)
        screen.fill()
        for i=1,8 do
            screen.level(0)
            screen.rect(((i-1)*15)+5, (15*j)+ui_offset+1, 14, 13)
            screen.fill()

            local step = i+((j-1)*8)
            local light = 6
            light = (step<lane:range_min() or step>lane:range_max() or lane:step_mute(step) == 1) and 2 or light
            light = self.focus_x == step and 15 or light
            screen.level(light)
            if j==1 then
                screen.move(((i-1)*15)+7, (20*j)+ui_offset+3)
            else
                screen.move(((i-1)*15)+7, (20*j)+ui_offset+1)
            end
            local note = self.piano.scale[lane:data(step)] and music.note_num_to_name(self.piano.scale[lane:data(step)], true) or "*"
            if lane:riff_lane() then
                note = lane:data(step)
            elseif lane:chord_lane() then
                local chord = lane:data(step)
                local inversion = 0--layer.inversion_seq[position]
                ----local name = music.CHORDS[chord].alt_names and music.CHORDS[chord].alt_names[1] or music.CHORDS[chord].name
                --note = music.CHORDS[chord].alt_names and music.CHORDS[chord].alt_names[1] or music.CHORDS[chord].name
                note = chord
            end
            local vel = self:calc_vel_step_thresh(step - lane:range_min() + 1)
            local text = display == self.STEP and note or vel
            screen.text(text)
        end
    end
end

function context:calc_vel_step_thresh(step)
    local step_thresh = self.lane[self.focus]:get_vel_step_threshold()
    local thresh = tostring(util.clamp((step * step_thresh) + self.lane[self.focus].vel_floor,1,127))
    if step == self.lane[self.focus]:range_max() then thresh = tostring(self.lane[self.focus].vel_ceiling) end
    if tonumber(thresh) < (step_thresh + self.lane[self.focus].vel_floor)  or tonumber(thresh) > 127 then thresh = 'xxx' end
    return thresh
end

function context:draw_grid()
    if self.piano.live_record_mode and use_med_piano==1 then
        self:draw_grid_main()
        g:led(10, 5, basic_lighting(self.piano.live_record_mode))
        self.piano:draw_med_keyboard()
    else
        self:draw_grid_main()
        self:draw_grid_base()

        g:led(4, 5, active_indicator(
            self.invert_direction,
            self.lane[self.focus]:direction() == -1
        ))
        g:led(5, 5, active_indicator(
            self.invert_ping_pong,
            self.lane[self.focus]:ping_pong() == 1
        ))
        g:led(6, 5, active_indicator(
            self.invert_ping_pong_2,
            self.lane[self.focus]:ping_pong_2() == 1
        ))
        g:led(7, 5, active_indicator(
            self.invert_random_step,
            self.lane[self.focus]:random_step() == 1
        ))
        g:led(3, 5, active_indicator(
            self.invert_b_section,
            self.lane[self.focus].b_section == 1
        ))
        g:led(8, 5, active_indicator(
            self.pattern_chaining_ind,
            self.lane[self.focus].pattern_chaining == 1
        ))

        g:led(1, 6, negative_lighting(self.copy))
        g:led(2, 6, negative_lighting(self.paste))

        g:led(16, 8, negative_lighting(self.tap_tempo_pressed or tap_tempo_light==1))
        g:led(9, 5, negative_lighting(self.change_seq_type_pressed))
        g:led(10, 5, basic_lighting(self.piano.live_record_mode))
        g:led(11, 5, basic_lighting(self.lock_step_pressed))
        if self.lane[self.focus]:riff_lane() then
            g:led(8, 8, basic_lighting(self.interval_dec))
            g:led(9, 8, basic_lighting(self.interval_int))
            g:led(7, 8, negative_lighting(self.interval_dec_7))
            g:led(10, 8, negative_lighting(self.interval_int_7))
        elseif self.lane[self.focus]:chord_lane() then
            self:draw_interval_player()
        else
            local note = self.focus_x_held>0 and self.lane[self.focus]:data(self.focus_x_held) or 0
            self.piano:draw_grid(self.note_lighting, note)
            g:led(3, 6, self.piano.link_machine_interval*7)
        end

        if self.lane[self.focus]:riff_lane() or self.lane[self.focus]:note_lane() then
            g:led(4, 6, basic_lighting(self.fill_ascending))
            g:led(4, 7, basic_lighting(self.fill_descending))
            g:led(5, 6, basic_lighting(self.fill_triangle_asc))
            g:led(5, 7, basic_lighting(self.fill_triangle_desc))
            g:led(6, 6, basic_lighting(self.fill_narrow))
            g:led(6, 7, basic_lighting(self.fill_spiral))
            g:led(7, 6, basic_lighting(self.fill_scatter_asc))
            g:led(7, 7, basic_lighting(self.fill_scatter_desc))
            g:led(8, 6, basic_lighting(self.fill_random))
            g:led(8, 7, basic_lighting(self.fill_clear))
            g:led(9, 6, negative_lighting(self.clear_step or not self.lane[self.focus]:check_play_step(self.focus_x)))
            g:led(9, 7, negative_lighting(self.shift))

            g:led(11, 6, basic_lighting(self.lane[self.focus].preserve_density == 1) or self.preserve_density_pressed)
            g:led(10, 6, basic_lighting(self.note_lighting))
            g:led(10, 7, negative_lighting(self.pattern_dec))
            g:led(11, 7, negative_lighting(self.pattern_inc))
        end
    end
end

function context:draw_interval_player()
    local light = 1
    for j=1,12 do
        light = 1
        if (j==1 or j==8) then light = 8 end -- major, dominant
        if self.momentary[j][7] == 1 then light = 15 end
        g:led(j, 7, light)
    end
    for j=1,14 do
        light = 1
        if j==5 then light = 8 end -- minor
        if self.momentary[j][8] == 1 then light = 15 end
        g:led(j, 8, light)
    end
end

function context:draw_grid_main()
    for i=1,self.area do
        local mod_val = i + (4 * (self.active_page - 1))
        local light = 6
        local min = self.lane[mod_val]:range_min(self.lane[mod_val].strum_pattern)
        local max = self.lane[mod_val]:range_max(self.lane[mod_val].strum_pattern)
        for j=min, max do
            if self.focus == mod_val then light = 6 else light = 3 end
            light = self.lane[mod_val]:check_play_step(j) and light or 0
            light = (j == self.lane[mod_val].position or j == self.lane[mod_val].strum_light) and 14 or light
            light = self.step_visual[mod_val][j] > 0 and self.step_visual[mod_val][j] or light
            if self.note_lighting then
                if self.lane[mod_val]:riff_lane() or self.lane[mod_val]:chord_lane() then
                    light = self.note_visual[mod_val][j] > 0 and self.note_visual[mod_val][j] or 3
                else
                    light = self.note_visual[mod_val][j] > 0 and self.note_visual[mod_val][j] or self:get_notes_lighting(self.lane[mod_val]:data(j))
                end
            else
                light = self.note_visual[mod_val][j] > 0 and self.note_visual[mod_val][j] or light
            end
            light = self.riff_visual[mod_val][j] > 0 and self.riff_visual[mod_val][j] or light
            if self.lock_step_pressed then
                light = self.lane[mod_val]:step_lock(j) == 1 and 15 or 0
            end
            g:led(j, i, light)
        end
    end
end

function context:get_notes_lighting(note)
    if  note == nil or note < self.piano.keyboard[1] then return 0
    elseif note >= self.piano.keyboard[#self.piano.keyboard] then return 15
    else
        for i = 1,#self.piano.keyboard-1 do
            if note == self.piano.keyboard[i] then return i end
        end
    end
end

function context:enc_one(d)
    local step = self:upper_grid_pressed()
    if step > 0 then
        if d > 0 then
            self.lane[self.focus]:octave_up(self.focus_x)
        else
            self.lane[self.focus]:octave_down(self.focus_x)
        end
    end
end

function context:enc_two(d)
    local step = self:upper_grid_pressed()
    if step == 0 then
        self.piano:enc_two(d)
    end
    if step > 0 then
        for i=1,16 do
            self.lane[self.focus]:set_step_data(i, self.lane[self.focus]:data(i) + d)
        end
    end
end

function context:enc_three(d)
    local step = self:upper_grid_pressed()
    if step == 0 then
        self.piano:enc_three(d)
    end
    if step > 0 then
        self.lane[self.focus]:set_step_data(step, self.lane[self.focus]:data(step) + d)
    end
end

function context:get_scale_index(note)
    for i=1,#self.piano.scale do
        if self.piano.scale[i] == note then return i end
    end
    return 1
end

function context:grid_patching(x,y,z)
    self.focus = y
    pattern_context.focus = y
    self.focus_x = x
    self.focus_x_held = x
    local track = self.lane[y]
    if self.piano.live_record_mode then track.position = x
    elseif self.audition and not self.shift then harvest_audition(y, x)
    elseif self.advance_sequence and not self.shift then grid_harvest(y)
    elseif self.piano:key_pressed() > 0 then
        local val = self.piano.keyboard[self.piano:key_pressed()]
        print(self.piano.keyboard[self.piano:key_pressed()])
        track:set_step_data(x, val)
    elseif self.lock_step_pressed then track:toggle_step_lock(x)
    elseif self.preserve_density_pressed then track:set_preserve_density()
    --elseif self.invert_pattern_chaining then track:set_pattern_chaining()
    elseif self.fill_triangle_asc then track:triangle_asc(table.move(self.piano.keyboard, 1, 15, 1, {}))
    elseif self.fill_triangle_desc then track:triangle_desc(table.move(self.piano.keyboard, 1, 15, 1, {}))
    elseif self.fill_ascending then track:ascending(table.move(self.piano.keyboard, 1, 15, 1, {}))
    elseif self.fill_descending then track:descending(table.move(self.piano.keyboard, 1, 15, 1, {}))
    elseif self.fill_scatter_asc then track:scatter_asc(table.move(self.piano.keyboard, 1, 15, 1, {}))
    elseif self.fill_scatter_desc then track:scatter_desc(table.move(self.piano.keyboard, 1, 15, 1, {}))
    elseif self.fill_narrow then track:random(table.move(self.piano.keyboard, 5, 11, 1, {}))
    elseif self.fill_spiral then track:spiral(table.move(self.piano.keyboard, 1, 15, 1, {}))
    elseif self.fill_random then track:random(self.piano.keyboard)
    elseif self.change_seq_type_pressed and processing_v2==1 then track:set_seq_type(1)
    elseif self.pattern_dec then track:advance_pattern_seq(-1)
    elseif self.pattern_inc then track:advance_pattern_seq(1)
    elseif self.octave_down then
        self.lane[self.focus]:octave_down()
        self.step_octave_down = true
    elseif self.octave_up then
        self.lane[self.focus]:octave_up()
        self.step_octave_up = true
    elseif processing_v2==1 and self.held_chord>0 then
        print(self.held_chord)
        track:set_step_data(x, self.held_chord)
    else
        self:grid_patching_automation(x,y)
    end
end

function context:grid_patching_off(x,y,z)
    self.focus_x_held = 0
    if not self.step_octave_down and not self.step_octave_up then
        self.piano:gestures(self.octave_down, self.octave_up, false)
    end
    self.step_octave_down = false
    self.step_octave_up = false
end

function context:grid_key(x,y,on)
    self:gesture_indicators_base()
    self.copy = self.momentary[1][6] == 1 and true or false
    self.paste = self.momentary[2][6] == 1 and true or false
    self.kill_midi = self.copy and self.paste and true or false
    self.invert_direction = self.momentary[4][5] == 1 and true or false
    self.invert_ping_pong = self.momentary[5][5] == 1 and true or false
    self.invert_ping_pong_2 = self.momentary[6][5] == 1 and true or false
    self.invert_random_step = self.momentary[7][5] == 1 and true or false
    self.invert_b_section = self.momentary[3][5] == 1 and true or false
    self.pattern_chaining_ind = self.momentary[8][5] == 1 and true or false

    if self.piano.live_record_mode then
        if self.clear_step then
            local track = self.lane[self.focus]
            track:set_step_mute(track.position, 1)
            track.position = track.position + track:direction()
            track:clamp_position_chaining()
        end
    end

    self.change_seq_type_pressed = self.momentary[9][5] == 1 and true or false
    self.lock_step_pressed = self.momentary[11][5] == 1 and true or false

    if self.audition and self.shift then self.focus_x = self.lane[self.focus]:nudge_pattern(-1) end
    if self.advance_sequence and self.shift then self.focus_x = self.lane[self.focus]:nudge_pattern(1) end

    self.tap_tempo_pressed = self.momentary[16][8] == 1 and true or false

    if self.lane[self.focus]:riff_lane() then
        self.interval_dec = self.momentary[8][8] == 1 and true or false
        if self.interval_dec then self.lane[self.focus]:set_step_data(self.focus_x, self.lane[self.focus]:data(self.focus_x) - 1) end
        self.interval_inc = self.momentary[9][8] == 1 and true or false
        if self.interval_inc then self.lane[self.focus]:set_step_data(self.focus_x, self.lane[self.focus]:data(self.focus_x) + 1) end
        self.interval_dec_7 = self.momentary[7][8] == 1 and true or false
        if self.interval_dec_7 then self.lane[self.focus]:set_step_data(self.focus_x, self.lane[self.focus]:data(self.focus_x) - 7) end
        self.interval_inc_7 = self.momentary[10][8] == 1 and true or false
        if self.interval_inc_7 then self.lane[self.focus]:set_step_data(self.focus_x, self.lane[self.focus]:data(self.focus_x) + 7) end
    elseif self.lane[self.focus]:chord_lane() then
        self:play_chord_piano(x,y,on)
    else
        self.octave_up = self.momentary[2][7] == 1 and true or false
        self.octave_down = self.momentary[1][7] == 1 and true or false
        
        local track = self.lane[self.focus]
        if self.piano:key_pressed() > 0 then
            local chord_buffer = self.piano.chord_buffer
            if self.fill_ascending then track:ascending(chord_buffer)
            elseif self.fill_descending then track:descending(chord_buffer)
            elseif self.fill_scatter_asc then track:piano_scatter_asc(chord_buffer)
            elseif self.fill_scatter_desc then track:piano_scatter_desc(chord_buffer)
            elseif self.fill_triangle_asc then track:piano_triangle(chord_buffer, "up")
            elseif self.fill_triangle_desc then track:piano_triangle(chord_buffer, "down")
            elseif self.fill_random then track:random(chord_buffer)
            end
        end

        self.piano_mute = self.momentary[3][7] == 1 and true or false
        self.piano:gestures(false, false, self.piano_mute)

        self.live_record_mode_pressed = self.momentary[10][5] == 1 and true or false
        if self.live_record_mode_pressed then
            self.piano:invert_live_record_mode()
        end

        self.link_machine_int_pressed = self.momentary[3][6] == 1 and true or false
        if self.link_machine_int_pressed then self.piano:invert_link_machine_int() end

        self.piano:check_chord_buffer()
    end

    if self.lane[self.focus]:riff_lane() or self.lane[self.focus]:note_lane() then
        self:all_lane_gestures_automation()
        self.fill_ascending = self.momentary[4][6] == 1 and true or false
        self.fill_descending = self.momentary[4][7] == 1 and true or false
        self.fill_triangle_asc = self.momentary[5][6] == 1 and true or false
        self.fill_triangle_desc = self.momentary[5][7] == 1 and true or false
        self.fill_narrow = self.momentary[6][6] == 1 and true or false
        self.fill_spiral = self.momentary[6][7] == 1 and true or false
        self.fill_scatter_asc = self.momentary[7][6] == 1 and true or false
        self.fill_scatter_desc = self.momentary[7][7] == 1 and true or false
        self.fill_random = self.momentary[8][6] == 1 and true or false
        self.fill_clear = self.momentary[8][7] == 1 and true or false
        self.clear_step = self.momentary[9][6] == 1 and true or false
        self.shift = self.momentary[9][7] == 1 and true or false

        self.pattern_dec = self.momentary[10][7] == 1 and true or false
        -- if self.pattern_dec then self.lane[self.focus]:advance_pattern_seq(-1) end
        self.pattern_inc = self.momentary[11][7] == 1 and true or false
        -- if self.pattern_inc then self.lane[self.focus]:advance_pattern_seq(1) end

        if self.note_lighting == false then
            if self.note_lighting_pressed then self.note_lighting = true end
        else
            if self.note_lighting_pressed then self.note_lighting = false end
        end
        self.note_lighting_pressed = self.momentary[10][6] == 1 and true or false

        self.preserve_density_pressed = self.momentary[11][6] == 1 and true or false
    end
end

function context:play_chord_piano(x,y,on)
    if not on then
        self.held_chord_name = ""
        self.held_chord = 0
        return
    end
	if y==7 and x<=12 then self.held_chord = x
	elseif y==8 and x<=14 then self.held_chord = 12 + x
    else return
	end

	local channels = {1}
    for j=1,#channels do
        local root = notes_context.piano.scale[notes_context.lane[self.focus_x]:data()]
        self.held_chord_name = music.CHORDS[self.held_chord].name
        local chord =  music.generate_chord(root,self.held_chord_name,0)
        for k=1,#chord do
            play_midi(true, chord[k], notes_context.piano.p_vel, channels[j], notes_context.piano.hold_time) -- note number, velocity, channel, duration
        end
    end
end

function context:get_current_gesture()
    local gesture
    if self.live_record_mode_pressed then gesture = "piano live record mode"
    elseif (self.audition or self.advance_sequence) and self.shift then gesture = "nudge pattern"
    elseif self.lock_step_pressed then gesture = "lock step"
    elseif self.preserve_density_pressed then gesture = "preserve density"
    elseif self.octave_up then gesture = "ocatve up"
    elseif self.octave_down then gesture = "octave down"
    elseif self.piano_mute then gesture = "piano mute"
    elseif self.note_lighting_pressed then gesture = "note lighting"
    elseif self.fill_narrow then gesture = "fill narrow"
    elseif self.fill_spiral then gesture = "fill spiral"
    elseif self.link_machine_int_pressed then gesture = "link machine int"
    elseif self.fill_clear then gesture = "clear mutes"
    elseif self.clear_step then gesture = "mute step"
    elseif self.pattern_chaining_ind then gesture = "pattern chaining ind"
    elseif self.pattern_inc then gesture = "pattern inc"
    elseif self.pattern_dec then gesture = "pattern dec"
    elseif self.interval_dec then gesture = "interval dec"
    elseif self.interval_inc then gesture = "interval int"
    elseif self.interval_dec_7 then gesture = "interval dec 7"
    elseif self.interval_inc_7 then gesture = "interval int 7"
    elseif self.change_seq_type_pressed and processing_v2==1 then gesture = "chng seq type"
    elseif self.held_chord_name~="" and processing_v2==1 then gesture = self.held_chord_name
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
    return y <= self.area and safe
end

return context