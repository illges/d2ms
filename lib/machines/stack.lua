---@diagnostic disable: undefined-global, lowercase-global

local base = include 'lib/machines/base'
local stack_chords = include 'lib/config/stack_chord_intervals'

local machine = setmetatable({}, {__index = base})
machine.__index = machine

function machine.new()
	local self = setmetatable(base.new(), machine)
    self.draw_upper_grid = true
	self.chord_player = true
	self.meta_step_pressed = 0

	self.meta_shift_pressed = false
	self.interval_decrease = false
    self.interval_increase = false
    self.interval_decrease_7 = false
    self.interval_increase_7 = false
	self.fixed_note_random_robin_pressed = false
    self.fixed_note_round_robin_pressed = false
    self.fixed_note_vel_mode_pressed = false
	self.fixed_note_reset_mode_pressed = false
	self.fixed_note_one_shot_mode_pressed = false
	self.fixed_note_hold_release_mode_pressed = false
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

	g:led(9, 5, negative_lighting(self.fixed_note_round_robin_pressed or layer.round_robin == 1))
	g:led(10, 5, negative_lighting(self.fixed_note_random_robin_pressed or layer.random_robin == 1))
	g:led(11, 5, negative_lighting(self.fixed_note_vel_mode_pressed or layer.vel_mode == 1))
	g:led(12, 5, negative_lighting(self.fixed_note_reset_mode_pressed or layer.reset_mode == 1))
	g:led(14, 8, basic_lighting(self.fixed_note_one_shot_mode_pressed or layer.one_shot_mode == 1))
	self:draw_grid_hold_release_mode(layer)

	if self.meta_shift_pressed then
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
	screen.move(1, 52)
	local position = layer.position
	--local int = layer.riff_intervals[position]
	local int = layer.riff_intervals[1]
	local offset = layer.follow_offset
	screen.text("int:"..int)

	screen.move(32, 52)
	local strum = layer.chord_strum_division
	screen.text("dv:1/"..strum)

	self:draw_screen_hold_release_mode(layer)
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
			if self.meta_shift_pressed then
				local val
				if delta == -notes_context.piano.octave_size then val = "h"
				elseif delta == notes_context.piano.octave_size then val = "d"
				else val = delta
				end
				layer:set_chord_strum(val)
			else
				--layer:set_riff_interval(num, delta, self.meta_shift_pressed)
				layer:set_riff_interval(1, delta, false)
			end
		end
	end

	self.fixed_note_round_robin_pressed = momentary[9][5] == 1 and true or false
	self.fixed_note_random_robin_pressed = momentary[10][5] == 1 and true or false
	self.fixed_note_vel_mode_pressed = momentary[11][5] == 1 and true or false
	self.fixed_note_reset_mode_pressed = momentary[12][5] == 1 and true or false
	self.fixed_note_one_shot_mode_pressed = momentary[14][8] == 1 and true or false
	if self.fixed_note_round_robin_pressed then layer:set_round_robin(1)
	elseif self.fixed_note_random_robin_pressed then layer:set_random_robin(1)
	elseif self.fixed_note_vel_mode_pressed then layer:set_vel_mode(1)
	elseif self.fixed_note_reset_mode_pressed then layer:set_reset_mode()
	elseif self.fixed_note_one_shot_mode_pressed then layer:set_one_shot_mode()
	end
	self:grid_key_hold_release_mode(layer, momentary)

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
	--local val = machine_context:get_current_layer().riff_intervals[self.meta_step_pressed]
    for i=1,#stack_chords do
        light = 6
		if machine_context:get_current_layer().stack_chord[self.meta_step_pressed]==i then light=15 end
		g:led(i, 1, light)
    end

	for j=1,machine_context:get_current_layer():get_stack_chord_length() do
		light = 6
		if machine_context:get_current_layer().stack_inversion[self.meta_step_pressed]==j then light=15 end
		g:led(j, 3, light)
	end
end

function machine:set_meta_and_play(x,y,layer,num)
	if y==1 then
		layer:set_stack_chord_seq_val(self.meta_step_pressed, x)
		self:play(layer,num)
	elseif y==3 then
		layer:set_stack_inversion_seq_val(self.meta_step_pressed, x)
		self:play(layer,num)
	end
end

function machine:play(layer,num)
	-- play layer routing with interval value
	for i=1,16 do
		if layer.lane_send[i]==1 then
			local channels = machine_context.layer_routing[num].output_list[i]
			for j=1,#channels do
				local root = notes_context.lane[i]:data() + layer:get_interval()
				local chord = layer:get_stack_chord(root)
				for k=1,#chord do
					play_midi(false, chord[k], notes_context.piano.p_vel, channels[j], layer:get_hold_time()) -- note number, velocity, channel, duration
				end
			end
		end
	end
end

function machine:get_current_gesture()
    local gesture
    if (self.interval_decrease or self.interval_increase) and self.meta_shift_pressed then gesture = "+/- division"
	elseif (self.interval_decrease or self.interval_increase) then gesture = "+/- interval"
	elseif (self.interval_decrease_7 or self.interval_increase_7) and self.meta_shift_pressed then gesture = "+/- division"
	elseif (self.interval_decrease_7 or self.interval_increase_7)  then gesture = "+/- interval"
	elseif self.fixed_note_round_robin_pressed then gesture = "round robin"
    elseif self.fixed_note_random_robin_pressed then gesture = "random robin"
    elseif self.fixed_note_vel_mode_pressed then gesture = "velocity robin"
	elseif self.fixed_note_reset_mode_pressed then gesture = "reset on adv"
	elseif self.fixed_note_one_shot_mode_pressed then gesture = "one shot robin"
	elseif self.fixed_note_hold_release_mode_pressed then gesture = self.hold_release_mode_text
	end
	return gesture
end

function machine:process(event)
	self:process_follower(event)
end

function machine:work(routing, event)
	if event.layer:is_muted() then return end
	local pos = notes_context.lane[routing].position
	local division = event.layer.chord_strum_division
	clock.run(stack, routing, event, division, pos)
end

function machine:abort(event)
	if event.layer.mute_strum == 1 and notes_context.lane[event.lane].chord_strum_active == 1 then
		return true
	end
	return false
end

return machine.new()