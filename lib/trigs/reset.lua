---@diagnostic disable: undefined-global, lowercase-global

local base = include 'lib/trigs/base'

local trig = setmetatable({}, {__index = base})
trig.__index = trig

function trig.new()
	local self = setmetatable(base.new(), trig)
    self.draw_upper_grid = true
	self.draw_machine_grid = false

	self.option_prev = false
    self.option_next = false
	self.cc_channel_increase = false
    self.cc_channel_decrease = false
	return self
end

function trig:draw_grid(layer, momentary)
    g:led(10, 8, basic_lighting(self.option_prev))
    g:led(11, 8, basic_lighting(self.option_next))
	if layer.reset_type == "cc" then
		g:led(10, 6, basic_lighting(self.cc_channel_decrease))
		g:led(11, 6, basic_lighting(self.cc_channel_increase))
	end
end

function trig:draw_screen(layer)
    screen.level(4)
	screen.move(1, 52)
	local option = layer.reset_type
	screen.text("reset:"..option)
	if  option == "cc" then
		screen.move(50, 52)
		screen.text("ch:"..layer.cc_ch_route)
	end
end

function trig:grid_key(layer, momentary)
    self.option_prev = momentary[10][8] == 1 and true or false
    self.option_next = momentary[11][8] == 1 and true or false
	if self.option_prev then
		layer:set_reset_option(-1)
	end
	if self.option_next then
		layer:set_reset_option(1)
	end
	if layer.reset_type == "cc" then
		self.cc_channel_decrease = momentary[10][6] == 1 and true or false
		self.cc_channel_increase = momentary[11][6] == 1 and true or false
		if self.cc_channel_decrease then layer:set_cc_ch_route(-1) end
		if self.cc_channel_increase then layer:set_cc_ch_route(1) end
	end
end

function trig:process(event)
	local option = event.layer.reset_type
	if option=="machine" then
		for i=1,16 do
			if event.layer.input_machine[i].active then
				for j=1,5 do
					if event.layer.input_machine[i].layer[j] == 1 then
						machine_context.input[i].machine[j]:reset_meta_seq()
					end
				end
			end
		end
	elseif option=="trig" then
		for i=1,16 do
			if event.layer.input_machine[i].active then
				for j=1,5 do
					local self_ref = i==event.input_num and j==event.layer_num
					if not self_ref and event.layer.input_machine[i].layer[j] == 1 then
						if trig_context.input[i].trig[j].meta_process_mode == 1 then
							trig_context.input[i].trig[j].meta_process_position = 0

							-- if trig_context.input[i].trig[j].clock_id ~= nil then clock.cancel(trig_context.input[i].trig[j].clock_id) end
							-- trig_context.input[i].trig[j].clock_id = self:reset_meta_process(event,i,j)

						-- elseif trig_context.input[i].trig[j].process_clock_active == 1 and trig_context.input[i].trig[j].delayed_process_reset_mode == 0 then
						-- 	self:debug(trig_context.input[i].trig[j].type,"delayed processing reset skipped")
						-- else
						-- 	-- only reset teh delay if reset mode is on and the process clock is active	
						-- 	if trig_context.input[i].trig[j].delayed_process_reset_mode == 1 and trig_context.input[i].trig[j].process_clock_active ==1 then
						-- 		if trig_context.input[i].trig[j].clock_id ~= nil then clock.cancel(trig_context.input[i].trig[j].clock_id) end
						-- 		trig_context.input[i].trig[j].clock_id = self:reset_delayed_process(event)
						-- 	end
						end
					end
				end
			end
		end
	else
		if option == "note" then
			notes_context.lane[event.lane]:set_position(notes_context.lane[event.lane]:range_min())
			notes_context.lane[event.lane].reset_flag = 1
		elseif option == "cc" then cc_context.channel[event.layer.cc_ch].lane[event.lane]:set_position(cc_context.channel[event.layer.cc_ch].lane[event.lane]:range_min())
		end
	end
end

return trig.new()