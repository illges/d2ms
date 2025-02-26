---@diagnostic disable: undefined-global, lowercase-global

local automation_lane = include 'lib/automation_lane'

local automation_lane_engine = {}
automation_lane_engine.__index = automation_lane_engine
setmetatable(automation_lane_engine, automation_lane)

function automation_lane_engine.new(id, name, parameter, threshold, minimum, maximum, page, channel)
    local self = setmetatable(automation_lane.new(id, page, "engine", name, parameter, threshold, minimum, maximum, channel), automation_lane_engine)
    self.extra_params = 0
    self.channel = channel
    self:add_params()
    return self
end

function automation_lane_engine:add_params()
    -- local group_length = self.generic_params_count + self.extra_params
    -- params:add_group(self.name.." lane "..self.id, group_length)
    -- self:add_params_generic()
    -- params:hide(self.name.." lane "..self.id)
end

function automation_lane_engine:data(x)
    if x == nil then
        return self.pattern[self.active_pattern].data
    else
        return self.pattern[self.active_pattern].data[x]
    end
end

function automation_lane_engine:minimum()
    return self.pattern[self.active_pattern].minimum
end

function automation_lane_engine:maximum()
    return self.pattern[self.active_pattern].maximum
end

function automation_lane_engine:threshold()
    return self.pattern[self.active_pattern].threshold
end

function automation_lane_engine:set_step_data(step, val)
    self.pattern[self.active_pattern]:set_step_data(step, val)
end

function automation_lane_engine:ascending()
    self.pattern[self.active_pattern]:ascending()
end

function automation_lane_engine:descending()
    self.pattern[self.active_pattern]:descending()
end

function automation_lane_engine:random()
    self.pattern[self.active_pattern]:random()
end

function automation_lane_engine:triangle_asc()
    self.pattern[self.active_pattern]:triangle_asc()
end

function automation_lane_engine:triangle_desc()
    self.pattern[self.active_pattern]:triangle_desc()
end

function automation_lane_engine:scatter_asc()
    self.pattern[self.active_pattern]:scatter_asc()
end

function automation_lane_engine:scatter_desc()
    self.pattern[self.active_pattern]:scatter_desc()
end

function automation_lane_engine:static()
    self.pattern[self.active_pattern]:static()
end

function automation_lane_engine:clear_step(step)
    self.pattern[self.active_pattern]:clear_step(step)
end

return automation_lane_engine