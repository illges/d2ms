---@diagnostic disable: undefined-global, lowercase-global

local automation = include 'lib/context_automation'
local channel = include 'lib/channel_cc'
local engine_opt = {"cutoff","release","pan","pw"}
local engine_display = {display_cutoff, display_release, display_pan, display_pw}

context = setmetatable({}, {__index = automation})
context.__index = context

function context.new()
    local self = setmetatable(automation.new(), context)
    self.name = "cc"
    self.type = "cc"

    self.channel_pressed = false
    self.cc_bang = false
    self.cc_num_inc = false
    self.cc_num_dec = false
    self.velocity_mode_pressed = false
    self.hide_position_pressed = false
    self.engine_active_pressed = false

    self.fill_low = false
    self.fill_mid = false
    self.fill_high = false
    self.fill_low_high = false
    self.fill_low_high_alt = false
    self.fill_low_mid = false
    self.fill_low_mid_alt = false
    self.fill_mid_high = false
    self.fill_mid_high_alt = false
    self.fill_narrow_high = false
    self.fill_narrow_low = false
    self.step_held = false
    self.step_was_set = false -- allows cc input grid to stay active for multiple presses

    self.sel_channel = 1
    self.channel = {}
    for i=1,16 do
        table.insert(self.channel, channel.new(i))
    end

    self.step_visual = {}
    for i=1,16 do
        self.step_visual[i] = {}
        for j=1,16 do
            self.step_visual[i][j]={}
            for k=1,16 do
                self.step_visual[i][j][k] = 0
            end
        end
    end

    self.channel_visual = self:init_channel_visual()
    self.grid_refresh=metro.init()
    self.grid_refresh.count=-1
    self.grid_refresh.time=0.1
    self.grid_refresh.event=function()
        self:get_visuals()
    end
    self.grid_refresh:start()
    return self
end

function context:load_cc_config(config_option, ch)
    for lane=1,16 do
        self.channel[ch].lane[lane]:set_active_direct(config_option[lane].active and 1 or 0)
        self.channel[ch].lane[lane]:set_velocity_mode_direct(config_option[lane].velocity and 1 or 0)
        self.channel[ch].lane[lane]:set_cc_number_direct(config_option[lane].cc_number)
    end
end

function context:init_channel_visual()
    local visual = {}
    for i=1,16 do
        visual[i] = 0
    end
    return visual
end

function context:set_channel_visual(n)
    self.channel_visual[n] = 12
end

function context:set_vel_step_visuals(channel, lane, step)
    for j=1,16 do
        self.step_visual[channel][lane][j]=0
    end
    self.step_visual[channel][lane][step] = 15
end

function context:get_visuals()
    for j=1,16 do
        for i=1,16 do
            for k=1,16 do
                if self.step_visual[j][i][k]>0 then
                    self.step_visual[j][i][k]=self.step_visual[j][i][k]-1
                end
                if self.step_visual[j][i][k]<0 then
                    self.step_visual[j][i][k]=0
                end 
            end
        end
        if self.channel_visual[j]>0 then
            self.channel_visual[j]=self.channel_visual[j]-1
        end
    end
end

function context:draw_screen()
    local ch = self.sel_channel
    local lane = self.channel[ch].lane[self.focus]

    -- lane.step.channel
    self:draw_header_top_right(self.focus.."."..self.focus_x.."."..ch)

    local text = (self:is_engine_lane()) and ": "..engine_opt[self.focus] or ""
    screen.move(25, 7)
    screen.level(0)
    screen.text(text)

    screen.level(15)
    screen.move(0, 18)
    screen.text("cc:"..lane.cc_number)

    screen.move(35, 18)
    screen.text("value:"..lane:data(self.focus_x))

    screen.move(85,18)
    screen.text("vel<="..self:calc_vel_step_thresh(self.focus_x - lane:range_min() + 1))

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
            light = (step<lane:range_min() or step>lane:range_max()) and 2 or light
            light = self.focus_x == step and 15 or light
            screen.level(light)
            if j==1 then
                screen.move(((i-1)*15)+7, (20*j)+ui_offset+3)
            else
                screen.move(((i-1)*15)+7, (20*j)+ui_offset+1)
            end
            local note = self.channel[self.sel_channel].lane[self.focus]:data(step)
            if self:is_engine_lane() then note = engine_display[self.focus](note) end
            local vel = self:calc_vel_step_thresh(step - lane:range_min() + 1)
            local text = self.display == self.STEP and note or vel
            screen.text(text)
        end
    end
