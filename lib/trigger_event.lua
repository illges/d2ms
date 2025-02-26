---@diagnostic disable: undefined-global, lowercase-global

local event = {}
event.__index = event

function event.new(vel)
	local self = setmetatable({}, event)
    self.vel_in = vel
    self.vel_out = vel
    self.vel_raw = vel
    self.layer = {}
    self.input_num = 0
    self.layer_num = 0
    self._input = {} -- input instance
    self.proxy_ignore_mutes = false
    self.lane = 0
    self.channels = {}

    self.offset = 0
    self.riff_lane = 0
    self.iteration = 0
	return self
end

function event:set_machine_layer(input,layer,io)
    self.layer = io[input].machine[layer]
    self:set_common(input,layer,io)
end

function event:set_trig_layer(input,layer,io)
    self.layer = io[input].trig[layer]
    self:set_common(input,layer,io)
end

function event:set_common(input,layer,io)
    self.input_num = input
    self.layer_num = layer
    self._input = io[input]
end

function event:set_velocity(input,layer,io)
    if self.layer.invert_velocity == 1 then
        self.vel_out = 128 - self.vel_in
    end
    self.vel_out = self.layer.pass_vel == 1 and self.vel_out or io[input].machine[layer].d_vel_out
end

function event:set_bulk(lane, channels, vel_in, vel_out, vel_raw, layer, _input, input_num, layer_num)
    self.lane = lane
    self.channels = channels
    self.vel_in = vel_in
    self.vel_out = vel_out
    self.vel_raw = vel_raw
    self.layer = layer
    self._input = _input -- input instance
    self.input_num = input_num
    self.layer_num = layer_num
end

return event