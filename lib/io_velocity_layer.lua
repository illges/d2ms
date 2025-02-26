---@diagnostic disable: undefined-global, lowercase-global

local layer = {}
layer.__index = layer

function layer.new(type)
    local self = setmetatable({}, layer)
    self.ui_clamp = 8
    self.low_thresh = 0
    self.high_thresh = 127
    self.hold_time = 0.1
    self.hold_time_b = 2
    self.hold_inf = 0
    self.hold_time_toggle = 0
    self.invert_velocity = 0
    self.monophonic = 0
    self.lane_send = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    self.prev_note = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0} -- prev_note[channel]
    self.probability = {100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100}
    self.buffered_probability = {100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100}
    self.layer_type = type

    self.gears_block = 0
    self.gears_retrig = 0
    self.range = {}
    self.position = 1
    self.range.min = 1
    self.range.max = 8 -- overridden in machine context using config
    self.round_robin = 1
    self.random_robin = 0
    self.vel_mode = 0
    self.length = self.range.max - self.range.min + 1
    self.reset_mode = 0
    self.one_shot_mode = 0
    self.hold_release_mode = 0
    self.hold_flag = 0
    self.release_flag = 0
    self.meta_seq_one_shots = {1,1,1,1,1,1,1,1}
    self.prev_routing_pos = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
    self.meta_seq_step_mute = {0,0,0,0,0,0,0,0}

    self.vel_window = 127
    self.vel_step_thresh = 16
    return self
end

function layer:get_probability(scene)
    return self.probability[scene]
end

function layer:add_params_velocity()
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_invert_velocity"),
        name = ("invert velocity"),
        min = 0, max = 1,
        default = self.invert_velocity,
        action = function(x) self.invert_velocity = x end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_hold_inf"),
        name = ("infinite hold"),
        min = 0, max = 1,
        default = self.hold_inf,
        action = function(x) self.hold_inf = x end
    }
end

