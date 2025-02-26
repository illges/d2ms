---@diagnostic disable: undefined-global, lowercase-global

local context = {}
context.__index = context

function context.new()
    local self = setmetatable({}, context)

    self.keyboard = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    self.focus = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    self.med_focus = {
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    }
    self.chord_buffer = {}
    self.light = 3
    self.octave = 3
    self.octave_count = 11
    self.mute = 0
    self.root = 0
    self.p_vel = 70
    self.d_vel = 70
    self.hold_time = 0.1
    self.scale_choice = 1
    self.modifier = 0
    self.scale_size = 81
    self.scale = {}
    self:build_scale()
    self.default_output_channel = 1
    self.default_input_channel = 2
    self.midi_in_device = 16
    self.output_dest = "midi/engine"
    self.destination_list = {"midi/engine", "midi", "engine"}
    self.link_machine_interval = 1
    self.live_record_mode = false
    self:add_params()
    return self
end

function context:build_scale()
    self.octave_size = #music.generate_scale(self.root, music.SCALES[self.scale_choice].name) - 1
    self.scale = music.generate_scale(self.root, music.SCALES[self.scale_choice].name, self.octave_count)
    self.scale_size = #self.scale

    self.keyboard = self:build_small_keyboard()
    self.med_keyboard = self:build_med_keyboard()

    self.note_name_scale = music.note_nums_to_names(self.scale, true)
    self.freq_scale = music.note_nums_to_freqs(self.scale)
end

function context:build_small_keyboard()
    self.small_root_index = ((self.octave + 2) * self.octave_size) + 1

    local size = 2
    if self.octave_size <= 5 then size = 3
    elseif self.octave_size > 8 then size = 1
    end

    local keyboard_size = (size*self.octave_size)+1
    if keyboard_size > 15 then keyboard_size = 15 end
    local temp = {}
    local index = nil
    for i=1,keyboard_size do
        index = self.small_root_index + i - 1
        if index <= #self.scale then
            table.insert(temp, index) -- fill keyboard with scale indices
        end
    end
    return temp
end

function context:build_med_keyboard()
    if self.octave<0 then
        self.med_root_index = ((self.octave + 2) * self.octave_size) + 1
    elseif self.octave<6 then
        self.med_root_index = ((self.octave + 0) * self.octave_size) + 1
    else
        self.med_root_index = ((self.octave - 2) * self.octave_size) + 1
    end

    -- max size  for medium keyboard 43 (14 + 14 + 15)
    -- nlocal size = math.floor(43/self.octave_size)
    local keyboard_size = 43--size*self.octave_size
    local temp = {}
    local index = nil
    for i=1,keyboard_size do
        index = self.med_root_index + i - 1
        if index <= #self.scale then
            table.insert(temp, index) -- fill keyboard with scale indices
        end
    end
    return temp
end

function context:current_scale()
    return music.note_num_to_name(self.root)..(self.octave).." "..music.SCALES[self.scale_choice].name
end

function context:match_note_to_scale(note)
    local min = 1
    local max = #self.scale
    local mid = math.floor((max/2)+0.5)
    -- attempt to cut back on potential iteration below
    if note<self.scale[mid] then
        max = mid-1
    else
        min = mid
    end
    for i=min,max do
        if note == self.scale[i] or
           note < self.scale[i+1] then
                return i
        end
    end
end

function context:get_note_from_scale(index)
    return self.scale[index]
end

function context:draw_grid(note_lighting, note)
    local light
    for x=1,#self.keyboard do
        if self.focus[x] == 1 then light = 15
        elseif note_lighting then light = x
        elseif note>0 and music.note_num_to_name(self.scale[self.keyboard[x]]) == music.note_num_to_name(self.scale[note]) then light = 15
        elseif music.note_num_to_name(self.scale[self.keyboard[x]]) == music.note_num_to_name(self.root) then light = 10
        else light = 5 end
        g:led(x, 8, light)
    end

    -- piano octave buttons
    g:led(1, 7, self.octave+6)
    g:led(2, 7, self.octave+6)
    -- piano mute button
    g:led(3, 7, self.mute*15)
end

function context:draw_med_keyboard()
    local light = 0
    local note
    for y=6,8 do
        for x=1,15 do
            light = 0
            if (y==6 and x<=14) or
                (y==7 and x<=14) or
                (y==8 and x<=15) then
                    if self.med_focus[self:get_scale_index_med(x,y)] == 1 then light = 15
                    elseif self:get_scale_index_med(x,y) <= #self.med_keyboard then
                        if self:check_same_note(self.med_keyboard[self:get_scale_index_med(x,y)]) then
                            light = 15
                        else
                            light = 5
                        end
                    end
            end
            g:led(x, y, light)
        end
    end
end

function context:check_same_note(index)
    return music.note_num_to_name(self.root) == music.note_num_to_name(self.scale[index])
end

function context:get_offset_med(y)
    return (y - 6) * 14
end

function context:get_scale_index_med(x,y)
    return x + self:get_offset_med(y)
end

function context:draw_screen()
    local held_key = self:key_pressed()
    local scale_note = self.scale[self:get_keyboard_val(held_key)]
    if held_key > 0 then
        screen.level(0)
        screen.move(2, 62)
        screen.text("hint: "..scale_note.." - "..music.note_num_to_name(scale_note, true))
    end
