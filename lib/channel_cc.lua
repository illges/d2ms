---@diagnostic disable: undefined-global, lowercase-global
local automation_lane_cc = include 'lib/automation_lane_cc'
local automation_lane_engine = include 'lib/automation_lane_engine'

local channel_cc = {}
channel_cc.__index = channel_cc

function channel_cc.new(channel)
    local self = setmetatable({}, channel_cc)
    self.channel = channel
    self.engine_active = 0
    self.lane = {}
    for i=1,16 do
        table.insert(self.lane, automation_lane_cc.new(i, channel))
        self.lane[i]:ascending()
    end
    self:add_params_hidden()
    return self
end

function channel_cc:any_active_lane()
    for slot=1,16 do
        if self.lane[slot].active == 1 then
            return true
        end
    end
end

function channel_cc:add_params_hidden()
    params:add_group("channel "..self.channel, 1)

    params:add{
        type = "number", id = ("channel_"..self.channel.."_engine_active"),
        name = ("engine active"),
        min = 0, max = 1,
        default = self.engine_active,
        action = function(x) self.engine_active = x end
    }

    params:hide("channel "..self.channel)
end

function channel_cc:invert_engine_active()
    params:set("channel_"..self.channel.."_engine_active", 1 - self.engine_active)
end

return channel_cc