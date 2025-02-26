---@diagnostic disable: undefined-global, lowercase-global

local base = include 'lib/trigs/base'

local trig = setmetatable({}, {__index = base})
trig.__index = trig

function trig.new()
	local self = setmetatable(base.new(), trig)
    self.draw_upper_grid = false
	self.draw_machine_grid = false

	self.option_prev = false
    self.option_next = false
	self.group_advance_pressed = false
	return self
end

function trig:draw_grid(layer, momentary)
    g:led(10, 7, basic_lighting(self.group_advance_pressed or layer.group_advance == 1))
	g:led(10, 8, basic_lighting(self.option_prev))
	g:led(11, 8, basic_lighting(self.option_next))
end

function trig:draw_screen(layer)
	local group = layer.group_advance==1 and 'Y' or 'N'
    screen.level(4)
	screen.move(1, 52)
	screen.text("direct:"..layer.patch_num)
	screen.move(50, 52)
	screen.text("group:"..group)
end

function trig:grid_key(layer, momentary)
    self.option_prev = momentary[10][8] == 1 and true or false
	self.option_next = momentary[11][8] == 1 and true or false
	self.group_advance_pressed = momentary[10][7] == 1 and true or false
	if self.group_advance_pressed then layer:invert_group_advance() end
	if self.option_prev then layer:set_patch_num(-1) end
	if self.option_next then layer:set_patch_num(1) end
end

function trig:process(event)
	local val = event.layer.patch_num
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

return trig.new()