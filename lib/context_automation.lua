---@diagnostic disable: undefined-global, lowercase-global

local base = include 'lib/context_base'

local context = setmetatable({}, {__index = base})
context.__index = context

function context.new()
    local self = setmetatable(base.new(), context)

    self.STEP = 1;  self.VEL = 2;
    self.display = self.STEP
    self.lane = {}
    self.copy_buffer = {}
    self.copy_mute_buffer = {}
    self.copy_length_buffer_min = 1
    self.copy_length_buffer_max = 16
    self.copy = false
    self.paste = false
    self.kill_midi = false
    self.invert_direction = false
    self.invert_ping_pong = false
    self.invert_ping_pong_2 = false
    self.invert_random_step = false
    self.invert_b_section = false
    self.fill_ascending = false
    self.fill_descending = false
    self.fill_scatter_asc = false
    self.fill_scatter_desc = false
    self.fill_triangle_asc = false
    self.fill_triangle_desc = false
    self.fill_random = false
    self.fill_clear = false
    self.clear_step = false
    self.shift = false
    self.octave_down = false
    self.octave_up = false

    -- update range vars
    self.held = {}
    self.heldmax = {}
    self.first = {}
    self.second = {}
    for i = 1,8 do
        self.held[i] = 0
        self.heldmax[i] = 0
        self.first[i] = 0
        self.second[i] = 0
    end

    self.step_visual = {}
    for i=1,16 do
        self.step_visual[i] = {}
        for j=1,16 do
            self.step_visual[i][j]=0
        end
    end

    self.grid_refresh=metro.init()
    self.grid_refresh.count=-1
    self.grid_refresh.time=0.1
    self.grid_refresh.event=function()
        self:get_visuals()
    end
    self.grid_refresh:start()

    return self
end

function context:get_visuals()
    for j=1,16 do
        for i=1,16 do
            if self.step_visual[j][i]>0 then
                self.step_visual[j][i]=self.step_visual[j][i]-1
                grid_redraw()
            end
            if self.step_visual[j][i]<0 then
                self.step_visual[j][i]=0
                grid_redraw()
            end
        end
    end
end

function context:set_vel_step_visuals(lane, step)
    for j=1,16 do
        self.step_visual[lane][j]=0
    end
    self.step_visual[lane][step] = 15
end

function context:key_two()
    self.display = util.wrap(self.display-1,1,2)
end

-- function context:key_three()
--     self.display = util.wrap(self.display+1,1,2)
-- end

function context:invert_all_direction()
    for i=1,16 do
        self.lane[i]:invert_direction()
    end
end

function context:invert_all_ping_pong()
    for i=1,16 do
        self.lane[i]:invert_ping_pong()
    end
end

function context:invert_all_ping_pong_2()
    for i=1,16 do
        self.lane[i]:invert_ping_pong_2()
    end
end

function context:invert_all_random_step()
    for i=1,16 do
        self.lane[i]:invert_random_step()
    end
end

function context:invert_all_b_section()
    for i=1,16 do
        self.lane[i]:invert_b_section()
    end
end

function context:copy_lane(lane)
    -- for key,value in pairs(self.lane[lane]:data()) do
    --     self.copy_buffer[key] = value
    -- end
    self.copy_length_buffer_min = self.lane[lane]:range_min()
    self.copy_length_buffer_max = self.lane[lane]:range_max()
    for i=1,16 do
        self.copy_buffer[i] = self.lane[lane]:data(i)
        self.copy_mute_buffer[i] = self.lane[lane]:step_mute(i)
    end
end

function context:paste_lane(lane)
    self.lane[lane]:set_range_data(self.copy_length_buffer_min,self.copy_length_buffer_max)
    for i=1,16 do
        self.lane[lane]:set_step_data(i, self.copy_buffer[i])
        self.lane[lane]:set_step_mute(i, self.copy_mute_buffer[i])
    end
end

function context:draw_grid_automation()
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

    self:draw_lane_actions_automation()
end

function context:draw_lane_actions_automation()
    g:led(4, 6, basic_lighting(self.fill_ascending))
    g:led(4, 7, basic_lighting(self.fill_descending))

    g:led(6, 6, basic_lighting(self.fill_scatter_asc))
    g:led(6, 7, basic_lighting(self.fill_scatter_desc))

    g:led(5, 6, basic_lighting(self.fill_triangle_asc))
    g:led(5, 7, basic_lighting(self.fill_triangle_desc))

    g:led(7, 6, basic_lighting(self.fill_random))
    g:led(7, 7, basic_lighting(self.fill_clear))

    g:led(8, 6, negative_lighting(self.clear_step))
    g:led(8, 7, negative_lighting(self.shift))
    
    g:led(1, 6, negative_lighting(self.copy))
    g:led(2, 6, negative_lighting(self.paste))