function layer:add_params_hidden_common()
    params:add_group("input"..self.input.." "..self.layer_type.." vel layer "..self.id.." common", 54)
    for k=1,16 do
        params:add{
            type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_lane_send_"..k),
            name = ("lane send "..k),
            min = 0, max = 1,
            default = self.lane_send[k],
            action = function(x) self.lane_send[k] = x end
        }
        if k<=8 then
            params:add{
                type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_meta_seq_step_mute_"..k),
                name = ("meta seq step mute "..k),
                min = 0, max = 1,
                default = self.meta_seq_step_mute[k],
                action = function(x) self.meta_seq_step_mute[k] = x end
            }
        end
    end
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_low_thresh"),
        name = ("low thresh"),
        min = 0, max = 127,
        default = self.low_thresh,
        action = function(x) self.low_thresh = x end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_high_thresh"),
        name = ("high thresh"),
        min = 0, max = 127,
        default = self.high_thresh,
        action = function(x) self.high_thresh = x end
    }
    for i=1,16 do
        params:add{
            type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_scene_"..i.."_probability"),
            name = ("probability"),
            min = 0, max = 100,
            default = self.probability[i],
            action = function(x)
                self.probability[i] = x
                if self.probability[i] > 0 then self.buffered_probability[i] = self.probability[i] end
            end
        }
    end
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_hold_time"),
        name = ("hold time"),
        min = 0.1, max = 10,
        default = self.hold_time,
        action = function(x) self.hold_time = x end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_hold_time_b"),
        name = ("hold time b"),
        min = 0.1, max = 10,
        default = self.hold_time_b,
        action = function(x) self.hold_time_b = x end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_hold_time_toggle"),
        name = ("hold time toggle"),
        min = 0, max = 1,
        default = self.hold_time_toggle,
        action = function(x) self.hold_time_toggle = x end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_monophonic"),
        name = ("monophonic"),
        min = 0, max = 1,
        default = self.monophonic,
        action = function(x) self.monophonic = x end
    }
    params:add{ type = "number", id= ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_fixed_note_range_min"),
        name = ("fixed range min"), min = 1, max = 8,
        default = self.range.min,
        action = function(x)
            self.range.min = x
            self:set_public_properties()
            self:clamp_position()
        end
    }
    params:add{ type = "number", id= ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_fixed_note_range_max"),
        name = ("fixed range max"), min = 1, max = 8,
        default = self.range.max,
        action = function(x)
            self.range.max = x
            self:set_public_properties()
            self:clamp_position()
        end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_round_robin"),
        name = ("round robin"),
        min = 0, max = 1,
        default = self.round_robin,
        action = function(x)
            if x == 1 then
                self:set_random_robin(0)
                self:set_vel_mode(0)
                self:reset_meta_seq()
            end
            self.round_robin = x
        end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_random_robin"),
        name = ("random robin"),
        min = 0, max = 1,
        default = self.random_robin,
        action = function(x)
            if x == 1 then
                self:set_round_robin(0)
                self:set_vel_mode(0)
                self:reset_meta_seq()
            end
            self.random_robin = x
        end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_vel_mode"),
        name = ("vel mode"),
        min = 0, max = 1,
        default = self.vel_mode,
        action = function(x)
            if x == 1 then
                self:set_random_robin(0)
                self:set_round_robin(0)
                self:set_one_shot_mode(0)
                self:set_hold_release_mode(0)
                self:reset_meta_seq()
            end
            self.vel_mode = x
        end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_reset_mode"),
        name = ("reset mode"),
        min = 0, max = 1,
        default = self.reset_mode,
        action = function(x) self.reset_mode = x end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_one_shot_mode"),
        name = ("one shot mode"),
        min = 0, max = 1,
        default = self.one_shot_mode,
        action = function(x)
            if x==1 and self.vel_mode==1 then
                self:set_vel_mode(0)
                self:set_round_robin(1)
            elseif x==1 then
                self:set_hold_release_mode(0)
            end
            self:reset_meta_seq()
            self.one_shot_mode = x
        end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_hold_release_mode"),
        name = ("hold release mode"),
        min = 0, max = 2,
        default = self.hold_release_mode,
        action = function(x)
            if x>0 and self.vel_mode==1 then
                self:set_vel_mode(0)
                self:set_round_robin(1)
            elseif x>0 then
                self:set_one_shot_mode(0)
            end
            self:reset_meta_seq()
            self.hold_release_mode = x
        end
    }
    params:hide("input"..self.input.." "..self.layer_type.." vel layer "..self.id.." common")
end

function layer:set_low_thresh(val)
    local high = self.high_thresh
    if val >= high then val = high - 1 end
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_low_thresh", val)
end

function layer:set_high_thresh(val)
    local low = self.low_thresh
    if val <= low then val = low + 1 end
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_high_thresh", val)
end

function layer:set_probability(val, scene)
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_scene_"..scene.."_probability", val)
end

function layer:invert_probability(scene)
    local val = self.probability[scene] == 0 and self.buffered_probability[scene] or 0
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_scene_"..scene.."_probability", val)
end

function layer:set_hold_toggle(d)
    local val = self.hold_time_toggle == 0 and 1 or 0
    if d then val = d end
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_hold_time_toggle", val)
end

function layer:set_monophonic_toggle()
    local val = self.monophonic == 0 and 1 or 0
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_monophonic", val)
end

function layer:set_hold_inf()
    local val = self.hold_inf == 0 and 1 or 0
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_hold_inf", val)
end

function layer:set_hold_time(d, direct)
    if direct then
        if self.hold_time_toggle==1 then
            params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_hold_time_b", d)
        else
            params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_hold_time", d)
        end
    else
        if self.hold_time_toggle==1 then
            params:delta("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_hold_time_b", d/10)
        else
            params:delta("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_hold_time", d/10)
        end
    end
end

function layer:set_lane_send_data(lane)
    local val = self.lane_send[lane] == 0 and 1 or 0
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_lane_send_"..lane, val)
end

