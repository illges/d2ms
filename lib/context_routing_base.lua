---@diagnostic disable: undefined-global, lowercase-global

local base = include 'lib/context_base'
local config = include 'lib/config/inputs'
local automation_lane_pattern = include 'lib/automation_lane_pattern'

local context = setmetatable({}, {__index = base})
context.__index = context

function context.new(name)
    local self = setmetatable(base.new(), context)
    self.name = name
    self.display_vel = 0
    self.incoming_note = '*'
    self.incoming_ch = '*'
    self.incoming_vel = '*'
    self.adjusted_vel = '*'
    self.midi_learn = false
    self.midi_learn_vel_low = false
    self.midi_learn_vel_high = false
    self.clear_velocity = false
    self.layer_routing = {}
    self.scene = {}
    self.scene_lane = automation_lane_pattern.new(name, 1, "scene", "scene")
    self.scene_lane:add_params()
    self.scene_lane:set_range_data(1, 1)

    if self.name=="machine" then
        for i=1,5 do
            table.insert(self.layer_routing, {})
            self.layer_routing[i].patch = {}
            for j=1,16 do
                table.insert(self.layer_routing[i].patch, {})
                self.layer_routing[i].patch[j].routing = self:init_layer_routing(16+i)
            end
            self.layer_routing[i].output_list = self:init_layer_output_list()
        end
    
        self.pattern_lane = automation_lane_pattern.new(name, 1, "patch", "patch")
        self.pattern_lane:add_params()
        self.pattern_lane:set_range_data(1, 1)
    
        self:add_channel_params_hidden()
        self:update_output_channel_data()
    end

    -- setup tables to track visual input pulse
    self.layer_visual = self:init_visual(5)
    self.machine_layer_visual = self:init_visual(5)
    self.page_visual = self:init_visual(4)
    self.lane_visual = self:init_visual(4)
    self.input_visual = self:init_visual(16)

    self.grid_refresh=metro.init()
    self.grid_refresh.count=-1
    self.grid_refresh.time=0.1
    self.grid_refresh.event=function()
        self:get_visuals()
    end
    self.grid_refresh:start()

    self.held = 0
    self.heldmax = 0
    self.first = 0
    self.second = 0
    return self
end

function context:draw_generic()
    local input_num = self.selected_input
    local trig_num = self.input[input_num].sel_trig_layer
    local machine_num = self.input[input_num].sel_machine_layer
    local input = self.input[input_num]
    local layer = nil
    if self.name == machine_context.name then
        layer = input.machine[machine_num]
    else
        layer = input.trig[trig_num]
    end

    --setup
    self:get_param_screen_level(1)
    screen.move(1, 20)
    screen.text("note: "..input.note)
    screen.level(1)
    screen.move(42, 20)
    screen.text(self.incoming_note)

    self:get_param_screen_level(2)
    screen.move(1, 30)
    screen.text("ch : "..input.channel)
    screen.level(1)
    screen.move(42, 30)
    screen.text(self.incoming_ch)

    self:get_param_screen_level(3)
    screen.move(1, 40)
    screen.text("prob: "..layer:get_probability(self.scene_lane.position).."%")

    --velocity
    screen.level(4)
    screen.move(60, 20)
    screen.text("vel: ")

    local low = layer.low_thresh
    self:get_param_screen_level(4)
    screen.move(75, 20)
    screen.text(""..low)

    local calc = 0
    calc = low >= 10 and 5 or calc
    calc = low >= 100 and 8 or calc
    self:get_param_screen_level(5)
    screen.move(80+calc, 20)
    screen.text("-"..layer.high_thresh)
    screen.level(1)
    screen.move(100+calc, 20)
    screen.text(self.incoming_vel)

    screen.level(4)
    screen.move(60, 30)
    screen.text("adj: "..self.adjusted_vel)

    screen.level(4)
    screen.move(60, 40)
    local vel_flr_ceil = "flr/ceil: "
    screen.text(vel_flr_ceil)

    local flr = input:get_vel_floor()
    self:get_param_screen_level(6)
    screen.move(62+screen.text_extents(vel_flr_ceil), 40)
    screen.text(flr)

    self:get_param_screen_level(7)
    screen.move(59+screen.text_extents(vel_flr_ceil..flr), 40)
    screen.text("-"..input:get_vel_ceiling())

    --params
    screen.level(15)
    screen.move(0,44)
    screen.line(128,44)
    screen.stroke()
end

function context:get_param_screen_level(element)
    if self.selected_ui == element then screen.level(15) else screen.level(4) end
end

function context:set_incoming(event)
    self.incoming_ch = event.ch
    self.incoming_note = event.note
    self.incoming_vel = event.vel
end

function context:set_adusted_vel(event)
    self.adjusted_vel = event.vel_in
end

function context:init_visual(n)
    local visual = {}
    for i=1,n do
        visual[i]=0
    end
    return visual
end

function context:get_visuals()
    for i=1,16 do
        self:_get_visuals(self.input_visual,i)
        if i <=5 then
            self:_get_visuals(self.layer_visual,i)
            self:_get_visuals(self.machine_layer_visual,i)
            if i <= 4 then
                self:_get_visuals(self.page_visual,i)
                self:_get_visuals(self.lane_visual,i)
            end
        end
    end
end

function context:_get_visuals(visual,i)
    if visual[i]>0 then
        visual[i]=visual[i]-1
        grid_dirty = true
    end
    if visual[i]<0 then
        visual[i]=0
        grid_dirty = true
    end
end

