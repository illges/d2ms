---@diagnostic disable: undefined-global, lowercase-global

local trig = {}
trig.__index = trig

function trig.new()
	local self = setmetatable({}, trig)
	self.handle_tracks_internal = false
	return self
end

function trig:draw_grid(layer, momentary)
    
end

function trig:draw_grid_extended(layer, momentary)
    
end

function trig:draw_grid_machine_layers(layer, input, sel, i)

end

function trig:draw_screen(layer)
    
end

function trig:draw_secondary_mode(layer)
    return "";
end

function trig:grid_key(layer, momentary, x, y, on)
    
end

function trig:get_current_gesture()
    
end

function trig:process(event)
	flush_midi_notes()
end

return trig