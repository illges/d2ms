---@diagnostic disable: undefined-global, lowercase-global

local transport = {}

transport.tap_tempo_index = 1
transport.tap_tempo_table = {}
transport.tap_tempo_display = {}

tap = 0
deltatap = 1
local sum_tempo = 0
local next_val

function transport.tap_tempo()
    if transport_clock_id~=nil then
        clock.cancel(transport_clock_id)
    end
    local last = params:get("clock_tempo")
    local tap1 = util.time()
    deltatap = tap1 - tap
    tap = tap1
    local t_t = 60/deltatap
    -- if t_t >= 1 and deltatap <=3 then
    next_val = math.floor(t_t+0.5)
    transport.tap_tempo_table[transport.tap_tempo_index] = next_val
    transport.tap_tempo_display[transport.tap_tempo_index] = next_val
    transport.tap_tempo_index = transport.tap_tempo_index + 1
    -- end
    if #transport.tap_tempo_table == 4 then
        for i = 2,4 do
            sum_tempo = sum_tempo + transport.tap_tempo_table[i]
        end
        local val = util.round(sum_tempo/3,0.1)
        if round_bpm == 1 then val = math.floor(val+0.5) end
        params:set("clock_tempo",val)
        tap_tempo_set_counter = 10
        print("clock set to "..params:get("clock_tempo"))
        transport.tap_tempo_table = {}
        transport.tap_tempo_index = 1
        sum_tempo = 0
    elseif #transport.tap_tempo_table == 1 then
        transport_clock_id = clock.run(transport.check_input_time_reset_thresh)
        for i=2,4 do
            transport.tap_tempo_display[i] = nil
        end
    elseif #transport.tap_tempo_table > 1 and #transport.tap_tempo_table < 4 then
        transport_clock_id = clock.run(transport.check_input_time_reset_thresh)
    end
end

function transport.clear_tempo_table()
    transport.tap_tempo_table = {}
    transport.tap_tempo_index = 1
    sum_tempo = 0
    for i=2,4 do
        transport.tap_tempo_display[i] = nil
    end
end

function transport.check_input_time_reset_thresh()
    clock.sleep(6)
    transport.clear_tempo_table()
    redraw()
end

return transport