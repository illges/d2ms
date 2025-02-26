-- drums 2 midi synth...
-- sampler, sequence,
-- sound, something
--
-- v1.0.0
--
-- an augmented drumming script
--
-- developed by phillwilson
--           and illges

---@diagnostic disable: undefined-global, lowercase-global

engine.name = 'PolyPerc'
music = require 'musicutil'

SCRIPT_NAME = "d2ms"
parameters = include 'lib/parameters'
local _dm=include("lib/device_manager")
local trigger_event = include 'lib/trigger_event'
local config = include 'lib/config/dev'
local context_machine = include 'lib/context_machine'
local context_trig = include 'lib/context_trig'
local context_note = include 'lib/context_note'
local context_engine = include 'lib/context_engine'
local context_pattern = include 'lib/context_pattern'
local context_patch = include 'lib/context_patch'
local context_cc = include 'lib/context_cc'
local context_play = include 'lib/context_play'
local context_scene = include 'lib/context_scene'
local piano_context = include 'lib/piano'
local config_cc = include 'lib/config/custom_cc_mappings'
local io_obj = include 'lib/io'
local io = {}
local piano = {}

MACHINES = {
    EMPTY = include 'lib/machines/EMPTY',
    basic = include 'lib/machines/basic',
    riff = include 'lib/machines/riff',
    chord = include 'lib/machines/chord',
    prog = include 'lib/machines/prog',
    stack = include 'lib/machines/stack',
    velocity = include 'lib/machines/velocity',
    fixed = include 'lib/machines/fixed',
    strum = include 'lib/machines/strum',
    ratchet = include 'lib/machines/ratchet',
    follow = include 'lib/machines/follow',
    advance = include 'lib/machines/advance',
}

TRIGS = {
    EMPTY = include 'lib/trigs/EMPTY',
    AB = include 'lib/trigs/AB',
    direction = include 'lib/trigs/direction',
    layer_mute = include 'lib/trigs/layer_mute',
    reset = include 'lib/trigs/reset',
    gears = include 'lib/trigs/gears',
    fill = include 'lib/trigs/fill',
    sustain = include 'lib/trigs/sustain',
    offset = include 'lib/trigs/offset',
    cc = include 'lib/trigs/cc',
    root = include 'lib/trigs/root',
    scale = include 'lib/trigs/scale',
    tap_tempo = include 'lib/trigs/tap_tempo',
    auto = include 'lib/trigs/auto',
    proxy = include 'lib/trigs/proxy',
    release = include 'lib/trigs/release',
    conductor = include 'lib/trigs/conductor',
}

g = grid.connect()
--g = util.file_exists(_path.code.."toga") and include "toga/lib/togagrid" or g

lane_area = 4
total_tracks = 16
tap_tempo_light = 1
tap_tempo_set_counter = 0

function init()
    add_main_params()
    device_manager = _dm.new({adv=true, debug=false})
    params:bang()
    build_contexts()
    if config.load_default == 1 then print("default pset loaded") params:default() end
    machine_context:update_output_channel_data()

    grid_dirty = true ------------------------ ensure we only redraw when something changes
    grid_redraw_clock_id = clock.run(grid_redraw_clock) -- create a "redraw_clock" and note the id
    tap_tempo_clock_id = clock.run(tap_tempo_redraw_clock)

    screen_dirty = true
    screen_refresh=metro.init()
    screen_refresh.count=-1
    screen_refresh.time=0.1
    screen_refresh.event=function()
        if screen_dirty then
            redraw()
            screen_dirty = false
        end
    end
    screen_refresh:start()
end

function init_config_params()
    local config_options={}
    for k,_ in pairs(config_cc) do
        table.insert(config_options,k)
    end
    --table.sort(config_options)
    params:add_separator("cc config")
    params:add_option("choose cc config","choose cc config",config_options)
    params:add{ type = "number", id= ("cc config load channel"),
                name = ("load channel"), min = 0, max = 16,
                default = 1,
                action = function(x) end
    }
    params:add{type="binary",name="load cc config",id="load cc config",behavior="trigger",
        action=function(v)
            print("***uploading cc config***")
            local loadCh = params:get("cc config load channel")
            if loadCh == 0 then
                for ch=1,16 do
                    cc_context:load_cc_config(config_cc[config_options[params:get("choose cc config")]], ch)
                end
            else
                cc_context:load_cc_config(config_cc[config_options[params:get("choose cc config")]], loadCh)
            end
        end
    }
end

function tap_tempo_redraw_clock()
    while true do
        tap_tempo_light = 0
        grid_redraw()
        clock.sleep(clock.get_beat_sec())
        tap_tempo_light = 1
        grid_redraw()
    end
end

function build_contexts()
    piano = piano_context.new()
    init_config_params()
    params:add_separator("midi routing")
    for i=1,16 do
        table.insert(io, io_obj.new(i))
    end
    machine_context = context_machine.new(io)
    trig_context = context_trig.new(io)
    notes_context = context_note.new(piano)
    pattern_context = context_pattern.new(piano, notes_context.lane)
    cc_context = context_cc.new()
    -- filter_context = context_engine.new("filter", "cutoff", 309.375, 359.375, 5000)
    -- release_context = context_engine.new("release", "release", 0.2, 0.1, 3.1)
    -- pan_context = context_engine.new("pan", "pan", 0.125, -0.9, 0.9)
    -- pw_context = context_engine.new("pulse width", "pw", 7, 1, 97)

    patch_context = context_patch.new("patch", machine_context)
    scene_context = context_scene.new("scene", machine_context)
    play_context = context_play.new("play")

    params:bang()

    current_context = notes_context
end

function enc(n,d)
    if n == 3 then current_context:enc_three(d) end
    if n == 2 then current_context:enc_two(d) end
    if n == 1 then current_context:enc_one(d) end
    screen_dirty = true
    grid_dirty = true
end

