---@diagnostic disable: undefined-global, lowercase-global

local machine = {}
machine.__index = machine

function machine.new()
	local self = setmetatable({}, machine)
    self.draw_upper_grid = true

	self.meta_option_1_increase = false
    self.meta_option_1_increase_double = false
    self.meta_option_1_decrease = false
    self.meta_option_1_decrease_half = false
    self.meta_option_2_increase = false
    self.meta_option_2_increase_double = false
    self.meta_option_2_decrease = false
    self.meta_option_2_decrease_half = false
	self.interval_decrease = false
    self.interval_increase = false
    self.interval_decrease_7 = false
    self.interval_increase_7 = false
	self.cc_match_pressed = false
    self.continue_strum_pressed = false
    self.mute_strum_pressed = false
	return self
end

function machine:draw_grid(layer, momentary)
    g:led(10, 5, negative_lighting(layer.cc_match == 1))
	g:led(11, 5, negative_lighting(layer.continue_strum == 1))
	g:led(12, 5, negative_lighting(layer.mute_strum == 1))
	g:led(10, 6, basic_lighting(self.meta_option_1_decrease))
	g:led(11, 6, basic_lighting(self.meta_option_1_increase))
	g:led(9, 6, negative_high_lighting(self.meta_option_1_decrease_half))
	g:led(12, 6, negative_high_lighting(self.meta_option_1_increase_double))
	g:led(10, 7, basic_lighting(self.meta_option_2_decrease))
	g:led(11, 7, basic_lighting(self.meta_option_2_increase))
	g:led(9, 7, negative_high_lighting(self.meta_option_2_decrease_half))
	g:led(12, 7, negative_high_lighting(self.meta_option_2_increase_double))

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
	screen.move(65, 52)
	screen.text("ln:"..layer.strum_length)
	screen.move(30, 52)
	screen.text("dv:1/"..layer.strum_division)
end

function machine:grid_key(layer, momentary)
    self.meta_option_1_decrease = momentary[10][6] == 1 and true or false
	self.meta_option_1_increase = momentary[11][6] == 1 and true or false
	self.meta_option_2_decrease = momentary[10][7] == 1 and true or false
	self.meta_option_2_increase = momentary[11][7] == 1 and true or false
	self.meta_option_1_decrease_half = momentary[9][6] == 1 and true or false
	self.meta_option_1_increase_double = momentary[12][6] == 1 and true or false
	self.meta_option_2_decrease_half = momentary[9][7] == 1 and true or false
	self.meta_option_2_increase_double = momentary[12][7] == 1 and true or false
	if self.meta_option_1_decrease then layer:set_strum_division(-1) end
	if self.meta_option_1_increase then layer:set_strum_division(1) end
	if self.meta_option_2_decrease then layer:set_strum_length(-1) end
	if self.meta_option_2_increase then layer:set_strum_length(1) end
	if self.meta_option_1_decrease_half then layer:set_strum_division("h") end
	if self.meta_option_1_increase_double then layer:set_strum_division("d") end
	if self.meta_option_2_decrease_half then layer:set_strum_length("h") end
	if self.meta_option_2_increase_double then layer:set_strum_length("d") end

	self.cc_match_pressed = momentary[10][5] == 1 and true or false
	if self.cc_match_pressed then layer:invert_cc_match() end
	-- self.continue_strum_pressed = momentary[11][5] == 1 and true or false
	-- if self.continue_strum_pressed then layer:invert_continue_strum() end
	-- self.mute_strum_pressed = momentary[12][5] == 1 and true or false
	-- if self.mute_strum_pressed then layer:invert_mute_strum() end

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
    local gesture
    if self.interval_decrease or self.interval_increase or self.interval_decrease_7 or self.interval_increase_7 then
		gesture = "+/- interval"
	elseif self.cc_match_pressed then gesture = "cc match"
    -- elseif self.continue_strum_pressed then gesture = "continue strum"
    -- elseif self.mute_strum_pressed then gesture = "mute strum"
	end
	return gesture
end

local zero_offset = 0

function machine:process(event)
	if event.layer.gears_block == 1 then return end
	event.offset = zero_offset
	if event.layer.notes_send == 1 then
		if notes_context.lane[event.lane].prime_ab then
			notes_context.lane[event.lane]:invert_b_section()
			notes_context.lane[event.lane].prime_ab = false
		end
		--clock.cancel(notes_context.lane[event.lane].strum_clock_id)
		notes_context.lane[event.lane].strum_clock_id = clock.run(ratchet, event)
	end
end

return machine.new()