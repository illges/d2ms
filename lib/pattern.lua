---@diagnostic disable: undefined-global, lowercase-global

local pattern = {}
pattern.__index = pattern

function pattern.new(type, lane, pattern_num)
    local self = setmetatable({}, pattern)
    self.type = type
    self.lane = lane
    self.pattern_num = pattern_num
    self.step_mute = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

    self.range = {}
    --treat as private properties
    self.range.minA = 1
    self.range.maxA = 16
    self.range.minB = 9
    self.range.maxB = 16

    if self.type~="filter" and
       self.type~="release" and
       self.type~="pan" and
       self.type~="pulse width" then
            self:add_pattern_range_params()
    end
    return self
end

function pattern:add_pattern_range_params()
    params:add_group(self.type.."_lane_"..self.lane.."_pattern_num_"..self.pattern_num.."_hidden_range_params", 20)
    for j=1,16 do
        params:add{ type = "number", id= (self.type.."_lane_"..self.lane.."_pattern_num_"..self.pattern_num.."_step_mute_"..j),
                    name = ("step mute "..j), min = 0, max = 1,
                    default = self.step_mute[j],
                    action = function(x) self.step_mute[j] = x end
        }
    end
    params:add{ type = "number", id= (self.type.."_lane_"..self.lane.."_pattern_num_"..self.pattern_num.."_range_min_A"), name = ("range min A"), min = 1, max = 16,
        default = self.range.minA,
        action = function(x)
            self.range.minA = x
        end
    }
    params:add{ type = "number", id= (self.type.."_lane_"..self.lane.."_pattern_num_"..self.pattern_num.."_range_max_A"), name = ("range max A"), min = 1, max = 16,
        default = self.range.maxA,
        action = function(x)
            self.range.maxA = x
        end
    }
    params:add{ type = "number", id= (self.type.."_lane_"..self.lane.."_pattern_num_"..self.pattern_num.."_range_min_B"), name = ("range min B"), min = 1, max = 16,
        default = self.range.minB,
        action = function(x)
            self.range.minB = x
        end
    }
    params:add{ type = "number", id= (self.type.."_lane_"..self.lane.."_pattern_num_"..self.pattern_num.."_range_max_B"), name = ("range max B"), min = 1, max = 16,
        default = self.range.maxB,
        action = function(x)
            self.range.maxB = x
        end
    }
    params:hide(self.type.."_lane_"..self.lane.."_pattern_num_"..self.pattern_num.."_hidden_range_params")
end

function pattern:set_step_mute(step, val)
    params:set(self.type.."_lane_"..self.lane.."_pattern_num_"..self.pattern_num.."_step_mute_"..step, val)
end

function pattern:toggle_step_mute(step)
    local val = self.step_mute[step] == 1 and 0 or 1
    params:set(self.type.."_lane_"..self.lane.."_pattern_num_"..self.pattern_num.."_step_mute_"..step, val)
end

function pattern:clear_step(step)
    self:toggle_step_mute(step)
end

function pattern:unmute_step(step)
    self:set_step_mute(step, 0)
end

function pattern:static()
    for i=1,16 do
        --self:set_step_data(i, 0)
        self:set_step_mute(i, 0)
    end
end

function pattern:set_range_data(min, max, x)
    params:set(self.type.."_lane_"..self.lane.."_pattern_num_"..self.pattern_num.."_range_min_"..x, min)
    params:set(self.type.."_lane_"..self.lane.."_pattern_num_"..self.pattern_num.."_range_max_"..x, max)
end

return pattern