function key(n,z)
    if z == 1 then
        if n == 3 then current_context:key_three(n,z) end
        if n == 2 then current_context:key_two(n,z) end
        screen_dirty = true
    end
end

function redraw()
    screen.clear()

    --context header banner
    screen.level(15)
    screen.rect(0,0,128,9)
    screen.fill()
    screen.level(0)
    screen.move(15, 7)
    screen.text(string.upper(current_context.name))

    --screen boarder
    -- screen.level(15)
    -- screen.move(1,9)
    -- screen.line(1,55)
    -- screen.move(128,9)
    -- screen.line(128,55)
    -- screen.stroke()

    --page number
    screen.level(0)
    screen.rect(1,1,9,7)
    screen.fill()
    screen.level(15)
    screen.move(4,7)
    screen.text(current_context.active_page)

    --hint footer banner
    screen.level(15)
    screen.rect(0,55,128,9)
    screen.fill()

    --hint text
    screen.level(0)
    current_context:get_current_gesture()
    screen.move(2, 62)
    local gesture = tap_tempo_set_counter>0 and "tempo = "..params:get("clock_tempo") or current_context.gesture
    screen.text("hint: "..gesture)

    current_context:draw_screen()
    screen.update()
end

function grid_redraw_clock() ----- a clock that draws space
    while true do ------------- "while true do" means "do this forever"
        clock.sleep(1/15) ------- pause for a fifteenth of a second (aka 15fps)
        if grid_dirty then ---- only if something changed
            grid_redraw() -------------- redraw space
            grid_dirty = false -- and everything is clean again
        end
    end
end

function grid_redraw()
    g:all(0)

    current_context:draw_grid()

    if notes_context.piano.live_record_mode==false or use_med_piano==0 then
        -- contexts
        g:led(13, 6, current_context.name == notes_context.name and 8 or 3)
        g:led(14, 6, current_context.name == cc_context.name and 8 or 3)
        g:led(15, 6, current_context.name == pattern_context.name and 8 or 3)
        g:led(16, 6, current_context.name == scene_context.name and 8 or 3)
        g:led(13, 7, current_context.name == machine_context.name and 8 or 3)
        g:led(14, 7, current_context.name == trig_context.name and 8 or 3)
        g:led(15, 7, current_context.name == patch_context.name and 8 or 3)
        g:led(16, 7, current_context.name == play_context.name and 8 or 3)
    end

    g:refresh()
end

function basic_lighting(condition)
    return condition == true and 8 or 3
end

function medium_lighting(condition)
    return condition == true and 8 or 6
end

function high_lighting(condition)
    return condition == true and 15 or 8
end

function negative_lighting(condition)
    return condition == true and 8 or 0
end

function negative_high_lighting(condition)
    return condition == true and 15 or 0
end

function custom_lighting(condition, high, low)
    if high == nil or low == nil then
        basic_lighting(condition)
        return
    end
    return condition == true and high or low
end

function active_indicator(x, y)
    return (x == true or y == true) and 8 or 0
end

g.key = function(x,y,z)
    current_context.momentary[x][y] = z == 1 and 1 or 0
    local mod_val = y + (4 * (current_context.active_page - 1))

    if z == 1 then
        if y <= lane_area and current_context.name ~= play_context.name then -- only execute for buttons pressed within note_lanes
            current_context:grid_patching(x,mod_val,z)
        elseif current_context.name == patch_context.name then
            if y==8 then patch_context:grid_patching_override(x,y,z) end
        end
    else
        current_context:grid_patching_off(x,y,0)
    end

    if (current_context.name == pattern_context.name or current_context.name == notes_context.name) and current_context.piano.live_record_mode and use_med_piano==1 then
        current_context.live_record_mode_pressed = current_context.momentary[10][5] == 1 and true or false
        if current_context.live_record_mode_pressed then
            current_context.piano:invert_live_record_mode()
        end
    else
        current_context:grid_key(x,y,z==1)

        --active page
        if x == 13 and y == 5 and z == 1 then current_context.active_page = 1 end
        if x == 14 and y == 5 and z == 1 then current_context.active_page = 2 end
        if x == 15 and y == 5 and z == 1 then current_context.active_page = 3 end
        if x == 16 and y == 5 and z == 1 then current_context.active_page = 4 end

        -- context stuff
        if x == 13 and y == 6 and z == 1 then change_context(notes_context) end
        if x == 14 and y == 6 and z == 1 then change_context(cc_context) end
        if x == 15 and y == 6 and z == 1 then change_context(pattern_context) end
        if x == 16 and y == 6 and z == 1 then change_context(scene_context) end
        if x == 13 and y == 7 and z == 1 then change_context(machine_context) end
        if x == 14 and y == 7 and z == 1 then change_context(trig_context) end
        if x == 15 and y == 7 and z == 1 then change_context(patch_context) end
        if x == 16 and y == 7 and z == 1 then change_context(play_context) end

        -- if current_context.type == filter_context.type then
        --     if x == 13 and y == 8 and z == 1 then change_context(filter_context) end
        --     if x == 14 and y == 8 and z == 1 then change_context(release_context) end
        --     if x == 15 and y == 8 and z == 1 then change_context(pan_context) end
        --     if x == 16 and y == 8 and z == 1 then change_context(pw_context) end
        -- end
    end

    if current_context.name == notes_context.name or
        --    current_context.type == filter_context.type or
        current_context.name == cc_context.name or
        current_context.name == machine_context.name or
        current_context.name == trig_context.name or
        current_context.name == patch_context.name or
        current_context.name == scene_context.name or
        current_context.name == pattern_context.name then
            current_context:range_update(x,y,z,mod_val)
    end

    if isTapTempoPressed() then
        if hold_to_tap==0 then
            trig_context.transport.tap_tempo()
        end
    end

    if (current_context.name == notes_context.name and notes_context.lane[notes_context.focus]:note_lane()) or
        current_context.name == pattern_context.name then
            piano_play(x,y,z)
    end

    -- midi note_off all
    if current_context.momentary[1][5] == 1 and
       current_context.momentary[2][5] == 1 then kill_midi_notes() end

    grid_dirty = true
    screen_dirty = true
