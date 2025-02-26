---@diagnostic disable: undefined-global, lowercase-global

local automation_lane = include 'lib/automation_lane'

local automation_lane_pattern = {}
automation_lane_pattern.__index = automation_lane_pattern
setmetatable(automation_lane_pattern, automation_lane)

function automation_lane_pattern.new(id, page, type, name)
    local self = setmetatable(automation_lane.new(id, page, type, name), automation_lane_pattern)
    self.extra_params = 0
    return self
end

function automation_lane_pattern:check_play_step(step)
    if self.pattern[self.active_pattern].step_mute[step] == 1 then return false
    else return true end
end

function automation_lane_pattern:step_mute(x)
    return self.pattern[self.active_pattern].step_mute[x]
end

function automation_lane_pattern:clear_step(step)
    self.pattern[self.active_pattern]:clear_step(step)
end

function automation_lane_pattern:unmute_step(step)
    self.pattern[self.active_pattern]:unmute_step(step)
end

function automation_lane_pattern:static()
    self.pattern[self.active_pattern]:static()
end

function automation_lane_pattern:add_params()
    local group_length = self.generic_params_count + self.extra_params
    params:add_group(self.name.." lane "..self.id, group_length)
    self:add_params_generic()
    params:hide(self.name.." lane "..self.id)
end

function automation_lane_pattern:adv_strum_position()
    if self:random_step() == 1 then self.strum_position = math.random(self:range_min(), self:range_max())
    else
        self.strum_position = self.strum_position + self:direction()
        if self:step_mute(self.strum_position) == 1 then
            self:adv_strum_position()
        end
    end
    self.strum_light = self.strum_position
    self:clamp_position(true)
    self:check_ping_pong()
end

function automation_lane_pattern:adv_lane_position(direction)
    local min = self:range_min()
    local max = self:range_max()
    local clamp_all = false
    if min == max then
        min = 1
        max = 16
        clamp_all = true
    end
    if self:random_step() == 1 and dir == nil then self.position = math.random(min, max)
    else
        local dir = direction == nil and self:direction() or direction
        self.position = self.position + dir
    end
    if clamp_all then
        if direction == nil then
            self:clamp_all()
        else
            self:clamp_all_manual()
        end
    else
        if direction == nil then
            self:clamp_position()
            self:check_ping_pong()
        else
            self:clamp_position_manual()
        end
    end
    if self:step_mute(self.position) == 1 then
        self:adv_lane_position(direction)
    end
end

function automation_lane_pattern:clamp_position_manual()
    local min = self:range_min()
    local max = self:range_max()
    local position = self.position
    if (position < min) then
        self:set_position(max)
    elseif (position > max) then
        self:set_position(min)
    end
end

function automation_lane_pattern:clamp_all()
    local min = 1
    local max = 16
    if (self.position < min) or (self.position > max) then
        if self:direction() == 1 then
            self:set_position(min)
        else
            self:set_position(max)
        end
    end
    self:set_range_data(self.position, self.position)
end

function automation_lane_pattern:clamp_all_manual()
    local min = 1
    local max = 16
    if self.position < min then
        self:set_position(max)
    elseif self.position > max then
        self:set_position(min)
    end
    self:set_range_data(self.position, self.position)
end

function automation_lane_pattern:adv_chain(pattern)
    local new_min = pattern>0 and pattern or self:find_next_unmuted()
    if self:range_min() == new_min then return end
    if new_min + self:length() - 1 > 16 then new_min = 1 end
    self:set_range_data(new_min, new_min + self:length() -1)
end

function automation_lane_pattern:find_next_unmuted()
    if self:random_step() == 1 then
        local unmuted = {}
        for i=1,16 do
            if self:step_mute(i)==0 then table.insert(unmuted, i) end
        end
        return unmuted[math.random(#unmuted)]
    elseif self:direction() == 1 then
        for i=self:range_max()+1,16 do
            if self:step_mute(i)==0 then
                return i
            end
        end
        for j=1,self:range_min()-1 do
            if self:step_mute(j)==0 then
                return j
            end
        end
    elseif self:direction() == -1 then
        for j=self:range_min()-self:length(),1,-1 do
            if self:step_mute(j)==0 then
                return j
            end
        end
        for i=16-self:length()+1,self:range_max()+1,-1 do
            if self:step_mute(i)==0 then
                return i
            end
        end
    end
    return self:range_min()
end

return automation_lane_pattern

