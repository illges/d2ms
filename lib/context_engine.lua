---@diagnostic disable: undefined-global, lowercase-global

local automation = include 'lib/context_automation'
local automation_lane_engine = include 'lib/automation_lane_engine'

local context_engine = setmetatable({}, {__index = automation})
context_engine.__index = context_engine

function context_engine.new(name, parameter, threshold, minimum, maximum)
    local self = setmetatable(automation.new(), context_engine)
    self.name = name
    self.type = "engine"

    self.engine_patching = false
    self.engine_entry_mode_increasing = false
    self.engine_entry_mode_decreasing = false

    for i=1,16 do
        local page = math.ceil(i/4)
        table.insert(self.lane, automation_lane_engine.new(i, name, parameter, threshold, minimum, maximum, page))
        self.lane[i]:static()
    end

    return self
end

function context_engine:all_ascending()
    for i=1,16 do
        self.lane[i]:ascending()
    end
end

function context_engine:all_descending()
    for i=1,16 do
        self.lane[i]:descending()
    end
end

function context_engine:all_triangle_asc()
    for i=1,16 do
        self.lane[i]:triangle_asc()
    end
end

function context_engine:all_triangle_desc()
    for i=1,16 do
        self.lane[i]:triangle_desc()
    end
end

function context_engine:all_scatter_asc()
    for i=1,16 do
        self.lane[i]:scatter_asc()
    end
end

function context_engine:all_scatter_desc()
    for i=1,16 do
        self.lane[i]:scatter_desc()
    end
end

function context_engine:all_random()
    for i=1,16 do
        self.lane[i]:random()
    end
end

function context_engine:all_static()
    for i=1,16 do
        self.lane[i]:static()
    end
end

function context_engine:all_octave_down()
    -- TODO + threshold amount
end

function context_engine:all_octave_up()
    -- TODO - threshold amount
end

function context_engine:enc_one(d)
    
end

function context_engine:enc_two(d)

end

function context_engine:enc_three(d)
    local step = self:upper_grid_pressed()

    if step > 0 then
        local old_value = self.lane[self.focus]:data(step)
        self.lane[self.focus]:set_step_data(step, old_value + d)
    end
end

function context_engine:draw_grid()
    self:draw_grid_main()
    self:draw_grid_automation()
    self:draw_engine_sub_contexts()
    self:draw_engine_entry_mode()
end

function context_engine:draw_grid_main()
    for i=1,self.area do
        local mod_val = i + (4 * (self.active_page - 1))
        if self.engine_patching then
            for j=1,16 do
                g:led(j, i, self:draw_engine_send_patching(notes_context.lane[mod_val], j))
            end
        else
            local min = self.lane[mod_val]:range_min()
            local max = self.lane[mod_val]:range_max()
            for j=min,max do
                g:led(j, i, j == self.lane[mod_val].position and 15 or self:get_value_lighting(mod_val, j))
            end
        end
    end
end

function context_engine:draw_screen()
    screen.level(15)
    self:draw_step_info(self.focus_x)
    screen.move(5, 25)
    screen.text("lane focus: "..self.focus)
end

function context_engine:draw_step_info(x)
    local value = self.lane[self.focus]:data(x)
    screen.move(5, 35)
    screen.text("x: "..x.." y: "..self.focus.." value: "..value)
end

function context_engine:draw_engine_sub_contexts()
    g:led(13, 8, self.name == filter_context.name and 8 or 3)
    g:led(14, 8, self.name == release_context.name and 8 or 3)
    g:led(15, 8, self.name == pan_context.name and 8 or 3)
    g:led(16, 8, self.name == pw_context.name and 8 or 3)

    g:led(11, 8, basic_lighting(self.engine_patching))
end

function context_engine:draw_engine_entry_mode()
    g:led(1, 7, basic_lighting(self.engine_entry_mode_decreasing))
    g:led(2, 7, basic_lighting(self.engine_entry_mode_increasing))
end

function context_engine:draw_engine_send_patching(note_lane, pos)
    if self.name == filter_context.name then
        return note_lane.filter_send == pos and 15 or 3
    end
    if self.name == release_context.name then
        return note_lane.release_send == pos and 15 or 3
    end
    if self.name == pan_context.name then
        return note_lane.pan_send == pos and 15 or 3
    end
    if self.name == pw_context.name then
        return note_lane.pw_send == pos and 15 or 3
    end
end

function context_engine:get_value_lighting(row, pos)
    for i=1,16 do
        if self.lane[row]:data(pos) <= self.lane[row]:minimum() + (self.lane[row]:threshold()*(i-1)) then return i - 1 end
    end
end

function context_engine:grid_patching(x,y,z)
    self.focus = y
    self.focus_x = x
    local track = self.lane[y]
    local note_lane = notes_context.lane[y]

    if self.engine_patching then
        local val
        if self.name == filter_context.name then
            val = note_lane.filter_send ~= x and x or 0
            note_lane:set_filter_send_data(val)
        elseif self.name == release_context.name then
            val = note_lane.release_send ~= x and x or 0
            note_lane:set_release_send_data(val)
        elseif self.name == pan_context.name then
            val = note_lane.pan_send ~= x and x or 0
            note_lane:set_pan_send_data(val)
        elseif self.name == pw_context.name then
            val = note_lane.pw_send ~= x and x or 0
            note_lane:set_pw_send_data(val)
        end
    elseif self.fill_triangle_asc then track:triangle_asc()
    elseif self.fill_triangle_desc then track:triangle_desc()
    elseif self.fill_ascending then track:ascending()
    elseif self.fill_descending then track:descending()
    elseif self.fill_scatter_asc then track:scatter_asc()
    elseif self.fill_scatter_desc then track:scatter_desc()
    elseif self.fill_random then track:random()
    elseif self.engine_entry_mode_decreasing then
        track:set_step_data(x, track:data(x) - track:threshold())
    elseif self.engine_entry_mode_increasing then
        track:set_step_data(x, track:data(x) + track:threshold())
    else
        self:grid_patching_automation(x,y)
    end
end

function context_engine:grid_key()
    self:gesture_indicators_automation()
    self:all_lane_gestures_automation()
    self:gesture_indicators()
end

function context_engine:get_current_gesture()
    local gesture
    if self.engine_patching then gesture = "engine patching"
    elseif self.octave_up then gesture = "engine entry (+)"
    elseif self.octave_down then gesture = "engine entry (-)"
    else gesture =  self:get_current_gesture_automation()
    end
    self.gesture = gesture
end

function context_engine:gesture_indicators()
    self.engine_patching = self.momentary[11][8] == 1 and true or false

    if self.engine_entry_mode_decreasing == false then
        if self.octave_down then
            self.engine_entry_mode_increasing = false
            self.engine_entry_mode_decreasing = true
        end
    else
        if self.octave_down then
            self.engine_entry_mode_decreasing = false
        end
    end

    if self.engine_entry_mode_increasing == false then
        if self.octave_up then
            self.engine_entry_mode_decreasing = false
            self.engine_entry_mode_increasing = true
        end
    else
        if self.octave_up then
            self.engine_entry_mode_increasing = false
        end
    end
end

function context_engine:range_update_ok(y)
    local safe = true
    for i=1,#self.momentary do
        for j=5,#self.momentary[i] do
            if self.momentary[i][j] == 1 then
                safe = false
                break
            end
        end
    end
    if (self.engine_entry_mode_increasing or
        self.engine_entry_mode_decreasing) then
        safe = false
    end
    return y <= self.area and safe
end

return context_engine