end

function isTapTempoPressed()
    if current_context.name == notes_context.name or
       current_context.name == pattern_context.name or
       current_context.name == machine_context.name or
       current_context.name == play_context.name or
       current_context.name == trig_context.name then
        if current_context.tap_tempo_pressed then
            return true
        end
    end
    return false
end

local input = 1
local vel_layer = 1
function change_context(new_context)
    if current_context == new_context then return end
    if (current_context.name ~= notes_context.name and current_context.name ~= pattern_context.name) or
       (new_context.name ~= notes_context.name and new_context.name ~= pattern_context.name) then
            notes_context.piano.live_record_mode = false
            pattern_context.piano.live_record_mode = false
    end
    -- filter_context.engine_entry_mode_decreasing = false
    -- filter_context.engine_entry_mode_increasing = false
    -- release_context.engine_entry_mode_decreasing = false
    -- release_context.engine_entry_mode_increasing = false
    -- pan_context.engine_entry_mode_decreasing = false
    -- pan_context.engine_entry_mode_increasing = false
    -- pw_context.engine_entry_mode_decreasing = false
    -- pw_context.engine_entry_mode_increasing = false
    cc_context.cc_entry_mode_decreasing = false
    cc_context.cc_entry_mode_increasing = false

    if sticky_contexts==1 then
        if current_context.name == machine_context.name then
            input = current_context.selected_input
            vel_layer = machine_context.input[input].sel_machine_layer
        elseif current_context.name == trig_context.name then
            input = current_context.selected_input
            vel_layer = machine_context.input[input].sel_trig_layer
        end
    end

    new_context.active_page = current_context.active_page
    current_context = new_context
    if sticky_contexts==1 then
        if current_context.name == machine_context.name then
            current_context.selected_input = input
            current_context.input[input].sel_machine_layer = vel_layer
        elseif current_context.name == trig_context.name then
            current_context.selected_input = input
            current_context.input[input].sel_trig_layer = vel_layer
        end
    end
    current_context:init_metas()
end

function piano_play(x,y,z)
    if not notes_context.piano:check_play_piano(x,y) then return end
    local index = notes_context.piano:get_keyboard_index(x,y)
    notes_context.piano:set_focus(index,z)
    if notes_context.piano:get_focus(index) == 1 then
        notes_context.piano:log_key_press(notes_context.piano:get_keyboard_val(index))
        table.insert(notes_context.piano.chord_buffer, notes_context.piano:get_keyboard_val(index))
        if notes_context.piano.live_record_mode then
            live_record(notes_context.piano:get_keyboard_val(index))
        end
        if notes_context.piano.mute == 0 then
            if notes_context.piano.output_dest == "engine" then
                local freq = cutoff
                engine.cutoff(freq)
                engine.hz(music.note_num_to_freq(notes_context.piano.scale[notes_context.piano:get_keyboard_val(index)]))
            elseif notes_context.piano.output_dest == "midi" then
                build_play_output(notes_context.piano:get_keyboard_val(index))
            else
                local freq = cutoff
                engine.cutoff(freq)
                engine.hz(music.note_num_to_freq(notes_context.piano.scale[notes_context.piano:get_keyboard_val(index)]))
                build_play_output(notes_context.piano:get_keyboard_val(index))
            end
        end
    end
end

function live_record(note)
    local track = notes_context.lane[notes_context.focus]
    track:set_step_data(track.position, note)
    track:set_step_mute(track.position, 0)
    track.position = track.position + track:direction()
    track:clamp_position_chaining()
end

function build_play_output(n)
    local result = get_channels(notes_context.focus)
    local channels = result[1]
    local interval = result[2]
    local note = n
    for i=1,#channels do
        play_midi(true, note + interval, notes_context.piano.p_vel, channels[i], notes_context.piano.hold_time) -- note number, velocity, channel, duration
    end
end

function get_channels(focus)
    local channels = {}
    local interval = 0
    if notes_context.piano.link_machine_interval==1 then
        local input = machine_context.selected_input
        local layer = io[input].sel_machine_layer
        interval = get_interval(input, layer)
        for j=1,#machine_context.layer_routing[layer].output_list[focus] do
            table.insert(channels, machine_context.layer_routing[layer].output_list[focus][j])
        end
    end
    if #channels < 1 then table.insert(channels, notes_context.piano.default_output_channel) end
    return {channels, interval}
end

function get_interval(input, layer)
    local machine = machine_context.input[input].machine[layer]
    if machine.type == "basic" or
       machine.type == "velocity" or
       machine.type == "strum" or
       machine.type == "ratchet" then
        return machine.riff_intervals[1]
    elseif machine.type == "chord" or
           machine.type == "riff" then
        return machine.riff_intervals[machine.range.min]
    else
        return 0
    end
end

