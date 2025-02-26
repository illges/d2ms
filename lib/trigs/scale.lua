---@diagnostic disable: undefined-global, lowercase-global

local base = include 'lib/trigs/base'

local trig = setmetatable({}, {__index = base})
trig.__index = trig

function trig.new()
	local self = setmetatable(base.new(), trig)
    self.draw_upper_grid = false
	self.draw_machine_grid = false
	self.auto_trig = true

	self.interval_decrease = false
    self.interval_increase = false
    self.interval_decrease_7 = false
    self.interval_increase_7 = false
    self.auto_seq_random_robin_pressed = false
    self.auto_seq_round_robin_pressed = false
    self.auto_seq_vel_mode_pressed = false
	return self
end

function trig:draw_grid(layer, momentary)
    g:led(10, 8, basic_lighting(self.auto_value_decrease))
	g:led(11, 8, basic_lighting(self.auto_value_increase))
	g:led(9, 5, negative_lighting(self.auto_seq_round_robin_pressed or layer.round_robin == 1))
	g:led(10, 5, negative_lighting(self.auto_seq_random_robin_pressed or layer.random_robin == 1))
	g:led(11, 5, negative_lighting(self.auto_seq_vel_mode_pressed or layer.vel_mode == 1))
	for i=1,8 do
		local light = 1
		local max = layer.range.max
		local min = layer.range.min
		if i <= max and i >= min then light = 2 end
		if i == layer.position then light = 4 end
		if i < 5 then
			if momentary[8+i][6] == 1 then light = 15 end
			g:led(8+i, 6, light)
		else
			if momentary[4+i][7] == 1 then light = 15 end
			g:led(4+i, 7, light)
		end
	end
end

function trig:draw_screen(layer)
	screen.level(4)
	screen.move(1, 52)
	local position = layer.position
	local val = layer.scale_sequence[layer.position]
	screen.text("n"..position..":"..music.SCALES[val].name)
end

function trig:grid_key(layer, momentary)
    self.auto_seq_round_robin_pressed = momentary[9][5] == 1 and true or false
	self.auto_seq_random_robin_pressed = momentary[10][5] == 1 and true or false
	self.auto_seq_vel_mode_pressed = momentary[11][5] == 1 and true or false
	if self.auto_seq_round_robin_pressed then layer:set_round_robin(1)
	elseif self.auto_seq_random_robin_pressed then layer:set_random_robin(1)
	elseif self.auto_seq_vel_mode_pressed then layer:set_vel_mode(1)
	end

	local delta = 0
	self.interval_decrease = momentary[10][8] == 1 and true or false
	self.interval_increase = momentary[11][8] == 1 and true or false
	self.interval_decrease_7 = momentary[9][8] == 1 and true or false
	self.interval_increase_7 = momentary[12][8] == 1 and true or false
	if self.interval_decrease then delta = -1
	elseif self.interval_increase then delta = 1
	elseif self.interval_decrease_7 then delta = -12
	elseif self.interval_increase_7 then delta = 12
	end

	if delta ~= 0 then
		local num = layer.position
		if num > 0 then
			layer:set_scale(num, layer.scale_sequence[num] + delta)
		end
	end
end

function trig:get_current_gesture()
    local gesture
    if self.interval_decrease or self.interval_increase or self.interval_decrease_7 or self.interval_increase_7 then
		gesture = "+/- scale"
	elseif self.auto_seq_round_robin_pressed then gesture = "round robin"
    elseif self.auto_seq_random_robin_pressed then gesture = "random robin"
    elseif self.auto_seq_vel_mode_pressed then gesture = "velocity robin"
	end
	return gesture
end

function trig:process(event)
	local layer = event.layer
	if layer.vel_mode == 1 then
		event.layer:get_vel_step_threshold()
		layer:adv_position(event.vel_in)
		trig_context.auto_sequence_visual = layer.position
		notes_context.piano:set_scale(event.layer.scale_sequence[event.layer.position])
	else
		notes_context.piano:set_scale(event.layer.scale_sequence[event.layer.position])
		layer:adv_position(0)
		trig_context.auto_sequence_visual = layer.position
	end
end

return trig.new()