---@diagnostic disable: undefined-global, lowercase-global

local base = include 'lib/trigs/base'

local trig = setmetatable({}, {__index = base})
trig.__index = trig

function trig.new()
	local self = setmetatable(base.new(), trig)
    self.draw_upper_grid = false
	self.draw_machine_grid = false

	self.toggle_hold_to_tap = false
	self.toggle_tap_tempo_one_shot = false
	return self
end

function trig:draw_grid(layer, momentary)
    g:led(10, 6, basic_lighting(self.toggle_hold_to_tap or hold_to_tap == 1))
	g:led(11, 6, basic_lighting(self.toggle_tap_tempo_one_shot or layer.tap_tempo_one_shot == 1))
end

function trig:draw_screen(layer, transport)
	screen.level(4)
	screen.move(1, 52)
	local tap1 = self:get_tap_display(layer, transport, 1)
	local tap2 = self:get_tap_display(layer, transport, 2)
	local tap3 = self:get_tap_display(layer, transport, 3)
	local tap4 = self:get_tap_display(layer, transport, 4)
	screen.text("t1:"..tap1.." t2:"..tap2.." t3:"..tap3.." t4:"..tap4.." C:"..params:get("clock_tempo"))
end

function trig:get_tap_display(layer, transport, n)
	if layer.tap_tempo_one_shot == 1 and transport.tap_tempo_set == 1 then
		return "!!!"
	elseif n == 1 then
		return transport.tap_tempo_table[n] ~= nil and "->" or ((hold_to_tap == 1 and not isTapTempoPressed()) and "X" or "*")
	else
		return transport.tap_tempo_display[n] ~= nil and transport.tap_tempo_display[n] or "*"
	end
end

function trig:grid_key(layer, momentary, x, y, on)
    self.toggle_hold_to_tap = momentary[10][6] == 1 and true or false
	if self.toggle_hold_to_tap then invert_hold_to_tap() end
	self.toggle_tap_tempo_one_shot = momentary[11][6] == 1 and true or false
	if self.toggle_tap_tempo_one_shot then layer:invert_tap_tempo_one_shot() end

	if hold_to_tap == 1 and x==16 and y==8 and on==false then
		trig_context.transport.clear_tempo_table()
	end
end

function trig:get_current_gesture()
    local gesture
    if self.toggle_hold_to_tap then gesture = "global hold to tap"
	elseif self.toggle_tap_tempo_one_shot then gesture = "one shot"
	end
	return gesture
end

function trig:process(event)
	if hold_to_tap==1 and not isTapTempoPressed() then
		return
	elseif event.layer.tap_tempo_one_shot == 1 and trig_context.transport.tap_tempo_set == 1 then
		return
	end
	trig_context.transport.tap_tempo()
end

return trig.new()