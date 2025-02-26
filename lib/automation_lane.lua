---@diagnostic disable: undefined-global, lowercase-global

local pattern_note = include 'lib/pattern_note'
local pattern_cc = include 'lib/pattern_cc'
local pattern_engine = include 'lib/pattern_engine'
local pattern = include 'lib/pattern'

local automation_lane = {}
automation_lane.__index = automation_lane

function automation_lane.new(id, page, type, name, parameter, threshold, minimum, maximum, channel)
    local self = setmetatable({}, automation_lane)
    self.id = id
    self.page = page
    self.type = type
    self.name = name
    self.generic_params_count = 10
    self.range = {}
    self.reset_flag = 0
    self.b_section = 0
    self.position = 1
    self.strum_position = 1
    self.strum_light = 0
    self.strum_pattern = 1
    self.strum_active = 0
    self.chord_strum_active = 0
    self.prime_ab = false
    self.pattern_chaining = 0
    self.active_pattern = 1
    self.pattern = {}
    -- logic called in abstract lane class due to range_min/max getters use the table of patterns
    if self.type == "note" then
        for i=1,16 do
            table.insert(self.pattern, pattern_note.new(self.type,id,i))
        end
    elseif self.type == "cc" then
        table.insert(self.pattern, pattern_cc.new(self.name,id,1))
    elseif self.type == "pattern" or self.type == "patch" or self.type == "scene" then
        table.insert(self.pattern, pattern.new(self.type,id,1))
        for j=2,16 do
            self.pattern[1]:set_step_mute(j, 1)
        end
    elseif self.type == "engine" then
        table.insert(self.pattern, pattern_engine.new(self.name,id,1, parameter, threshold, minimum, maximum, channel))
    end

    --treat as private properties
    self.directionA = 1
    self.ping_pongA = 0
    self.ping_pong_2A = 0
    self.random_stepA = 0

    self.directionB = 1
    self.ping_pongB = 0
    self.ping_pong_2B = 0
    self.random_stepB = 0

    self.vel_floor = 0
    self.vel_ceiling = 127
    self.vel_window = 127
    self.vel_step_thresh = 8
    return self
end

function automation_lane:set_position(val)
    self.position = val
    self.strum_position = val
end

function automation_lane:reset_position()
    self.position = self:range_min()
    self.strum_position = self:range_min()
end

function automation_lane:set_pattern(val)
    self.strum_pattern = val
    self.active_pattern = val
    self.pattern_lane.strum_position = val
    self.pattern_lane.position = val
end

function automation_lane:next_step()
    return util.wrap(self.position+self:direction(), self:range_min(), self:range_max())
end

function automation_lane:step_mute(x)
    return self.pattern[self.active_pattern].step_mute[x]
end

function automation_lane:set_step_mute(step, val)
    self.pattern[self.active_pattern]:set_step_mute(step, val)
end

function automation_lane:range_min(ptrn)
    ptrn = ptrn and ptrn or self.active_pattern
    return self.b_section == 0 and self.pattern[ptrn].range.minA or self.pattern[ptrn].range.minB
end

function automation_lane:range_max(ptrn)
    ptrn = ptrn and ptrn or self.active_pattern
    return self.b_section == 0 and self.pattern[ptrn].range.maxA or self.pattern[ptrn].range.maxB
end

function automation_lane:length()
    return self:range_max() - self:range_min() + 1
end

function automation_lane:direction()
    return self.b_section == 0 and self.directionA or self.directionB
end

function automation_lane:random_step()
    return self.b_section == 0 and self.random_stepA or self.random_stepB
end

function automation_lane:ping_pong()
    return self.b_section == 0 and self.ping_pongA or self.ping_pongB
end

function automation_lane:ping_pong_2()
    return self.b_section == 0 and self.ping_pong_2A or self.ping_pong_2B
end

