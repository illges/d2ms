---@diagnostic disable: undefined-global, lowercase-global

local machine = {}
machine.__index = machine

function machine.new()
	local self = setmetatable({}, machine)
    self.draw_upper_grid = true
	self.interval_player = true
	self.meta_step_pressed = 0

	self.meta_shift_pressed = false
	self.chord_strum_pressed = false
    self.chord_vel_density_pressed = false
	self.interval_decrease = false
    self.interval_increase = false
    self.interval_decrease_7 = false
    self.interval_increase_7 = false
	self.mute_strum_pressed = false
	self.fixed_note_one_shot_mode_pressed = false
	return self
end

function machine:draw_grid(layer, momentary)
    for i=1,8 do
		local light = 1
		local max = layer.range.max
		local min = layer.range.min
		if i <= max and i >= min then light = 2 end
		if layer.meta_seq_step_mute[i]==1 then light = 0 end
		if layer.meta_seq_one_shots[i]==0 then light = 0 end
		if i == layer.position then light = 4 end
		if i < 5 then
			if momentary[8+i][6] == 1 then light = 15 end
			g:led(8+i, 6, light)
		else
			if momentary[4+i][7] == 1 then light = 15 end
			g:led(4+i, 7, light)
		end
	end

	g:led(11, 5, negative_lighting(self.chord_vel_density_pressed or layer.chord_vel_density == 1))
    g:led(9, 5, negative_lighting(self.chord_strum_pressed))
	g:led(12, 5, negative_lighting(layer.mute_strum == 1))
	g:led(14, 8, basic_lighting(self.fixed_note_one_shot_mode_pressed or layer.one_shot_mode == 1))

	if self.chord_strum_pressed or self.meta_shift_pressed then
		g:led(10, 8, high_lighting(self.interval_decrease))
		g:led(11, 8, high_lighting(self.interval_increase))
		g:led(9, 8, basic_lighting(self.interval_decrease_7))
		g:led(12, 8, basic_lighting(self.interval_increase_7))
	else
		g:led(10, 8, basic_lighting(self.interval_decrease))
		g:led(11, 8, basic_lighting(self.interval_increase))
		g:led(9, 8, negative_lighting(self.interval_decrease_7))
		g:led(12, 8, negative_lighting(self.interval_increase_7))
	end
end

function machine:draw_screen(layer)
    screen.level(4)
	screen.move(55, 52)
	local strum = layer.chord_strum_division
	screen.text("dv:1/"..strum)

	screen.move(1, 52)
	local position = layer.position
	local int = layer.riff_intervals[position]
	local offset = layer.follow_offset
	screen.text("n"..position..":"..int.." ofst:"..offset)
end

function machine:grid_key(layer, momentary)
	self.meta_shift_pressed = momentary[13][8] == 1 and true or false

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

	if delta ~= 0 then
		local num = layer.position
		if num > 0 then
			if self.chord_strum_pressed then
				local val
				if delta == -notes_context.piano.octave_size then val = "h"
				elseif delta == notes_context.piano.octave_size then val = "d"
				else val = delta
				end
				layer:set_chord_strum(val)
			else
				layer:set_riff_interval(num, delta, self.meta_shift_pressed)
			end
		end
	end

	self.chord_vel_density_pressed = momentary[11][5] == 1 and true or false
	if self.chord_vel_density_pressed then
		layer:invert_chord_vel_density()
		layer:set_one_shot_mode(0) -- for now chord one shot mode cant work with vel to density
	end
	self.chord_strum_pressed = momentary[9][5] == 1 and true or false
	self.mute_strum_pressed = momentary[12][5] == 1 and true or false
	if self.mute_strum_pressed then layer:invert_mute_strum() end
	self.fixed_note_one_shot_mode_pressed = momentary[14][8] == 1 and true or false
	if self.fixed_note_one_shot_mode_pressed then
		layer:set_one_shot_mode()
		layer:invert_chord_vel_density(0) -- for now chord one shot mode cant work with vel to density
	end

	self.meta_step_pressed = 0
	for y=6,7 do
		for x=9,12 do
			if momentary[x][y] == 1 then
				if y == 6 then self.meta_step_pressed = x-8
				elseif y == 7 then self.meta_step_pressed = x-4
				end
			end
		end
	end