end

function context:is_engine_lane()
    return (self.channel[self.sel_channel].engine_active == 1 and self.focus<=4)
end

function context:calc_vel_step_thresh(step)
    local ch = self.sel_channel
    local step_thresh = self.channel[ch].lane[self.focus]:get_vel_step_threshold()
    local thresh = tostring(util.clamp((step * step_thresh) + self.channel[ch].lane[self.focus].vel_floor,1,127))
    if step == self.channel[ch].lane[self.focus]:range_max() then thresh = tostring(self.channel[ch].lane[self.focus].vel_ceiling) end
    if tonumber(thresh) < (step_thresh + self.channel[ch].lane[self.focus].vel_floor)  or tonumber(thresh) > 127 then thresh = 'xxx' end
    return thresh
end

function context:bang(slot, min)
    local ch = self.sel_channel
    local cc = self.channel[ch].lane[slot].cc_number
    local position = self.channel[ch].lane[slot]:range_min()
    local num = min and self.channel[ch].lane[slot]:data(position) or 64
    local val = util.clamp(num, 0, 127)
    for j=1,#device_manager.output_devices do
        device_manager.output_devices[j].midi:cc(cc, val, ch)
    end
    log_cc_update(cc, val, ch)
end

function context:enc_one(d)
    local step = self:upper_grid_pressed()
    if step > 0 then
        self.channel[self.sel_channel].lane[self.focus]:set_cc_number(d)
        return
    end
end

function context:enc_two(d)

end

function context:enc_three(d)
    local step = self:upper_grid_pressed()

    if step > 0 then
        local old_value = self.channel[self.sel_channel].lane[self.focus]:data(step)
        self.channel[self.sel_channel].lane[self.focus]:set_step_data(step, old_value + d)
        return
    end
end

function context:grid_key(x,y,on)
    self:gesture_indicators_automation_override()
    self:gesture_indicators()

    local ch_pressed = self:get_channel_pressed()
    if ch_pressed > 0 and not self.step_held then self.sel_channel = ch_pressed end
    self.channel_pressed = (ch_pressed > 0 and not self.step_held) and true or false

    self.cc_bang = self.momentary[8][5] == 1 and true or false

    if self.velocity_mode_pressed then self.channel[self.sel_channel].lane[self.focus]:set_velocity_mode() end
    if self.hide_position_pressed then self.channel[self.sel_channel].lane[self.focus]:set_hide_position() end

    local track = self.channel[self.sel_channel].lane[self.focus]
    self.octave_down = self.momentary[1][7] == 1 and true or false
    if self.octave_down then track:set_step_data(self.focus_x, track:data(self.focus_x) - 1) end
    self.octave_up = self.momentary[2][7] == 1 and true or false
    if self.octave_up then track:set_step_data(self.focus_x, track:data(self.focus_x) + 1) end

    self.cc_num_dec = self.momentary[9][5] == 1 and true or false
    if self.cc_num_dec then self.channel[self.sel_channel].lane[self.focus]:set_cc_number(-1) end
    self.cc_num_inc = self.momentary[10][5] == 1 and true or false
    if self.cc_num_inc then self.channel[self.sel_channel].lane[self.focus]:set_cc_number(1) end

    self:cc_input(x,y,on)
end

