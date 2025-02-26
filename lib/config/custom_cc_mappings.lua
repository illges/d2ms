---@diagnostic disable: undefined-global, lowercase-global

local config = {}
-- custom cc configurations support.
-- Copy custom config table and change the name. See custom1/custom2 below.

-- choose option and channel number in norns params then load cc config

-- tables for custome configs
config["Gadget"] = {
-- cc slots
        { active = false, velocity = false, cc_number = 1},
        { active = false, velocity = false, cc_number = 2},
        { active = false, velocity = false, cc_number = 3},
        { active = false, velocity = false, cc_number = 4},
        { active = false, velocity = false, cc_number = 5},
        { active = false, velocity = false, cc_number = 6},
        { active = false, velocity = false, cc_number = 7},
        { active = false, velocity = false, cc_number = 8},
        { active = false, velocity = false, cc_number = 9},
        { active = false, velocity = false, cc_number = 10},
        { active = false, velocity = false, cc_number = 11},
        { active = false, velocity = false, cc_number = 12},
        { active = false, velocity = false, cc_number = 13},
        { active = false, velocity = false, cc_number = 14},
        { active = false, velocity = false, cc_number = 15},
        { active = false, velocity = false, cc_number = 16}
    }
config["OP-Z"] = {
    -- cc slots
        { active = false, velocity = false, cc_number = 1},
        { active = false, velocity = false, cc_number = 2},
        { active = false, velocity = false, cc_number = 3},
        { active = false, velocity = false, cc_number = 4},
        { active = false, velocity = false, cc_number = 5},
        { active = false, velocity = false, cc_number = 6},
        { active = false, velocity = false, cc_number = 7},
        { active = false, velocity = false, cc_number = 8},
        { active = false, velocity = false, cc_number = 9},
        { active = false, velocity = false, cc_number = 10},
        { active = false, velocity = false, cc_number = 11},
        { active = false, velocity = false, cc_number = 12},
        { active = false, velocity = false, cc_number = 13},
        { active = false, velocity = false, cc_number = 14},
        { active = false, velocity = false, cc_number = 15},
        { active = false, velocity = false, cc_number = 16}
    }
     config["OP-Z Abso"] = {
      -- cc slots
        { active = false, velocity = false, cc_number = 03},
        { active = false, velocity = false, cc_number = 04},
        { active = false, velocity = false, cc_number = 18},
        { active = false, velocity = false, cc_number = 17},
        { active = false, velocity = false, cc_number = 05},
        { active = false, velocity = false, cc_number = 06},
        { active = false, velocity = false, cc_number = 07},
        { active = false, velocity = false, cc_number = 08},
        { active = false, velocity = false, cc_number = 01},
        { active = false, velocity = false, cc_number = 02},
        { active = false, velocity = false, cc_number = 09},
        { active = false, velocity = false, cc_number = 10},
        { active = false, velocity = false, cc_number = 13},
        { active = false, velocity = false, cc_number = 14},
        { active = false, velocity = false, cc_number = 11},
        { active = false, velocity = false, cc_number = 12}
    }
    config["MiniLogue XD"] = {
    -- cc slots
        { active = false, velocity = false, cc_number = 43},
        { active = false, velocity = false, cc_number = 44},
        { active = false, velocity = false, cc_number = 33},
        { active = false, velocity = false, cc_number = 05},
        { active = false, velocity = false, cc_number = 16},
        { active = false, velocity = false, cc_number = 17},
        { active = false, velocity = false, cc_number = 18},
        { active = false, velocity = false, cc_number = 19},
        { active = false, velocity = false, cc_number = 36},
        { active = false, velocity = false, cc_number = 37},
        { active = false, velocity = false, cc_number = 33},
        { active = false, velocity = false, cc_number = 24},
        { active = false, velocity = false, cc_number = 107},
        { active = false, velocity = false, cc_number = 110},
        { active = false, velocity = false, cc_number = 28},
        { active = false, velocity = false, cc_number = 29}
    }
     config["Microkorg"] = {
     -- cc slots
        { active = false, velocity = false, cc_number = 74},
        { active = false, velocity = false, cc_number = 71},
        { active = false, velocity = false, cc_number = 22},
        { active = false, velocity = false, cc_number = 05},
        { active = false, velocity = false, cc_number = 73},
        { active = false, velocity = false, cc_number = 75},
        { active = false, velocity = false, cc_number = 70},
        { active = false, velocity = false, cc_number = 72},
        { active = false, velocity = false, cc_number = 77},
        { active = false, velocity = false, cc_number = 27},
        { active = false, velocity = false, cc_number = 14},
        { active = false, velocity = false, cc_number = 15},
        { active = false, velocity = false, cc_number = 13},
        { active = false, velocity = false, cc_number = 94},
        { active = false, velocity = false, cc_number = 92},
        { active = false, velocity = false, cc_number = 19}
    }
             config["Microkorg XL"] = {
     -- cc slots
        { active = false, velocity = false, cc_number = 74},
        { active = false, velocity = false, cc_number = 71},
        { active = false, velocity = false, cc_number = 25},
        { active = false, velocity = false, cc_number = 05},
        { active = false, velocity = false, cc_number = 73},
        { active = false, velocity = false, cc_number = 75},
        { active = false, velocity = false, cc_number = 70},
        { active = false, velocity = false, cc_number = 72},
        { active = false, velocity = false, cc_number = 08},
        { active = false, velocity = false, cc_number = 15},
        { active = false, velocity = false, cc_number = 17},
        { active = false, velocity = false, cc_number = 21},
        { active = false, velocity = false, cc_number = 115},
        { active = false, velocity = false, cc_number = 12},
        { active = false, velocity = false, cc_number = 116},
        { active = false, velocity = false, cc_number = 13}
    }
     config["Microstation"] = {
      -- cc slots
        { active = false, velocity = false, cc_number = 74},
        { active = false, velocity = false, cc_number = 71},
        { active = false, velocity = false, cc_number = 07},
        { active = false, velocity = false, cc_number = 05},
        { active = false, velocity = false, cc_number = 73},
        { active = false, velocity = false, cc_number = 75},
        { active = false, velocity = false, cc_number = 70},
        { active = false, velocity = false, cc_number = 72},
        { active = false, velocity = false, cc_number = 76},
        { active = false, velocity = false, cc_number = 77},
        { active = false, velocity = false, cc_number = 78},
        { active = false, velocity = false, cc_number = 79},
        { active = false, velocity = false, cc_number = 12},
        { active = false, velocity = false, cc_number = 91},
        { active = false, velocity = false, cc_number = 13},
        { active = false, velocity = false, cc_number = 93}
    }
    config["ESX"] = {
     -- cc slots
        { active = false, velocity = false, cc_number = 74},
        { active = false, velocity = false, cc_number = 71},
        { active = false, velocity = false, cc_number = 79},
        { active = false, velocity = false, cc_number = 05},
        { active = false, velocity = false, cc_number = 18},
        { active = false, velocity = false, cc_number = 75},
        { active = false, velocity = false, cc_number = 19},
        { active = false, velocity = false, cc_number = 85},
        { active = false, velocity = false, cc_number = 90},
        { active = false, velocity = false, cc_number = 89},
        { active = false, velocity = false, cc_number = 92},
        { active = false, velocity = false, cc_number = 93},
        { active = false, velocity = false, cc_number = 94},
        { active = false, velocity = false, cc_number = 95},
        { active = false, velocity = false, cc_number = 25},
        { active = false, velocity = false, cc_number = 26}
    }
    config["Electribe 2"] = {
     -- cc slots
        { active = false, velocity = false, cc_number = 74},
        { active = false, velocity = false, cc_number = 71},
        { active = false, velocity = false, cc_number = 7},
        { active = false, velocity = false, cc_number = 81},
        { active = false, velocity = false, cc_number = 73},
        { active = false, velocity = false, cc_number = 72},
        { active = false, velocity = false, cc_number = 82},
        { active = false, velocity = false, cc_number = 83},
        { active = false, velocity = false, cc_number = 85},
        { active = false, velocity = false, cc_number = 86},
        { active = false, velocity = false, cc_number = 80},
        { active = false, velocity = false, cc_number = 87},
        { active = false, velocity = false, cc_number = 102},
        { active = false, velocity = false, cc_number = 103},
        { active = false, velocity = false, cc_number = 104},
        { active = false, velocity = false, cc_number = 105}
    }
    config["Electribe Sample 2"] = {
     -- cc slots
        { active = false, velocity = false, cc_number = 74},
        { active = false, velocity = false, cc_number = 71},
        { active = false, velocity = false, cc_number = 7},
        { active = false, velocity = false, cc_number = 81},
        { active = false, velocity = false, cc_number = 73},
        { active = false, velocity = false, cc_number = 72},
        { active = false, velocity = false, cc_number = 82},
        { active = false, velocity = false, cc_number = 83},
        { active = false, velocity = false, cc_number = 85},
        { active = false, velocity = false, cc_number = 86},
        { active = false, velocity = false, cc_number = 80},
        { active = false, velocity = false, cc_number = 87},
        { active = false, velocity = false, cc_number = 102},
        { active = false, velocity = false, cc_number = 103},
        { active = false, velocity = false, cc_number = 104},
        { active = false, velocity = false, cc_number = 105}
    }
    config["Volca Bass"] = {
      -- cc slots
        { active = false, velocity = false, cc_number = 48},
        { active = false, velocity = false, cc_number = 49},
        { active = false, velocity = false, cc_number = 11},
        { active = false, velocity = false, cc_number = 05},
        { active = false, velocity = false, cc_number = 46},
        { active = false, velocity = false, cc_number = 47},
        { active = false, velocity = false, cc_number = 41},
        { active = false, velocity = false, cc_number = 42},
        { active = false, velocity = false, cc_number = 43},
        { active = false, velocity = false, cc_number = 44},
        { active = false, velocity = false, cc_number = 45},
        { active = false, velocity = false, cc_number = 40},
        { active = false, velocity = false, cc_number = 102},
        { active = false, velocity = false, cc_number = 103},
        { active = false, velocity = false, cc_number = 104},
        { active = false, velocity = false, cc_number = 105}
    }
    config["Volca Keys"] = {
      -- cc slots
        { active = false, velocity = false, cc_number = 44},
        { active = false, velocity = false, cc_number = 45},
        { active = false, velocity = false, cc_number = 42},
        { active = false, velocity = false, cc_number = 05},
        { active = false, velocity = false, cc_number = 49},
        { active = false, velocity = false, cc_number = 50},
        { active = false, velocity = false, cc_number = 51},
        { active = false, velocity = false, cc_number = 11},
        { active = false, velocity = false, cc_number = 46},
        { active = false, velocity = false, cc_number = 47},
        { active = false, velocity = false, cc_number = 48},
        { active = false, velocity = false, cc_number = 40},
        { active = false, velocity = false, cc_number = 52},
        { active = false, velocity = false, cc_number = 53},
        { active = false, velocity = false, cc_number = 104},
        { active = false, velocity = false, cc_number = 105}
    }
     config["Volca FM"] = {
      -- cc slots
        { active = false, velocity = false, cc_number = 48},
        { active = false, velocity = false, cc_number = 49},
        { active = false, velocity = false, cc_number = 50},
        { active = false, velocity = false, cc_number = 40},
        { active = false, velocity = false, cc_number = 42},
        { active = false, velocity = false, cc_number = 43},
        { active = false, velocity = false, cc_number = 44},
        { active = false, velocity = false, cc_number = 45},
        { active = false, velocity = false, cc_number = 46},
        { active = false, velocity = false, cc_number = 47},
        { active = false, velocity = false, cc_number = 41},
        { active = false, velocity = false, cc_number = 101},
        { active = false, velocity = false, cc_number = 102},
        { active = false, velocity = false, cc_number = 103},
        { active = false, velocity = false, cc_number = 104},
        { active = false, velocity = false, cc_number = 105}
    }
     config["Volca Kick"] = {
      -- cc slots
        { active = false, velocity = false, cc_number = 40},
        { active = false, velocity = false, cc_number = 45},
        { active = false, velocity = false, cc_number = 41},
        { active = false, velocity = false, cc_number = 49},
        { active = false, velocity = false, cc_number = 42},
        { active = false, velocity = false, cc_number = 43},
        { active = false, velocity = false, cc_number = 44},
        { active = false, velocity = false, cc_number = 45},
        { active = false, velocity = false, cc_number = 46},
        { active = false, velocity = false, cc_number = 47},
        { active = false, velocity = false, cc_number = 48},
        { active = false, velocity = false, cc_number = 101},
        { active = false, velocity = false, cc_number = 102},
        { active = false, velocity = false, cc_number = 103},
        { active = false, velocity = false, cc_number = 104},
        { active = false, velocity = false, cc_number = 105}
    }
    config["Volca Beats"] = {
      -- cc slots
        { active = false, velocity = false, cc_number = 40},
        { active = false, velocity = false, cc_number = 41},
        { active = false, velocity = false, cc_number = 42},
        { active = false, velocity = false, cc_number = 43},
        { active = false, velocity = false, cc_number = 56},
        { active = false, velocity = false, cc_number = 57},
        { active = false, velocity = false, cc_number = 58},
        { active = false, velocity = false, cc_number = 59},
        { active = false, velocity = false, cc_number = 50},
        { active = false, velocity = false, cc_number = 51},
        { active = false, velocity = false, cc_number = 52},
        { active = false, velocity = false, cc_number = 53},
        { active = false, velocity = false, cc_number = 54},
        { active = false, velocity = false, cc_number = 55},
        { active = false, velocity = false, cc_number = 44},
        { active = false, velocity = false, cc_number = 45}
    }
    config["Volca Drum SCh"] = {
      -- cc slots
        { active = false, velocity = false, cc_number = 16},
        { active = false, velocity = false, cc_number = 20},
        { active = false, velocity = false, cc_number = 25},
        { active = false, velocity = false, cc_number = 29},
        { active = false, velocity = false, cc_number = 48},
        { active = false, velocity = false, cc_number = 52},
        { active = false, velocity = false, cc_number = 57},
        { active = false, velocity = false, cc_number = 61},
        { active = false, velocity = false, cc_number = 82},
        { active = false, velocity = false, cc_number = 86},
        { active = false, velocity = false, cc_number = 96},
        { active = false, velocity = false, cc_number = 100},
        { active = false, velocity = false, cc_number = 116},
        { active = false, velocity = false, cc_number = 117},
        { active = false, velocity = false, cc_number = 118},
        { active = false, velocity = false, cc_number = 119}
    }
     config["NTS-1"] = {
      -- cc slots
        { active = false, velocity = false, cc_number = 43},
        { active = false, velocity = false, cc_number = 44},
        { active = false, velocity = false, cc_number = 44},
        { active = false, velocity = false, cc_number = 45},
        { active = false, velocity = false, cc_number = 16},
        { active = false, velocity = false, cc_number = 17},
        { active = false, velocity = false, cc_number = 18},
        { active = false, velocity = false, cc_number = 19},
        { active = false, velocity = false, cc_number = 20},
        { active = false, velocity = false, cc_number = 21},
        { active = false, velocity = false, cc_number = 28},
        { active = false, velocity = false, cc_number = 29},
        { active = false, velocity = false, cc_number = 30},
        { active = false, velocity = false, cc_number = 31},
        { active = false, velocity = false, cc_number = 34},
        { active = false, velocity = false, cc_number = 35}
    }
    config["SH01A"] = {
     -- cc slots
        { active = false, velocity = false, cc_number = 74},
        { active = false, velocity = false, cc_number = 71},
        { active = false, velocity = false, cc_number = 23},
        { active = false, velocity = false, cc_number = 05},
        { active = false, velocity = false, cc_number = 73},
        { active = false, velocity = false, cc_number = 75},
        { active = false, velocity = false, cc_number = 30},
        { active = false, velocity = false, cc_number = 72},
        { active = false, velocity = false, cc_number = 3},
        { active = false, velocity = false, cc_number = 19},
        { active = false, velocity = false, cc_number = 20},
        { active = false, velocity = false, cc_number = 21},
        { active = false, velocity = false, cc_number = 24},
        { active = false, velocity = false, cc_number = 25},
        { active = false, velocity = false, cc_number = 13},
        { active = false, velocity = false, cc_number = 15}
    }
  config["JX03"] = {
      -- cc slots
        { active = false, velocity = false, cc_number = 74},
        { active = false, velocity = false, cc_number = 71},
        { active = false, velocity = false, cc_number = 20},
        { active = false, velocity = false, cc_number = 05},
        { active = false, velocity = false, cc_number = 73},
        { active = false, velocity = false, cc_number = 75},
        { active = false, velocity = false, cc_number = 53},
        { active = false, velocity = false, cc_number = 72},
        { active = false, velocity = false, cc_number = 27},
        { active = false, velocity = false, cc_number = 30},
        { active = false, velocity = false, cc_number = 28},
        { active = false, velocity = false, cc_number = 21},
        { active = false, velocity = false, cc_number = 91},
        { active = false, velocity = false, cc_number = 25},
        { active = false, velocity = false, cc_number = 31},
        { active = false, velocity = false, cc_number = 82}
    }
     config["JP08"] = {
      -- cc slots
        { active = false, velocity = false, cc_number = 74},
        { active = false, velocity = false, cc_number = 71},
        { active = false, velocity = false, cc_number = 26},
        { active = false, velocity = false, cc_number = 05},
        { active = false, velocity = false, cc_number = 73},
        { active = false, velocity = false, cc_number = 75},
        { active = false, velocity = false, cc_number = 56},
        { active = false, velocity = false, cc_number = 72},
        { active = false, velocity = false, cc_number = 47},
        { active = false, velocity = false, cc_number = 52},
        { active = false, velocity = false, cc_number = 53},
        { active = false, velocity = false, cc_number = 5},
        { active = false, velocity = false, cc_number = 91},
        { active = false, velocity = false, cc_number = 16},
        { active = false, velocity = false, cc_number = 3},
        { active = false, velocity = false, cc_number = 9}
    }
    config["TR-8"] = {
      -- cc slots
        { active = false, velocity = false, cc_number = 23},
        { active = false, velocity = false, cc_number = 22},
        { active = false, velocity = false, cc_number = 26},
        { active = false, velocity = false, cc_number = 28},
        { active = false, velocity = false, cc_number = 47},
        { active = false, velocity = false, cc_number = 50},
        { active = false, velocity = false, cc_number = 53},
        { active = false, velocity = false, cc_number = 56},
        { active = false, velocity = false, cc_number = 62},
        { active = false, velocity = false, cc_number = 81},
        { active = false, velocity = false, cc_number = 56},
        { active = false, velocity = false, cc_number = 84},
        { active = false, velocity = false, cc_number = 17},
        { active = false, velocity = false, cc_number = 18},
        { active = false, velocity = false, cc_number = 89},
        { active = false, velocity = false, cc_number = 91}
    }
