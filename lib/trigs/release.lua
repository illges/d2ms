---@diagnostic disable: undefined-global, lowercase-global

local base = include 'lib/trigs/base'

local trig = setmetatable({}, {__index = base})
trig.__index = trig

function trig.new()
	local self = setmetatable(base.new(), trig)
    self.draw_upper_grid = false
	self.draw_machine_grid = true

	self.meta_option_1_increase = false
    self.meta_option_1_increase_double = false
    self.meta_option_1_decrease = false
    self.meta_option_1_decrease_half = false
	-- self.toggle_delayed_process_reset_mode = false
	-- self.toggle_meta_process_mode = false
	-- self.toggle_meta_process_first_step = false
	return self
end

function trig:draw_grid(layer, momentary)
	-- self:draw_grid_meta_process_sequence(layer, momentary)
	-- g:led(10, 6, basic_lighting(layer.meta_process_mode == 1))
	-- g:led(10, 7, basic_lighting(layer.meta_process_first_step==1))
	-- g:led(11, 6, basic_lighting(layer.delayed_process_reset_mode == 1))

    -- g:led(10, 8, basic_lighting(self.meta_option_1_decrease))
	-- g:led(11, 8, basic_lighting(self.meta_option_1_increase))
	-- g:led(9, 8, negative_lighting(self.meta_option_1_decrease_half))
	-- g:led(12, 8, negative_lighting(self.meta_option_1_increase_double))
end

function trig:draw_grid_machine_layers(layer, input, sel, i)
	if layer.input_machine[sel].layer[i] == 1 then
		return input[sel].machine[i].probability == 0 and 8 or 15
	end
	return nil
end

function trig:draw_screen(layer)
	--self:draw_screen_meta_delayed_processing(layer)
end

-- function trig:draw_secondary_mode(layer)
--     return " : "..(layer.meta_process_mode == 1 and "seq" or "delay")
-- end

function trig:grid_key(layer, momentary)
	--self:grid_key_meta_process_sequence(layer, momentary)

	-- self.toggle_meta_process_first_step = momentary[10][7] == 1 and true or false
	-- if self.toggle_meta_process_first_step then layer:invert_meta_process_first_step() end
	-- self.toggle_meta_process_mode = momentary[10][6] == 1 and true or false
	-- if self.toggle_meta_process_mode then layer:invert_meta_process_mode() end
	-- self.toggle_delayed_process_reset_mode = momentary[11][6] == 1 and true or false
	-- if self.toggle_delayed_process_reset_mode then layer:invert_delayed_process_reset_mode() end

	-- self.meta_option_1_decrease = momentary[10][8] == 1 and true or false
	-- self.meta_option_1_increase = momentary[11][8] == 1 and true or false
	-- self.meta_option_1_decrease_half = momentary[9][8] == 1 and true or false
	-- self.meta_option_1_increase_double = momentary[12][8] == 1 and true or false
	-- if self.meta_option_1_decrease then layer:set_process_clock_division(-1) end
	-- if self.meta_option_1_increase then layer:set_process_clock_division(1) end
	-- if self.meta_option_1_decrease_half then layer:set_process_clock_division("h") end
	-- if self.meta_option_1_increase_double then layer:set_process_clock_division("d") end
end

function trig:work(event,i,j)
	machine_context.input[i].machine[j].release_flag = 1
end

function trig:abort(event,i,j)
	machine_context.input[i].machine[j].hold_flag = 1
end

function trig:process(event)
	--self:process_proxy(event)
	self:loop_work(event)
end

function trig:get_current_gesture()
    local gesture
	if self.toggle_meta_process_first_step then gesture = "process first step"
	end
	return gesture
end

return trig.new()