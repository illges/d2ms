---@diagnostic disable: undefined-global, lowercase-global

local base = include 'lib/trigs/base'

local trig = setmetatable({}, {__index = base})
trig.__index = trig

function trig.new()
	local self = setmetatable(base.new(), trig)
    self.draw_upper_grid = false
	self.draw_machine_grid = true
	self.auto_trig = true

	self.layer_mute_toggle_pressed = false
	self.layer_mute_pressed = false
    self.layer_unmute_pressed = false
	return self
end

function trig:draw_grid(layer, momentary)
    g:led(9, 5, basic_lighting(self.layer_mute_toggle_pressed or layer.layer_mute_toggle == 1))
	g:led(10, 5, basic_lighting(self.layer_mute_pressed or layer.layer_mute == 1))
	g:led(11, 5, basic_lighting(self.layer_unmute_pressed or layer.layer_unmute == 1))
end

function trig:draw_grid_machine_layers(layer, input, sel, i)
	if layer.input_machine[sel].layer[i] == 1 then
		return input[sel].machine[i].hold_time_toggle == 0 and 8 or 15
	end
	return nil
end

function trig:draw_screen(layer)
    screen.level(4)
	screen.move(1, 52)
	local action = "toggle"
	if layer.layer_mute == 1 then action = "offset 0"
	elseif layer.layer_unmute == 1 then action = "offset 1"
	end
	screen.text("action : "..action)
end

function trig:grid_key(layer, momentary)
    self.layer_mute_toggle_pressed = momentary[9][5] == 1 and true or false
	self.layer_mute_pressed = momentary[10][5] == 1 and true or false
	self.layer_unmute_pressed = momentary[11][5] == 1 and true or false
	if self.layer_mute_toggle_pressed then layer:invert_layer_mute_toggle(1)
	elseif self.layer_mute_pressed then layer:invert_layer_mute(1)
	elseif self.layer_unmute_pressed then layer:invert_layer_unmute(1)
	end
end

function trig:get_current_gesture()
    local gesture
    if self.layer_mute_toggle_pressed then gesture = "toggle"
    elseif self.layer_mute_pressed then gesture = "sus1"
    elseif self.layer_unmute_pressed then gesture = "sus2"
	end
	return gesture
end

function trig:process(event)
	for i=1,16 do
		if event.layer.input_machine[i].active then
			for j=1,5 do
				if event.layer.input_machine[i].layer[j] == 1 then
					if event.layer.layer_mute_toggle==1 then
						machine_context.input[i].machine[j]:set_follow_offset()
					elseif event.layer.layer_mute==1 then
						machine_context.input[i].machine[j]:set_follow_offset(0)
					else
						machine_context.input[i].machine[j]:set_follow_offset(1)
					end
				end
			end
		end
	end
end

return trig.new()