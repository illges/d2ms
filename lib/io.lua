---@diagnostic disable: undefined-global, lowercase-global, need-check-nil

local machine_layer = include 'lib/io_machine_layer'
local trig_layer = include 'lib/io_trig_layer'
local config = include 'lib/config/inputs'

local io = {}
function io.new(id)
    local self = setmetatable({}, { __index = io })

    self.id = id
    self.note = config[id].note
    self.channel = config[id].channel
    self.momentary = false
    self.ready_to_trigger = true

    self.setup_list = {
        studio = {trig_mask_timer = config[id].studio_trig_mask_timer,
                  velocity_multiplier = config[id].studio_velocity_multiplier,
                  velocity_floor = config[id].studio_velocity_floor,
                  velocity_ceiling = config[id].studio_velocity_ceiling},
        venue = {trig_mask_timer = config[id].venue_trig_mask_timer,
                 velocity_multiplier = config[id].venue_velocity_multiplier,
                 velocity_floor = config[id].venue_velocity_floor,
                 velocity_ceiling = config[id].venue_velocity_ceiling}
    }

    self.sel_machine_layer = 1
    self.prev_sel_machine_layer = 1
    self.machine = {}
    table.insert(self.machine, machine_layer.new(self.id,1)) -- default to basic machine
    table.insert(self.machine, machine_layer.new(self.id,2))
    table.insert(self.machine, machine_layer.new(self.id,3))
    table.insert(self.machine, machine_layer.new(self.id,4))
    table.insert(self.machine, machine_layer.new(self.id,5))

    self.sel_trig_layer = 1
    self.prev_sel_trig_layer = 1
    self.trig = {}
    table.insert(self.trig, trig_layer.new(self.id,1,2)) -- default to AB trig
    table.insert(self.trig, trig_layer.new(self.id,2,1))
    table.insert(self.trig, trig_layer.new(self.id,3,1))
    table.insert(self.trig, trig_layer.new(self.id,4,1))
    table.insert(self.trig, trig_layer.new(self.id,5,1))

    self:add_params()
    return self
end

function io:ready()
    return self.ready_to_trigger
end

function io:reset()
    self.trigger_reset_id = clock.run(function()
        self.ready_to_trigger = false
        local val = self.setup_list[current_setup].trig_mask_timer
        --print("trigger timer val - "..val)
        clock.sleep(val)
        self.ready_to_trigger = true
    end)
end

function io:get_vel_multiplier()
    return self.setup_list[current_setup].velocity_multiplier
end

function io:get_vel_floor()
    return self.setup_list[current_setup].velocity_floor
end

function io:get_vel_ceiling()
    return self.setup_list[current_setup].velocity_ceiling
end

function io:log_instance(n,m)
    print("***log input instance***")
    print("note: "..self.note)
    print("channel: "..self.channel)
    tab.print(self.machine[n].output_list[m])
    print("***********************")
end

function io:add_params()
    params:add_group("input "..self.id, 60) -- do not add hidden params count to this number
    params:add{
        type = "number", id = ("input_"..self.id.."_note"),
        name = ("midi note"),
        min = 0, max = 127,
        default = self.note,
        action = function(x) self.note = x end
    }
    params:add{
        type = "number", id = ("input_"..self.id.."_channel"),
        name = ("midi channel"),
        min = 1, max = 16,
        default = self.channel,
        action = function(x) self.channel = x end
    }

    for i=1,#setup_types do
        params:add_control("input_"..self.id.."_"..setup_types[i].."_velocity_multiplier",setup_types[i].." vel multiplier",controlspec.new(0.10,5.00,'lin',0,self.setup_list[setup_types[i]].velocity_multiplier,'x'))
        params:set_action("input_"..self.id.."_"..setup_types[i].."_velocity_multiplier", function(x) self.setup_list[setup_types[i]].velocity_multiplier = x end)

        params:add_control("input_"..self.id.."_"..setup_types[i].."_trig_mask_timer",setup_types[i].." trig mask time",controlspec.new(0,1,'lin',0,self.setup_list[setup_types[i]].trig_mask_timer,'s'))
        params:set_action("input_"..self.id.."_"..setup_types[i].."_trig_mask_timer", function(x) self.setup_list[setup_types[i]].trig_mask_timer = x end)

        params:add{
            type = "number", id = ("input_"..self.id.."_"..setup_types[i].."_velocity_floor"),
            name = (setup_types[i].." velocity floor"),
            min = 0, max = 127,
            default = self.setup_list[setup_types[i]].velocity_floor,
            action = function(x) self.setup_list[setup_types[i]].velocity_floor = x end
        }
        params:add{
            type = "number", id = ("input_"..self.id.."_"..setup_types[i].."_velocity_ceiling"),
            name = (setup_types[i].." velocity ceiling"),
            min = 1, max = 127,
            default = self.setup_list[setup_types[i]].velocity_ceiling,
            action = function(x) self.setup_list[setup_types[i]].velocity_ceiling = x end
        }
    end

    for i=1,#self.machine do
        self.machine[i]:add_params()
    end

    for i=1,#self.trig do
        self.trig[i]:add_params()
    end

    for i=1,#self.machine do
        self.machine[i]:add_params_hidden()
        self.machine[i]:add_params_hidden_common()
        self.trig[i]:add_params_hidden()
        self.trig[i]:add_params_hidden_common()
    end

    for i=1,#self.trig do
        self.trig[i]:add_trig_to_machine_params()
    end
end

function io:set_note(val)
    params:set("input_"..self.id.."_note", val)
end

function io:set_channel(val)
    params:set("input_"..self.id.."_channel", val)
end

function io:set_velocity_floor(val)
    params:set("input_"..self.id.."_"..current_setup.."_velocity_floor", util.clamp(val, 0, self.setup_list[current_setup].velocity_ceiling-1))
end

function io:set_velocity_ceiling(val)
    params:set("input_"..self.id.."_"..current_setup.."_velocity_ceiling", util.clamp(val, self.setup_list[current_setup].velocity_floor+1, 127))
end

function io:set_low_thresh(layer_type, layer_num, val)
    if linked_velocity_layers == 1 then
        self.machine[layer_num]:set_low_thresh(val)
        self.trig[layer_num]:set_low_thresh(val)
    elseif layer_type == "machine" then
        self.machine[layer_num]:set_low_thresh(val)
    else
        self.trig[layer_num]:set_low_thresh(val)
    end
end

function io:set_high_thresh(layer_type, layer_num, val)
    if linked_velocity_layers == 1 then
        self.machine[layer_num]:set_high_thresh(val)
        self.trig[layer_num]:set_high_thresh(val)
    elseif layer_type == "machine" then
        self.machine[layer_num]:set_high_thresh(val)
    else
        self.trig[layer_num]:set_high_thresh(val)
    end
end

return io