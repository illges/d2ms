---@diagnostic disable: undefined-global, lowercase-global

local velocity_layer = include 'lib/io_velocity_layer'

local layer = setmetatable({}, {__index = velocity_layer})
layer.__index = layer

function layer.new(input, id, default)
    local self = setmetatable(velocity_layer.new("trig"), layer)
    self.input = input
    self.id = id
    self.momentary = false
    self.trig_types_list = {"EMPTY","AB","proxy","conductor","release","reset","direction","layer_mute","fill","sustain","offset","cc","root","scale","tap_tempo","auto","gears"}
    self.type = "fill"
    self.type_num = default
    self.ui_clamp = 7

    self.gears_sequence = {0,0,0,1,0,0,0,1}
    self.gears_retrig = 1
    self.prime_AB = 0
    self.fill = "note" -- also used for direction trigs
    self.fill_options = {"note", "cc"}--, "filter", "release", "pan", "pw"}
    self.func = "random"
    self.fill_funcs = {"random", "scAsc", "scDesc", "triAsc", "triDesc", "asc", "desc"}
    self.direction_toggle = "reverse"
    self.direction_options = {"reverse", "pingpong", "pingpong2", "random"}
    self.reset_type = "note"
    self.reset_options = {"note", "cc", "machine", "trig"}--, "filter", "release", "pan", "pw"}

    self.scale_sequence = {1,1,1,1,2,2,2,2}
    self.root_sequence = {0,0,0,0,5,5,5,5}

    self.conduct_pattern = 0
    self.conduct_patch = 0
    self.conduct_scene = 0
    self.patch_num = 0
    self.pattern_num = 0
    self.scene_num = 0
    self.group_advance = 0
    self.cc_num = 1
    self.cc_ch = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    self.cc_val = 64
    self.cc_val_2 = 0
    self.cc_val_memory = 64
    self.cc_ch_route = 1
    self.layer_mute_toggle = 1
    self.layer_mute = 0
    self.layer_unmute = 0
    self.reset_on_adv = 0

    self.input_machine = {}
    for i=1,16 do
        self.input_machine[i] = {}
        self.input_machine[i].layer = {}
        self.input_machine[i].layer_process_clock_active = {}
        for j=1,5 do
            self.input_machine[i].layer[j] = 0
        end
        self:check_input_routing(i)
    end

    self.auto_choice = 1
    self.auto_options = {"division","length","sustain","interval"}
    self.auto_large_deltas = {12,12,10,7}
    -- update machine layer actions in the same order
    self.auto_options_update = {
        function(num,d) self:set_division(num,d) end,
        function(num,d) self:set_length(num,d) end,
        function(num,d) self:set_hold_time(num,d) end,
        function(num,d) self:set_interval_offset(num,d) end,
    }
    self.auto_options_get = {
        {8,8,12,12,8,8,12,12},             -- division
        {4,8,4,8,4,8,4,8},                 -- length
        {0.1,0.2,0.4,0.6,0.8,1.0,1.2,1.4}, -- hold time
        {-7,0,7,0,-7,0,7,0},               -- interval offset
    }

    self.trig_pointer = 0
    self.proxy_ignore_mutes = 1
    self.clock_id = nil
    self.process_clock_division = 0
    self.delayed_process_reset_mode = 0
    self.process_clock_active = 0

    self.meta_process_position = 0
    self.meta_process_sequence_length = 8
    self.meta_process_mode = 1
    self.meta_process_first_step = 1

    return self
end
DIVISION=1; LENGTH=2; HOLD_TIME=3; INTERVAL=4;

function layer:route_auto_trig()
    local val = self.auto_options_get[self.auto_choice][self.position]
    for i=1,16 do
        if self.input_machine[i].active then
            for j=1,5 do
                if self.input_machine[i].layer[j] == 1 then
                    machine_context.input[i].machine[j].auto_options_update[self.auto_choice](val)
                end
            end
        end
    end
end

function layer:check_input_routing(n)
    for i=1,5 do
        if self.input_machine[n].layer[i] == 1 then
            self.input_machine[n].active = true
            return true
        else
            self.input_machine[n].active = false
        end
    end
    return false
end

function layer:any_input_routing_high()
    for i=1,16 do
		if self.input_machine[i].active then
			return true
		end
	end
    return false
end

function layer:check_reset_meta()
    if self.type=="reset" and (self.reset_type=="machine" or self.reset_type=="trig") then return true end
    return false
end

function layer:get_interval()
    return 0
end

