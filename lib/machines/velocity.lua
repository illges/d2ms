---@diagnostic disable: undefined-global, lowercase-global

local machine = {}
machine.__index = machine

function machine.new()
	local self = setmetatable({}, machine)
    self.draw_upper_grid = true
	self.interval_decrease = false
    self.interval_increase = false
    self.interval_decrease_7 = false
    self.interval_increase_7 = false
	return self
end

function machine:draw_grid(layer, momentary)
    g:led(10, 8, basic_lighting(self.interval_decrease))
	g:led(11, 8, basic_lighting(self.interval_increase))
	g:led(9, 8, negative_lighting(self.interval_decrease_7))
	g:led(12, 8, negative_lighting(self.interval_increase_7))
end

function machine:draw_screen(layer)
    screen.level(4)
	screen.move(1, 52)
	local int = layer.riff_intervals[1]
	screen.text("int:"..int)
end

function machine:grid_key(layer, momentary)
    local delta = 0
	self.interval_decrease = momentary[10][8] == 1 and true or false
	self.interval_increase = momentary[11][8] == 1 and true or false
	self.interval_decrease_7 = momentary[9][8] == 1 and true or false
	self.interval_increase_7 = momentary[12][8] == 1 and true or false
	if self.interval_decrease then delta = -1
	elseif self.interval_increase then delta = 1
	elseif self.interval_decrease_7 then delta = -notes_context.piano.octave_size
	elseif self.interval_increase_7 then delta = notes_context.piano.octave_size
	end
	if delta ~= 0 then layer:set_riff_interval(1, delta, false) end
end

function machine:get_current_gesture()
    if self.interval_decrease or self.interval_increase or self.interval_decrease_7 or self.interval_increase_7 then
		return "+/- interval"
	end
end

function machine:process(event)
	if event.layer.gears_block == 1 then return end
	if event.layer.cc_send == 1 then
		route_cc(event)
	end
	if event.layer.notes_send == 1 then
		if notes_context.lane[event.lane].prime_ab then
			notes_context.lane[event.lane]:invert_b_section()
			notes_context.lane[event.lane].prime_ab = false
		end
		local step = harvest_velocity(event)
		notes_context:set_vel_step_visuals(event.lane, step)
		set_focus_x(event.lane,  step)
	end
end

return machine.new()