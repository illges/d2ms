---@diagnostic disable: undefined-global, lowercase-global

local automation_lane = include 'lib/automation_lane'
local automation_lane_pattern = include 'lib/automation_lane_pattern'
--local pattern = include 'lib/pattern_note'

local automation_lane_note = {}
automation_lane_note.__index = automation_lane_note
setmetatable(automation_lane_note, automation_lane)

function automation_lane_note.new(id, page, pool)
    local self = setmetatable(automation_lane.new(id, page, "note", "note"), automation_lane_note)
    self.filter_send = id
    self.release_send = id
    self.pan_send = id
    self.pw_send = id
    self.strum_clock_id = id
    self.destination = "combo"
    self.extra_params = 7
    self.prev_note = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0} -- prev_note[channel]
    self.preserve_density = 0
    self.pattern_chaining = 0
    self.riff_lane_active = 0
    self.prev_position = self.position
    self.prev_pattern = self.active_pattern
    self.prev_strum_position = self.position
    self.prev_strum_pattern = self.active_pattern

    self.seq_types_list = {"note","riff","chord"}
    self.seq_type = "note"
    self.seq_type_num = 1
    for i=1,16 do
        self.pattern[i]:random(pool)
    end
    self.pattern_lane = automation_lane_pattern.new(id, page, "pattern", "pattern")
    self:add_params()
    return self
end

function automation_lane_note:data(x,p)
    p = p~=nil and p or self.active_pattern
    if self:riff_lane() then
        if x==nil then return self.pattern[p].interval[self.position]
        else return self.pattern[p].interval[x]
        end
    elseif self:chord_lane() then
        if x==nil then return self.pattern[p].chord[self.position]
        else return self.pattern[p].chord[x]
        end
    else
        if x==nil then return self.pattern[p].data[self.position]
        else return self.pattern[p].data[x]
        end
    end
end

function automation_lane_note:strum_data(x)
    --print("pat: "..self.strum_pattern.." step: "..x)
    if self:riff_lane() then
        return self.pattern[self.strum_pattern].interval[x]
    elseif self:chord_lane() then
        return self.pattern[self.strum_pattern].chord[x]
    end
    return self.pattern[self.strum_pattern].data[x]
end

function automation_lane_note:step_lock(x)
    return self.pattern[self.active_pattern].step_lock[x]
end

function automation_lane_note:note_lane()
    return self.seq_type == "note"
end

function automation_lane_note:riff_lane()
    return self.seq_type == "riff"
end

function automation_lane_note:chord_lane()
    return self.seq_type == "chord"
end

function automation_lane_note:check_play_step(step)
    if self.pattern[self.active_pattern].data[step] == 0 then return false
    elseif self.pattern[self.active_pattern].step_mute[step] == 1 then return false
    else return true end
end

function automation_lane_note:set_step_data(step, val)
    if self:riff_lane() then
        self.pattern[self.active_pattern]:set_step_interval(step, val)
    elseif self:chord_lane() then
        self.pattern[self.active_pattern]:set_step_chord(step, val)
    else
        self.pattern[self.active_pattern]:set_step_data(step, val)
    end
end

function automation_lane_note:toggle_step_mute(step)
    self.pattern[self.active_pattern]:toggle_step_mute(step)
end

function automation_lane_note:toggle_step_lock(step)
    self.pattern[self.active_pattern]:toggle_step_lock(step)
end

function automation_lane_note:ascending(pool)
    self.pattern[self.active_pattern]:ascending(pool)
end

function automation_lane_note:descending(pool)
    self.pattern[self.active_pattern]:descending(pool)
end

function automation_lane_note:scatter_asc(pool)
    self.pattern[self.active_pattern]:scatter_asc(pool)
end

function automation_lane_note:scatter_desc(pool)
    self.pattern[self.active_pattern]:scatter_desc(pool)
end

function automation_lane_note:triangle_asc(pool)
    self.pattern[self.active_pattern]:triangle_asc(pool)