function layer:add_params()
    params:add_separator("input "..self.input.." trig layer "..self.id)
    params:add{
        type = "option", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_trig_type"),
        name = ("trig type"),
        options = self.trig_types_list,
        default = self.type_num,
        action = function(x)
            self.type_num = x
            self.type = self.trig_types_list[x]
        end
    }
    self:add_params_velocity()
end

function layer:add_params_hidden()
    params:add_group("input"..self.input.." "..self.layer_type.." vel layer "..self.id, 101)
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_reset_on_adv"),
        name = ("reset on adv"),
        min = 0, max = 1,
        default = self.reset_on_adv,
        action = function(x) self.reset_on_adv = x end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_process_clock_division"),
        name = ("process clock division"),
        min = 0, max = 128,
        default = self.process_clock_division,
        action = function(x) self.process_clock_division = x end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_delayed_process_reset_mode"),
        name = ("delayed process reset mode"),
        min = 0, max = 1,
        default = self.delayed_process_reset_mode,
        action = function(x) self.delayed_process_reset_mode = x end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_meta_process_mode"),
        name = ("meta process mode"),
        min = 0, max = 1,
        default = self.meta_process_mode,
        action = function(x) self.meta_process_mode = x end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_meta_process_first_step"),
        name = ("meta process mode"),
        min = 0, max = 1,
        default = self.meta_process_first_step,
        action = function(x) self.meta_process_first_step = x end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_meta_process_sequence_length"),
        name = ("meta process sequence length"),
        min = 1, max = 16,
        default = self.meta_process_sequence_length,
        action = function(x) self.meta_process_sequence_length = x end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_gears_retrig"),
        name = ("gears retrig"),
        min = 0, max = 1,
        default = self.gears_retrig,
        action = function(x) self.gears_retrig = x end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_trig_pointer"),
        name = ("gears trig pointer"),
        min = 0, max = 1,
        default = self.trig_pointer,
        action = function(x) self.trig_pointer = x end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_proxy_ignore_mutes"),
        name = ("proxy ignore mutes"),
        min = 0, max = 1,
        default = self.proxy_ignore_mutes,
        action = function(x) self.proxy_ignore_mutes = x end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_prime_AB"),
        name = ("prime AB"),
        min = 0, max = 1,
        default = self.prime_AB,
        action = function(x) self.prime_AB = x end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_layer_mute_toggle"),
        name = ("layer mute toggle"),
        min = 0, max = 1,
        default = self.layer_mute_toggle,
        action = function(x) self.layer_mute_toggle = x end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_layer_mute"),
        name = ("layer mute"),
        min = 0, max = 1,
        default = self.layer_mute,
        action = function(x) self.layer_mute = x end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_layer_unmute"),
        name = ("layer unmute"),
        min = 0, max = 1,
        default = self.layer_unmute,
        action = function(x) self.layer_unmute = x end
    }
    params:add{
        type = "option", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_fill_option"),
        name = ("fill"),
        options = self.fill_options,
        default = 1,
        action = function(x) self.fill = self.fill_options[x] end
    }
    params:add{
        type = "option", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_reset_option"),
        name = ("reset type"),
        options = self.reset_options,
        default = 1,
        action = function(x) self.reset_type = self.reset_options[x] end
    }
    params:add{
        type = "option", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_fill_func"),
        name = ("fill func"),
        options = self.fill_funcs,
        default = 1,
        action = function(x) self.func = self.fill_funcs[x] end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_cc_num"),
        name = ("cc num"),
        min = 0, max = 127,
        default = self.cc_num,
        action = function(x) self.cc_num = x end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_cc_ch_route"),
        name = ("cc ch"),
        min = 1, max = 16,
        default = self.cc_ch_route,
        action = function(x) self.cc_ch_route = x end
    }
    for i=1,16 do
        params:add{
            type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_cc_ch_"..i),
            name = ("cc ch"),
            min = 0, max = 1,
            default = self.cc_ch[i],
            action = function(x) self.cc_ch[i] = x end
        }
    end
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_cc_val"),
        name = ("cc val"),
        min = 0, max = 127,
        default = self.cc_val,
        action = function(x) self.cc_val = x end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_cc_val_2"),
        name = ("cc val 2"),
        min = 0, max = 127,
        default = self.cc_val_2,
        action = function(x) self.cc_val_2 = x end
    }
    params:add{
        type = "option", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_direction_option"),
        name = ("direction toggle"),
        options = self.direction_options,
        default = 1,
        action = function(x) self.direction_toggle = self.direction_options[x] end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_conduct_pattern"),
        name = ("conduct pattern"),
        min = 0, max = 1,
        default = self.conduct_pattern,
        action = function(x) self.conduct_pattern = x end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_conduct_patch"),
        name = ("conduct patch"),
        min = 0, max = 1,
        default = self.conduct_patch,
        action = function(x) self.conduct_patch = x end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_conduct_scene"),
        name = ("conduct scene"),
        min = 0, max = 1,
        default = self.conduct_scene,
        action = function(x) self.conduct_scene = x end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_patch_num"),
        name = ("patch num"),
        min = 0, max = 16,
        default = self.patch_num,
        action = function(x) self.patch_num = x end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_scene_num"),
        name = ("scene num"),
        min = 0, max = 16,
        default = self.scene_num,
        action = function(x) self.scene_num = x end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_pattern_num"),
        name = ("pattern num"),
        min = 0, max = 16,
        default = self.pattern_num,
        action = function(x) self.pattern_num = x end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_group_advance"),
        name = ("group adv"),
        min = 0, max = 1,
        default = self.group_advance,
        action = function(x) self.group_advance = x end
    }
    params:add{
        type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_auto_choice"),
        name = ("auto choice"),
        min = 1, max = #self.auto_options,
        default = self.auto_choice,
        action = function(x) self.auto_choice = x end
    }
    for i=1,8 do
        params:add{
            type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_root_sequence_"..i),
            name = ("root sequence "..i),
            min = 0, max = 11,
            default = self.root_sequence[i],
            action = function(x) self.root_sequence[i] = x end
        }
        params:add{
            type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_scale_sequence_"..i),
            name = ("scale sequence "..i),
            min = 1, max = 41,
            default = self.scale_sequence[i],
            action = function(x) self.scale_sequence[i] = x end
        }
        params:add{
            type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_gears_sequence_"..i),
            name = ("gears sequence "..i),
            min = 0, max = 1,
            default = self.gears_sequence[i],
            action = function(x) self.gears_sequence[i] = x end
        }
        params:add{
            type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_division_"..i),
            name = ("division "..i),
            min = 0, max = 128,
            default = self.auto_options_get[DIVISION][i],
            action = function(x) self.auto_options_get[DIVISION][i] = x end
        }
        params:add{
            type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_length_"..i),
            name = ("length "..i),
            min = 1, max = 128,
            default = self.auto_options_get[LENGTH][i],
            action = function(x) self.auto_options_get[LENGTH][i] = x end
        }
        params:add{
            type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_hold_time_"..i),
            name = ("hold time "..i),
            min = 0.1, max = 10,
            default = self.auto_options_get[HOLD_TIME][i],
            action = function(x) self.auto_options_get[HOLD_TIME][i] = x end
        }
        params:add{
            type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_interval_offset_"..i),
            name = ("interval offset "..i),
            min = -28, max = 28,
            default = self.auto_options_get[INTERVAL][i],
            action = function(x) self.auto_options_get[INTERVAL][i] = x end
        }
    end
    params:hide("input"..self.input.." "..self.layer_type.." vel layer "..self.id)
