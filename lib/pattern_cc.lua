---@diagnostic disable: undefined-global, lowercase-global

local pattern = include 'lib/pattern'

local cc_pattern = {}
cc_pattern.__index = cc_pattern
setmetatable(cc_pattern, pattern)

function cc_pattern.new(type, lane, pattern_num)
    local self = setmetatable(pattern.new(type, lane, pattern_num), cc_pattern)
    self.minimum = 0
    self.maximum = 127
    self.threshold = 8
    self.data = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    self:add_pattern_params()
    return self
end

function cc_pattern:add_pattern_params()
    params:add_group(self.type.."_lane_"..self.lane.."_pattern_num_"..self.pattern_num.."_hidden_step_params", 16)
    for j=1,16 do
        params:add{ type = "number", id= (self.type.."_lane_"..self.lane.."_pattern_num_"..self.pattern_num.."_value_"..j),
                    name = ("data "..j), min = self.minimum, max = self.maximum,
                    default = self.data[j],
                    action = function(x) self.data[j] = x end
        }
    end
    params:hide(self.type.."_lane_"..self.lane.."_pattern_num_"..self.pattern_num.."_hidden_step_params")
end

function cc_pattern:set_step_data(step, val)
    params:set(self.type.."_lane_"..self.lane.."_pattern_num_"..self.pattern_num.."_value_"..step, val)
end

function cc_pattern:ascending()
    local val
    for i=1,16 do
        val = self.minimum + (self.threshold*(i-1))
        self:set_step_data(i, val)
    end
end

function cc_pattern:descending()
    local val
    for i=1,16 do
        val = self.maximum - (self.threshold*(i-1))
        self:set_step_data(i, val)
    end
end

function cc_pattern:random()
    local val
    for i=1,16 do
        val = self.maximum - (self.threshold*(math.random(1,16)-1))
        self:set_step_data(i, val)
    end
end

function cc_pattern:triangle_asc()
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

function cc_pattern:triangle_desc()
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

function cc_pattern:scatter_asc()
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

function cc_pattern:scatter_desc()
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

function cc_pattern:fill_split(low, high)
    for i=1,8 do
        self:set_step_data(i, low)
    end
    for i=9,16 do
        self:set_step_data(i, high)
    end
end

function cc_pattern:fill_split_alt(low, high)
    for i=1,16 do
        if (i % 2 == 0) then
            self:set_step_data(i, high)
        else
            self:set_step_data(i, low)
        end
    end
end

function cc_pattern:fill_narrow_high()
    local val
    for i=1,16 do
        val = 64 + (self.threshold*(i-1)/2)
        self:set_step_data(i, math.floor(val+0.5))
    end
end

function cc_pattern:fill_narrow_low()
    local val
    for i=1,16 do
        val = self.minimum + (self.threshold*(i-1)/2)
        self:set_step_data(i, math.floor(val+0.5))
    end
end

function cc_pattern:fill_low()
    for i=1,16 do
        self:set_step_data(i, 0)
    end
end

function cc_pattern:fill_mid()
    for i=1,16 do
        self:set_step_data(i, 64)
    end
end

function cc_pattern:fill_high()
    for i=1,16 do
        self:set_step_data(i, 127)
    end
end

function cc_pattern:clear_step(step)
    --local val = params:get(self.parameter)
    self:set_step_data(step, 0)
end

function pattern:nudge_pattern(dir, min, max)
    local temp = {}
    local temp_mutes = {}
    for i=min,max do
        temp[i] = self.data[i]
        temp_mutes[i] = self.step_mute[i]
    end
    if dir==1 then
        self:set_step_data(min, temp[max])
        self:set_step_mute(min, temp_mutes[max])
        for j=min+1,max do
            self:set_step_data(j, temp[j-1])
            self:set_step_mute(j, temp_mutes[j-1])
        end
    else
        self:set_step_data(max, temp[min])
        self:set_step_mute(max, temp_mutes[min])
        for j=min,max-1 do
            self:set_step_data(j, temp[j+1])
            self:set_step_mute(j, temp_mutes[j+1])
        end
    end
end

return cc_pattern