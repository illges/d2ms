---@diagnostic disable: undefined-global, lowercase-global

local machine = {}
machine.__index = machine

function machine.new()
	local self = setmetatable({}, machine)
    self.draw_upper_grid = true

	--self.riff_pointer_pressed = false
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
    -- if #layer.riff_routing > 0 then
	--         g:led(9, 5, high_lighting(self.riff_pointer_pressed))
	--     else
	--         g:led(9, 5, basic_lighting(self.riff_pointer_pressed))
	--     end

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
	screen.move(30, 52)
	screen.text("Ln:"..layer.strum_length)
	screen.move(65, 52)
	screen.text("dv:1/"..layer.strum_division)
end

function machine:grid_key(layer, momentary)
	-- self.riff_pointer_pressed = momentary[9][5] == 1 and true or false

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
	self.continue_strum_pressed = momentary[11][5] == 1 and true or false
	if self.continue_strum_pressed then layer:invert_continue_strum() end
	self.mute_strum_pressed = momentary[12][5] == 1 and true or false
	if self.mute_strum_pressed then layer:invert_mute_strum() end
end

function machine:get_current_gesture()
	local gesture
    if self.interval_decrease or self.interval_increase or self.interval_decrease_7 or self.interval_increase_7 then
		gesture = "+/- interval"
	elseif self.cc_match_pressed then gesture = "cc match"
    elseif self.continue_strum_pressed then gesture = "continue strum"
    elseif self.mute_strum_pressed then gesture = "block re-strum"
	end
	return gesture
end

local zero_offset = 0

function machine:process(event)
	if event.layer.gears_block == 1 then return end
	local routing = {}
	local riff = false
	if #event.layer.riff_routing > 0 then
		routing = event.layer.riff_routing
		event.offset = event.layer.follow_offset
		riff = true
	else
		routing = {event.lane}
		event.offset = zero_offset
	end

	for i=1,#routing do
		if event.layer.mute_strum == 0 or (event.layer.mute_strum == 1 and notes_context.lane[routing[i]].strum_active == 0) then
			if notes_context.lane[routing[i]].prime_ab then
				notes_context.lane[routing[i]]:invert_b_section()
				notes_context.lane[routing[i]].prime_ab = false
			end
			local position = event.layer.continue_strum == 1 and notes_context.lane[routing[i]].strum_position or notes_context.lane[routing[i]].position
			local pattern = event.layer.continue_strum == 1 and notes_context.lane[routing[i]].strum_pattern or notes_context.lane[routing[i]].active_pattern
			clock.cancel(notes_context.lane[routing[i]].strum_clock_id)
			notes_context.lane[routing[i]]:set_position(position)
			notes_context.lane[routing[i]]:set_pattern(pattern)
			if event.layer.cc_send==1 and event.layer.cc_match==1 then
				local cc_position = 1
				for j=1,#event.channels do
					local channel = cc_context.channel[event.channels[j]]
					for k=1,16 do
						local slot = channel.lane[k]
						if slot.active == 1 then
							cc_position = event.layer.continue_strum == 1 and slot.strum_position or slot.position
							slot:set_position(cc_position)
						end
					end
				end
			end
			if riff then event.riff_lane = routing[i] end
			notes_context.lane[routing[i]].strum_clock_id = clock.run(strum, event, routing[i], riff)
		end
	end
end

function machine:process_v2(event)
	print("*****strum_v2*****")
	if event.layer.gears_block == 1 then return end
	local routing = {}
	if notes_context.lane[event.lane]:riff_lane() then
		event.riff_lane = event.lane
		event.offset = event.layer.follow_offset
		if #event.layer.leader_routing==0 then
			print("route leader pointer to note lane")
			return
		end
	else
		event.riff_lane = 0
		event.offset = zero_offset
	end
	routing = {event.lane}

	for i=1,#routing do
		if event.layer.mute_strum == 0 or (event.layer.mute_strum == 1 and notes_context.lane[routing[i]].strum_active == 0) then
			if notes_context.lane[routing[i]].prime_ab then
				notes_context.lane[routing[i]]:invert_b_section()
				notes_context.lane[routing[i]].prime_ab = false
			end
			local position = event.layer.continue_strum == 1 and notes_context.lane[routing[i]].strum_position or notes_context.lane[routing[i]].position
			local pattern = event.layer.continue_strum == 1 and notes_context.lane[routing[i]].strum_pattern or notes_context.lane[routing[i]].active_pattern
			clock.cancel(notes_context.lane[routing[i]].strum_clock_id)
			notes_context.lane[routing[i]]:set_position(position)
			notes_context.lane[routing[i]]:set_pattern(pattern)
			if event.layer.cc_send==1 and event.layer.cc_match==1 then
				local cc_position = 1
				for j=1,#event.channels do
					local channel = cc_context.channel[event.channels[j]]
					for k=1,16 do
						local slot = channel.lane[k]
						if slot.active == 1 then
							cc_position = event.layer.continue_strum == 1 and slot.strum_position or slot.position
							slot:set_position(cc_position)
						end
					end
				end
			end
			notes_context.lane[routing[i]].strum_clock_id = clock.run(strum, event, routing[i], event.riff_lane>0)
		end
	end
end

return machine.new()