end

function context:is_external(ch, n)
    if external_piano_input and
       ch==self.default_input_channel and
       n == self.midi_in_device then
        return true
    end
    return false
end

function context:add_params()
    params:add_group("piano", 10)
    params:add{ type = "number", id= ("input_channel"),
        name = ("input channel"), min = 1, max = 16,
        default = self.default_input_channel,
        action = function(x) self.default_input_channel = x end
    }

    local midi_in = self.midi_in_device
    for i=1,#device_manager.device_name_list do
        if device_manager.device_name_list[i] == "LMM2" then midi_in = i end
    end
    params:add{
        type = "option", id = ("midi_in"),
        name = ("midi in"),
        options = device_manager.device_name_list,
        default = midi_in,
        action = function(x)
            self.midi_in_device = x
        end
    }

    params:add{
        type = "option", id = ("piano_output_destination"),
        name = ("output"),
        options = self.destination_list,
        default = 1,
        action = function(x) self.output_dest = self.destination_list[x] end
    }
    params:add{ type = "number", id= ("piano_default_channel"),
        name = ("piano default channel"), min = 1, max = 16,
        default = self.default_output_channel,
        action = function(x) self.default_output_channel = x end
    }
    params:add{ type = "number", id= ("piano_velocity"),
        name = ("piano velocity"), min = 1, max = 127,
        default = self.p_vel,
        action = function(x) self.p_vel = x end
    }
    params:add{
        type = "number", id = ("piano_hold_time"),
        name = ("piano hold time"),
        min = 0.1, max = 10,
        default = self.hold_time,
        action = function(x) self.hold_time = x end
    }
    params:add{ type = "number", id= ("piano_root"),
        name = ("root"), min = 0, max = 11,
        default = self.root,
        action = function(x)
            self.root = x
            self:build_scale()
        end
    }
    params:add{ type = "number", id= ("piano_scale"),
        name = ("scale"), min = 1, max = 41,
        default = self.scale_choice,
        action = function(x)
            self.scale_choice = x
            self:build_scale()
        end
    }
    params:add{ type = "number", id= ("default_velocity"),
        name = ("default velocity"), min = 1, max = 127,
        default = self.d_vel,
        action = function(x) self.d_vel = x end
    }
    params:add{ type = "number", id= ("link_to_machine_interval"),
        name = ("link to machine interval"), min = 0, max = 1,
        default = self.link_machine_interval,
        action = function(x) self.link_machine_interval = x end
    }
end

function context:invert_link_machine_int()
    params:set("link_to_machine_interval", util.wrap(self.link_machine_interval+1,0,1))
end

function context:set_root(val)
    params:set("piano_root", val)
end

function context:set_scale(val)
    params:set("piano_scale", val)
end

function context:invert_live_record_mode()
    if self.live_record_mode == false then
        self.live_record_mode = true
    else
        self.live_record_mode = false
    end
end

function context:get_focus(index)
    if self.live_record_mode==false or use_med_piano==0 then
        return self.focus[index]
    else
        return self.med_focus[index]
    end
end

function context:set_focus(index, z)
    if self.live_record_mode == false or use_med_piano==0 then
        self.focus[index] = z == 1 and 1 or 0
    else
        self.med_focus[index] = z == 1 and 1 or 0
    end
end

function context:get_keyboard_index(x,y)
    if self.live_record_mode==false or use_med_piano==0 then
        return x
    else
        return self:get_scale_index_med(x,y)
    end
end

function context:get_keyboard_val(index)
    if self.live_record_mode==false or use_med_piano==0 then
        return self.keyboard[index]
    else
        return self.med_keyboard[index]
    end
end

function context:check_play_piano(x,y)
    if self.live_record_mode==false or use_med_piano==0 then
        return y == 8 and x <= #self.keyboard
    else
        return y >= 6 and self:get_scale_index_med(x,y) <= #self.med_keyboard
    end
end

function context:log_key_press(index)
    if DEBUG_PIANO == 0 then return end
    print("***log_piano_key_press***")
    print("midi note: "..self.scale[index])
    print("piano note: "..music.note_num_to_name(self.scale[index],true))
    print("dest: "..self.output_dest)
    print("********************")
end

function context:key_pressed()
    if self.live_record_mode==false or use_med_piano==0 then
        for i=1,#self.keyboard do
            if self.focus[i] == 1 then return i end
        end
    else
        for i=1,#self.med_keyboard do
            if self.med_focus[i] == 1 then return i end
        end
    end
    
    return 0
end

function context:check_chord_buffer()
    if self:key_pressed() == 0 then
        for i=1,#self.chord_buffer do
            self.chord_buffer[i] = nil
        end
    end
end

function context:gestures(oct_d, oct_u, mute)
    if oct_d then
        self.octave = util.clamp(self.octave - 1, -2, 7)
        self:build_scale()
    elseif oct_u then
        self.octave = util.clamp(self.octave + 1, -2, 7)
        self:build_scale()
    end
    if mute then self.mute = 1 - self.mute end
end

function context:enc_one(d)
    
end

function context:enc_two(d)
    self:set_root(self.root + d)
end

function context:enc_three(d)
    self:set_scale(self.scale_choice + d)
end

return context