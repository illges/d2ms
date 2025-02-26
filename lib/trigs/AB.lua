---@diagnostic disable: undefined-global, lowercase-global

local base = include 'lib/trigs/base'

local trig = setmetatable({}, {__index = base})
trig.__index = trig

function trig.new()
	local self = setmetatable(base.new(), trig)
    self.draw_upper_grid = true
	self.draw_machine_grid = false

    self.prime_AB_toggle = false
	return self
end

function trig:draw_grid(layer, momentary)
    g:led(10, 6, basic_lighting(self.prime_AB_toggle or layer.prime_AB == 1))
end

function trig:draw_screen(layer)
    screen.level(4)
	screen.move(1, 52)
	local prime = layer.prime_AB==1 and 'Y' or 'N'
	screen.text("prime:"..prime)
end

function trig:grid_key(layer, momentary)
    self.prime_AB_toggle = momentary[10][6] == 1 and true or false
	if self.prime_AB_toggle then
		layer:invert_prime_AB()
	end
end

function trig:process(event)
	if event.layer.prime_AB == 1 then
		notes_context.lane[event.lane].prime_ab = true
	else
		notes_context.lane[event.lane]:invert_b_section()
	end
end

return trig.new()