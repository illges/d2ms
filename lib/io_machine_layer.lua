---@diagnostic disable: undefined-global, lowercase-global, need-check-nil

local velocity_layer = include 'lib/io_velocity_layer'
local config = include 'lib/config/inputs'
local stack_chords = include 'lib/config/stack_chord_intervals'

local layer = setmetatable({}, {__index = velocity_layer})
layer.__index = layer

function layer.new(input, id)
    --local self = setmetatable({}, layer)
    local self = setmetatable(velocity_layer.new("machine"), layer)
    self.input = input
    self.id = id
    self.destination = "midi/engine"
    self.momentary = false
    self.machine_types_list = {"EMPTY", "basic", "riff", "chord", "fixed", "strum", "velocity", "stack", "ratchet", "follow", "advance", "prog"}
    self.type = "basic"
    self.type_num = config[input].machine[id]
    self.d_vel_out = config[input].default_velocity_out[id]

    for i=1,16 do
        self.lane_send[i] = config[input].lane_send[id][i]
    end

    self.riff_intervals = {0,2,4,6,-21,-14,-7,0}
    self.fixed_notes = {config[input].fixed_step[id], 37, 38, 39, 40, 41, 42, 43}
    self.range.max = config[input].meta_seq_len[id]
    self:set_public_properties()
    self.gears_sequence = {0,0,0,1,0,0,0,1}
    self.chord_seq = {1,1,1,1,1,1,1,1}
    self.inversion_seq = {0,0,0,0,0,0,0,0}

    self.stack_chord = {1,1,1,1,1,1,1,1}
    self.stack_inversion = {1,1,1,1,1,1,1,1}

    self.gears_retrig = 1
    self.chord_strum_division = 0
    self.chord_vel_density = 0
    self.notes_send = 1
    self.cc_send = 0
    self.cc_match = 1
    self.continue_strum = 0
    self.mute_strum = 0
    self.strum_length = 8
    self.strum_division = 16
    self.pass_vel = config[input].pass_vel[id]
    self.follow_offset = 0
    self.leader_pointer = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    self.leader_routing = {}
    self.riff_pointer = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    self.riff_routing = {}
    self.AB_prime = 0
    self.extra_interval_offset = 0
    self.follow_strum = 0
    self.release_flag = 0

    self.auto_options_update = {
        function(val)
            self:set_strum_division("trig", val)
            self:set_chord_strum("trig", val)
        end,
        function(val) self:set_strum_length("trig", val) end,
        function(val) self:set_hold_time(val, true) end,
        function(val) self.extra_interval_offset = val end,
    }

    self:update_leader_routing()
    return self
end

function layer:get_interval()
    --if self.type == "riff" or self.type == "chord" or self.type == "prog" then
    if self.type == "riff" or self.type == "chord" then
        return self.riff_intervals[self.position] + self.extra_interval_offset
    else
        return self.riff_intervals[1] + self.extra_interval_offset
    end
end

function layer:get_chord_length()
    return #music.CHORDS[self.chord_seq[self.position]].intervals
end

function layer:get_chord(root)
    local name = music.CHORDS[self.chord_seq[self.position]].name
    return music.generate_chord(root,name,self.inversion_seq[self.position])
end

function layer:get_stack_chord_inversion_length()
    return #stack_chords[self.stack_chord[self.position]][self.stack_inversion[self.position]]
end

function layer:get_stack_chord_length()
    return #stack_chords[self.stack_chord[self.position]]
end

function layer:get_stack_chord(root)
    local temp = {}
    for i=1,self:get_stack_chord_inversion_length() do
        local int = stack_chords[self.stack_chord[self.position]][self.stack_inversion[self.position]][i]
        table.insert(temp, notes_context.piano.scale[root + int])
    end
    return temp
end

function layer:add_params()
    params:add_separator("input "..self.input.." machine layer "..self.id)
    params:add{
        type = "option", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_machine_type"),
        name = ("machine type"),
        options = self.machine_types_list,
        default = self.type_num,
        action = function(x)
            self.type_num = x
            self.type = self.machine_types_list[x]
        end
    }
    params:add{
        type = "option", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_destination"), name = ("output"),
        options = {"midi/engine", "midi", "engine"}, default = 1,
        action = function(x) self.destination = x end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_d_vel_out"),
        name = ("default vel out"),
        min = 1, max = 127,
        default = self.d_vel_out,
        action = function(x) self.d_vel_out = x end
    }
    self:add_params_velocity()
end

