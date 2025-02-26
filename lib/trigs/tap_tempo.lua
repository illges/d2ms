---@diagnostic disable: undefined-global, lowercase-global

local base = include 'lib/trigs/base'

local trig = setmetatable({}, {__index = base})
trig.__index = trig

function trig.new()
	local self = setmetatable(base.new(), trig)
    self.draw_upper_grid = false
	self.draw_machine_grid = false

	self.toggle_hold_to_tap = false
	return self
end

function trig:draw_grid(layer, momentary)
    g:led(10, 6, basic_lighting(self.toggle_hold_to_tap or hold_to_tap == 1))
end

function trig:draw_screen(layer, transport)
	screen.level(4)
	screen.move(1, 52)
	local tap1 = (hold_to_tap == 1 and not isTapTempoPressed()) and "X" or "*"
	tap1 = transport.tap_tempo_table[1] ~= nil and "->" or tap1
	local tap2 = transport.tap_tempo_display[2] ~= nil and transport.tap_tempo_display[2] or "*"
	local tap3 = transport.tap_tempo_display[3] ~= nil and transport.tap_tempo_display[3] or "*"
	local tap4 = transport.tap_tempo_display[4] ~= nil and transport.tap_tempo_display[4] or "*"
	screen.text("t1:"..tap1.." t2:"..tap2.." t3:"..tap3.." t4:"..tap4.." C:"..params:get("clock_tempo"))
end

function trig:grid_key(layer, momentary, x, y, on)
    self.toggle_hold_to_tap = momentary[10][6] == 1 and true or false
	if self.toggle_hold_to_tap then
		invert_hold_to_tap()
	end
	if hold_to_tap == 1 and x==16 and y==8 and on==false then
		trig_context.transport.clear_tempo_table()
	end
end

function trig:get_current_gesture()
    local gesture
    if self.toggle_hold_to_tap then gesture = "global hold to tap"
	end
	return gesture
end

function trig:process(event)
	if hold_to_tap==1 and
		not isTapTempoPressed() then
		return
	end
	trig_context.transport.tap_tempo()
end

return trig.new()