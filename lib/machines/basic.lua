---@diagnostic disable: undefined-global, lowercase-global

local base = include 'lib/machines/base'

local machine = setmetatable({}, {__index = base})
machine.__index = machine

function machine.new()
	local self = setmetatable(base.new(), machine)
    self.draw_upper_grid = true

	--self.riff_pointer_pressed = false
	self.interval_decrease = false
    self.interval_increase = false
    self.interval_decrease_7 = false
    self.interval_increase_7 = false
	return self
end

function machine:draw_grid(layer, momentary)
    -- if #layer.riff_routing > 0 then
	--         g:led(9, 5, high_lighting(self.riff_pointer_pressed))
	--     else
	--         g:led(9, 5, basic_lighting(self.riff_pointer_pressed))
	--     end

	g:led(10, 8, basic_lighting(self.interval_decrease))
	g:led(11, 8, basic_lighting(self.interval_increase))
	g:led(9, 8, negative_lighting(self.interval_decrease_7))
	g:led(12, 8, negative_lighting(self.interval_increase_7))

	self:draw_grid_hold_release_mode(layer)
end

function machine:draw_screen(layer)
    screen.level(4)
	screen.move(1, 52)
	local int = layer.riff_intervals[1]
	local offset = layer.follow_offset
	screen.text("int:"..int.." ofst:"..offset)

	--self:draw_screen_hold_release_mode(layer)
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

	--self:grid_key_hold_release_mode(layer, momentary)
end

function machine:get_current_gesture()
	local gesture
    if self.interval_decrease or self.interval_increase or self.interval_decrease_7 or self.interval_increase_7 then
		gesture =  "+/- interval"
	--elseif self.fixed_note_hold_release_mode_pressed then gesture = self.hold_release_mode_text
	end
	return gesture
end

local zero_offset = 0

function machine:process(event)
	local gears_retrig = false
	local advance = false
	if event.layer.gears_block == 1 and event.layer.gears_retrig == 1 then
		gears_retrig = true
	end
	if event.layer.cc_send == 1 then
		route_cc(event)
	end
	if event.layer.notes_send == 1 then
		if notes_context.lane[event.lane].prime_ab then
			notes_context.lane[event.lane]:invert_b_section()
			notes_context.lane[event.lane].prime_ab = false
		end
		event.offset = event.layer.follow_offset
		local routing = event.layer.leader_routing
		if #routing == 0 then
			event.offset = zero_offset
			advance = true
			routing = {event.lane}
		end
		for i=1,#routing do
			harvest(routing[i], event, false)
		end
		if gears_retrig == false and advance then
			advance_lane_position(notes_context.lane[event.lane] ,event.lane)
		end
	end
end

return machine.new()