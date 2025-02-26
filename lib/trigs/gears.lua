---@diagnostic disable: undefined-global, lowercase-global

local base = include 'lib/trigs/base'

local trig = setmetatable({}, {__index = base})
trig.__index = trig

function trig.new()
	local self = setmetatable(base.new(), trig)
    self.draw_upper_grid = false
	self.draw_machine_grid = true
	self.auto_trig = true

	self.gears_retrig_pressed = false
    self.trig_pointer_pressed = false
    self.gear_step_toggle_pressed = false
	return self
end

function trig:draw_grid(layer, momentary)
    g:led(10, 5, basic_lighting(layer.trig_pointer==1))
	g:led(9, 5, basic_lighting(layer.gears_retrig==1))
	g:led(10, 8, basic_lighting(self.gear_step_toggle_pressed))

	local light = 2
	local max = layer.range.max
	local min = layer.range.min
	for i=1,8 do
		if self.gear_step_toggle_pressed then
			light = layer.gears_sequence[i]==1 and 12 or 6
			if i < 5 then
				g:led(8+i, 6, light)
			else
				g:led(4+i, 7, light)
			end
		else
			light = 2
			if layer.gears_sequence[i]==1 then light = 4 end
			if i == layer.position then light = 12 end
			if i > max or i < min then light = 1 end
			if i < 5 then
				if momentary[8+i][6] == 1 then light = 15 end
				g:led(8+i, 6, light)
			else
				if momentary[4+i][7] == 1 then light = 15 end
				g:led(4+i, 7, light)
			end
		end
	end
end

function trig:draw_screen(layer)
    screen.level(4)
	screen.move(1, 52)
	local position = layer.position
	local val = layer.gears_sequence[position]==1 and "ON" or "OFF"
	local destination = layer.trig_pointer==1 and 'trigs' or 'machines'
	local retrig = layer.gears_retrig==1 and 'Y' or 'N'
	screen.text("n"..position..":"..val.." retrg:"..retrig.." dest:"..destination)
end

function trig:grid_key(layer, momentary)
    self.trig_pointer_pressed = momentary[10][5] == 1 and true or false
	if self.trig_pointer_pressed then layer:invert_trig_pointer() end
	self.gears_retrig_pressed = momentary[9][5] == 1 and true or false
	if self.gears_retrig_pressed then layer:invert_gears_retrig() end
	self.gear_step_toggle_pressed = momentary[10][8] == 1 and true or false

	local step=0
	if momentary[9][6] == 1 then step = 1
	elseif momentary[10][6] == 1 then step = 2
	elseif momentary[11][6] == 1 then step = 3
	elseif momentary[12][6] == 1 then step = 4
	elseif momentary[9][7] == 1 then step = 5
	elseif momentary[10][7] == 1 then step = 6
	elseif momentary[11][7] == 1 then step = 7
	elseif momentary[12][7] == 1 then step = 8
	end
	if self.gear_step_toggle_pressed and step > 0 then layer:invert_gears_sequence(step) end
end

function trig:process(event)
	-- if processing_v2==1 then
	-- 	self:process_v2(event)
	-- else
	-- 	self:process_v1(event)
	-- end
	self:process_v1(event)
end

function trig:process_v1(event)
	for i=1,16 do
		if event.layer.input_machine[i].active then
			for j=1,5 do
				if event.layer.input_machine[i].layer[j] == 1 then
					if event.layer.trig_pointer == 1 then
						local self_ref = i==event.input_num and j==event.layer_num
						if not self_ref then
							if event.layer.gears_sequence[event.layer.position]==1 then
								trig_context.input[i].trig[j].gears_block=0
							else
								trig_context.input[i].trig[j].gears_block=1
							end
						else
							return
						end
					else
						if event.layer.gears_sequence[event.layer.position]==1 then
							machine_context.input[i].machine[j].gears_block=0
						else
							machine_context.input[i].machine[j].gears_block=1
						end
						if event.layer.gears_retrig==1 then
							machine_context.input[i].machine[j].gears_retrig=1
						else
							machine_context.input[i].machine[j].gears_retrig=0
						end
					end
				end
			end
		end
	end
	event.layer:adv_position(0)
end

function trig:process_v2(event)
	print("*****gears_v2*****")
	print(event.lane)
	for i=1,16 do
		if event.layer.input_machine[i].active then
			for j=1,5 do
				if event.layer.input_machine[i].layer[j] == 1 then
					if event.layer.trig_pointer == 1 then
						local self_ref = i==event.input_num and j==event.layer_num
						if not self_ref then
							if notes_context.lane[event.lane]:step_mute(notes_context.lane[event.lane].position)==0 then
								trig_context.input[i].trig[j].gears_block=0
							else
								trig_context.input[i].trig[j].gears_block=1
							end
						else
							return
						end
					else
						if notes_context.lane[event.lane]:step_mute(notes_context.lane[event.lane].position)==0 then
							machine_context.input[i].machine[j].gears_block=0
						else
							machine_context.input[i].machine[j].gears_block=1
						end
						if event.layer.gears_retrig==1 then
							machine_context.input[i].machine[j].gears_retrig=1
						else
							machine_context.input[i].machine[j].gears_retrig=0
						end
					end
				end
			end
		end
	end
	advance_lane_position(notes_context.lane[event.lane],event.lane)
end

return trig.new()