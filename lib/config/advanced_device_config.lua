---@diagnostic disable: undefined-global, lowercase-global

-- {"OFF", "IN", "OUT", "IN/OUT"}
local OFF = 1; local IN = 2; local OUT = 3; local INOUT = 4;

local config = {
    -- name, routing
    {"RSPDS", IN},
    {"WIDI Bud Pro", OUT},
    {"LMM2", IN},
    {"mio", OUT},
    {"LMM1", OFF},
}

return config