function strum(event, strum_lane, riff)
    local track = notes_context.lane[event.lane]
    if riff then
        track = notes_context.lane[event.layer.leader_routing[1]]
    end
    local strum_track = notes_context.lane[strum_lane]
    local cc_send = event.layer.cc_send == 1
    local cc_match = event.layer.cc_match == 1
    local note_send = event.layer.notes_send == 1
    strum_track.strum_active = 1
    if cc_send and cc_match == false then
        route_cc(event)
    end
    local position = event.offset == 1 and track.prev_position or track.position
    for i=1,event.layer.strum_length do
        if cc_send and cc_match then
            route_cc_match(event, i)
        end
        if note_send then
            if riff then
                proto_harvest_riff_strum(track, event, strum_track, position)
                if i == 1 then notes_context:set_riff_visual(event.layer.leader_routing[1], position) end
            else
                proto_harvest(track, event, true, false)
            end
            strum_track:adv_strum_position()
            --notes_context:set_note_visual(strum_lane, strum_track.strum_position)
            set_focus_x(strum_lane,  strum_track.strum_position)
            screen_dirty = true
        end
        grid_dirty = true
        local division = event.layer.strum_division
        if division > 0 and not skip_strum_sleep(i, event.layer.strum_length) then clock.sleep(clock.get_beat_sec()/division*4) end
    end
    if note_send then
        strum_track:set_position(strum_track.strum_position)
        strum_track:set_pattern(strum_track.strum_pattern)
        --set_focus_x(strum_lane,  strum_track.strum_position)
        strum_track.strum_light=0
        strum_track.strum_active = 0
        if strum_track.prime_ab then
            strum_track:invert_b_section()
            strum_track.prime_ab = false
        end
    end
    if cc_send and cc_match then
        for j=1,#event.channels do
            local channel = cc_context.channel[event.channels[j]]
            for i=1,16 do
                local slot = channel.lane[i]
                if slot.active == 1 then
                    slot:set_position(slot.strum_position)
                    slot.strum_light=0
                    slot.strum_active = 0
                end
            end
        end
    end
    clock.cancel(strum_track.strum_clock_id)
    screen_dirty = true
end

function skip_strum_sleep(index, length)
    if index == length and ext_strum_reset_window == 0 then return true end
    return false
end

function ratchet(event)
    local track = notes_context.lane[event.lane]
    local cc_send = event.layer.cc_send == 1
    local cc_match = event.layer.cc_match == 1
    if cc_send and cc_match == false then
        route_cc(event)
    end
    for i=1,event.layer.strum_length do
        if cc_send and cc_match then
            route_cc(event)
        end
        proto_harvest(track, event, true, false)
        grid_dirty = true
        local division = event.layer.strum_division
        if  division > 0 then clock.sleep(clock.get_beat_sec()/division*4) end
    end
    notes_context:set_note_visual(event.lane, track.position)
    advance_lane_position(track,event.lane)
end

function chord(row, event, length, division, pos)
    local track = notes_context.lane[row]
    local cc_send = event.layer.cc_send == 1
    if cc_send then
        route_cc(event)
    end
    for i=1,length do
        if division > 0 then track.chord_strum_active = 1 end
        if event.layer:check_play() then
            chord_harvest(track, event, pos)
            --notes_context:set_note_visual(row, event.offset == 1 and track.prev_position or track.position)
        end
        event.layer:adv_position(0)
        if i == length then -- maybe not need anymore since we adv on every i
            event.layer.position = event.layer.range.min
            machine_context.fixed_note_visual = event.layer.position
            grid_redraw()
        end
        machine_context.fixed_note_visual = event.layer.position
        if division > 0 and not skip_strum_sleep(i, length) then clock.sleep(clock.get_beat_sec()/division*4) end
    end
    track.chord_strum_active = 0
end

function prog(row, event, division, pos)
    local track = notes_context.lane[row]
    local position = event.offset == 1 and track.prev_position or pos
    local pattern = event.offset == 1 and track.prev_pattern or track.active_pattern
    if track:check_play_step(position) then
        if position < track:range_min() then position = track:range_max() end
        if position > track:range_max() then position = track:range_min() end
        local root = notes_context.piano.scale[track:data(position, pattern) + event.layer:get_interval()]
        local chord = event.layer:get_chord(root)
        local length = #chord
        local cc_send = event.layer.cc_send == 1
        if cc_send then
            route_cc(event)
        end
        for i=1,length do
            if division > 0 then track.chord_strum_active = 1 end
            if event.layer:check_play() then
                route_harvest(track, chord[i], event, false)
            end
            if division > 0 then clock.sleep(clock.get_beat_sec()/division*4) end
        end
        track.chord_strum_active = 0
    end
end

function prog_v2(row, leader, event, division, pos)
    local track = notes_context.lane[row]
    local leader_track = notes_context.lane[leader]
    local position = event.offset == 1 and track.prev_position or pos
    local pattern = event.offset == 1 and track.prev_pattern or track.active_pattern
    if track:check_play_step(position) then
        if position < track:range_min() then position = track:range_max() end
        if position > track:range_max() then position = track:range_min() end
        local root = notes_context.piano.scale[leader_track:data(pos, pattern) + event.layer:get_interval()]
        local name = music.CHORDS[track:data(pos, pattern)].name
        print(name)
        local chord = music.generate_chord(root,name,0)
        local length = #chord
        local cc_send = event.layer.cc_send == 1
        if cc_send then
            route_cc(event)
        end
        for i=1,length do
            if division > 0 then track.chord_strum_active = 1 end
            if event.layer:check_play() then
                route_harvest(track, chord[i], event, false)
            end
            if division > 0 then clock.sleep(clock.get_beat_sec()/division*4) end
        end
        track.chord_strum_active = 0
    end
end

function stack(row, event, division, pos)
    local track = notes_context.lane[row]
    local position = event.offset == 1 and track.prev_position or pos
    local pattern = event.offset == 1 and track.prev_pattern or track.active_pattern
    if track:check_play_step(position) then
        if position < track:range_min() then position = track:range_max() end
        if position > track:range_max() then position = track:range_min() end
        local root = track:data(position, pattern) + event.layer:get_interval()
        local chord = event.layer:get_stack_chord(root)
        local length = #chord
        local cc_send = event.layer.cc_send == 1
        if cc_send then
            route_cc(event)
        end
        for i=1,length do
            if division > 0 then track.chord_strum_active = 1 end
            --if event.layer:check_play() then
                route_harvest(track, chord[i], event, false)
            --end
            if division > 0 and not skip_strum_sleep(i, length) then clock.sleep(clock.get_beat_sec()/division*4) end
        end
        track.chord_strum_active = 0
    end
end