end

function layer:add_trig_to_machine_params()
    params:add_group("input"..self.input.." "..self.layer_type.." vel layer "..self.id.."_machine_routing", 80)
    for i=1,16 do
        for j=1,5 do
            params:add{
                type = "number", id = ("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_input_machine_"..i.."_layer_"..j),
                name = ("input machine "..i.." layer "..j),
                min = 0, max = 1,
                default = self.input_machine[i].layer[j],
                action = function(x)
                    self.input_machine[i].layer[j] = x
                    self:check_input_routing(i)
                end
            }
        end
    end
    params:hide("input"..self.input.." "..self.layer_type.." vel layer "..self.id.."_machine_routing")
end

function layer:set_trig_type(d)
    local val = self.type_num + d
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_trig_type", val)
end

function layer:set_process_clock_division(d, trig_val)
    local val
    if d == "h" then val = math.floor(util.clamp(self.process_clock_division/2, 0, 128))
    elseif d=="d" then val = util.clamp(self.process_clock_division*2, 1, 128)
    elseif d=="trig" then val = trig_val
    else val = self.process_clock_division + d
    end
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_process_clock_division", val)
end

function layer:invert_reset_on_adv()
    local val = self.reset_on_adv == 0 and 1 or 0
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_reset_on_adv", val)
end

function layer:invert_delayed_process_reset_mode()
    local val = self.delayed_process_reset_mode == 0 and 1 or 0
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_delayed_process_reset_mode", val)
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_meta_process_mode", 0)
end

