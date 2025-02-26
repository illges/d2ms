---@diagnostic disable: undefined-global, lowercase-global

local config = { --chords built by interval offsets
    {
        {0,2,4}, --major
        {2,4,7},
        {4,7,9},
        {-1,-3,-5},
        {-3,-5,-7}
    },
    {
        {0,2,4,5}, --major 6
        {2,4,5,7},
        {4,5,7,9},
        {5,7,9,11}
    },
    {
        {0,2,4,6}, --major 7
        {2,4,6,7},
        {4,6,7,9},
        {6,7,9,11}
    },
    {
        {0,2,4,5,8}, --major 69
        {2,4,5,8,7},
        {4,5,8,7,9},
        {5,8,7,9,11},
        {8,7,9,11,12}
    },
    {
        {0,2,4,6,8}, --major 9
        {2,4,6,8,9},
        {4,6,8,9,11},
        {6,8,9,11,13},
        {8,9,11,13,14}
    }
} --dont add more than 16 chords lol

return config