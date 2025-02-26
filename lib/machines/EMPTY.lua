---@diagnostic disable: undefined-global, lowercase-global

local machine = {}
machine.__index = machine

function machine.new()
	local self = setmetatable({}, machine)
    self.draw_upper_grid = false
	return self
end

function machine:draw_grid(layer, momentary)
    
end

function machine:draw_screen(layer)
    
end

function machine:grid_key(layer, momentary)
    
end

function machine:get_current_gesture()
    
end

function machine:process(event)
	
end

return machine.new()