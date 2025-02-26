-- https://github.com/illges/device_manager
---@diagnostic disable: undefined-global, lowercase-global

local adv_config
if util.file_exists("/home/we/dust/code/"..SCRIPT_NAME.."/lib/config/advanced_device_config.lua") then
    adv_config = include("lib/config/advanced_device_config")
end

local basic_config
if util.file_exists("/home/we/dust/code/"..SCRIPT_NAME.."/lib/config/basic_device_config.lua") then
    basic_config = include("lib/config/basic_device_config")
end

local dm = {}
dm.__index = dm

function dm.new(args)
    local self = setmetatable({}, dm)
    args=args==nil and {} or args
    self.debug = args.debug
    self.devices = {}
    self.device_name_list = {}
    self.device_route = {}
    self.route_options = {"OFF", "IN", "OUT", "IN/OUT"}
    self.output_devices = {}
    if args.adv then
        self:adv_configuration()
    else
        self:basic_configuration()
    end
    return self
end

function dm:basic_configuration()
    for _,dev in pairs(midi.devices) do
        local name = string.len(dev.name) > 15 and util.acronym(dev.name) or dev.name
        local device={
            name=name,
            port=dev.port,
            midi=midi.connect(dev.port),
        }
        self.devices[device.name]=device
        self.devices[device.name].midi.event=function(data)
            if device.name==self.device_name_list[params:get("midi_in")] then
                self:print("device: "..device.name.." is configured for MIDI IN.")
                self:midi_in(data)
            elseif device.name==self.device_name_list[params:get("midi_out")] then
                self:print("device: "..device.name.." is configured for MIDI OUT.")
            else
                self:print("device: "..device.name.." is NOT configured.")
            end
        end
        table.insert(self.device_name_list,device.name)
        table.insert(self.devices,device)
    end

    -- set user defined defaults
    local midi_in = 1
    if basic_config ~= nil then
        for i=1,#self.device_name_list do
            if self.device_name_list[i] == basic_config.midi_in then midi_in = i end
        end
        local midi_out = 1
        for i=1,#self.device_name_list do
            if self.device_name_list[i] == basic_config.midi_out then midi_out = i end
        end
    end

    params:add_group("device setup",2)
    params:add_option("midi_in","midi in",self.device_name_list,midi_in)
    params:add_option("midi_out","midi out",self.device_name_list,midi_out)
end

function dm:adv_configuration()
    for i=1,#midi.vports do
        local name = string.len(midi.vports[i].name) > 15 and util.acronym(midi.vports[i].name) or midi.vports[i].name
        local device={
            name=name,
            port=i,
            midi=midi.connect(i),
        }
        table.insert(self.device_name_list,device.name)
        table.insert(self.devices,device)
        self.devices[i].midi.event = function(data) self:route(data, i) end
    end

    self:add_adv_params()
end

function dm:add_adv_params()
    params:add_group("device setup", #self.devices)
    for i=1,1 do
        params:add{
            type = "option", id = ("midi_port_"..i), name = ("port "..i..": "..self.device_name_list[i]),
            options = self.route_options, default = self:set_config_default((self.devices[i].name), 2),
            action = function(value)
                self.devices[i].route = self.route_options[value]
                self:build_output_device_list()
            end
        }
    end
    for i=2,2 do
        params:add{
            type = "option", id = ("midi_port_"..i), name = ("port "..i..": "..self.device_name_list[i]),
            options = self.route_options, default = self:set_config_default((self.devices[i].name), 3),
            action = function(value)
                self.devices[i].route = self.route_options[value]
                self:build_output_device_list()
            end
        }
    end
    for i=3,#self.devices do
        params:add{
            type = "option", id = ("midi_port_"..i), name = ("port "..i..": "..self.device_name_list[i]),
            options = self.route_options, default = self:set_config_default((self.devices[i].name), 1),
            action = function(value)
                self.devices[i].route = self.route_options[value]
                self:build_output_device_list()
            end
        }
    end
end

function dm:build_output_device_list()
    for i=1,#self.output_devices do
        self.output_devices[i] = nil
    end
    for i=1,#self.devices do
        if self.devices[i].route == "OUT" or self.devices[i].route == "IN/OUT" then
            table.insert(self.output_devices, self.devices[i])
        end
    end
end

function dm:set_config_default(name, default)
    if adv_config ~= nil then
        for _, item in pairs(adv_config) do
            if item[1]==name then
                self:print(item[1].." "..item[2])
                return item[2]
            end
        end
    end
    return default
end

function dm:route(data, i)
    if self.devices[i].route == "IN" then
        self:print("device: "..self.devices[i].name.." is configured for MIDI IN.")
        self:midi_in(data, i)
    elseif self.devices[i].route == "IN/OUT" then
        self:print("device: "..self.devices[i].name.." is configured for MIDI IN/OUT.")
        self:midi_in(data, i)
    elseif self.devices[i].route == "OUT" then
        self:print("device: "..self.devices[i].name.." is configured for MIDI OUT.")
    else
        self:print("device: "..self.devices[i].name.." is OFF.")
    end
end

function dm:midi_in(data, device_num)
    local d=midi.to_msg(data)
    -- if d.type~="clock" then self:print(d.type) end
    -- print(d.cc)
    -- print(d.val)
    -- print(d.ch)
    if d.type == "note_on" then
        self:print("note on")
        midi_event_note_on(d, device_num)
    elseif d.type == "note_off" then
        self:print("note off")
        midi_event_note_off(d)
    elseif d.type=="stop" then
        self:print("stop")
        midi_event_stop(d)
    elseif d.type=="start" then
        self:print("start")
        midi_event_start(d)
    elseif (d.type == "cc") then
        self:print("cc")
        midi_event_cc(d)
    --elseif (d.type == "cc" and d.cc == 123) then -- double tap stop on elektron boxes
    end
end

-- Add the following global functions to main script lua file

-- function midi_event_note_on(d) end

-- function midi_event_note_off(d) end

-- function midi_event_start(d) end

-- function midi_event_stop(d) end

-- function midi_event_cc(d) end

function dm:print(msg)
    if self.debug then print(msg) end
end

return dm