---@diagnostic disable: undefined-global, lowercase-global

local pattern = include 'lib/pattern'

local note_pattern = {}
note_pattern.__index = note_pattern
setmetatable(note_pattern, pattern)

function note_pattern.new(type, lane, pattern_num)
    local self = setmetatable(pattern.new(type, lane, pattern_num), note_pattern)
    self.data =      {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    --self.interval = {-7,-6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6,7,8}
    self.interval =  {0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7}
    self.chord =     {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
    self.inversion = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    self.step_lock = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    self:add_pattern_params()
    return self
end

function note_pattern:add_pattern_params()
    params:add_group(self.type.."_lane_"..self.lane.."_pattern_num_"..self.pattern_num.."_hidden_step_params", 80)
    for j=1,16 do
        params:add{ type = "number", id= (self.type.."_lane_"..self.lane.."_pattern_num_"..self.pattern_num.."_note_"..j),
                    name = ("data "..j), min = 0, max = 127,
                    default = self.data[j],
                    action = function(x) self.data[j] = x end
        }
        params:add{ type = "number", id= (self.type.."_lane_"..self.lane.."_pattern_num_"..self.pattern_num.."_interval_"..j),
                    name = ("interval "..j), min = -28, max = 14,
                    default = self.interval[j],
                    action = function(x) self.interval[j] = x end
        }
        params:add{ type = "number", id= (self.type.."_lane_"..self.lane.."_pattern_num_"..self.pattern_num.."_chord_"..j),
                    name = ("chord "..j), min = 1, max = 26,
                    default = self.chord[j],
                    action = function(x) self.chord[j] = x end
        }
        params:add{ type = "number", id= (self.type.."_lane_"..self.lane.."_pattern_num_"..self.pattern_num.."_inversion_"..j),
                    name = ("inversion "..j), min = 0, max = 2,
                    default = self.inversion[j],
                    action = function(x) self.inversion[j] = x end
        }
        params:add{ type = "number", id= (self.type.."_lane_"..self.lane.."_pattern_num_"..self.pattern_num.."_step_lock_"..j),
                    name = ("step lock "..j), min = 0, max = 1,
                    default = self.step_lock[j],
                    action = function(x) self.step_lock[j] = x end
        }
    end
    params:hide(self.type.."_lane_"..self.lane.."_pattern_num_"..self.pattern_num.."_hidden_step_params")
end

function note_pattern:set_step_data(step, val)
    params:set(self.type.."_lane_"..self.lane.."_pattern_num_"..self.pattern_num.."_note_"..step, val)
end

function note_pattern:set_step_interval(step, val)
    params:set(self.type.."_lane_"..self.lane.."_pattern_num_"..self.pattern_num.."_interval_"..step, val)
end

function note_pattern:set_step_chord(step, val)
    params:set(self.type.."_lane_"..self.lane.."_pattern_num_"..self.pattern_num.."_chord_"..step, val)
    self:set_step_inversion(step, 0)
end

function note_pattern:set_step_inversion(step, val)
    params:set(self.type.."_lane_"..self.lane.."_pattern_num_"..self.pattern_num.."_inversion_"..step, val)
end

function note_pattern:toggle_step_lock(step)
    local val = self.step_lock[step] == 1 and 0 or 1
    params:set(self.type.."_lane_"..self.lane.."_pattern_num_"..self.pattern_num.."_step_lock_"..step, val)
end

function note_pattern:try_set_step_data(step, val)
    if self.step_lock[step] == 0 then
        self:set_step_data(step, val)
    end
end

function note_pattern:ascending(pool)
    local val
    for i=1,15 do
        val = pool[util.wrap(i, 1, #pool)]
        self:try_set_step_data(i, val)
    end
    self:try_set_step_data(16, pool[#pool]+1)
end

function note_pattern:descending(pool)
    table.sort(pool, function(a, b) return a > b end)
    self:ascending(pool)
    self:try_set_step_data(16, pool[#pool]-1)
end

function note_pattern:scatter_asc(pool)
    self:scatter(pool, function(a, b) return a < b end)
end

function note_pattern:scatter_desc(pool)
    self:scatter(pool, function(a, b) return a > b end)
end

function note_pattern:triangle_asc(pool)
    self:scatter(pool, function(a, b) return a < b end
                     , function(a, b) return a > b end)
end

function note_pattern:triangle_desc(pool)
    self:scatter(pool, function(a, b) return a > b end
                     , function(a, b) return a < b end)
end

function note_pattern:spiral(pool)
    self:try_set_step_data(1, pool[8])
    local step = 2
    for i=1,7 do
        self:try_set_step_data(step, pool[8+i])
        step = step + 1
        self:try_set_step_data(step, pool[8-i])
        step = step + 1
    end
    self:try_set_step_data(16, pool[15]+1)
end

function note_pattern:random(pool, preserve_density)
    if preserve_density == 1 then self:reshuffle_locked_steps() end
    local val
    for i=1,16 do
        val = pool[math.random(1, #pool)]
        self:try_set_step_data(i, val)
    end
end

function note_pattern:reshuffle_locked_steps()
    local temp = {}
    for i=1,16 do
        if self.step_lock[i] == 1 then
            table.insert(temp, {note=self.data[i], mute=self.step_mute[i]})
            self:toggle_step_lock(i)
        elseif self.step_mute[i] == 1 then
            table.insert(temp, {note=self.data[i], mute=self.step_mute[i]})
        end
        self:set_step_data(i, 0)
        self:set_step_mute(i, 0)
    end
    local rand = {}
    local generated_num
    local current_val
    local max_val
    local list = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}
    local max_index = #list
    for i=1,#temp do
        generated_num = math.random(1,max_index)
        max_val = list[max_index]
        current_val = list[generated_num]
        self:set_step_data(current_val, temp[i].note)
        self:set_step_mute(current_val, temp[i].mute)
        self:toggle_step_lock(current_val)
        rand[i] = current_val
        list[max_index] = current_val
        list[generated_num] = max_val
        --log_scatter_sorting(max_index, generated_num, max_val, current_val)
        max_index = max_index - 1
    end
end

function note_pattern:scatter(pool, func, funcB)
    funcB = funcB == nil and func or funcB
    for k=1,2 do
        local list = self:get_list()
        local val
        local rand = {}
        local generated_num
        local max_index
        local current_val
        local max_val
        for i=1,8 do
            max_index = #list-(i-1)
            generated_num = math.random(1,max_index)
            max_val = list[max_index]
            current_val = list[generated_num]
            rand[i] = current_val
            list[max_index] = current_val
            list[generated_num] = max_val
            --self:log_scatter_sorting(max_index, generated_num, max_val, current_val)
        end
        local temp = k == 1 and func or funcB
        table.sort(rand, temp)
        -- print("************")
        -- tab.print(rand)
        for i=1,8 do
            val = pool[rand[i]]
            self:try_set_step_data(i+(k-1)*8, val)
        end
    end
end

function note_pattern:get_list()
    local temp = {}
    for i=1,#notes_context.piano.keyboard do
        table.insert(temp, i)
    end
    return temp
end

function note_pattern:octave_down(n)
    if n then
        self:try_set_step_data(n, self.data[n] - notes_context.piano.octave_size)
    else
        for x=1,16 do
            self:try_set_step_data(x, self.data[x] - notes_context.piano.octave_size)
        end
    end
end

function note_pattern:octave_up(n)
    if n then
        self:try_set_step_data(n, self.data[n] + notes_context.piano.octave_size)
    else
        for x=1,16 do
            self:try_set_step_data(x, self.data[x] + notes_context.piano.octave_size)
        end
    end
end

function note_pattern:piano_scatter_asc(pool)
    for i=1,#pool do
        table.insert(pool, pool[i]+7)
    end
    self:ascending(pool)
end

function note_pattern:piano_scatter_desc(pool)
    for i=1,#pool do
        table.insert(pool, pool[i]+7)
    end
    table.sort(pool, function(a, b) return a > b end)
    self:ascending(pool)
end

function note_pattern:piano_triangle(pool, dir)
    local val
    local inc = table.move(pool, 1, #pool-1, 1, {})
    local dec = table.move(pool, 2, #pool, 1, {})
    table.sort(dec, function(a, b) return a > b end)
    local sel = dir == "up" and inc or dec
    for i=1,16 do
        mod = util.wrap(i, 1, #pool-1)
        val = sel[mod]
        self:try_set_step_data(i, val)
        if mod == #pool-1 then
            sel = sel == inc and dec or inc
        end
    end
end

function note_pattern:nudge_pattern(dir, min, max)
    local temp = {}
    local temp_mutes = {}
    for i=min,max do
        temp[i] = self.data[i]
        temp_mutes[i] = self.step_mute[i]
    end
    if dir==1 then
        self:set_step_data(min, temp[max])
        self:set_step_mute(min, temp_mutes[max])
        for j=min+1,max do
            self:set_step_data(j, temp[j-1])
            self:set_step_mute(j, temp_mutes[j-1])
        end
    else
        self:set_step_data(max, temp[min])
        self:set_step_mute(max, temp_mutes[min])
        for j=min,max-1 do
            self:set_step_data(j, temp[j+1])
            self:set_step_mute(j, temp_mutes[j+1])
        end
    end
end

function note_pattern:log_scatter_sorting(max_index, generated_num, max_val, current_val)
    print("************")
    print("max_index: "..max_index)
    print("generated_num: "..generated_num)
    print("max_val: "..max_val)
    print("current_val: "..current_val)
end

return note_pattern