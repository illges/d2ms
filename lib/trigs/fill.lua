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
	local func = layer.func
	screen.text(""..func..": "..option)
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
		layer:set_fill_func(-1)
	end
	if self.option_2_next then
		layer:set_fill_func(1)
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
	local lane = {}
	if option == "note" then table.insert(lane, notes_context.lane[event.lane])
	elseif option == "cc" then table.insert(lane, cc_context.channel[event.layer.cc_ch_route].lane[event.lane])
	end
	local func = event.layer.func
	local arg = nil
	if option == "note" then
		if func == "asc" or func == "desc" then arg = table.move(notes_context.piano.keyboard, 1, 16, 1, {})
		else arg = notes_context.piano.keyboard
		end
	end
	for i=1,#lane do
		if func == "random" then lane[i]:random(arg)
		elseif func == "scAsc" then lane[i]:scatter_asc(arg)
		elseif func == "scDesc" then lane[i]:scatter_desc(arg)
		elseif func == "triAsc" then lane[i]:triangle_asc(arg)
		elseif func == "triDesc" then lane[i]:triangle_desc(arg)
		elseif func == "asc" then lane[i]:ascending(arg)
		elseif func == "desc" then lane[i]:descending(arg)
		end
	end
end

return trig.new()