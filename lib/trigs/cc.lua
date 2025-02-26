---@diagnostic disable: undefined-global, lowercase-global

local base = include 'lib/trigs/base'

local trig = setmetatable({}, {__index = base})
trig.__index = trig

function trig.new()
	local self = setmetatable(base.new(), trig)
    self.draw_upper_grid = false
    self.draw_machine_grid = false

    self.cc_num_inc = false
    self.cc_num_dec = false
    self.cc_val_inc = false
    self.cc_val_dec = false
    self.cc_val_2_inc = false
    self.cc_val_2_dec = false
    self.cc_num_inc_7 = false
    self.cc_num_dec_7 = false
    self.cc_val_inc_7 = false
    self.cc_val_dec_7 = false
    self.cc_val_2_inc_7 = false
    self.cc_val_2_dec_7 = false
    self.pulse_cc = false
	return self
end

function trig:draw_grid(layer, momentary)
    g:led(10, 8, basic_lighting(self.cc_num_dec))
    g:led(11, 8, basic_lighting(self.cc_num_inc))
    g:led(9, 8, negative_lighting(self.cc_num_dec_7))
    g:led(12, 8, negative_lighting(self.cc_num_inc_7))
    g:led(10, 7, basic_lighting(self.cc_val_2_dec))
    g:led(11, 7, basic_lighting(self.cc_val_2_inc))
    g:led(9, 7, negative_lighting(self.cc_val_2_dec_7))
    g:led(12, 7, negative_lighting(self.cc_val_2_inc_7))
    g:led(10, 6, basic_lighting(self.cc_val_dec))
    g:led(11, 6, basic_lighting(self.cc_val_inc))
    g:led(9, 6, negative_lighting(self.cc_val_dec_7))
    g:led(12, 6, negative_lighting(self.cc_val_inc_7))
    g:led(9, 5, basic_lighting(self.pulse_cc))
end

function trig:draw_grid_extended(layer, momentary)
    for i=1,16 do
        local light = 2
        if i==1 or i==5 or i==9 or i==13 then light = 4 end
        if layer.cc_ch[i] == 1 then light = 12 end
        light = cc_context.channel_visual[i] > 0 and cc_context.channel_visual[i] or light
        g:led(i, 2, light)
    end
end

function trig:draw_screen(layer)
    screen.level(4)
    screen.move(1, 52)
    local num = layer.cc_num
    local val = layer.cc_val
    local val2 = layer.cc_val_2
    screen.text("cc:"..num.." val:"..val.." val2:"..val2)
end

function trig:grid_key(layer, momentary, x, y, on)
    if y == 2 and on then
        layer:set_cc_ch(x)
        return
    end
    self.cc_num_dec = momentary[10][8] == 1 and true or false
    self.cc_num_inc = momentary[11][8] == 1 and true or false
    self.cc_val_2_dec = momentary[10][7] == 1 and true or false
    self.cc_val_2_inc = momentary[11][7] == 1 and true or false
    self.cc_val_dec = momentary[10][6] == 1 and true or false
    self.cc_val_inc = momentary[11][6] == 1 and true or false
    self.cc_num_dec_7 = momentary[9][8] == 1 and true or false
    self.cc_num_inc_7 = momentary[12][8] == 1 and true or false
    self.cc_val_2_dec_7 = momentary[9][7] == 1 and true or false
    self.cc_val_2_inc_7 = momentary[12][7] == 1 and true or false
    self.cc_val_dec_7 = momentary[9][6] == 1 and true or false
    self.cc_val_inc_7 = momentary[12][6] == 1 and true or false
    self.pulse_cc = momentary[9][5] == 1 and true or false
    if self.cc_num_dec then
        layer:set_cc_num(-1)
    end
    if self.cc_num_inc then
        layer:set_cc_num(1)
    end
    if self.cc_val_dec then
        layer:set_cc_val(-1)
    end
    if self.cc_val_inc then
        layer:set_cc_val(1)
    end
    if self.cc_val_2_dec then
        layer:set_cc_val_2(-1)
    end
    if self.cc_val_2_inc then
        layer:set_cc_val_2(1)
    end
    if self.cc_num_dec_7 then
        layer:set_cc_num(-10)
    end
    if self.cc_num_inc_7 then
        layer:set_cc_num(10)
    end
    if self.cc_val_dec_7 then
        layer:set_cc_val(-10)
    end
    if self.cc_val_inc_7 then
        layer:set_cc_val(10)
    end
    if self.cc_val_2_dec_7 then
        layer:set_cc_val_2(-10)
    end
    if self.cc_val_2_inc_7 then
        layer:set_cc_val_2(10)
    end
    if self.pulse_cc then
        self:bang(layer, layer.cc_val)
    end
end

function trig:get_current_gesture()
    local gesture
    if self.pulse_cc then gesture = "cc pulse"
	end
	return gesture
end

function trig:process(event)
    local val = event.layer.cc_val == event.layer.cc_val_memory and event.layer.cc_val_2 or event.layer.cc_val
    event.layer.cc_val_memory = val
	self:bang(event.layer, val)
end

function trig:bang(layer, val)
    local cc = layer.cc_num
    for ch=1,#layer.cc_ch do
       if layer.cc_ch[ch]==1 then
        for j=1,#device_manager.output_devices do
            device_manager.output_devices[j].midi:cc(cc, val, ch)
        end
        log_cc_update(cc, val, ch)
       end
    end
end

return trig.new()