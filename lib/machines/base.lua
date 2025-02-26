---@diagnostic disable: undefined-global, lowercase-global

local machine = {}
machine.__index = machine

function machine.new()
	local self = setmetatable({}, machine)
	self.fixed_note_hold_release_mode_pressed = false

	-- gesture hint text
	self.hold_release_mode_text = "lock/release mode"
	return self
end

function machine:draw_grid_hold_release_mode(layer)
	g:led(15, 8, layer.hold_release_mode*7)
end

function machine:draw_screen_hold_release_mode(layer)
	local ind = layer.hold_flag == 1 and "*" or ">"
	ind = layer.release_flag==1 and ">" or ind
	local mode = layer.hold_release_mode==2 and "retrig" or "lock"
	local state = layer.hold_release_mode>0 and "ON" or "OFF"
	screen.move(127, 52)
	screen.text_right(ind..mode.." mode:"..state)
end

function machine:grid_key_hold_release_mode(layer, momentary)
	self.fixed_note_hold_release_mode_pressed = momentary[15][8] == 1 and true or false
	if self.fixed_note_hold_release_mode_pressed then layer:set_hold_release_mode(util.wrap(layer.hold_release_mode+1,0,2)) end
end

function machine:work(routing, event)

end

function machine:abort(event)
	return false
end

function machine:process_follower(event)
	local gears_retrig = false
	local advance = false
	local released = false
	local reset = false
	if event.layer.gears_block == 1 and event.layer.gears_retrig == 1 then
		gears_retrig = true
	end
	if event.layer.cc_send == 1 then
		route_cc(event)
	end
	if event.layer.notes_send == 1 then
		local routing = event.layer.leader_routing
		event.offset = event.layer.follow_offset
		if #routing == 0 then routing = {event.lane} end
		for i=1,#routing do
			if self:abort(event) then return end
			advance = false
			released = false
			reset = false
			if event.layer.reset_mode==1 then
				if notes_context.lane[routing[i]].reset_flag==1 or
				event.layer.prev_routing_pos[routing[i]] ~= notes_context.lane[routing[i]].position then
					notes_context.lane[routing[i]].reset_flag=0
					reset = true
				end
			end
			if event.layer.hold_release_mode>0 then
				if event.layer.release_flag == 1 or
				event.layer.prev_routing_pos[routing[i]] ~= notes_context.lane[routing[i]].position then
					event.layer.hold_flag = 0
					event.layer.release_flag = 0
					released = true
				end
			end
			if event.layer.vel_mode == 1 and not reset then
				if event.layer.gears_block == 1 then return end
				event.layer:get_vel_step_threshold()
				event.layer:adv_position(event.vel_in)
				machine_context.fixed_note_visual = event.layer.position
				if event.layer:check_route() then
					self:work(routing[i], event)
					if event.layer.hold_release_mode>0 then
						event.layer.hold_flag = 1
					end
				end
			else
				if reset then
					event.layer:reset_meta_seq()
					machine_context.fixed_note_visual = event.layer.position
				end
				if event.layer:check_route() then
					if released then
						if event.layer.hold_release_mode==2 then
							event.layer:adv_position(0)
						end
					end
					self:work(routing[i], event)
					if event.layer.hold_release_mode==1 then
						event.layer.hold_flag = 1
						advance = true
					elseif event.layer.hold_release_mode==2 then
						event.layer.hold_flag = 1
						advance = false
					else
						advance = true
					end
				end

				machine_context.fixed_note_visual = event.layer.position
				event.layer.prev_routing_pos[routing[i]] = notes_context.lane[routing[i]].position
			end
		end
		if advance and not gears_retrig and event.layer.vel_mode ~= 1 then event.layer:adv_position(0) end
	end
end

return machine