function automation_lane:log_instance()
    print("***log lane instance***")
    tab.print(self.data)
    print("position : "..self.position)
    print("range.min : "..self:range_min())
    print("range.max : "..self:range_max())
    print("direction : "..self:direction())
    print("ping_pong : "..self:ping_pong())
    print("***********************")
end

function automation_lane:add_params_generic()
    params:add{ type = "number", id= (self.name.."_lane_"..self.id.."_b_section"), name = ("b section"), min = 0, max = 1,
        default = self.b_section,
        action = function(x)
            self.b_section = x
        end
    }
    params:add{ type = "number", id= (self.name.."_lane_"..self.id.."_direction_A"), name = ("direction A"), min = -1, max = 1,
        default = self.directionA,
        action = function(x)
            self.directionA = x
        end
    }
    params:add{ type = "number", id= (self.name.."_lane_"..self.id.."_direction_B"), name = ("direction B"), min = -1, max = 1,
        default = self.directionB,
        action = function(x)
            self.directionB = x
        end
    }
    params:add{ type = "number", id= (self.name.."_lane_"..self.id.."_ping_pong_A"), name = ("ping pong 1A"), min = 0, max = 1,
        default = self.ping_pongA,
        action = function(x)
            self.ping_pongA = x
        end
    }
    params:add{ type = "number", id= (self.name.."_lane_"..self.id.."_ping_pong_2_A"), name = ("ping pong 2A"), min = 0, max = 1,
        default = self.ping_pong_2A,
        action = function(x)
            self.ping_pong_2A = x
        end
    }
    params:add{ type = "number", id= (self.name.."_lane_"..self.id.."_ping_pong_B"), name = ("ping pong 1B"), min = 0, max = 1,
        default = self.ping_pongB,
        action = function(x)
            self.ping_pongB = x
        end
    }
    params:add{ type = "number", id= (self.name.."_lane_"..self.id.."_ping_pong_2_B"), name = ("ping pong 2B"), min = 0, max = 1,
        default = self.ping_pong_2B,
        action = function(x)
            self.ping_pong_2B = x
        end
    }
    params:add{ type = "number", id= (self.name.."_lane_"..self.id.."_random_step_A"), name = ("random step A"), min = 0, max = 1,
        default = self.random_stepA,
        action = function(x)
            self.random_stepA = x
        end
    }
    params:add{ type = "number", id= (self.name.."_lane_"..self.id.."_random_step_B"), name = ("random step B"), min = 0, max = 1,
        default = self.random_stepB,
        action = function(x)
            self.random_stepB = x
        end
    }
    params:add{ type = "number", id= (self.name.."_lane_"..self.id.."_pattern_chaining"), name = ("pattern chaining"), min = 0, max = 1,
        default = self.pattern_chaining,
        action = function(x)
            self.pattern_chaining = x
        end
    }
end

function automation_lane:set_range_data(min, max)
    local x = self.b_section == 0 and 'A' or 'B'
    self.pattern[self.active_pattern]:set_range_data(min, max, x)
    self:clamp_position()
end

function automation_lane:invert_b_section()
    if self.strum_active == 1 then
        self.prime_ab = true
        return false
    end
    local val = self.b_section == 0 and 1 or 0
    params:set(self.name.."_lane_"..self.id.."_b_section", val)
    local position = self:direction() > 0 and self:range_min() or self:range_max()
    self:set_position(position)
    self.reset_flag = 1
    return true
end

function automation_lane:get_vel_step_threshold(vel_floor, vel_ceiling)
    if vel_floor and vel_ceiling then
        self.vel_floor = vel_floor
        self.vel_ceiling = vel_ceiling
        self.vel_window = vel_ceiling - vel_floor
    end
    self.vel_step_thresh = util.clamp(math.floor((self.vel_window/self:length())+0.5),1,127)
    return self.vel_step_thresh
end

function automation_lane:invert_direction()
    local val = self:direction() == -1 and 1 or -1
    local X = self.b_section == 0 and "A" or "B"
    params:set(self.name.."_lane_"..self.id.."_direction_"..X, val)