function layer:add_params_hidden()
    params:add_group("input"..self.input.." "..self.layer_type.." vel layer "..self.id, 92)
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_pass_vel"),
        name = ("pass vel"),
        min = 0, max = 1,
        default = self.pass_vel,
        action = function(x) self.pass_vel = x end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_strum_length"),
        name = ("strum length"),
        min = 1, max = 128,
        default = self.strum_length,
        action = function(x) self.strum_length = x end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_strum_division"),
        name = ("strum division"),
        min = 0, max = 128,
        default = self.strum_division,
        action = function(x) self.strum_division = x end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_chord_strum_division"),
        name = ("chord strum division"),
        min = 0, max = 128,
        default = self.chord_strum_division,
        action = function(x) self.chord_strum_division = x end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_chord_vel_density"),
        name = ("chord vel density"),
        min = 0, max = 1,
        default = self.chord_vel_density,
        action = function(x) self.chord_vel_density = x end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_notes_send"),
        name = ("notes send"),
        min = 0, max = 1,
        default = self.notes_send,
        action = function(x) self.notes_send = x end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_cc_send"),
        name = ("cc send"),
        min = 0, max = 1,
        default = self.cc_send,
        action = function(x) self.cc_send = x end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_follow_strum"),
        name = ("follow strum"),
        min = 0, max = 1,
        default = self.follow_strum,
        action = function(x) self.follow_strum = x end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_continue_strum"),
        name = ("continue strum"),
        min = 0, max = 1,
        default = self.continue_strum,
        action = function(x) self.continue_strum = x end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_mute_strum"),
        name = ("mute strum"),
        min = 0, max = 1,
        default = self.mute_strum,
        action = function(x) self.mute_strum = x end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_cc_match"),
        name = ("cc match"),
        min = 0, max = 1,
        default = self.cc_match,
        action = function(x) self.cc_match = x end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_follow_offset"),
        name = ("follow offset"),
        min = 0, max = 1,
        default = self.follow_offset,
        action = function(x) self.follow_offset = x end
    }
    for k=1,16 do
        params:add{
            type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_leader_pointer_"..k),
            name = ("leader pointer "..k),
            min = 0, max = 1,
            default = self.leader_pointer[k],
            action = function(x)
                self.leader_pointer[k] = x
                self:update_leader_routing()
            end
        }
        params:add{
            type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_riff_pointer_"..k),
            name = ("riff pointer "..k),
            min = 0, max = 1,
            default = self.riff_pointer[k],
            action = function(x)
                self.riff_pointer[k] = x
                self:update_riff_routing()
            end
        }
    end
    for i=1,8 do
        params:add{
            type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_riff_interval_"..i),
            name = ("riff interval "..i),
            min = -28, max = 28,
            default = self.riff_intervals[i],
            action = function(x) self.riff_intervals[i] = x end
        }
        params:add{
            type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_fixed_note_"..i),
            name = ("fixed note "..i),
            min = 0, max = 120,
            default = self.fixed_notes[i],
            action = function(x) self.fixed_notes[i] = x end
        }
        params:add{
            type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_chord_seq_"..i),
            name = ("chord seq "..i),
            min = 1, max = #music.CHORDS,
            default = self.chord_seq[i],
            action = function(x) self.chord_seq[i] = x end
        }
        params:add{
            type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_inversion_seq_"..i),
            name = ("inversion seq "..i),
            min = 0, max = 12,
            default = self.inversion_seq[i],
            action = function(x) self.inversion_seq[i] = x end
        }
        params:add{
            type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_stack_chord_seq_"..i),
            name = ("chord seq "..i),
            min = 1, max = #stack_chords,
            default = self.stack_chord[i],
            action = function(x) self.stack_chord[i] = x end
        }
        params:add{
            type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_stack_inversion_seq_"..i),
            name = ("inversion seq "..i),
            min = 1, max = 12,
            default = self.stack_inversion[i],
            action = function(x) self.stack_inversion[i] = x end
        }
    end
    -- for i=1,8 do
    --     params:add{
    --         type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_gears_sequence_"..i),
    --         name = ("gears sequence "..i),
    --         min = 0, max = 1,
    --         default = self.gears_sequence[i],
    --         action = function(x) self.gears_sequence[i] = x end
    --     }
    -- end
    -- params:add{
    --     type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_gears_retrig"),
    --     name = ("gears retrig"),
    --     min = 0, max = 1,
    --     default = self.gears_retrig,
    --     action = function(x) self.gears_retrig = x end
    -- }
    params:hide("input"..self.input.." "..self.layer_type.." vel layer "..self.id)
end

function layer:invert_pass_velocity()
    local val = self.pass_vel == 0 and 1 or 0
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_pass_vel", val)
end

function layer:set_machine_type(d)
    local val = self.type_num + d
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_machine_type", val)
    if self.type == "chord" then
        self:set_round_robin(1)
        self.position = self.range.min
    end
end

function layer:set_strum_length(d, trig_val)
    local val
    if d == "h" then val = math.floor(util.clamp(self.strum_length/2, 1, 128))
    elseif d=="d" then val = util.clamp(self.strum_length*2, 1, 128)
    elseif d=="trig" then val = trig_val
    else val = self.strum_length + d
    end
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_strum_length", val)
end

