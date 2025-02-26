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
	
end

function trig:work(event,i,j)

end

function trig:abort(event,i,j)

end

function trig:loop_work(event)
	for i=1,16 do
		if event.layer.input_machine[i].active then
			for j=1,5 do
				if event.layer.input_machine[i].layer[j] == 1 then
					self:work(event,i,j)
				end
			end
		end
	end
end

function trig:loop_abort(event)
	for i=1,16 do
		if event.layer.input_machine[i].active then
			for j=1,5 do
				if event.layer.input_machine[i].layer[j] == 1 then
					self:abort(event,i,j)
				end
			end
		end
	end
end

--#region meta / proxy processing

function trig:process_proxy(event)
	if not event.layer:any_input_routing_high() then
		self:debug(event.layer.type,"proxy processing skipped")
		return
	end
	if event.layer.meta_process_mode == 1 then
		if event.layer.clock_id ~= nil then clock.cancel(event.layer.clock_id) end
		event.layer.clock_id = self:meta_process(event)
	elseif event.layer.process_clock_active == 1 and event.layer.delayed_process_reset_mode == 0 then
		-- delayed processing will trigger after time has elapsed
		self:debug(event.layer.type,"delayed processing skipped")
	else
		-- only cancel clock if delayed process reset mode is on	
		if event.layer.delayed_process_reset_mode == 1 and event.layer.clock_id ~= nil then clock.cancel(event.layer.clock_id) end
		event.layer.clock_id = self:delayed_process(event)
	end
end

function trig:delayed_process(event)
	return clock.run(function() self:_delayed_process(event) end)
end

function trig:_delayed_process(event)
	self:debug(event.layer.type,"delayed processing start")
	event.layer.process_clock_active = 1
	-- iterate (for visual feedback only)
	event.layer.meta_process_position = util.wrap(event.layer.meta_process_position + 1,1,event.layer.meta_process_sequence_length)
	if event.layer.process_clock_division > 0 then clock.sleep(clock.get_beat_sec()/event.layer.process_clock_division*4) end
	self:loop_work(event)
	-- reset meta process steps (for visual feedback only)
	event.layer.meta_process_position = 0
	self:debug(event.layer.type,"delayed processing end")
	event.layer.process_clock_active = 0
end

function trig:meta_process(event)
	return clock.run(function() self:_meta_process(event) end)
end

function trig:_meta_process(event)
	self:debug(event.layer.type,"meta processing start")
	event.layer.process_clock_active = 1
	-- iterate
	event.layer.meta_process_position = util.wrap(event.layer.meta_process_position + 1,1,event.layer.meta_process_sequence_length)
	if event.layer.meta_process_position == self:get_trigger_step(event) then
		self:loop_work(event)
	else
		self:loop_abort(event)
	end
	-- check run clock in between triggers
	if event.layer.process_clock_division > 0 then
		clock.sleep(clock.get_beat_sec()/event.layer.process_clock_division*4)
		-- reset meta process steps
		event.layer.meta_process_position = 0
	end
	self:debug(event.layer.type,"meta processing end")
	event.layer.process_clock_active = 0
end

function trig:get_trigger_step(event)
	if event.layer.meta_process_first_step==1 then
		return 1
	end
	return event.layer.meta_process_sequence_length
end

function trig:reset_meta_process(event,i,j)
	return clock.run(function() self:_reset_meta_process(event,i,j) end)
end

function trig:_reset_meta_process(event,i,j)
	self:debug(trig_context.input[i].trig[j].type,"meta processing reset blocked")
	-- check run clock in between triggers
	if trig_context.input[i].trig[j].process_clock_division > 0 then
		clock.sleep(clock.get_beat_sec()/trig_context.input[i].trig[j].process_clock_division*4)
		-- reset meta process steps
		trig_context.input[i].trig[j].meta_process_position = 0
	end
	self:debug(trig_context.input[i].trig[j].type,"meta processing reset complete")
	trig_context.input[i].trig[j].process_clock_active = 0
end

-- function trig:reset_delay_process(event,i,j)
-- 	return clock.run(function() self:_reset_delay_process(event,i,j) end)
-- end

-- function trig:_reset_delay_process(event,i,j)
-- 	self:debug(trig_context.input[i].trig[j].type,"delayed processing reset start")
-- 	trig_context.input[i].trig[j].meta_process_position = util.wrap(trig_context.input[i].trig[j].meta_process_position + 1,1,trig_context.input[i].trig[j].meta_process_sequence_length)
-- 	if trig_context.input[i].trig[j].process_clock_division > 0 then clock.sleep(clock.get_beat_sec()/trig_context.input[i].trig[j].process_clock_division*4) end
-- 	self:loop_work(event)
-- 	-- reset meta process steps (for visual feedback only)
-- 	trig_context.input[i].trig[j].meta_process_position = 0
-- 	self:debug(trig_context.input[i].trig[j].type,"delayed processing restart end")
-- 	trig_context.input[i].trig[j].process_clock_active = 0
-- end

function trig:draw_grid_meta_process_sequence(layer, momentary)
	for i=1,16 do
		if i==1 then
			g:led(i, 4, custom_lighting(layer.meta_process_position >= i, 12, layer.meta_process_first_step==1 and 8 or 2))
		elseif i==layer.meta_process_sequence_length then
			g:led(i, 4, custom_lighting(layer.meta_process_position >= i, 12, layer.meta_process_first_step==1 and 2 or 8))
		elseif i<=layer.meta_process_sequence_length then
			g:led(i, 4, custom_lighting(layer.meta_process_position >= i, 12,2))
		else
			g:led(i, 4, 0)
		end
	end
end

function trig:grid_key_meta_process_sequence(layer, momentary)
	for i=1,16 do
		if momentary[i][4] == 1 then
			layer:set_meta_process_sequence_length(i)
		end
	end
end

function trig:draw_screen_meta_delayed_processing(layer)
	local reset = layer.delayed_process_reset_mode==1 and "ON" or "OFF"
	local mode = " mode:"..(layer.meta_process_mode == 1 and "meta" or "delay")
    screen.move(1, 52)
	screen.text("dv:1/"..layer.process_clock_division.." reset:"..reset)
end

--#endregion

function trig:debug(type, message)
	--print(type.." "..message)
end

return trig