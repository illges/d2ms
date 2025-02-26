---@diagnostic disable: undefined-global, lowercase-global

local context = {}
context.__index = context

function context.new()
	local self = setmetatable({}, context)
    self.audition = false
    self.advance_sequence = false
    self.active_page = 1
    self.area = 4
    self.focus = 1
    self.focus_x = 1
    self.gesture = ""
    self.momentary = {}
    self.tap_tempo_pressed = false
    self:init_metas()
	return self
end

function context:get_mod_val(lane)
    return lane + (4 * (self.active_page - 1))
end

function context:init_metas()
    for x = 1,16 do -- for each x-column (16 on a 128-sized grid)...
        self.momentary[x] = {} -- create a table that holds...
        for y = 1,8 do -- each y-row (8 on a 128-sized grid)!
          self.momentary[x][y] = 0 -- the state of each key is 'off'
        end
    end
end

function context:upper_grid_pressed()
    for i=1,#self.momentary do
        for j=1,4 do
            if self.momentary[i][j] == 1 then
                return i
            end
        end
    end
    return 0
end

function context:lower_grid_pressed()
    for i=1,#self.momentary do
        for j=5,#self.momentary[i] do
            if self.momentary[i][j] == 1 then
                return true
            end
        end
    end
    return false
end

function context:get_lane(n)
    return n + (4 * (self.active_page - 1))
end

function context:draw_grid_base()
    g:led(1, 5, basic_lighting(self.audition))
    g:led(2, 5, basic_lighting(self.advance_sequence))

    g:led(13, 5, negative_lighting(self.active_page == 1))
    g:led(14, 5, negative_lighting(self.active_page == 2))
    g:led(15, 5, negative_lighting(self.active_page == 3))
    g:led(16, 5, negative_lighting(self.active_page == 4))
end

function context:gesture_indicators_base()
    self.audition = self.momentary[1][5] == 1 and true or false
    self.advance_sequence = self.momentary[2][5] == 1 and true or false
end

function context:get_current_gesture_base()
    local gesture
    if self.audition then gesture = "audition note"
    elseif self.advance_sequence then gesture = "advance sequence"
    elseif self.tap_tempo_pressed then gesture = "tap tempo"
    else gesture = "" end
    return gesture
end

function context:key_two(n,z)

end

function context:key_three(n,z)
    print("***RESET ALL SEQUENCES***")
    reset_all()
end

function context:draw_header_top_right(val)
    screen.level(0)
    screen.rect(125-screen.text_extents(val),1,screen.text_extents(val)+2,7)
    screen.fill()
    screen.level(15)
    screen.move(126, 7)
    screen.text_right(val)
end

function context:grid_patching_off(x,y,z)
    
end

return context