function layer:set_strum_division(d, trig_val)
    local val
    if d == "h" then val = math.floor(util.clamp(self.strum_division/2, 0, 128))
    elseif d=="d" then val = util.clamp(self.strum_division*2, 1, 128)
    elseif d=="trig" then val = trig_val
    else val = self.strum_division + d
    end
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_strum_division", val)
end

function layer:set_riff_interval(num, d, shift)
    if not shift then
        local val = self.riff_intervals[num] + d
        params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_riff_interval_"..num, val)
    else
        local range = self.range.max - self.range.min + 1
        local pos = self.range.min
        for i=1,range do
            local val = self.riff_intervals[pos] + d
            params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_riff_interval_"..pos, val)
            pos = pos + 1
        end
    end
end

function layer:set_riff_interval_val(num, val)
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_riff_interval_"..num, val)
end

function layer:set_fixed_note(num, d, shift)
    if not shift then
        local val = self.fixed_notes[num] + d
        params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_fixed_note_"..num, val)
    else
        local range = self.range.max - self.range.min + 1
        local pos = self.range.min
        for i=1,range do
            local val = self.fixed_notes[pos] + d
            params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_fixed_note_"..pos, val)
            pos = pos + 1
        end
    end
end

function layer:set_chord_seq(num, d)
    local val = self.chord_seq[num] + d
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_chord_seq_"..num, val)
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_inversion_seq_"..num, 0)
end

function layer:set_chord_seq_val(num, val)
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_chord_seq_"..num, val)
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_inversion_seq_"..num, 0)
end

function layer:set_inversion_seq(num, d)
    local val = util.clamp(self.inversion_seq[num] + d, 0, #music.generate_chord(64,music.CHORDS[self.chord_seq[num]].name))
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_inversion_seq_"..num, val)
end

function layer:set_chord_strum(d, trig_val)
    local val
    if d == "h" then val = math.floor(util.clamp(self.chord_strum_division/2, 0, 128))
    elseif d=="d" then val = util.clamp(self.chord_strum_division*2, 1, 128)
    elseif d=="trig" then val = trig_val
    else val = self.chord_strum_division + d
    end
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_chord_strum_division", val)
end

function layer:invert_chord_vel_density(d)
    local val = self.chord_vel_density == 0 and 1 or 0
    if d then val = d end
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_chord_vel_density", val)
end

function layer:invert_notes_send()
    local val = self.notes_send == 0 and 1 or 0
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_notes_send", val)
end

function layer:invert_cc_send()
    local val = self.cc_send == 0 and 1 or 0
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_cc_send", val)
end

function layer:invert_follow_strum()
    local val = self.follow_strum == 0 and 1 or 0
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_follow_strum", val)
end

function layer:invert_cc_match()
    local val = self.cc_match == 0 and 1 or 0
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_cc_match", val)
end

function layer:invert_continue_strum()
    local val = self.continue_strum == 0 and 1 or 0
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_continue_strum", val)
    if val == 1 then
        params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_mute_strum", 0)
    end
end

function layer:invert_mute_strum()
    local val = self.mute_strum == 0 and 1 or 0
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_mute_strum", val)
    if val == 1 then
        params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_continue_strum", 0)
    end
end

function layer:set_follow_offset(d)
    local val = self.follow_offset == 0 and 1 or 0
    if d then val = d end
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_follow_offset", val)
end

function layer:set_leader_pointer_data(lane)
    local val = self.leader_pointer[lane] == 0 and 1 or 0
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_leader_pointer_"..lane, val)
end

function layer:update_leader_routing()
    if #self.leader_routing > 0 then
        for k=1,#self.leader_routing do self.leader_routing[k] = nil end -- clear list of routings
    end
    for j=1,16 do
        if self.leader_pointer[j] == 1 then table.insert(self.leader_routing, j) end -- process active outs and add to list
    end
end

function layer:set_riff_pointer_data(lane)
    local val = self.riff_pointer[lane] == 0 and 1 or 0
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_riff_pointer_"..lane, val)
end

function layer:update_riff_routing()
    if #self.riff_routing > 0 then
        for k=1,#self.riff_routing do self.riff_routing[k] = nil end -- clear list of routings
    end
    for j=1,16 do
        if self.riff_pointer[j] == 1 then table.insert(self.riff_routing, j) end -- process active outs and add to list
    end
end

function layer:invert_gears_sequence(step)
    local val = self.gears_sequence[step] == 0 and 1 or 0
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_gears_sequence_"..step, val)
end

function layer:invert_gears_retrig()
    local val = self.gears_retrig == 0 and 1 or 0
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_gears_retrig", val)
end

function layer:set_stack_chord_seq_val(num, val)
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_stack_chord_seq_"..num, val)
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_stack_inversion_seq_"..num, 1)
end

function layer:set_stack_inversion_seq_val(num, d)
    local val = util.clamp(d, 1, #stack_chords[self.stack_chord[self.position]])
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_stack_inversion_seq_"..num, val)
end

return layer