end

function automation_lane_note:triangle_desc(pool)
    self.pattern[self.active_pattern]:triangle_desc(pool)
end

function automation_lane_note:spiral(pool)
    self.pattern[self.active_pattern]:spiral(pool)
end

function automation_lane_note:clear_step(step)
    self.pattern[self.active_pattern]:clear_step(step)
end

function automation_lane_note:random(pool)
    self.pattern[self.active_pattern]:random(pool, self.preserve_density)
end

function automation_lane_note:static()
    self.pattern[self.active_pattern]:static()
end

function automation_lane_note:octave_down(step)
    self.pattern[self.active_pattern]:octave_down(step)
end

function automation_lane_note:octave_up(step)
    self.pattern[self.active_pattern]:octave_up(step)
end

function automation_lane_note:piano_scatter_asc(pool)
    self.pattern[self.active_pattern]:piano_scatter_asc(pool)
end

function automation_lane_note:piano_scatter_desc(pool)
    self.pattern[self.active_pattern]:piano_scatter_desc(pool)
end

function automation_lane_note:piano_triangle(pool, dir)
    self.pattern[self.active_pattern]:piano_triangle(pool, dir)
end

function automation_lane_note:nudge_pattern(dir)
    self.pattern[self.active_pattern]:nudge_pattern(dir, self:range_min(), self:range_max())
    self.position = util.wrap(self.position + dir, self:range_min(), self:range_max())
    return self.position
end

function automation_lane_note:add_params()
    self:add_params_main()
    self:add_params_hidden()
end

function automation_lane_note:add_params_hidden()
    local group_length = self.generic_params_count + 2
    params:add_group(self.name.." lane "..self.id.." hidden", group_length)
    params:add{
        type = "number", id = (self.type.."_lane_"..self.id.."_riff_lane"),
        name = ("riff lane"),
        min = 0, max = 1,
        default = self.riff_lane_active,
        action = function(x) self.riff_lane_active = x end
    }
    params:add{ type = "number", id= (self.type.."_lane_"..self.id.."_preserve_density"),
        name = ("preserve empty"), min = 0, max = 1,
        default = self.preserve_density,
        action = function(x) self.preserve_density = x end
    }
    -- params:add{ type = "number", id= (self.type.."_lane_"..self.id.."_active_pattern"),
    --     name = ("active pattern"), min = 0, max = 16,
    --     default = self.active_pattern,
    --     action = function(x) self.active_pattern = x end
    -- }
    self:add_params_generic()
    params:hide(self.name.." lane "..self.id.." hidden")
end

function automation_lane_note:add_params_main()
    params:add_group(self.name.." lane "..self.id, 6)
    params:add{
        type = "option", id = (self.type.."_lane_"..self.id.."_destination"), name = ("output"),
        options = {"combo", "midi", "engine"}, default = 1,
        action = function(x) self.destination = x end
    }
    params:add{ type = "number", id= (self.type.."_lane_"..self.id.."_filter_send"),
        name = ("filter send"), min = 1, max = 16,
        default = self.filter_send,
        action = function(x) self.filter_send = x end
    }
    params:add{ type = "number", id= (self.type.."_lane_"..self.id.."_release_send"),
        name = ("release send"), min = 1, max = 16,
        default = self.release_send,
        action = function(x) self.release_send = x end
    }
    params:add{ type = "number", id= (self.type.."_lane_"..self.id.."_pan_send"),
        name = ("pan send"), min = 1, max = 16,
        default = self.pan_send,
        action = function(x) self.pan_send = x end
    }
    params:add{ type = "number", id= (self.type.."_lane_"..self.id.."_pw_send"),
        name = ("pw send"), min = 1, max = 16,
        default = self.pw_send,
        action = function(x) self.pw_send = x end
    }
    params:add{
        type = "option", id = (self.type.."_lane_"..self.id.."_seq_type"),
        name = ("seq type"),
        options = self.seq_types_list,
        default = self.seq_type_num,
        action = function(x)
            self.seq_type_num = x
            self.seq_type = self.seq_types_list[x]
        end
    }