end

function context:gesture_indicators_automation()
    self:gesture_indicators_base()

    self.copy = self.momentary[1][6] == 1 and true or false
    self.paste = self.momentary[2][6] == 1 and true or false
    self.kill_midi = self.copy and self.paste and true or false

    self.octave_up = self.momentary[2][7] == 1 and true or false
    self.octave_down = self.momentary[1][7] == 1 and true or false

    self.invert_direction = self.momentary[4][5] == 1 and true or false
    self.invert_ping_pong = self.momentary[5][5] == 1 and true or false
    self.invert_ping_pong_2 = self.momentary[6][5] == 1 and true or false
    self.invert_random_step = self.momentary[7][5] == 1 and true or false
    self.invert_b_section = self.momentary[3][5] == 1 and true or false

    self.fill_ascending = self.momentary[4][6] == 1 and true or false
    self.fill_descending = self.momentary[4][7] == 1 and true or false
    self.fill_scatter_asc = self.momentary[6][6] == 1 and true or false
    self.fill_scatter_desc = self.momentary[6][7] == 1 and true or false
    self.fill_triangle_asc = self.momentary[5][6] == 1 and true or false
    self.fill_triangle_desc = self.momentary[5][7] == 1 and true or false
    self.fill_random = self.momentary[7][6] == 1 and true or false
    self.fill_clear = self.momentary[7][7] == 1 and true or false

    self.clear_step = self.momentary[8][6] == 1 and true or false
    self.shift = self.momentary[8][7] == 1 and true or false
end

function context:all_lane_gestures_automation()
    if self.shift then
        if self.fill_ascending then self:all_ascending()
        elseif self.fill_descending then self:all_descending()
        elseif self.fill_scatter_asc then self:all_scatter_asc()
        elseif self.fill_scatter_desc then self:all_scatter_desc()
        elseif self.fill_triangle_asc then self:all_triangle_asc()
        elseif self.fill_triangle_desc then self:all_triangle_desc()
        elseif self.fill_random then self:all_random()
        elseif self.fill_clear then self:all_static()
        elseif self.invert_direction then self:invert_all_direction()
        elseif self.invert_ping_pong then self:invert_all_ping_pong()
        elseif self.invert_ping_pong_2 then self:invert_all_ping_pong_2()
        elseif self.invert_random_step then self:invert_all_random_step()
        elseif self.invert_b_section then self:invert_all_b_section()
        -- elseif self.octave_up then self:all_octave_up()
        -- elseif self.octave_down then self:all_octave_down()
        end
    end
end

function context:grid_patching_automation(x,y)
    local track = self.lane[y]

    if self.invert_direction then track:invert_direction()
    elseif self.invert_ping_pong then track:invert_ping_pong()
    elseif self.invert_ping_pong_2 then track:invert_ping_pong_2()
    elseif self.invert_random_step then track:invert_random_step()
    elseif self.invert_b_section then track:invert_b_section()
    elseif self.fill_clear then track:static()
    elseif self.clear_step then track:clear_step(x)
    -- elseif self.octave_up then track:octave_up()
    -- elseif self.octave_down then track:octave_down()
    elseif self.copy then self:copy_lane(y)
    elseif self.paste then self:paste_lane(y)
    end
end

function context:get_current_gesture_automation()
    local gesture
    if self.invert_direction then gesture = "invert direction"
    elseif self.invert_ping_pong then gesture = "ping pong"
    elseif self.invert_ping_pong_2 then gesture = "ping pong 2"
    elseif self.invert_random_step then gesture = "random step"
    elseif self.invert_b_section then gesture = "AB section"
    elseif self.fill_clear then gesture = "clear lane data"
    elseif self.clear_step then gesture = "clear step"
    elseif self.shift then gesture = "shift"
    elseif self.copy then gesture = "COPY lane data"
    elseif self.paste then gesture = "PASTE lane data"
    elseif self.fill_ascending then gesture = "fill ascending"
    elseif self.fill_descending then gesture = "fill descending"
    elseif self.fill_triangle_asc then gesture = "fill triangle asc"
    elseif self.fill_triangle_desc then gesture = "fill triangle desc"
    elseif self.fill_scatter_asc then gesture = "fill scatter asc"
    elseif self.fill_scatter_desc then gesture = "fill scatter desc"
    elseif self.fill_random then gesture = "fill random"
    else gesture = self:get_current_gesture_base()
    end
    return gesture
end

function context:range_update(x,y,z,lane)
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
                screen_dirty = true
            end
        end
    end
end

return context