---@diagnostic disable: undefined-global, lowercase-global

local machine = {}
machine.__index = machine

function machine.new()
	local self = setmetatable({}, machine)
    self.draw_upper_grid = true
	self.chord_player = true
	self.meta_step_pressed = 0

	self.meta_shift_pressed = false
	self.change_chord_pressed = false
	self.interval_decrease = false
    self.interval_increase = false
    self.interval_decrease_7 = false
    self.interval_increase_7 = false
	self.fixed_note_random_robin_pressed = false
    self.fixed_note_round_robin_pressed = false
    self.fixed_note_vel_mode_pressed = false
	self.fixed_note_reset_mode_pressed = false
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

	g:led(9, 5, negative_lighting(self.fixed_note_round_robin_pressed or layer.round_robin == 1))
	g:led(10, 5, negative_lighting(self.fixed_note_random_robin_pressed or layer.random_robin == 1))
	g:led(11, 5, negative_lighting(self.fixed_note_vel_mode_pressed or layer.vel_mode == 1))
	g:led(12, 5, negative_lighting(self.fixed_note_reset_mode_pressed or layer.reset_mode == 1))
	g:led(14, 8, basic_lighting(self.fixed_note_one_shot_mode_pressed or layer.one_shot_mode == 1))

	if self.meta_shift_pressed or self.change_chord_pressed then
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
	local chord = layer.chord_seq[position]
	local inversion = layer.inversion_seq[position]
	local name = music.CHORDS[chord].alt_names and music.CHORDS[chord].alt_names[1] or music.CHORDS[chord].name
	--screen.text("n"..position..":"..int.." :"..name.."("..inversion..")")
	screen.text("int:"..int.." n"..position..":"..name.."("..inversion..")")

	screen.move(127, 52)
	local strum = layer.chord_strum_division
	screen.text_right("dv:1/"..strum)
end

function machine:grid_key(layer, momentary)
    self.meta_shift_pressed = momentary[13][8] == 1 and true or false
	self.change_chord_pressed = momentary[15][8] == 1 and true or false

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
			elseif self.change_chord_pressed then
				if self.interval_decrease then
					layer:set_chord_seq(layer.position, -1)
				elseif self.interval_increase then
					layer:set_chord_seq(layer.position, 1)
				elseif self.interval_decrease_7 then
					layer:set_inversion_seq(layer.position, -1)
				elseif self.interval_increase_7 then
					layer:set_inversion_seq(layer.position, 1)
				end
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
    local light = 3
    for i=1,2 do
        for j=1,13 do
			light = 3
			if i==1 and (j==1 or j==8) then light = 8 end -- major, dominant
			if i==2 and j==4 then light = 8 end -- minor
			if machine_context:get_current_layer().chord_seq[self.meta_step_pressed] == j + (i-1)*13 then
				light = 15
			end
            g:led(j+i, i+1, light)
        end
    end
end

function machine:set_meta_and_play(x,y,layer, num)
	local val = 0
	if y==2 then val = x-1
	-- elseif y==3 then val = #music.CHORDS - (x-2)
	elseif y==3 then val = 13 + (x-2)
	end
	layer:set_chord_seq_val(self.meta_step_pressed, val)
	-- -- play layer routing with interval value
	for i=1,16 do
		if layer.lane_send[i]==1 then
			local channels = machine_context.layer_routing[num].output_list[i]
			for j=1,#channels do
				local root = notes_context.piano.scale[notes_context.lane[i]:data() + layer:get_interval()]
				local chord = layer:get_chord(root)
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
	elseif (self.interval_decrease or self.interval_increase) and self.change_chord_pressed then gesture = "+/- chord type"
	elseif (self.interval_decrease or self.interval_increase) then gesture = "+/- interval"
	elseif (self.interval_decrease_7 or self.interval_increase_7) and self.meta_shift_pressed then gesture = "+/- division"
	elseif (self.interval_decrease_7 or self.interval_increase_7) and self.change_chord_pressed then gesture = "+/- inversion"
	elseif (self.interval_decrease_7 or self.interval_increase_7)  then gesture = "+/- interval"
	elseif self.change_chord_pressed then gesture = "chord params"
	elseif self.fixed_note_round_robin_pressed then gesture = "round robin"
    elseif self.fixed_note_random_robin_pressed then gesture = "random robin"
    elseif self.fixed_note_vel_mode_pressed then gesture = "velocity robin"
	elseif self.fixed_note_reset_mode_pressed then gesture = "reset on adv"
	elseif self.fixed_note_one_shot_mode_pressed then gesture = "one shot robin"
	end
	return gesture
end

function machine:process(event)
	if processing_v2==1 then
		self:process_v2(event)
	else
		self:process_v1(event)
	end
end

function machine:process_v1(event)
	local retrig = false
	local play = false
	if event.layer.gears_block == 1 and event.layer.gears_retrig == 1 then
		retrig = true
	end
	if event.layer.cc_send == 1 then
		route_cc(event)
	end
	if event.layer.notes_send == 1 then
		local routing = event.layer.leader_routing
		local adv_lane = false
		event.offset = event.layer.follow_offset
		if #routing == 0 then
			routing = {event.lane}
			adv_lane = true
		end
		for i=1,#routing do
			if event.layer.mute_strum == 1 and notes_context.lane[event.lane].chord_strum_active == 1 then
				return
			end
			local reset = false
			local pos = notes_context.lane[routing[i]].position
			local division = event.layer.chord_strum_division
			if event.layer.reset_mode==1 then
				if notes_context.lane[routing[i]].reset_flag==1 or
					event.layer.prev_routing_pos[routing[i]] ~= notes_context.lane[routing[i]].position then
					reset = true
					notes_context.lane[routing[i]].reset_flag=0
				end
			end
			if event.layer.vel_mode == 1 and not reset then
				if event.layer.gears_block == 1 then return end
				event.layer:get_vel_step_threshold()
				event.layer:adv_position(event.vel_in)
				machine_context.fixed_note_visual = event.layer.position
				if event.layer:check_play() then
					clock.run(prog, routing[i], event, division, pos)
				end
			else
				if reset then
					event.layer:reset_meta_seq()
					machine_context.fixed_note_visual = event.layer.position
				end
				if event.layer:check_play() then
					play = true
					clock.run(prog, routing[i], event, division, pos)
				end
				machine_context.fixed_note_visual = event.layer.position
				event.layer.prev_routing_pos[routing[i]] = notes_context.lane[routing[i]].position
			end
		end
		if (play or event.layer:is_muted()) and not retrig and event.layer.vel_mode ~= 1 then event.layer:adv_position(0) end
		if (play or event.layer:is_muted()) and not retrig and adv_lane then advance_lane_position(notes_context.lane[event.lane],event.lane) end
	end
end

function machine:process_v2(event)
	print("****PROG_V2*****")
	local retrig = false
	local play = false
	if event.layer.gears_block == 1 and event.layer.gears_retrig == 1 then
		retrig = true
	end
	if event.layer.cc_send == 1 then
		route_cc(event)
	end
	if event.layer.notes_send == 1 then
		local routing = event.layer.leader_routing
		event.offset = event.layer.follow_offset
		if #routing == 0 then
			print("***error - route leader to note lane***")
			return
		end
		for i=1,#routing do
			local division = 32
			local pos = notes_context.lane[routing[i]].position
			clock.run(prog_v2, event.lane, routing[i], event, division, pos)
			advance_lane_position(notes_context.lane[routing[i]],routing[i])
		end
		advance_lane_position(notes_context.lane[event.lane],event.lane)
	end
end

return machine.new()