end

function automation_lane_note:set_seq_type(d)
    local val = util.wrap(self.seq_type_num + d,1,#self.seq_types_list)
    params:set(self.type.."_lane_"..self.id.."_seq_type", val)
end

function automation_lane_note:toggle_riff_lane()
    local val = self.riff_lane_active == 1 and 0 or 1
    params:set(self.type.."_lane_"..self.id.."_riff_lane", val)
end

function automation_lane_note:set_active_pattern(val)
    params:set(self.type.."_lane_"..self.id.."_active_pattern", val)
end

function automation_lane_note:set_preserve_density()
    local val = self.preserve_density == 0 and 1 or 0
    params:set(self.type.."_lane_"..self.id.."_preserve_density", val)
end

function automation_lane_note:set_filter_send_data(val)
    params:set(self.type.."_lane_"..self.id.."_filter_send", val)
end

function automation_lane_note:set_release_send_data(val)
    params:set(self.type.."_lane_"..self.id.."_release_send", val)
end

function automation_lane_note:set_pan_send_data(val)
    params:set(self.type.."_lane_"..self.id.."_pan_send", val)
end

function automation_lane_note:set_pw_send_data(val)
    params:set(self.type.."_lane_"..self.id.."_pw_send", val)
end

function automation_lane_note:advance_pattern_seq(direction)
    self.prev_pattern = self.active_pattern
    self.pattern_lane:adv_lane_position(direction)
    self.active_pattern = self.pattern_lane.position
    self.position = self:range_min()
    self:set_pattern(self.active_pattern)
    self.reset_flag = 1
end

function automation_lane_note:advance_strum_pattern_seq()
    self.pattern_lane:adv_strum_position() -- this function call is to the automation_lane base class
    self.strum_pattern = self.pattern_lane.strum_position
    self.strum_position = self:range_min(self.strum_pattern)
end

function automation_lane_note:update_active_pattern(x)
    self.pattern_lane.position = x
    self.active_pattern = self.pattern_lane.position
    self.position = self:range_min()
    self:set_pattern(self.active_pattern)
    if x < self.pattern_lane:range_min() or
       x > self.pattern_lane:range_max() then
            self.pattern_lane:set_range_data(x, x)
    end
end

function automation_lane_note:adv_lane_position()
    self.prev_position = self.position
    self.prev_pattern = self.active_pattern
    --print(self:range_min(), self:range_max())
    if self:random_step() == 1 then self.position = math.random(self:range_min(), self:range_max())
    else
        if self.strum_active==1 then
            self.position = self.position + self:direction()
        else
            self:set_position(self.position + self:direction())
        end
    end
    self.reset_flag = 1
    self:clamp_position_chaining()
    self:check_ping_pong()
    return self.position
end

function automation_lane_note:adv_strum_position()
    if self:random_step() == 1 then self.strum_position = math.random(self:range_min(self.strum_pattern), self:range_max(self.strum_pattern))
    else self.strum_position = self.strum_position + self:direction()
    end
    self.strum_light = self.strum_position
    self:clamp_position_chaining(true)
    self:check_ping_pong()
end

function automation_lane_note:clamp_position_chaining(strum)
    local min = strum and self:range_min(self.strum_pattern) or self:range_min()
    local max = strum and self:range_max(self.strum_pattern) or self:range_max()
    local position = strum and self.strum_position or self.position
    if (position < min) or (position > max) then
        if self:direction() == 1 then
            if strum then
                self.strum_position = min
            else
                self:set_position(min)
            end
        else
            if strum then
                self.strum_position = max
            else
                self:set_position(max)
            end
        end
        if self.pattern_chaining == 1 then
            if strum then
                self:advance_strum_pattern_seq()
            else
                self:advance_pattern_seq()
            end
        end
    end
end

return automation_lane_note