config["Pro VS Mini"] = {
      -- cc slots
        { active = false, velocity = false, cc_number = 74},
        { active = false, velocity = false, cc_number = 71},
        { active = false, velocity = false, cc_number = 47},
        { active = false, velocity = false, cc_number = 1},
        { active = false, velocity = false, cc_number = 81},
        { active = false, velocity = false, cc_number = 82},
        { active = false, velocity = false, cc_number = 83},
        { active = false, velocity = false, cc_number = 84},
        { active = false, velocity = false, cc_number = 24},
        { active = false, velocity = false, cc_number = 25},
        { active = false, velocity = false, cc_number = 26},
        { active = false, velocity = false, cc_number = 27},
        { active = false, velocity = false, cc_number = 70},
        { active = false, velocity = false, cc_number = 72},
        { active = false, velocity = false, cc_number = 28},
        { active = false, velocity = false, cc_number = 73}
    }
    config["Pro 800"] = {
      -- cc slots
        { active = false, velocity = false, cc_number = 15},
        { active = false, velocity = false, cc_number = 16},
        { active = false, velocity = false, cc_number = 37},
        { active = false, velocity = false, cc_number = 30},
        { active = false, velocity = false, cc_number = 25},
        { active = false, velocity = false, cc_number = 24},
        { active = false, velocity = false, cc_number = 23},
        { active = false, velocity = false, cc_number = 22},
        { active = false, velocity = false, cc_number = 26},
        { active = false, velocity = false, cc_number = 27},
        { active = false, velocity = false, cc_number = 28},
        { active = false, velocity = false, cc_number = 29},
        { active = false, velocity = false, cc_number = 9},
        { active = false, velocity = false, cc_number = 10},
        { active = false, velocity = false, cc_number = 12},
        { active = false, velocity = false, cc_number = 13}
    }
    config["MicroFreak"] = {
     -- cc slots
        { active = false, velocity = false, cc_number = 23},
        { active = false, velocity = false, cc_number = 83},
        { active = false, velocity = false, cc_number = 94},
        { active = false, velocity = false, cc_number = 05},
        { active = false, velocity = false, cc_number = 105},
        { active = false, velocity = false, cc_number = 106},
        { active = false, velocity = false, cc_number = 29},
        { active = false, velocity = false, cc_number = 26},
        { active = false, velocity = false, cc_number = 102},
        { active = false, velocity = false, cc_number = 103},
        { active = false, velocity = false, cc_number = 28},
        { active = false, velocity = false, cc_number = 24},
        { active = false, velocity = false, cc_number = 09},
        { active = false, velocity = false, cc_number = 10},
        { active = false, velocity = false, cc_number = 12},
        { active = false, velocity = false, cc_number = 13}
    }
     config["Model Cycles"] = {
     -- cc slots
        { active = false, velocity = false, cc_number = 16},
        { active = false, velocity = false, cc_number = 17},
        { active = false, velocity = false, cc_number = 18},
        { active = false, velocity = false, cc_number = 19},
        { active = false, velocity = false, cc_number = 80},
        { active = false, velocity = false, cc_number = 65},
        { active = false, velocity = false, cc_number = 12},
        { active = false, velocity = false, cc_number = 13},
        { active = false, velocity = false, cc_number = 102},
        { active = false, velocity = false, cc_number = 103},
        { active = false, velocity = false, cc_number = 104},
        { active = false, velocity = false, cc_number = 109},
        { active = false, velocity = false, cc_number = 85},
        { active = false, velocity = false, cc_number = 86},
        { active = false, velocity = false, cc_number = 87},
        { active = false, velocity = false, cc_number = 88}
    }
     config["Octatrack"] = {
      -- cc slots
        { active = false, velocity = false, cc_number = 35},
        { active = false, velocity = false, cc_number = 36},
        { active = false, velocity = false, cc_number = 37},
        { active = false, velocity = false, cc_number = 39},
        { active = false, velocity = false, cc_number = 22},
        { active = false, velocity = false, cc_number = 23},
        { active = false, velocity = false, cc_number = 24},
        { active = false, velocity = false, cc_number = 26},
        { active = false, velocity = false, cc_number = 18},
        { active = false, velocity = false, cc_number = 19},
        { active = false, velocity = false, cc_number = 20},
        { active = false, velocity = false, cc_number = 21},
        { active = false, velocity = false, cc_number = 34},
        { active = false, velocity = false, cc_number = 35},
        { active = false, velocity = false, cc_number = 40},
        { active = false, velocity = false, cc_number = 41}
    }
    config["Digitakt"] = {
      -- cc slots
        { active = false, velocity = false, cc_number = 74},
        { active = false, velocity = false, cc_number = 75},
        { active = false, velocity = false, cc_number = 71},
        { active = false, velocity = false, cc_number = 77},
        { active = false, velocity = false, cc_number = 78},
        { active = false, velocity = false, cc_number = 79},
        { active = false, velocity = false, cc_number = 80},
        { active = false, velocity = false, cc_number = 81},
        { active = false, velocity = false, cc_number = 21},
        { active = false, velocity = false, cc_number = 22},
        { active = false, velocity = false, cc_number = 18},
        { active = false, velocity = false, cc_number = 102},
        { active = false, velocity = false, cc_number = 85},
        { active = false, velocity = false, cc_number = 92},
        { active = false, velocity = false, cc_number = 25},
        { active = false, velocity = false, cc_number = 31}
    }    
    config["Mininova"] = {
      -- cc slots
        { active = false, velocity = false, cc_number = 74},
        { active = false, velocity = false, cc_number = 71},
        { active = false, velocity = false, cc_number = 56},
        { active = false, velocity = false, cc_number = 05},
        { active = false, velocity = false, cc_number = 73},
        { active = false, velocity = false, cc_number = 75},
        { active = false, velocity = false, cc_number = 70},
        { active = false, velocity = false, cc_number = 72},
        { active = false, velocity = false, cc_number = 16},
        { active = false, velocity = false, cc_number = 20},
        { active = false, velocity = false, cc_number = 80},
        { active = false, velocity = false, cc_number = 117},
        { active = false, velocity = false, cc_number = 91},
        { active = false, velocity = false, cc_number = 92},
        { active = false, velocity = false, cc_number = 93},
        { active = false, velocity = false, cc_number = 94}
    }
       config["Circuit Synth"] = {
      -- cc slots
        { active = false, velocity = false, cc_number = 74},
        { active = false, velocity = false, cc_number = 71},
        { active = false, velocity = false, cc_number = 56},
        { active = false, velocity = false, cc_number = 05},
        { active = false, velocity = false, cc_number = 73},
        { active = false, velocity = false, cc_number = 75},
        { active = false, velocity = false, cc_number = 70},
        { active = false, velocity = false, cc_number = 72},
        { active = false, velocity = false, cc_number = 25},
        { active = false, velocity = false, cc_number = 20},
        { active = false, velocity = false, cc_number = 54},
        { active = false, velocity = false, cc_number = 63},
        { active = false, velocity = false, cc_number = 93},
        { active = false, velocity = false, cc_number = 91},
        { active = false, velocity = false, cc_number = 51},
        { active = false, velocity = false, cc_number = 52}
    }
      config["Circuit Macro"] = {
      -- cc slots
        { active = false, velocity = false, cc_number = 80},
        { active = false, velocity = false, cc_number = 81},
        { active = false, velocity = false, cc_number = 82},
        { active = false, velocity = false, cc_number = 83},
        { active = false, velocity = false, cc_number = 84},
        { active = false, velocity = false, cc_number = 85},
        { active = false, velocity = false, cc_number = 86},
        { active = false, velocity = false, cc_number = 87},
        { active = false, velocity = false, cc_number = 09},
        { active = false, velocity = false, cc_number = 10},
        { active = false, velocity = false, cc_number = 11},
        { active = false, velocity = false, cc_number = 12},
        { active = false, velocity = false, cc_number = 13},
        { active = false, velocity = false, cc_number = 14},
        { active = false, velocity = false, cc_number = 15},
        { active = false, velocity = false, cc_number = 16}
    } 
    config["Blofeld"] = {
      -- cc slots
        { active = false, velocity = false, cc_number = 69},
        { active = false, velocity = false, cc_number = 70},
        { active = false, velocity = false, cc_number = 60},
        { active = false, velocity = false, cc_number = 05},
        { active = false, velocity = false, cc_number = 101},
        { active = false, velocity = false, cc_number = 102},
        { active = false, velocity = false, cc_number = 103},
        { active = false, velocity = false, cc_number = 104},
        { active = false, velocity = false, cc_number = 29},
        { active = false, velocity = false, cc_number = 30},
        { active = false, velocity = false, cc_number = 33},
        { active = false, velocity = false, cc_number = 34},
        { active = false, velocity = false, cc_number = 93},
        { active = false, velocity = false, cc_number = 94},
        { active = false, velocity = false, cc_number = 16},
        { active = false, velocity = false, cc_number = 18}
    }
        config["Gen Midi"] = {
       -- cc slots
        { active = false, velocity = false, cc_number = 74},
        { active = false, velocity = false, cc_number = 71},
        { active = false, velocity = false, cc_number = 07},
        { active = false, velocity = false, cc_number = 05},
        { active = false, velocity = false, cc_number = 73},
        { active = false, velocity = false, cc_number = 75},
        { active = false, velocity = false, cc_number = 70},
        { active = false, velocity = false, cc_number = 72},
        { active = false, velocity = false, cc_number = 01},
        { active = false, velocity = false, cc_number = 02},
        { active = false, velocity = false, cc_number = 12},
        { active = false, velocity = false, cc_number = 13},
        { active = false, velocity = false, cc_number = 91},
        { active = false, velocity = false, cc_number = 92},
        { active = false, velocity = false, cc_number = 93},
        { active = false, velocity = false, cc_number = 94}
    }
    config["Empty"] = {
      -- cc slots
        { active = false, velocity = false, cc_number = 1},
        { active = false, velocity = false, cc_number = 2},
        { active = false, velocity = false, cc_number = 3},
        { active = false, velocity = false, cc_number = 4},
        { active = false, velocity = false, cc_number = 5},
        { active = false, velocity = false, cc_number = 6},
        { active = false, velocity = false, cc_number = 7},
        { active = false, velocity = false, cc_number = 8},
        { active = false, velocity = false, cc_number = 9},
        { active = false, velocity = false, cc_number = 10},
        { active = false, velocity = false, cc_number = 11},
        { active = false, velocity = false, cc_number = 12},
        { active = false, velocity = false, cc_number = 13},
        { active = false, velocity = false, cc_number = 14},
        { active = false, velocity = false, cc_number = 15},
        { active = false, velocity = false, cc_number = 16}
    }
return config