end

function machine:draw_interval_player()
    local light = 15
	local val = machine_context:get_current_layer().riff_intervals[self.meta_step_pressed]
    g:led(1, 2, val==0 and light or 6)
    for i=1,4 do
        for j=2,15 do
            light = 6
			if i==1 then if val==j+13 then light=15 end
			elseif i==2 then if val==j-1 then light=15 end
			elseif i==3 then if val==(j-1)*-1 then light=15 end
			else if val==(j-1)*(-1)-14 then light=15 end
			end
            g:led(j, i, light)
        end
    end
end

function machine:set_meta_and_play(x,y,layer, num)
	local val = 0
	if y==1 then val = (x-1)+14
	elseif y==2 then val = x-1
	elseif y==3 then val = (x-1)*-1
	elseif y==4 then val = ((x-1)*-1)-14
	end
	layer:set_riff_interval_val(self.meta_step_pressed, val)
	-- play layer routing with interval value
	for i=1,16 do
		if layer.lane_send[i]==1 then
			local channels = machine_context.layer_routing[num].output_list[i]
			for j=1,#channels do
				local note = util.clamp(notes_context.lane[i]:data() + val, 1, 57)
				play_midi(true, note, notes_context.piano.p_vel, channels[j], layer:get_hold_time()) -- note number, velocity, channel, duration
			end
		end
	end
end

function machine:get_current_gesture()
	local gesture
    if (self.interval_decrease or self.interval_increase or self.interval_decrease_7 or self.interval_increase_7) and not self.chord_strum_pressed then
		gesture = "+/- interval"
	elseif self.chord_strum_pressed then gesture = "chord strum division"
    elseif self.chord_vel_density_pressed then gesture = "vel chord density"
	elseif self.mute_strum_pressed then gesture = "block re-strum"
	elseif self.fixed_note_one_shot_mode_pressed then gesture = "one shot robin"
	end
	return gesture
end

local zero_offset = 0

function machine:process(event)
	local retrig = false
	if event.layer.gears_block == 1 and event.layer.gears_retrig == 1 then
		retrig = true
	end
	event.layer:get_vel_step_threshold()
	local length = event.layer.chord_vel_density == 1 and event.layer:get_vel_length(event.vel_in) or event.layer.length
	local division = event.layer.chord_strum_division
	if event.layer.notes_send == 1 then
		local routing = event.layer.leader_routing
		if #routing == 0 then
			if (event.layer.mute_strum == 1 and notes_context.lane[event.lane].chord_strum_active == 1) or event.layer:check_play() == false then
				return
			end
			if notes_context.lane[event.lane].prime_ab then
				notes_context.lane[event.lane]:invert_b_section()
				notes_context.lane[event.lane].prime_ab = false
			end
			local pos = notes_context.lane[event.lane].position
			notes_context:set_note_visual(event.lane, event.offset == 1 and notes_context.lane[event.lane].prev_position or pos)
			if not retrig then advance_lane_position(notes_context.lane[event.lane],event.lane) end
			event.offset = zero_offset
			clock.run(chord, event.lane, event, length, division, pos)
		elseif not retrig then
			for i=1,#routing do
				if (event.layer.mute_strum == 1 and notes_context.lane[routing[i]].chord_strum_active == 1) or event.layer:check_play() == false then
					return
				end
				local pos = notes_context.lane[routing[i]].position
				event.offset = event.layer.follow_offset
				clock.run(chord, routing[i], event, length, division, pos)
			end
		end
	end
end

return machine.new()