function layer:set_meta_seq_step_mute(step)
    local val = self.meta_seq_step_mute[step] == 0 and 1 or 0
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_meta_seq_step_mute_"..step, val)
end

function layer:set_range_data(min, max)
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_fixed_note_range_min", min)
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_fixed_note_range_max", max)
    self:reset_one_shots()
end

function layer:set_round_robin(val)
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_round_robin", val)
end

function layer:set_random_robin(val)
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_random_robin", val)
end

function layer:set_vel_mode(val)
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_vel_mode", val)
end

function layer:set_reset_mode(val)
    if val==nil then
        val = self.reset_mode == 0 and 1 or 0
    end
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_reset_mode", val)
end

function layer:set_one_shot_mode(val)
    if val==nil then
        val = self.one_shot_mode == 0 and 1 or 0
    end
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_one_shot_mode", val)
end

function layer:set_hold_release_mode(val)
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_hold_release_mode", val)
    if val == 2 then
        self.hold_flag=1
    end
end

function layer:get_hold_time()
    if self.hold_time_toggle == 1 then
        if self.hold_inf == 1 then return 0
        else return self.hold_time_b
        end
    else return self.hold_time
    end
end

function layer:check_play()
    if self.meta_seq_step_mute[self.position]==1 then
        return false
    elseif self.vel_mode==0 and not self:process_one_shots() then
        return false
    elseif self.hold_flag==1 and self.hold_release_mode<2 then
        return false
    end
    return true
end

function layer:check_route()
    if self.vel_mode==0 and not self:process_one_shots() then
        return false
    elseif self.hold_flag==1 and self.hold_release_mode<2 then
        return false
    end
    return true
end

function layer:is_muted()
    return self.meta_seq_step_mute[self.position]==1
end

function layer:process_one_shots()
    for i=self.range.min, self.range.max do
        if self.meta_seq_one_shots[i] == 1 then
            return true
        end
    end
    return false
end

function layer:reset_meta_seq()
    self.position = self.range.min
    self.hold_flag = 0
    if self.one_shot_mode == 1 then
        self:reset_one_shots()
    end
end

function layer:reset_one_shots()
    self.meta_seq_one_shots = {1,1,1,1,1,1,1,1}
end

function layer:get_random_meta_seq_step()
    local steps = {}
    for i=self.range.min,self.range.max do
        if self.one_shot_mode==1 and self.meta_seq_one_shots[i]==1 then
            table.insert(steps,i)
        elseif self.one_shot_mode==0 then
            table.insert(steps,i)
        end
    end
    -- print("******")
    -- tab.print(steps)
    if #steps>0 then
        return steps[math.random(1,#steps)]
    else
        return self.range.min
    end
end

function layer:adv_position(vel)
    if self.one_shot_mode == 1 then
        self.meta_seq_one_shots[self.position] = 0
    end
    if self.vel_mode == 1 and vel ~= 0 then
        local step = self:get_vel_length(vel)
        if step > 0 then
            self.position = step
        end
    elseif self.round_robin == 1 then
        self.position = self.position + 1
    else
        self.position = self:get_random_meta_seq_step()
    end
    self:clamp_position()
    grid_redraw()
end

function layer:get_vel_length(vel)
    for i=1,self.length do
        local calc_thresh = (i*self.vel_step_thresh) + self.low_thresh
        calc_thresh = i==self.length and 127 or calc_thresh
        if vel <= calc_thresh then
            local step = self.range.min + i - 1
            return step
        end
    end
    return 0
end

function layer:clamp_position()
    local min = self.range.min
    local max = self.range.max
    if (self.position < min) or (self.position > max) then
        self.position = min
    end
end

function layer:set_public_properties()
    self.length = self.range.max - self.range.min + 1
    self.vel_step_thresh = math.floor((self.vel_window/self.length)+0.5)
end

function layer:get_vel_step_threshold()
    self.vel_window = self.high_thresh - self.low_thresh
    self.vel_step_thresh = math.floor((self.vel_window/self.length)+0.5)
    return self.vel_step_thresh
end

return layer