function context:gesture_indicators_automation_override()
    self:gesture_indicators_base()

    self.copy = self.momentary[1][6] == 1 and true or false
    self.paste = self.momentary[2][6] == 1 and true or false
    self.kill_midi = self.copy and self.paste and true or false

    self.invert_direction = self.momentary[4][5] == 1 and true or false
    self.invert_ping_pong = self.momentary[5][5] == 1 and true or false
    self.invert_ping_pong_2 = self.momentary[6][5] == 1 and true or false
    self.invert_random_step = self.momentary[7][5] == 1 and true or false
    self.invert_b_section = self.momentary[3][5] == 1 and true or false

    self.fill_ascending = self.momentary[4][6] == 1 and true or false
    self.fill_descending = self.momentary[4][7] == 1 and true or false
    self.fill_triangle_asc = self.momentary[5][6] == 1 and true or false
    self.fill_triangle_desc = self.momentary[5][7] == 1 and true or false
    self.fill_low_high = self.momentary[6][6] == 1 and true or false
    self.fill_low_high_alt = self.momentary[6][7] == 1 and true or false
    self.fill_low_mid = self.momentary[7][6] == 1 and true or false
    self.fill_low_mid_alt = self.momentary[7][7] == 1 and true or false
    self.fill_mid_high = self.momentary[8][6] == 1 and true or false
    self.fill_mid_high_alt = self.momentary[8][7] == 1 and true or false
    self.fill_narrow_high = self.momentary[9][6] == 1 and true or false
    self.fill_narrow_low = self.momentary[9][7] == 1 and true or false
    self.fill_mid = self.momentary[10][7] == 1 and true or false
    self.fill_high = self.momentary[10][6] == 1 and true or false
    self.fill_random = self.momentary[11][6] == 1 and true or false
    self.fill_low = self.momentary[11][7] == 1 and true or false

    self.clear_step = self.momentary[12][6] == 1 and true or false
    self.shift = self.momentary[12][7] == 1 and true or false
end

function context:gesture_indicators()
    self.velocity_mode_pressed = self.momentary[11][5] == 1 and true or false
    self.hide_position_pressed = self.momentary[12][5] == 1 and true or false
    self.engine_active_pressed = self.momentary[3][6] == 1 and true or false

    if self.audition and self.shift then self.focus_x = self.channel[self.sel_channel].lane[self.focus]:nudge_pattern(-1) end
    if self.advance_sequence and self.shift then self.focus_x = self.channel[self.sel_channel].lane[self.focus]:nudge_pattern(1) end
    if self.engine_active_pressed then
        self.channel[self.sel_channel]:invert_engine_active()
        if self.channel[self.sel_channel].engine_active == 0 then
            set_cutoff(64)
            set_release(64)
            set_pan(64)
            set_pw(64)
        end
    end
end

function context:draw_grid()
    self:draw_grid_main()
    self:draw_grid_override()
    if self.step_held then
        self:draw_cc_input()
    else
        self:draw_channel_cc()
    end
    g:led(8, 5, basic_lighting(self.cc_bang))
    g:led(11, 5, basic_lighting(self.channel[self.sel_channel].lane[self.focus].velocity_mode == 1))
    g:led(12, 5, negative_lighting(self.channel[self.sel_channel].lane[self.focus].hide_position == 1))
    g:led(9, 5, negative_lighting(self.cc_num_dec))
    g:led(10, 5, negative_lighting(self.cc_num_inc))
    g:led(3, 6, negative_high_lighting(self.channel[self.sel_channel].engine_active == 1))
    g:led(1, 7, basic_lighting(self.octave_down))
    g:led(2, 7, basic_lighting(self.octave_up))
end

function context:draw_grid_main()
    for i=1,self.area do
        local mod = self:get_lane(i)
        local ch = self.sel_channel
        local lane = self.channel[ch].lane[mod]
        local min = lane:range_min()
        local max = lane:range_max()
        local light
        for j=min,max do
            light = self:get_value_lighting(lane, j)
            if (lane.velocity_mode==1 and lane.hide_position==0) or lane.velocity_mode==0 then
                light = j == lane.position and 15 or light
                light = j == lane.strum_position and 15 or light
            end
            light = self.step_visual[ch][mod][j] > 0 and self.step_visual[ch][mod][j] or light
            light = lane.active==1 and light or 2
            g:led(j, i, light)
        end
    end
end

function context:get_value_lighting(lane, pos)
    for i=1,16 do
        if lane:data(pos) <= lane:minimum() + (lane:threshold()*(i-1)) then return i - 1 end
        if lane:data(pos) > 120 then return 15 end
    end
end

function context:draw_grid_override()
    local ch = self.sel_channel
    local lane = self.channel[ch].lane[self.focus]

    self:draw_grid_base()

    g:led(4, 5, active_indicator(
        self.invert_direction,
        lane:direction() == -1
    ))
    g:led(5, 5, active_indicator(
        self.invert_ping_pong,
        lane:ping_pong() == 1
    ))
    g:led(6, 5, active_indicator(
        self.invert_ping_pong_2,
        lane:ping_pong_2() == 1
    ))
    g:led(7, 5, active_indicator(
        self.invert_random_step,
        lane:random_step() == 1
    ))
    g:led(3, 5, active_indicator(
        self.invert_b_section,
        lane.b_section == 1
    ))

    self:draw_lane_actions_automation_override()