end

function automation_lane:set_direction(val)
    local X = self.b_section == 0 and "A" or "B"
    params:set(self.name.."_lane_"..self.id.."_direction_"..X, val)
end

function automation_lane:invert_ping_pong()
    local X = self.b_section == 0 and "A" or "B"
    local random_step = 0
    local ping_pong_2 = 0
    local ping_pong = 1 - self:ping_pong()
    self:check_ping_pong()
    params:set(self.name.."_lane_"..self.id.."_ping_pong_"..X, ping_pong)
    params:set(self.name.."_lane_"..self.id.."_ping_pong_2_"..X, ping_pong_2)
    params:set(self.name.."_lane_"..self.id.."_random_step_"..X, random_step)
end

function automation_lane:invert_ping_pong_2()
    local X = self.b_section == 0 and "A" or "B"
    local random_step = 0
    local ping_pong = 0
    local ping_pong_2 = 1 - self:ping_pong_2()
    if ping_pong_2 == 0 then
        if self.position == self:range_min() or self.position == self:range_max() then
            self:set_direction(1)
        end
    else
        self:check_ping_pong_2()
    end
    params:set(self.name.."_lane_"..self.id.."_ping_pong_"..X, ping_pong)
    params:set(self.name.."_lane_"..self.id.."_ping_pong_2_"..X, ping_pong_2)
    params:set(self.name.."_lane_"..self.id.."_random_step_"..X, random_step)
end

function automation_lane:invert_random_step()
    local X = self.b_section == 0 and "A" or "B"
    local ping_pong_2 = 0
    local ping_pong = 0
    local random_step = 1 - self:random_step()
    params:set(self.name.."_lane_"..self.id.."_ping_pong_"..X, ping_pong)
    params:set(self.name.."_lane_"..self.id.."_ping_pong_2_"..X, ping_pong_2)
    params:set(self.name.."_lane_"..self.id.."_random_step_"..X, random_step)
end

function automation_lane:set_pattern_chaining(val)
    params:set(self.name.."_lane_"..self.id.."_pattern_chaining", val)
end

function automation_lane:clamp_position(strum)
    local min = self:range_min()
    local max = self:range_max()
    local position = strum and self.strum_position or self.position
    if (position < min) or (position > max) then
        if self:direction() == 1 then
            if strum then self.strum_position = min else self:set_position(min) end
        else
            if strum then self.strum_position = max else self:set_position(max) end
        end
    end
end

function automation_lane:check_ping_pong()
    local min = self:range_min()
    local max = self:range_max()
    if self:ping_pong() == 1 then
        if self.position == min then
            self:set_direction(1)
        elseif self.position == max then
            self:set_direction(-1)
        end
    elseif self:ping_pong_2() == 1 then
        self:check_ping_pong_2()
    end
end

function automation_lane:check_ping_pong_2()
    local min = self:range_min()
    local max = self:range_max()
    if (self.position == min or
        self.position == max) and
        self:direction() ~= 0 then
            self:set_direction(0)
    else
        if self.position == min then
            self:set_direction(1)
        elseif self.position == max then
            self:set_direction(-1)
        end
    end
end

function automation_lane:adv_strum_position()
    if self:random_step() == 1 then self.strum_position = math.random(self:range_min(), self:range_max())
    else self.strum_position = self.strum_position + self:direction()
    end
    self.strum_light = self.strum_position
    self:clamp_position(true)
    self:check_ping_pong()
end

function automation_lane:adv_lane_position()
    if self:random_step() == 1 then self.position = math.random(self:range_min(), self:range_max())
    else self.position = self.position + self:direction()
    end
    self.reset_flag = 1
    self:set_position(self.position)
    self:clamp_position()
    self:check_ping_pong()
end

function automation_lane:clear_lane_data()
    for i=1,16 do self.data[i] = nil end
end

return automation_lane