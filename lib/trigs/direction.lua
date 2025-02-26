---@diagnostic disable: undefined-global, lowercase-global

local base = include 'lib/trigs/base'

local trig = setmetatable({}, {__index = base})
trig.__index = trig

function trig.new()
	local self = setmetatable(base.new(), trig)
    self.draw_upper_grid = true
	self.draw_machine_grid = false

	self.option_prev = false
    self.option_next = false
    self.option_2_prev = false
    self.option_2_next = false
    self.cc_channel_increase = false
    self.cc_channel_decrease = false
	return self
end

function trig:draw_grid(layer, momentary)
    g:led(10, 8, basic_lighting(self.option_prev))
	g:led(11, 8, basic_lighting(self.option_next))
	g:led(10, 7, basic_lighting(self.option_2_prev))
	g:led(11, 7, basic_lighting(self.option_2_next))
	if layer.fill == "cc" then
		g:led(10, 6, basic_lighting(self.cc_channel_decrease))
		g:led(11, 6, basic_lighting(self.cc_channel_increase))
	end
end

function trig:draw_screen(layer)
    screen.level(4)
	screen.move(1, 52)
	local option = layer.fill
	local dir = layer.direction_toggle
	screen.text(""..dir..": "..option)
	if  option == "cc" then
		screen.move(50, 52)
		screen.text("ch:"..layer.cc_ch_route)
	end
end

function trig:grid_key(layer, momentary)
    self.option_prev = momentary[10][8] == 1 and true or false
    self.option_next = momentary[11][8] == 1 and true or false
	self.option_2_prev = momentary[10][7] == 1 and true or false
    self.option_2_next = momentary[11][7] == 1 and true or false
	if self.option_prev then
		layer:set_fill_option(-1)
	end
	if self.option_next then
		layer:set_fill_option(1)
	end
	if self.option_2_prev then
		layer:set_direction_option(-1)
	end
	if self.option_2_next then
		layer:set_direction_option(1)
	end
	if layer.fill == "cc" then
		self.cc_channel_decrease = momentary[10][6] == 1 and true or false
		self.cc_channel_increase = momentary[11][6] == 1 and true or false
		if self.cc_channel_decrease then layer:set_cc_ch_route(-1) end
		if self.cc_channel_increase then layer:set_cc_ch_route(1) end
	end
end

function trig:process(event)
	local option = event.layer.fill
	local direction = event.layer.direction_toggle
	local lane = {}
	if option == "note" then table.insert(lane, notes_context.lane[event.lane])
	elseif option == "cc" then table.insert(lane, cc_context.channel[event.layer.cc_ch_route].lane[event.lane])
	end
	for i=1,#lane do
		if direction == "reverse" then lane[i]:invert_direction()
		elseif direction == "pingpong" then lane[i]:invert_ping_pong()
		elseif direction == "pingpong2" then lane[i]:invert_ping_pong_2()
		elseif direction == "random" then lane[i]:invert_random_step()
		end
	end
end

return trig.new()