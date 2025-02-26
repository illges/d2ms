---@diagnostic disable: undefined-global, lowercase-global

local base = include 'lib/trigs/base'
local trigger_event = include 'lib/trigger_event'

local trig = setmetatable({}, {__index = base})
trig.__index = trig

function trig.new()
	local self = setmetatable(base.new(), trig)
    self.draw_upper_grid = false
	self.draw_machine_grid = true
	self.auto_trig = true

	self.meta_option_1_increase = false
    self.meta_option_1_increase_double = false
    self.meta_option_1_decrease = false
    self.meta_option_1_decrease_half = false
	self.toggle_delayed_process_reset_mode = false
	self.toggle_meta_process_mode = false
	self.toggle_meta_process_first_step = false
	self.trig_pointer_pressed = false
	self.proxy_ignore_mutes_pressed = false
	return self
end

function trig:draw_grid(layer, momentary)
	g:led(10, 7, basic_lighting(layer.meta_process_first_step==1))
	g:led(10, 5, basic_lighting(layer.trig_pointer==1))
	g:led(11, 7, basic_lighting(layer.proxy_ignore_mutes==1))

	self:draw_grid_meta_process_sequence(layer, momentary)
	g:led(10, 6, basic_lighting(layer.meta_process_mode == 0))
	g:led(11, 6, basic_lighting(layer.delayed_process_reset_mode == 1))

	g:led(10, 8, basic_lighting(self.meta_option_1_decrease))
	g:led(11, 8, basic_lighting(self.meta_option_1_increase))
	g:led(9, 8, negative_lighting(self.meta_option_1_decrease_half))
	g:led(12, 8, negative_lighting(self.meta_option_1_increase_double))
end

function trig:draw_grid_machine_layers(layer, input, sel, i)
	if layer.input_machine[sel].layer[i] == 1 then
		return input[sel].machine[i].probability == 0 and 8 or 15
	end
	return nil
end

function trig:draw_screen(layer)
	self:draw_screen_meta_delayed_processing(layer)
end

function trig:draw_secondary_mode(layer)
    return " : "..(layer.meta_process_mode == 1 and "seq" or "delay")
end

function trig:grid_key(layer, momentary)
	self.trig_pointer_pressed = momentary[10][5] == 1 and true or false
	if self.trig_pointer_pressed then layer:invert_trig_pointer() end
	self.proxy_ignore_mutes_pressed = momentary[11][7] == 1 and true or false
	if self.proxy_ignore_mutes_pressed then layer:invert_proxy_ignore_mutes() end
	self.toggle_meta_process_first_step = momentary[10][7] == 1 and true or false
	if self.toggle_meta_process_first_step then layer:invert_meta_process_first_step() end

	self:grid_key_meta_process_sequence(layer, momentary)
	self.toggle_meta_process_mode = momentary[10][6] == 1 and true or false
	self.toggle_delayed_process_reset_mode = momentary[11][6] == 1 and true or false
	self.meta_option_1_decrease = momentary[10][8] == 1 and true or false
	self.meta_option_1_increase = momentary[11][8] == 1 and true or false
	self.meta_option_1_decrease_half = momentary[9][8] == 1 and true or false
	self.meta_option_1_increase_double = momentary[12][8] == 1 and true or false
	if self.toggle_meta_process_mode then layer:invert_meta_process_mode() end
	if self.toggle_delayed_process_reset_mode then layer:invert_delayed_process_reset_mode() end
	if self.meta_option_1_decrease then layer:set_process_clock_division(-1) end
	if self.meta_option_1_increase then layer:set_process_clock_division(1) end
	if self.meta_option_1_decrease_half then layer:set_process_clock_division("h") end
	if self.meta_option_1_increase_double then layer:set_process_clock_division("d") end
end

function trig:work(event,i,j)
	local data = trigger_event.new(event.vel_raw)
	data.proxy_ignore_mutes = event.layer.proxy_ignore_mutes==1 and true or false
	local proxy_events = {}
	if event.layer.trig_pointer == 1 then
		if self:is_self_ref(event,i,j) then
			return
		else
			modify_velocity(i, data)
			process_trig_layers(data, i, j, proxy_events)
		end
	else
		modify_velocity(i, data)
		process_machine_layers(data, i, j, proxy_events)
		if grid_light_pulse==1 then
			if #proxy_events > 0 then
				machine_context:set_layer_visual_event(proxy_events)
			end
		end
	end
end

function trig:is_self_ref(event,i,j)
	if event.layer.trig_pointer == 1 then
		local self_ref = i==event.input_num and j==event.layer_num
		if self_ref then
			print("*****trig pointer self reference skipped*****")
			print()
			print("input:"..event.input_num.." layer:"..event.layer_num)
			print()
			print("*********************************************")
			return true
		end
	end
	return false
end

function trig:process(event)
	self:process_proxy(event)
end

function trig:get_current_gesture()
    local gesture
    if self.trig_pointer_pressed then gesture = "trig pointer"
	elseif self.proxy_ignore_mutes_pressed then gesture = "ignore layer mutes"
	elseif self.toggle_meta_process_first_step then gesture = "process first step"
	end
	return gesture
end

return trig.new()