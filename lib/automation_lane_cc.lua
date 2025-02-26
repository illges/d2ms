---@diagnostic disable: undefined-global, lowercase-global

local automation_lane = include 'lib/automation_lane'
local config = include 'lib/config/cc_slots'
--local pattern = include 'lib/pattern_cc'

local automation_lane_cc = {}
automation_lane_cc.__index = automation_lane_cc
setmetatable(automation_lane_cc, automation_lane)

function automation_lane_cc.new(id, page)
    local self = setmetatable(automation_lane.new(id, page, "cc", "channel_"..page), automation_lane_cc)
    self.active = config[page][id].active and 1 or 0
    self.velocity_mode = config[page][id].velocity and 1 or 0
    self.hide_position = 0
    self.cc_number = config[page][id].cc_number
    self.extra_params = 4
    self:add_params()
    return self
end

function automation_lane_cc:data(x)
    if x == nil then
        return self.pattern[self.active_pattern].data
    else
        return self.pattern[self.active_pattern].data[x]
    end
end

function automation_lane_cc:minimum()
    return self.pattern[self.active_pattern].minimum
end

function automation_lane_cc:maximum()
    return self.pattern[self.active_pattern].maximum
end

function automation_lane_cc:threshold()
    return self.pattern[self.active_pattern].threshold
end

function automation_lane_cc:set_step_data(step, val)
    self.pattern[self.active_pattern]:set_step_data(step, val)
end

function automation_lane_cc:ascending()
    self.pattern[self.active_pattern]:ascending()
end

function automation_lane_cc:descending()
    self.pattern[self.active_pattern]:descending()
end

function automation_lane_cc:random()
    self.pattern[self.active_pattern]:random()
end

function automation_lane_cc:triangle_asc()
    self.pattern[self.active_pattern]:triangle_asc()
end

function automation_lane_cc:triangle_desc()
    self.pattern[self.active_pattern]:triangle_desc()
end

function automation_lane_cc:scatter_asc()
    self.pattern[self.active_pattern]:scatter_asc()
end

function automation_lane_cc:scatter_desc()
    self.pattern[self.active_pattern]:scatter_desc()
end

function automation_lane_cc:fill_low_high()
    self.pattern[self.active_pattern]:fill_split(0,127)
end

function automation_lane_cc:fill_low_high_alt()
    self.pattern[self.active_pattern]:fill_split_alt(0,127)
end

function automation_lane_cc:fill_low_mid()
    self.pattern[self.active_pattern]:fill_split(0,64)
end

function automation_lane_cc:fill_low_mid_alt()
    self.pattern[self.active_pattern]:fill_split_alt(0,64)
end

function automation_lane_cc:fill_mid_high()
    self.pattern[self.active_pattern]:fill_split(64,127)
end

function automation_lane_cc:fill_mid_high_alt()
    self.pattern[self.active_pattern]:fill_split_alt(64,127)
end

function automation_lane_cc:fill_narrow_high()
    self.pattern[self.active_pattern]:fill_narrow_high()
end

function automation_lane_cc:fill_narrow_low()
    self.pattern[self.active_pattern]:fill_narrow_low()
end

function automation_lane_cc:fill_low()
    self.pattern[self.active_pattern]:fill_low()
end

function automation_lane_cc:fill_mid()
    self.pattern[self.active_pattern]:fill_mid()
end

function automation_lane_cc:fill_high()
    self.pattern[self.active_pattern]:fill_high()
end

function automation_lane_cc:clear_step(step)
    self.pattern[self.active_pattern]:clear_step(step)
end

function automation_lane_cc:nudge_pattern(dir)
    self.pattern[self.active_pattern]:nudge_pattern(dir, self:range_min(), self:range_max())
    self.position = util.wrap(self.position + dir, self:range_min(), self:range_max())
    return self.position
end

function automation_lane_cc:add_params()
    local group_length = self.generic_params_count + self.extra_params
    params:add_group(self.name.." lane "..self.id, group_length)
    self:add_params_main()
    self:add_params_generic()
    params:hide(self.name.." lane "..self.id)
end

function automation_lane_cc:add_params_main()
    params:add{ type = "number", id= (self.name.."_lane_"..self.id.."_cc_number"),
                name = ("cc number"), min = 0, max = 127,
                default = self.cc_number,
                action = function(x) self.cc_number = x end
    }
    params:add{ type = "number", id= (self.name.."_lane_"..self.id.."_active"),
                name = ("active"), min = 0, max = 1,
                default = self.active,
                action = function(x) self.active = x end
    }
    params:add{ type = "number", id= (self.name.."_lane_"..self.id.."_velocity_mode"),
                name = ("velocity mode"), min = 0, max = 1,
                default = self.velocity_mode,
                action = function(x) self.velocity_mode = x end
    }
    params:add{ type = "number", id= (self.name.."_lane_"..self.id.."_hide_position"),
                name = ("hide position"), min = 0, max = 1,
                default = self.hide_position,
                action = function(x) self.hide_position = x end
    }
end

function automation_lane_cc:set_active()
    local val = self.active == 1 and 0 or 1
    params:set(self.name.."_lane_"..self.id.."_active", val)
end

function automation_lane_cc:set_active_direct(val)
    params:set(self.name.."_lane_"..self.id.."_active", val)
end

function automation_lane_cc:set_hide_position()
    local val = self.hide_position == 1 and 0 or 1
    params:set(self.name.."_lane_"..self.id.."_hide_position", val)
end

function automation_lane_cc:set_velocity_mode()
    local val = self.velocity_mode == 1 and 0 or 1
    params:set(self.name.."_lane_"..self.id.."_velocity_mode", val)
end

function automation_lane_cc:set_velocity_mode_direct(val)
    params:set(self.name.."_lane_"..self.id.."_velocity_mode", val)
end

function automation_lane_cc:set_cc_number(d)
    local val = util.clamp(self.cc_number + d, 0, 127)
    params:set(self.name.."_lane_"..self.id.."_cc_number", val)
end

function automation_lane_cc:set_cc_number_direct(val)
    params:set(self.name.."_lane_"..self.id.."_cc_number", val)
end

return automation_lane_cc