function chord_harvest(track, event, pos)
    local position = event.offset == 1 and track.prev_position or pos
    local pattern = event.offset == 1 and track.prev_pattern or track.active_pattern
    if track:check_play_step(position) then
        if position < track:range_min() then position = track:range_max() end
        if position > track:range_max() then position = track:range_min() end
        local int = event.layer:get_interval()
        local note = util.clamp(track:data(position, pattern) + int, 1, #notes_context.piano.scale)
        route_harvest(track, note, event)
    end
end

function harvest(row, event, follow)
    local track = notes_context.lane[row]
    proto_harvest(track, event, false, follow)
    if event.riff_lane > 0 then
        notes_context:set_riff_visual(row, event.offset == 1 and track.prev_position or track.position)
        notes_context:set_note_visual(event.riff_lane, notes_context.lane[event.riff_lane].position)
    else
        notes_context:set_note_visual(row, event.offset == 1 and track.prev_position or track.position)
    end
end

function harvest_audition(row, x)
    local track = notes_context.lane[row]
    local result = get_channels(row)
    local channels = result[1]
    local int = result[2]
    local event = trigger_event.new()
    event:set_bulk(row, channels, 90, notes_context.piano.p_vel, 90, io[1].machine[1])
    if track:check_play_step(x) and not track:riff_lane() then
        local note = track:data(x) + int
        play_engine(true, track, note)
        route_harvest(track, note, event)
    end
    track:set_position(x)
end

function grid_harvest(row)
    local track = notes_context.lane[row]
    local result = get_channels(row)
    local channels = result[1]
    local int = result[2]
    local event = trigger_event.new()
    event:set_bulk(row, channels, 90, notes_context.piano.p_vel, 90, io[1].machine[1])
    if track:check_play_step(track.position) and not track:riff_lane() then
        local note = track:data(track.position) + int
        route_harvest(track, note, event)
    end
    advance_lane_position(track,row)
end

function proto_harvest(track, event, strum, follow)
    local position = event.offset == 1 and track.prev_position or track.position
    local pattern = event.offset == 1 and track.prev_pattern or track.active_pattern
    if strum or follow then position = track.strum_position end
    if track:check_play_step(position) then
        local min = strum and track:range_min(track.strum_pattern) or track:range_min()
        local max = strum and track:range_max(track.strum_pattern) or track:range_max()
        if position < min then position = max end
        if position > max then position = min end
        -- print("riff lane - "..event.riff_lane)
        -- print("riff interval - "..notes_context.lane[event.riff_lane]:data())
        local int = event.layer:get_interval()
        if event.riff_lane > 0 then
            int = int + notes_context.lane[event.riff_lane]:data()
        end
        --local int = event.riff_lane > 0 and notes_context.lane[event.riff_lane]:data() or event.layer:get_interval()
        local note = strum and util.clamp(track:strum_data(position) + int, 1, #notes_context.piano.scale) or util.clamp(track:data(position, pattern) + int, 1, #notes_context.piano.scale)
        route_harvest(track, note, event)
    end
end

function clamp_cancel(val, int, min, max)
    local temp = val + int
    if temp > max or temp < min then
        return val
    end
    return temp
end

function proto_harvest_riff_strum(track, event, riff_track, position)
    local riff_position = riff_track:direction() == 1 and riff_track.strum_position  or riff_track.strum_position
    if riff_track:check_play_step(riff_position) then
        local min = riff_track:range_min(riff_track.strum_pattern)
        local max = riff_track:range_max(riff_track.strum_pattern)
        if riff_position < min then riff_position = max end
        if riff_position > max then riff_position = min end
        -- print("riff lane - "..event.riff_lane)
        -- print("riff interval - "..notes_context.lane[event.riff_lane]:data())
        local int = event.layer:get_interval() + riff_track:strum_data(riff_position)
        local note = util.clamp(track:data(position) + int, 1, #notes_context.piano.scale)
        route_harvest(track, note, event)
    end
end

function route_harvest(track, note, event, rescale)
    if rescale == nil then rescale = true end
    if event.layer.destination == 1 or event.layer.destination == 3 then -- engine
        play_engine(rescale, track, note)
    end
    if event.layer.destination == 1 or event.layer.destination == 2 then -- midi
        local channels = event.channels
        for i=1,#channels do
            if event.layer.prev_note[channels[i]] > 0 then
                stop_midi(event.layer.prev_note[channels[i]], channels[i])
                --print("stopped "..event.layer.prev_note[channels[i]])
                event.layer.prev_note[channels[i]] = 0
            end
            local duration = 0.1
            if event.layer ~= nil then
                duration = event.layer:get_hold_time()
            end
            play_midi(rescale, note, event.vel_out, channels[i], duration) -- note number, velocity, channel, duration
            if duration == 0 or event.layer.monophonic==1 then
                event.layer.prev_note[channels[i]] = note
                --print("saved "..note)
            end
            --event.layer.prev_note[channels[i]] = note
        end
    end
end

NOTE_TIMER_IDS = {{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},}

function play_midi(rescale, note, vel, chan, duration)
    if duration == nil then duration = 0.1 end
    local scaled_note = rescale and notes_context.piano.scale[note] or note
    log_midi_output(scaled_note, vel, chan)
    for j=1,#device_manager.output_devices do
        device_manager.output_devices[j].midi:note_on(scaled_note, vel, chan)
    end
    if NOTE_TIMER_IDS[chan][scaled_note]~=nil then clock.cancel(NOTE_TIMER_IDS[chan][scaled_note]) end
    if duration > 0 then
        NOTE_TIMER_IDS[chan][scaled_note] = clock.run(
        --clock.run(
            function()
                clock.sleep(duration)
                for j=1,#device_manager.output_devices do
                    --print("note off",scaled_note,chan)
                    device_manager.output_devices[j].midi:note_off(scaled_note, 0, chan)
                end
            end
        )
    end
end

function stop_midi(note, chan)
    local scaled_note = notes_context.piano.scale[note]
    for j=1,#device_manager.output_devices do
        device_manager.output_devices[j].midi:note_off(scaled_note, 0, chan)
    end
end

function harvest_velocity(event)
    local track = notes_context.lane[event.lane]
    local length = track:length()
    local floor = event.layer.low_thresh
    local ceiling = event.layer.high_thresh
    local threshold = track:get_vel_step_threshold(floor, ceiling)
    for i=1,length do
        local calc_thresh = (i*threshold) + floor
        calc_thresh = i==length and ceiling or calc_thresh
        if event.vel_in <= calc_thresh then
            local step = track:range_min() + i - 1
            if track:check_play_step(step) then
                local int = event.layer:get_interval()
                local note = util.clamp(track:data(step) + int, 1, #notes_context.piano.scale)
                route_harvest(track, note, event)
            end
            return step
        end
    end
end

function route_cc(event)
    for j=1,#event.channels do
        local channel = cc_context.channel[event.channels[j]]
        cc_context:set_channel_visual(channel.channel)
        for i=1,16 do
            local slot = channel.lane[i]
            if slot.active == 1 then
                if slot.velocity_mode == 1 then
                    harvest_cc_velocity(channel, i, event.channels[j], event)
                else
                    update_engine_cc(channel, i)
                    harvest_cc(channel, i)
                end
            end
        end
    end
end

function update_engine_cc(channel, slot)
    if channel.engine_active==0 or slot>4 then return end
    local position = channel.lane[slot].strum_active==1 and channel.lane[slot].strum_position or channel.lane[slot].position
    local val = channel.lane[slot]:data(position)
    if slot==1 then set_cutoff(val)
    elseif slot==2 then set_release(val)
    elseif slot==3 then set_pan(val)
    elseif slot==4 then set_pw(val)
    end
end

function route_cc_match(event, count)
    for j=1,#event.channels do
        local channel = cc_context.channel[event.channels[j]]
        if count==1 then cc_context:set_channel_visual(channel.channel) end
        for i=1,16 do
            local slot = channel.lane[i]
            if slot.active == 1 then
                slot.strum_active = 1
                update_midi_cc(channel, i)
                update_engine_cc(channel, i)
                slot:adv_strum_position()
            end
        end
    end
end

function route_cc_trig(event)
    local slot_num = event.layer.cc_slot
    local channels = event.channels
    for j=1,#channels do
        local channel = cc_context.channel[channels[j]]
        local slot = channel.lane[slot_num]
        if event.layer.cc_slot_toggle == 1 then
            slot:set_active()
        elseif slot.velocity_mode == 1 then
            harvest_cc_velocity(channel, slot_num, channels[j], event)
        else
            harvest_cc(channel, slot_num)
        end
    end
end

function harvest_cc_velocity(channel, slot, channel_num, event)
    local track = channel.lane[slot]
    local length = track:length()
    local floor = event.layer.low_thresh
    local ceiling = event.layer.high_thresh
    local threshold = track:get_vel_step_threshold(floor, ceiling)
    for i=1,length do
        local calc_thresh = (i*threshold) + floor
        calc_thresh = i==length and ceiling or calc_thresh
        if event.vel_in <= calc_thresh then
            local step = track:range_min() + i - 1
            local cc = channel.lane[slot].cc_number
            local val = track:data(step)
            for j=1,#device_manager.output_devices do
                device_manager.output_devices[j].midi:cc(cc, val, channel.channel)
            end
            log_cc_update(cc, val, channel.channel)
            cc_context:set_vel_step_visuals(channel_num, slot, step)
            break
        end
    end
end

function harvest_cc(channel, slot)
    update_midi_cc(channel, slot)
    channel.lane[slot]:adv_lane_position()
    -- if cc_context.focus == slot then
    --     cc_context.focus_x = position
    -- end
end

function update_midi_cc(channel, slot)
    local position = channel.lane[slot].strum_active==1 and channel.lane[slot].strum_position or channel.lane[slot].position
    local cc = channel.lane[slot].cc_number
    local val = channel.lane[slot]:data(position)
    for j=1,#device_manager.output_devices do
        device_manager.output_devices[j].midi:cc(cc, val, channel.channel)
    end
    log_cc_update(cc, val, channel.channel)
end

function harvest_fixed(event)
    local channels = event.channels
    for i=1,#channels do
        if event.layer.prev_note[channels[i]] > 0 then
            for j=1,#device_manager.output_devices do
                device_manager.output_devices[j].midi:note_off(event.layer.prev_note[channels[i]], 0, channels[i])
            end
        end
        local duration = event.layer:get_hold_time()
        local note = event.layer.fixed_notes[event.layer.position]
        play_midi_fixed(note, event.vel_out, channels[i], duration) -- note number, velocity, channel, duration
        if duration == 0 or event.layer.monophonic==1 then
            event.layer.prev_note[channels[i]] = note
        end
    end
end

function play_midi_fixed(note, vel, chan, duration)
    if duration == nil then duration = 0.1 end
    log_midi_output(note, vel, chan)
    for j=1,#device_manager.output_devices do
        device_manager.output_devices[j].midi:note_on(note, vel, chan)
    end
    if duration > 0 then
        clock.run(
            function()
                clock.sleep(duration)
                for j=1,#device_manager.output_devices do
                    device_manager.output_devices[j].midi:note_off(note, 0, chan)
                end
            end
        )
    end
end

function play_engine(rescale, track, note)
    engine.cutoff(cutoff)
    engine.release(release)
    engine.pan(pan)
    engine.pw(pw/100)
    if rescale then
        if note <= #notes_context.piano.scale then
            engine.hz(music.note_num_to_freq(notes_context.piano.scale[note]))
        else
            print("NOTE MAPPING ERROR - note + interval out of range")
        end
    else
        engine.hz(music.note_num_to_freq(note))
    end
end

function set_focus_x(row, position)
    if notes_context.focus == row then
        notes_context.focus_x = position
    end
end

function advance_lane_position(track,n)
    local pos = track:adv_lane_position()
    set_focus_x(n, pos)
end

function process_external_piano(d)
    local note = notes_context.piano:match_note_to_scale(util.clamp(d.note, 0, 127))
    if notes_context.piano.live_record_mode then
        live_record(note)
    end
    --print(note)
    build_play_output(note)
    grid_dirty = true
    screen_dirty = true
end

function midi_event_note_on(d, device_num)
    if notes_context.piano:is_external(d.ch, device_num) then
        process_external_piano(d)
    else
        process_midi_event(d)
    end
end

function midi_event_note_off(d) end

function midi_event_start(d) end

function midi_event_stop(d)
    reset_all()
end

function reset_all()
    machine_context.pattern_lane:reset_position()
    machine_context.scene_lane:reset_position()
    reset_most()
end

function reset_most()
    for i=1,16  do
        notes_context.lane[i]:reset_position()
        notes_context.lane[i].pattern_lane:reset_position()
        for j=1,5 do
            machine_context.input[i].machine[j].position = machine_context.input[i].machine[j].range.min
            machine_context.input[i].machine[j].meta_seq_one_shots = {1,1,1,1,1,1,1,1}
            machine_context.input[i].machine[j].hold_flag = 0
            machine_context.input[i].machine[j].release_flag = 0
            machine_context.input[i].trig[j].position = machine_context.input[i].machine[j].range.min
            machine_context.input[i].trig[j].meta_process_position = 0
            -- for some reason reset_position() was not working for cc lanes, it was causing the position to be nil instead of 1
            --cc_context.channel[i].lane[j].position = cc_context.channel[i].lane[j]:reset_position()
            cc_context.channel[i].lane[j].position = cc_context.channel[i].lane[j]:range_min()
            cc_context.channel[i].lane[j].strum_position = cc_context.channel[i].lane[j]:range_min()
        end
        for j=6,16 do
            --cc_context.channel[i].lane[j].position = cc_context.channel[i].lane[j]:reset_position()
            cc_context.channel[i].lane[j].position = cc_context.channel[i].lane[j]:range_min()
            cc_context.channel[i].lane[j].strum_position = cc_context.channel[i].lane[j]:range_min()
        end
    end
    grid_dirty = true
    screen_dirty = true
end

function midi_event_cc(d) end

function process_midi_event(d)
    dev_map(d)
    log_midi_input(d)
    if machine_context.midi_learn and lock_midi_learn == 0 and not machine_context.midi_learn_vel_high and not machine_context.midi_learn_vel_low then
        local input = machine_context.selected_input
        io[input]:set_note(util.clamp(d.note, 0, 127))
        io[input]:set_channel(util.clamp(d.ch, 1, 16))
        screen_dirty = true
    elseif trig_context.midi_learn and lock_midi_learn == 0 and not trig_context.midi_learn_vel_high and not trig_context.midi_learn_vel_low then
        local input = trig_context.selected_input
        io[input]:set_note(util.clamp(d.note, 0, 127))
        io[input]:set_channel(util.clamp(d.ch, 1, 16))
        screen_dirty = true
    else
        machine_context:set_incoming(d)
        trig_context:set_incoming(d)
        if process_all_trigs_first==1 then
            map_midi_event_to_trigger_event_trigs_first(d)
        else
            map_midi_event_to_trigger_event(d)
        end
        grid_dirty = true
        screen_dirty = true
    end
end

function check_vel_learn(d, num)
    if current_context.name==play_context.name or
       current_context.name==machine_context.name or
       current_context.name==trig_context.name then
            return current_context:check_velocity_learn(io,d,num)
    else
        return false
    end
end

function map_midi_event_to_trigger_event(d)
    local machine_events = {}
    local trig_events = {}
    for i=1,#io do
        if d.note == io[i].note and
            d.ch == io[i].channel and
            io[i]:ready()
        then
            machine_context:set_input_visual_event(i)
            trig_context:set_input_visual_event(i)
            io[i]:reset()
            local learn = check_vel_learn(d, i)
            if learn then return end
            for j=5,1,-1 do
                local event = trigger_event.new(d.vel)
                modify_velocity(i, event)
                process_trig_layers(event, i, j, trig_events)
            end
            for j=5,1,-1 do
                local event = trigger_event.new(d.vel)
                modify_velocity(i, event)
                process_machine_layers(event, i, j, machine_events)
            end
        end
    end
    if grid_light_pulse==1 then
        if #machine_events > 0 then
            machine_context:set_layer_visual_event(machine_events)
            trig_context:set_machine_routing_layer_visual(machine_events)
        end
        if #trig_events > 0 then trig_context:set_layer_visual_event(trig_events) end
    end
end

function map_midi_event_to_trigger_event_trigs_first(d)
    local machine_events = {}
    local trig_events = {}
    for i=1,#io do
        if d.note == io[i].note and
            d.ch == io[i].channel and
            io[i]:ready()
        then
            -- do not reset the input until the machine has processed
            --io[i]:reset()
            trig_context:set_input_visual_event(i)
            local learn = check_vel_learn(d, i)
            if learn then return end
            for j=5,1,-1 do
                local event = trigger_event.new(d.vel)
                modify_velocity(i, event)
                process_trig_layers(event, i, j, trig_events)
            end
        end
    end
    if grid_light_pulse==1 then
        if #trig_events > 0 then trig_context:set_layer_visual_event(trig_events) end
    end
    for i=1,#io do
        if d.note == io[i].note and
            d.ch == io[i].channel and
            io[i]:ready()
        then
            machine_context:set_input_visual_event(i)
            io[i]:reset()
            for j=5,1,-1 do
                local event = trigger_event.new(d.vel)
                modify_velocity(i, event)
                process_machine_layers(event, i, j, machine_events)
            end
        end
    end
    if grid_light_pulse==1 then
        if #machine_events > 0 then
            machine_context:set_layer_visual_event(machine_events)
            trig_context:set_machine_routing_layer_visual(machine_events)
        end
    end
end

function process_machine_layers(event, i, j, machine_events)
    event:set_machine_layer(i,j,io)
    event:set_velocity(i,j,io)
    if check_velocity_window(event.layer, event.vel_in, machine_context.scene_lane.position, event.proxy_ignore_mutes) then
        for k=1,total_tracks do
            if io[i].machine[j].lane_send[k] == 1 then
                event.channels = machine_context.layer_routing[j].output_list[k]
                if #event.channels >= 0 then
                    event.lane = k
                    local machine = event.layer.type
                    if event.layer.gears_block == 1 and event.layer.gears_retrig == 0 then return end
                    MACHINES[machine]:process(event)
                    table.insert(machine_events, {input_num = event.input_num, layer_num = event.layer_num, lane = event.lane})
                end
            end
        end
    end
end

function process_trig_layers(event, i, j, trig_events)
    event:set_trig_layer(i,j,io)
    if check_velocity_window(event.layer, event.vel_in, trig_context.scene_lane.position, event.proxy_ignore_mutes) then
        local skip = false
        local tracks = 16
        if (trig_context:IsAutoTrig(io[i].trig[j]) or
            not trig_context:UpperGrid(io[i].trig[j]) or
            trig_context:handle_tracks_internal(io[i].trig[j])) then
                skip = true
                tracks = 1
        end
        for k=1,tracks do
            if (io[i].trig[j].lane_send[k] == 1 or skip) then
                event.lane = k
                local trig = event.layer.type
                if event.layer.gears_block == 1 then return end
                TRIGS[trig]:process(event)
                if trig ~= 'EMPTY' then table.insert(trig_events, {input_num = event.input_num, layer_num = event.layer_num, lane = event.lane}) end
            end
        end
    end
end

function modify_velocity(i_num, event)
    --local vel_multiplier = io[i_num]:get_vel_multiplier()
    local old = event.vel_in
    --event.vel_in = util.clamp(math.floor((event.vel_in * vel_multiplier)+0.5), 0.1, 127)
    local floor = io[i_num]:get_vel_floor()
    local ceiling = io[i_num]:get_vel_ceiling()
    if event.vel_in < floor then
        event.vel_in = floor
    elseif event.vel_in > ceiling then
        event.vel_in = ceiling
    end
    event.vel_in = util.clamp(math.floor(((127/(ceiling-floor))*(event.vel_in-floor))+0.5),1,127)
    log_vel_expansion(old, event.vel_in)
    machine_context:set_adusted_vel(event)
    trig_context:set_adusted_vel(event)
    --print("adjusted vel: "..event.vel_in)
end

function check_velocity_window(layer, vel, scene, proxy_ignore_mutes)
    if proxy_ignore_mutes == true then return true end
    local roll = math.random(1,100)
    --print("Dice Roll: "..roll)
    if vel >= layer.low_thresh and
       vel <= layer.high_thresh and
       roll <= layer:get_probability(scene) then
        return true
    end
    return false
end

function dev_map(d)
    if d.note >= 84 then
        d.vel = (d.note - 83) * 8
        d.note = 36
    end
end

function kill_midi_notes()
    for i=1,127 do
        for k=1,16 do
            for j=1,#device_manager.output_devices do
                device_manager.output_devices[j].midi:note_off(i, 90, k)
            end
        end
    end
    print("kill midi notes")
end

function log_midi_input(d)
    if DEBUG_IN==1 then
        print("***log_midi_input****")
        print("velocity: "..d.vel)
        print("channel: "..d.ch)
        print("note: "..d.note)
        print("type: "..d.type)
        print("********************")
    end
end

function log_vel_expansion(old, vel)
    if DEBUG_IN==1 then
        print("***log_vel_exp****")
        print("original: "..old)
        print("expanded: "..vel)
        print("********************")
    end
end

function log_midi_output(note, vel, chan)
    if DEBUG_OUT==1 then
        print("***log_midi_output****")
        print("velocity: "..vel)
        print("channel: "..chan)
        print("note: "..note.." - "..music.note_num_to_name(note, true))
        print("********************") 
    end
end

function log_cc_update(cc, val, ch)
    if DEBUG_CC==1 then
        print("***log_cc_update****")
        print("cc #: "..cc)
        print("value: "..val)
        print("channel: "..ch)
        print("********************") 
    end
end

function d(low, high)
    for i=low,high do
        print("*** column "..i.." ***")
        tab.print(machine_context.momentary[i])
    end
    print("*** extra ***")
    print("held: "..machine_context.held)
    print("heldmax: "..machine_context.heldmax)
    print("first: "..machine_context.first)
    print("second: "..machine_context.second)
end

params.action_read = function(filename,silent,number)
    for i=1,16 do
        notes_context.lane[i]:reset_position()
        notes_context.lane[i].b_section = 0
        notes_context.lane[i]:set_pattern(1)
        notes_context.lane[i].pattern_lane.b_section = 0
        machine_context.pattern_lane:reset_position()
        machine_context:update_output_channel_data()
        for j=1,5 do
            io[i].machine[j].position = io[i].machine[j].range.min
            io[i].trig[j].position = io[i].trig[j].range.min
        end
    end
    grid_redraw()
end

function r() ----------------------------- execute r() in the repl to quickly rerun this script
    norns.script.load(norns.state.script) -- https://github.com/monome/norns/blob/main/lua/core/state.lua
end

function cleanup() --------------- cleanup() is automatically called on script close
    metro.free_all() -- free all script level metros
    clock.cancel(grid_redraw_clock_id) -- melt our clock vie the id we noted
    clock.cancel(transport_clock_id)
    for i =1,16 do
        clock.cancel(notes_context.lane[i].strum_clock_id)
        clock.cancel(io[i].trigger_reset_id)
    end
    for channel, t in ipairs(NOTE_TIMER_IDS) do
        for note, value in ipairs(t) do
            clock.cancel(value)
        end
    end
end