end

function context:draw_lane_actions_automation_override()
    g:led(1, 6, negative_lighting(self.copy))
    g:led(2, 6, negative_lighting(self.paste))

    g:led(4, 6, basic_lighting(self.fill_ascending))
    g:led(4, 7, basic_lighting(self.fill_descending))
    g:led(5, 6, medium_lighting(self.fill_triangle_asc))
    g:led(5, 7, medium_lighting(self.fill_triangle_desc))
    g:led(6, 6, basic_lighting(self.fill_low_high))
    g:led(6, 7, basic_lighting(self.fill_low_high_alt))
    g:led(7, 6, medium_lighting(self.fill_low_mid))
    g:led(7, 7, medium_lighting(self.fill_low_mid_alt))
    g:led(8, 6, basic_lighting(self.fill_mid_high))
    g:led(8, 7, basic_lighting(self.fill_mid_high_alt))
    g:led(9, 6, medium_lighting(self.fill_narrow_high))
    g:led(9, 7, medium_lighting(self.fill_narrow_low))
    g:led(10, 7, basic_lighting(self.fill_mid))
    g:led(10, 6, basic_lighting(self.fill_high))
    g:led(11, 6, medium_lighting(self.fill_random))
    g:led(11, 7, medium_lighting(self.fill_low))
    g:led(12, 6, negative_lighting(self.clear_step))
    g:led(12, 7, negative_lighting(self.shift))
end

function context:draw_channel_cc()
    for i=1,16 do
        local light = 2
        if i==1 or i==5 or i==9 or i==13 then light = 4 end
        if self.channel[i]:any_active_lane() then light = 8 end
        light = (self.sel_channel == i or self.momentary[i][8] == 1) and 15 or light
        light = self.channel_visual[i] > 0 and self.channel_visual[i] or light
        g:led(i, 8, light)
    end
end

function context:draw_cc_input()
    for i=1,16 do
        g:led(i, 8, i-1)
    end
end

function context:cc_input(x,y,on)
    if self.step_held and y==8 and on then
        local val = (x*8) == 8 and 0 or (x*8)
        self.channel[self.sel_channel].lane[self.focus]:set_step_data(self.focus_x, val)
        self.step_was_set = true
    end
end

function context:grid_patching(x,y)
    self.focus = y
    self.focus_x = x
    local ch = self.sel_channel
    local track = self.channel[ch].lane[y]

    if self.audition then track:set_position(x)
    elseif self.fill_ascending then track:ascending()
    elseif self.fill_descending then track:descending()
    elseif self.fill_triangle_asc then track:triangle_asc()
    elseif self.fill_triangle_desc then track:triangle_desc()
    elseif self.fill_low_high then track:fill_low_high()
    elseif self.fill_low_high_alt then track:fill_low_high_alt()
    elseif self.fill_low_mid then track:fill_low_mid()
    elseif self.fill_low_mid_alt then track:fill_low_mid_alt()
    elseif self.fill_mid_high then track:fill_mid_high()
    elseif self.fill_mid_high_alt then track:fill_mid_high_alt()
    elseif self.fill_narrow_high then track:fill_narrow_high()
    elseif self.fill_narrow_low then track:fill_narrow_low()
    elseif self.fill_mid then track:fill_mid()
    elseif self.fill_high then track:fill_high()
    elseif self.fill_random then track:random()
    elseif self.fill_low then track:fill_low()
    elseif self.clear_step then track:clear_step(x)
    elseif self.cc_bang then self:bang(y)
    elseif self.channel_pressed then
        track:set_active()
        if track.active == 0 and
            pulse_min_cc_slot_off == 1 then
            self:bang(y, true)
        end
    elseif self.invert_direction then track:invert_direction()
    elseif self.invert_ping_pong then track:invert_ping_pong()
    elseif self.invert_ping_pong_2 then track:invert_ping_pong_2()
    elseif self.invert_random_step then track:invert_random_step()
    elseif self.invert_b_section then track:invert_b_section()
    elseif self.copy then self:copy_lane(y)
    elseif self.paste then self:paste_lane(y)
    else
        self.step_held = true
    end
