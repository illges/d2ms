---@diagnostic disable: undefined-global, lowercase-global

local pattern = include 'lib/pattern'

local engine_pattern = {}
engine_pattern.__index = engine_pattern
setmetatable(engine_pattern, pattern)

function engine_pattern.new(type, lane, pattern_num, parameter, threshold, minimum, maximum, channel)
    local self = setmetatable(pattern.new(type, lane, pattern_num), engine_pattern)
    self.minimum = minimum
    self.maximum = maximum
    self.threshold = threshold
    self.parameter = parameter
    self.channel = channel
    self.data = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    self:add_pattern_params()
    return self
end

function engine_pattern:add_pattern_params()
    params:add_group(self.type.."_lane_"..self.channel.."."..self.lane.."_pattern_num_"..self.pattern_num.."_hidden_step_params", 16)
    for j=1,16 do
        params:add{ type = "number", id= (self.type.."_lane_"..self.channel.."."..self.lane.."_pattern_num_"..self.pattern_num.."_value_"..j),
                    name = ("data "..j), min = self.minimum, max = self.maximum,
                    default = self.data[j],
                    action = function(x) self.data[j] = x end
        }
    end
    params:hide(self.type.."_lane_"..self.channel.."."..self.lane.."_pattern_num_"..self.pattern_num.."_hidden_step_params")
end

function engine_pattern:set_step_data(step, val)
    params:set(self.type.."_lane_"..self.channel.."."..self.lane.."_pattern_num_"..self.pattern_num.."_value_"..step, val)
end

function engine_pattern:ascending()
    local val
    for i=1,16 do
        val = self.minimum + (self.threshold*(i-1))
        self:set_step_data(i, val)
    end
end

function engine_pattern:descending()
    local val
    for i=1,16 do
        val = self.maximum - (self.threshold*(i-1))
        self:set_step_data(i, val)
    end
end

function engine_pattern:random()
    local val
    for i=1,16 do
        val = self.maximum - (self.threshold*(math.random(1,16)-1))
        self:set_step_data(i, val)
    end
end

function engine_pattern:triangle_asc()
    local val
    for i=1,8 do
        val = self.minimum + (2*self.threshold*(i-1))
        self:set_step_data(i, val)
    end
    for i=1,8 do
        val = self.maximum - (2*self.threshold*(i-1))
        self:set_step_data(i+8, val)
    end
end

function engine_pattern:triangle_desc()
    local val
    for i=1,8 do
        val = self.maximum - (2*self.threshold*(i-1))
        self:set_step_data(i, val)
    end
    for i=1,8 do
        val = self.minimum + (2*self.threshold*(i-1))
        self:set_step_data(i+8, val)
    end
end

function engine_pattern:scatter_asc()
    local val
    for i=1,8 do
        val = self.minimum + (2*self.threshold*(i-1))
        self:set_step_data(i, val)
    end
    for i=1,8 do
        val = self.minimum + (2*self.threshold*(i-1))
        self:set_step_data(i+8, val)
    end
end

function engine_pattern:scatter_desc()
    local val
    for i=1,8 do
        val = self.maximum - (2*self.threshold*(i-1))
        self:set_step_data(i, val)
    end
    for i=1,8 do
        val = self.maximum - (2*self.threshold*(i-1))
        self:set_step_data(i+8, val)
    end
end

function engine_pattern:static()
    local val
    for i=1,16 do
        val = params:get(self.parameter)
        self:set_step_data(i, val)
    end
end

function engine_pattern:clear_step(step)
    local val = params:get(self.parameter)
    self:set_step_data(step, val)
end

return engine_pattern