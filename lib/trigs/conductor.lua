---@diagnostic disable: undefined-global, lowercase-global

local base = include 'lib/trigs/base'

local trig = setmetatable({}, {__index = base})
trig.__index = trig

function trig.new()
	local self = setmetatable(base.new(), trig)
    self.draw_upper_grid = true
	self.draw_machine_grid = false
	self.handle_tracks_internal = true
	self.option_prev = false
    self.option_next = false
	self.group_advance_pressed = false
	self.toggle_conduct_pattern = false
	self.toggle_conduct_patch = false
	self.toggle_conduct_scene = false
	self.toggle_reset_on_adv = false
	return self
end

function trig:draw_grid(layer, momentary)
	g:led(9, 5, basic_lighting(layer.conduct_pattern == 1))
	g:led(10, 5, basic_lighting(layer.conduct_patch == 1))
	g:led(11, 5, basic_lighting(layer.conduct_scene == 1))

	g:led(11, 6, basic_lighting(self.toggle_reset_on_adv or layer.reset_on_adv == 1))
    g:led(10, 7, basic_lighting(self.group_advance_pressed or layer.group_advance == 1))
	g:led(10, 8, basic_lighting(self.option_prev))
    g:led(11, 8, basic_lighting(self.option_next))
end

function trig:draw_screen(layer)
	local group = layer.group_advance==1 and 'Y' or 'N'
    screen.level(4)
	screen.move(1, 52)
	screen.text("direct:"..layer.pattern_num)
	screen.move(45, 52)
	screen.text("group:"..group)

	local reset = layer.reset_on_adv==1 and 'Y' or 'N'
	screen.move(85, 52)
	screen.text("reset:"..reset)
end

function trig:grid_key(layer, momentary)
	self.toggle_conduct_pattern = momentary[9][5] == 1 and true or false
	self.toggle_conduct_patch = momentary[10][5] == 1 and true or false
	self.toggle_conduct_scene = momentary[11][5] == 1 and true or false
    self.option_prev = momentary[10][8] == 1 and true or false
	self.option_next = momentary[11][8] == 1 and true or false
	self.group_advance_pressed = momentary[10][7] == 1 and true or false
	self.toggle_reset_on_adv = momentary[11][6] == 1 and true or false
	if self.group_advance_pressed then layer:invert_group_advance() end
	if self.option_prev then layer:set_pattern_num(-1) end
	if self.option_next then layer:set_pattern_num(1) end
	if self.toggle_conduct_pattern then layer:invert_conduct_pattern() end
	if self.toggle_conduct_patch then layer:invert_conduct_patch() end
	if self.toggle_conduct_scene then layer:invert_conduct_scene() end
	if self.toggle_reset_on_adv then layer:invert_reset_on_adv() end
end

function trig:process(event)
	local val = event.layer.pattern_num
	if event.layer.conduct_pattern == 1 then
		for track=1,16 do
			if event.layer.group_advance == 1 then
				notes_context.lane[track].pattern_lane:adv_chain(val)
				notes_context.lane[track]:update_active_pattern(notes_context.lane[track].pattern_lane:range_min())
			else
				if val>0 then
					notes_context.lane[track]:update_active_pattern(val)
				else
					notes_context.lane[track]:advance_pattern_seq()
				end
			end
		end
	end

	if event.layer.conduct_patch == 1 then
		if event.layer.group_advance == 1 then
			patch_context.machine_context.pattern_lane:adv_chain(val)
		else
			if val>0 then
				patch_context:set_patch_num(val)
			else
				patch_context.machine_context.pattern_lane:adv_lane_position()
			end
		end
		patch_context.machine_context:update_output_channel_data()
	end

	if event.layer.conduct_scene == 1 then
		if event.layer.group_advance == 1 then
			machine_context.scene_lane:adv_chain(val)
		else
			if val>0 then
				scene_context:set_scene_num(val)
			else
				machine_context.scene_lane:adv_lane_position()
			end
		end
	end

	if (event.layer.conduct_pattern == 1 or
	   event.layer.conduct_patch == 1 or
	   event.layer.conduct_scene == 1) and
	   event.layer.reset_on_adv == 1 then
		reset_most()
	end
end

function trig:get_current_gesture()
    local gesture
    if self.toggle_conduct_pattern then gesture = "pattern"
    elseif self.toggle_conduct_patch then gesture = "patch"
    elseif self.toggle_conduct_scene then gesture = "scene"
	elseif self.toggle_reset_on_adv then gesture = "reset on adv"
	end
	return gesture
end

return trig.new()