function layer:invert_meta_process_mode()
    local val = self.meta_process_mode == 0 and 1 or 0
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_meta_process_mode", val)
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_delayed_process_reset_mode", 0)
end

function layer:invert_meta_process_first_step()
    local val = self.meta_process_first_step == 0 and 1 or 0
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_meta_process_first_step", val)
end

function layer:set_meta_process_sequence_length(val)
    self.meta_process_position = 0
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_meta_process_sequence_length", val)
end

function layer:invert_gears_retrig()
    local val = self.gears_retrig == 0 and 1 or 0
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_gears_retrig", val)
end

function layer:invert_trig_pointer()
    local val = self.trig_pointer == 0 and 1 or 0
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_trig_pointer", val)
end

function layer:invert_proxy_ignore_mutes()
    local val = self.proxy_ignore_mutes == 0 and 1 or 0
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_proxy_ignore_mutes", val)
end

function layer:invert_gears_sequence(step)
    local val = self.gears_sequence[step] == 0 and 1 or 0
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_gears_sequence_"..step, val)
end

function layer:invert_prime_AB()
    local val = self.prime_AB == 0 and 1 or 0
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_prime_AB", val)
end

function layer:invert_layer_mute_toggle()
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_layer_mute_toggle", 1)
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_layer_mute", 0)
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_layer_unmute", 0)
end

function layer:invert_layer_mute()
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_layer_mute", 1)
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_layer_mute_toggle", 0)
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_layer_unmute", 0)
end

function layer:invert_layer_unmute()
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_layer_unmute", 1)
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_layer_mute_toggle", 0)
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_layer_mute", 0)
end

function layer:set_fill_option(d)
    local current = params:get("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_fill_option")
    local val = current + d
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_fill_option", val)
end

function layer:set_fill_func(d)
    local current = params:get("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_fill_func")
    local val = current + d
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_fill_func", val)
end

function layer:set_direction_option(d)
    local current = params:get("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_direction_option")
    local val = current + d
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_direction_option", val)
end

function layer:set_reset_option(d)
    local current = params:get("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_reset_option")
    local val = current + d
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_reset_option", val)
end

function layer:set_root(num, val)
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_root_sequence_"..num, val)
end

function layer:set_scale(num, val)
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_scale_sequence_"..num, val)
end

function layer:set_cc_num(d)
    local val = self.cc_num + d
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_cc_num", val)
end

function layer:set_cc_ch(num)
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_cc_ch_"..num, 1-self.cc_ch[num])
end

function layer:set_cc_ch_route(d)
    local val = self.cc_ch_route + d
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_cc_ch_route", val)
end

function layer:set_cc_val(d)
    local val = self.cc_val + d
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_cc_val", val)
end

function layer:set_cc_val_2(d)
    local val = self.cc_val_2 + d
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_cc_val_2", val)
end

function layer:set_patch_num(d)
    local val = self.patch_num + d
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_patch_num", val)
end

function layer:set_scene_num(d)
    local val = self.scene_num + d
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_scene_num", val)
end

function layer:set_pattern_num(d)
    local val = self.pattern_num + d
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_pattern_num", val)
end

function layer:invert_group_advance()
    local val = self.group_advance == 0 and 1 or 0
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_group_advance", val)
end

function layer:set_trig_to_machine_layer_routing(input, layer)
    local val = self.input_machine[input].layer[layer] == 0 and 1 or 0
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_input_machine_"..input.."_layer_"..layer, val)
end

function layer:set_auto_choice(d)
    params:delta("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_auto_choice", d)
end

function layer:set_division(num, d)
    params:delta("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_division_"..num, d)
end

function layer:set_length(num, d)
    params:delta("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_length_"..num, d)
end

function layer:set_hold_time(num, d)
    params:delta("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_hold_time_"..num, d/10)
end

function layer:set_interval_offset(num, d)
    params:delta("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_interval_offset_"..num, d)
end

function layer:invert_conduct_pattern()
    local val = self.conduct_pattern == 0 and 1 or 0
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_conduct_pattern", val)
end

function layer:invert_conduct_patch()
    local val = self.conduct_patch == 0 and 1 or 0
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_conduct_patch", val)
end

function layer:invert_conduct_scene()
    local val = self.conduct_scene == 0 and 1 or 0
    params:set("input_"..self.input.."_"..self.layer_type.."_layer_"..self.id.."_conduct_scene", val)
end

return layer