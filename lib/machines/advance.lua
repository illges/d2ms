---@diagnostic disable: undefined-global, lowercase-global

local machine = {}
machine.__index = machine

function machine.new()
	local self = setmetatable({}, machine)
    self.draw_upper_grid = true
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

local function harvest_adv_only(row)
    local track = notes_context.lane[row]
    notes_context:set_note_visual(row, track.position)
    advance_lane_position(track,row)
end

function machine:process(event)
	if event.layer.gears_block == 1 then return end
	if notes_context.lane[event.lane].prime_ab then
		notes_context.lane[event.lane]:invert_b_section()
		notes_context.lane[event.lane].prime_ab = false
	end
	harvest_adv_only(event.lane)
end

return machine.new()