function context:init_layer_routing(layer)
    local routing = {}    
    for i=1,16 do
        -- add a table for each track
        table.insert(routing, {})
        for j=1,16 do
            -- default each channel as OFF for the track
            table.insert(routing[i], config[layer][i][j]==1 and 1 or 0)
        end
    end
    return routing
end

function context:init_layer_output_list()
    local output_list = {}
    for i=1,16 do
        -- represents a list of active output channels for the track
        -- hopefully helps to reduce route processing during triggers
        table.insert(output_list, {})
    end
    return output_list
end

function context:update_output_channel_data()
    for layer=1,5 do
        for track=1,16 do
            self:update_output_list(layer, self.pattern_lane.position, track)
        end
    end
end

function context:update_output_list(layer, patch, track)
    for channel=1,#self.layer_routing[layer].output_list[track] do self.layer_routing[layer].output_list[track][channel] = nil end -- clear list of output channels
    for channel=1,16 do
        if self.layer_routing[layer].patch[patch].routing[track][channel] == 1 then table.insert(self.layer_routing[layer].output_list[track], channel) end -- process active outs and add to list
    end
end

function context:add_channel_params_hidden()
    params:add_group("hidden "..self.name.." layer channels", 20480)
    for n=1,5 do
        for q=1,16 do
            for k=1,16 do
                for m=1,16 do
                    params:add{
                        type = "number", id = (self.name.."_layer_"..n.."_patch_"..q.."_track_"..k.."_channel_"..m),
                        name = ("channel "..m),
                        min = 0, max = 1,
                        default = self.layer_routing[n].patch[q].routing[k][m],
                        action = function(x)
                            self.layer_routing[n].patch[q].routing[k][m] = x
                            self:update_output_list(n, q, k)
                        end
                    }
                end
            end
        end
    end
    params:hide("hidden "..self.name.." layer channels")
end

function context:set_output_data(layer, track, channel)
    local val = self.layer_routing[layer].patch[self.pattern_lane.position].routing[track][channel] == 0 and 1 or 0
    params:set(self.name.."_layer_"..layer.."_patch_"..self.pattern_lane.position.."_track_"..track.."_channel_"..channel, val)
    --self:update_output_channel_data()
end

function context:set_output_data_val(layer, patch, track, channel, val)
    params:set(self.name.."_layer_"..layer.."_patch_"..patch.."_track_"..track.."_channel_"..channel, val)
    --self:update_output_channel_data()
end

function context:draw_grid_base()
    g:led(1, 5, basic_lighting(self.audition))
    g:led(2, 5, basic_lighting(self.advance_sequence))
    g:led(3, 5, negative_lighting(self.clear_velocity))
    g:led(3, 6, negative_lighting(self.midi_learn_vel_high))

    g:led(13, 5, self.page_visual[1] > 0 and self.page_visual[1] or negative_lighting(self.active_page == 1))
    g:led(14, 5, self.page_visual[2] > 0 and self.page_visual[2] or negative_lighting(self.active_page == 2))
    g:led(15, 5, self.page_visual[3] > 0 and self.page_visual[3] or negative_lighting(self.active_page == 3))
    g:led(16, 5, self.page_visual[4] > 0 and self.page_visual[4] or negative_lighting(self.active_page == 4))
end


function context:grid_key_base(layer)
    local input_num = self.selected_input
    local input = self.input[input_num]

    self.clear_velocity = self.momentary[3][5] == 1 and true or false
    if self.clear_velocity then
        if self.midi_learn_vel_low then
            input:set_low_thresh("trig", layer, 0)
            input:set_high_thresh("trig", layer, 127)
        elseif self.midi_learn then
            input:set_velocity_floor(0)
            input:set_velocity_ceiling(127)
        end
    end
end

function context:get_current_gesture_routing_base()
    local gesture
    if self.midi_learn and self.midi_learn_vel_high then gesture = lock_midi_learn==0 and "midi learn vel ceil" or "midi learn vel ceil*"
    elseif self.midi_learn and self.midi_learn_vel_low then gesture = lock_midi_learn==0 and "midi learn vel floor" or "midi learn vel floor*"
    elseif self.midi_learn and self.clear_velocity then gesture = "clear vel floor/ceiling"
    elseif self.midi_learn_vel_low and self.clear_velocity then gesture = "clear layer vel"
    elseif self.midi_learn  then gesture = lock_midi_learn==0 and "midi learn" or "midi learn*"
    elseif self.midi_learn_vel_high then gesture = lock_midi_learn==0 and "midi learn vel high" or "midi learn vel high*"
    elseif self.midi_learn_vel_low then gesture = lock_midi_learn==0 and "midi learn vel low" or "midi learn vel low*"
    elseif self.clear_velocity then gesture = "clear velocity"
    else gesture = self:get_current_gesture_base()
    end
    return gesture
end

function context:set_layer_visual_event(events)
    self.layer_visual = self:init_visual(5)
    self.page_visual = self:init_visual(4)

    local default = 8
    for i=1,#events do
        if events[i].input_num == self.selected_input then
            local lane = events[i].lane
            self.layer_visual[events[i].layer_num] = default
            if lane <= 4 then
                self.page_visual[1] = default
            elseif lane <= 8 then
                self.page_visual[2] = default
            elseif lane <= 12 then
                self.page_visual[3] = default
            elseif lane <= 16 then
                self.page_visual[4] = default
            end
        end
    end
end

function context:set_input_visual_event(input_num)
    self.input_visual = self:init_visual(16)
    self.input_visual[input_num] = 8
end

return context