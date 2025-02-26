---@diagnostic disable: undefined-global, lowercase-global

local config = include 'lib/config/dev'

setup_types = {"studio", "venue"}

cutoff_min = 50
cutoff_max = 5000
release_min = 1
release_max = 32
pan_min = -10
pan_max = 10
pw_min = 0
pw_max = 100

function add_main_params()
    params:add_separator("d2ms")
    params:add_group("config", 19)
    params:add{
        type = "option", id = ("setup"),
        name = ("setup"),
        options = setup_types,
        default = 1,
        action = function(x) current_setup = setup_types[x] end
    }
    params:add{ type = "number", id= ("medium piano"), name = ("medium piano"),
                min = 0, max = 1, default = config.use_med_piano, action = function(x) use_med_piano = x end}
    params:add{ type = "number", id= ("external_piano_input"), name = ("external_piano_input"),
                min = 0, max = 1, default = config.external_piano_input, action = function(x) external_piano_input = x end}
    params:add{ type = "number", id= ("round bpm"), name = ("round bpm"),
                min = 0, max = 1, default = config.round_bpm, action = function(x) round_bpm = x end}
    params:add{ type = "number", id= ("lock midi learn"), name = ("lock midi learn"),
                min = 0, max = 1, default = config.lock_midi_learn, action = function(x) lock_midi_learn = x end}
    params:add{ type = "number", id= ("grid light pulse"), name = ("grid light pulse"),
                min = 0, max = 1, default = config.grid_light_pulse, action = function(x) grid_light_pulse = x end}
    params:add{ type = "number", id= ("sticky contexts"), name = ("sticky contexts"),
                min = 0, max = 1, default = config.sticky_contexts, action = function(x) sticky_contexts = x end}
    params:add{ type = "number", id= ("linked velocity layers"), name = ("linked velocity layers"),
                min = 0, max = 1, default = config.linked_velocity_layers, action = function(x) linked_velocity_layers = x end}
    params:add{ type = "number", id= ("process all trigs first"), name = ("process all trigs first"),
                min = 0, max = 1, default = config.process_all_trigs_first, action = function(x) process_all_trigs_first = x end}
    params:add{ type = "number", id= ("pulse min cc slot off"), name = ("pulse min cc slot off"),
                min = 0, max = 1, default = config.pulse_min_cc_slot_off, action = function(x) pulse_min_cc_slot_off = x end}
    params:add{ type = "number", id= ("extend strum reset window"), name = ("extend strum reset window"),
                min = 0, max = 1, default = config.ext_strum_reset_window, action = function(x) ext_strum_reset_window = x end}
    params:add{ type = "number", id= ("hold_to_tap"), name = ("hold_to_tap"),
                min = 0, max = 1, default = config.hold_to_tap, action = function(x) hold_to_tap = x end}
    params:add{ type = "number", id= ("DEBUG IN"), name = ("DEBUG IN"),
                min = 0, max = 1, default = config.DEBUG_IN, action = function(x) DEBUG_IN = x end}
    params:add{ type = "number", id= ("DEBUG OUT"), name = ("DEBUG OUT"),
                min = 0, max = 1, default = config.DEBUG_OUT, action = function(x) DEBUG_OUT = x end}
    params:add{ type = "number", id= ("DEBUG CC"), name = ("DEBUG CC"),
                min = 0, max = 1, default = config.DEBUG_CC, action = function(x) DEBUG_CC = x end}
    params:add{ type = "number", id= ("DEBUG PIANO"), name = ("DEBUG PIANO"),
                min = 0, max = 1, default = config.DEBUG_PIANO, action = function(x) DEBUG_PIANO = x end}
    params:add{ type = "number", id= ("load default"), name = ("load default"),
                min = 0, max = 1, default = config.load_default, action = function(x) load_default = x end}
    params:add{ type = "number", id= ("layout v2"), name = ("layout v2"),
                min = 0, max = 1, default = config.layout_v2, action = function(x) layout_v2 = x end}
    params:add{ type = "number", id= ("processing v2"), name = ("processing v2"),
                min = 0, max = 1, default = config.processing_v2, action = function(x) processing_v2 = x end}

    params:add_group("engine", 6)
    params:add_control("cutoff","cutoff",controlspec.new(50,5000,'exp',0,2010,'hz'))
    params:set_action("cutoff", function(x) engine.cutoff(x) cutoff=x end)

    params:add_control("release","release",controlspec.new(1,32,'lin',0,13,'/10s'))
    params:set_action("release", function(x) engine.release(x/10) release=x/10 end)

    params:add_control("pan","pan",controlspec.new(-1,1, 'lin',0,0,''))
    params:set_action("pan", function(x) engine.pan(x/10) pan=x/10 end)

    params:add_control("pw","pw",controlspec.new(0,100,'lin',0,50,'%'))
    params:set_action("pw", function(x) engine.pw(x/100) pw=x/100 end)

    params:add_control("amp","amp",controlspec.new(0,1,'lin',0,0.5,''))
    params:set_action("amp", function(x) engine.amp(x) end)

    params:add_control("gain","gain",controlspec.new(0,4,'lin',0,1,''))
    params:set_action("gain", function(x) engine.gain(x) end)
end

function set_cutoff(val)
    params:set("cutoff", util.round(util.linlin(0,127,cutoff_min,cutoff_max,val)))
end
function set_release(val)
    params:set("release", util.round(util.linlin(0,127,release_min,release_max,val)))
end
function set_pan(val)
    params:set("pan", util.round(util.linlin(0,127,pan_min,pan_max,val)))
end
function set_pw(val)
    params:set("pw", util.round(util.linlin(0,127,pw_min,pw_max,val)))
end

function display_cutoff(val)
    return val
    --return util.round(util.linlin(0,127,cutoff_min,cutoff_max,val))
end
function display_release(val)
    return util.round(util.linlin(0,127,release_min,release_max,val))/10
end
function display_pan(val)
    return util.round(util.linlin(0,127,pan_min,pan_max,val))/10
end
function display_pw(val)
    return util.round(util.linlin(0,127,pw_min,pw_max,val))
end

function invert_hold_to_tap()
    local val = hold_to_tap == 0 and 1 or 0
    params:set("hold_to_tap", val)
end