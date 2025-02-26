---@diagnostic disable: undefined-global, lowercase-global

local base = include 'lib/machines/base'

local machine = setmetatable({}, {__index = base})
machine.__index = machine

function machine.new()
	local self = setmetatable(base.new(), machine)
    self.draw_upper_grid = true

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
	local midi_note = layer.fixed_notes[position]
	screen.text("n"..position..":"..midi_note.."-"..music.note_num_to_name(midi_note, true))

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
	elseif self.interval_decrease_7 then delta = -8
	elseif self.interval_increase_7 then delta = 8
	end

	if delta ~= 0 then
		local num = layer.position
		if num > 0 then
			layer:set_fixed_note(num, delta, self.meta_shift_pressed)
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
end

function machine:get_current_gesture()
	local gesture
    if self.interval_decrease or self.interval_increase or self.interval_decrease_7 or self.interval_increase_7 then
		gesture = "+/- interval"
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
	event.iteration = event.iteration + 1
	if event.layer:is_muted() then return end
	harvest_fixed(event)
end

function machine:abort(event)
	if event.iteration > 0 then return true end
	return false
end

return machine.new()