end

function context:grid_patching_off(x,y,z)
    if self.step_was_set == true then
        self.step_was_set = false
    else
        self.step_held = false
    end
end

function context:copy_lane(lane)
    for key,value in pairs(self.channel[self.sel_channel].lane[lane]:data()) do
        self.copy_buffer[key] = value
    end
end

function context:paste_lane(lane)
    for i=1,16 do
        self.channel[self.sel_channel].lane[lane]:set_step_data(i, self.copy_buffer[i])
    end
end

function context:get_channel_pressed()
    if self.momentary[1][8] == 1 then return 1 end
    if self.momentary[2][8] == 1 then return 2 end
    if self.momentary[3][8] == 1 then return 3 end
    if self.momentary[4][8] == 1 then return 4 end
    if self.momentary[5][8] == 1 then return 5 end
    if self.momentary[6][8] == 1 then return 6 end
    if self.momentary[7][8] == 1 then return 7 end
    if self.momentary[8][8] == 1 then return 8 end
    if self.momentary[9][8] == 1 then return 9 end
    if self.momentary[10][8] == 1 then return 10 end
    if self.momentary[11][8] == 1 then return 11 end
    if self.momentary[12][8] == 1 then return 12 end
    if self.momentary[13][8] == 1 then return 13 end
    if self.momentary[14][8] == 1 then return 14 end
    if self.momentary[15][8] == 1 then return 15 end
    if self.momentary[16][8] == 1 then return 16 end
    return 0
end

function context:get_current_gesture()
    local gesture
    if self.cc_bang then gesture = "cc pulse"
    elseif (self.audition or self.advance_sequence) and self.shift then gesture = "nudge pattern"
    elseif self.octave_up then gesture = "cc step (+)"
    elseif self.octave_down then gesture = "cc step (-)"
    elseif self.channel_pressed then gesture = "cc channel"
    elseif self.velocity_mode_pressed then gesture = "velocity mode"
    elseif self.hide_position_pressed then gesture = "hide step pos"
    elseif self.fill_low then gesture = "fill low"
    elseif self.fill_mid then gesture = "fill mid"
    elseif self.fill_high then gesture = "fill high"
    elseif self.fill_ascending then gesture = "fill ascending"
    elseif self.fill_descending then gesture = "fill descending"
    elseif self.fill_triangle_asc then gesture = "fill triangle asc"
    elseif self.fill_triangle_desc then gesture = "fill triangle desc"
    elseif self.fill_low_high then gesture = "fill low high"
    elseif self.fill_low_high_alt then gesture = "fill low high alt"
    elseif self.fill_low_mid then gesture = "fill low mid"
    elseif self.fill_low_mid_alt then gesture = "fill low mid alt"
    elseif self.fill_mid_high then gesture = "fill mid high"
    elseif self.fill_mid_high_alt then gesture = "fill mid high alt"
    elseif self.fill_narrow_high then gesture = "fill narrow high"
    elseif self.fill_narrow_low then gesture = "fill narrow low"
    elseif self.fill_random then gesture = "fill random"
    elseif self.cc_num_dec then gesture = "cc num dec"
    elseif self.cc_num_inc then gesture = "cc num inc"
    elseif self.engine_active_pressed then gesture = "engine mod active"
    else gesture = self:get_current_gesture_automation()
    end
    self.gesture = gesture
end

function context:range_update_ok(y)
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

function context:range_update(x,y,z,lane)
    local track = self.channel[self.sel_channel].lane[lane]
    if z==1 and self.held[y] then self.heldmax[y] = 0 end
    self.held[y] = self.held[y] + (z*2-1)
    if self.held[y] > self.heldmax[y] then self.heldmax[y] = self.held[y] end
    --print(self.held[y]) tab.print(self.held)

    if not self:range_update_ok(y) then return
    else
        if z == 1 then
            if self.focus ~= lane then
                self.focus = lane
                redraw()
            end

            if y<=self.area and self.held[y]==1 then
                self.first[y] = x
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
                    track:set_range_data(min, max)
                else
                    min = math.min(self.first[y],self.second[y])
                    max = math.max(self.first[y],self.second[y])
                    track:set_range_data(min, max)
                end

                track:clamp_position()

                grid_dirty = true
                redraw()
            end
        end
    end
end

return context
