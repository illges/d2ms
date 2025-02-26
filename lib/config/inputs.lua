---@diagnostic disable: undefined-global, lowercase-global

local config = {
    -- input 1
    {
        note = 36,
        channel = 1,
        studio_velocity_floor = 0,
        studio_velocity_ceiling = 127,
        venue_velocity_floor = 0,
        venue_velocity_ceiling = 127,
        studio_trig_mask_timer = 0.05,
        studio_velocity_multiplier = 1,
        venue_trig_mask_timer = 0.05,
        venue_velocity_multiplier = 1,
        default_velocity_out = {70,70,70,70,70},
        machine = {2,1,1,1,1},
        meta_seq_len = {8,8,8,8,8},
        fixed_step = {36,36,36,36,36},
        pass_vel = {0,0,0,0,0},
        lane_send = {
            {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, -- layer 1 : lanes 1-16
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
        }
    },
    -- input 2
    {
        note = 37,
        channel = 1,
        studio_velocity_floor = 0,
        studio_velocity_ceiling = 127,
        venue_velocity_floor = 0,
        venue_velocity_ceiling = 127,
        studio_trig_mask_timer = 0.05,
        studio_velocity_multiplier = 1,
        venue_trig_mask_timer = 0.05,
        venue_velocity_multiplier = 1,
        default_velocity_out = {70,70,70,70,70},
        machine = {2,1,1,1,1},
        meta_seq_len = {8,8,8,8,8},
        fixed_step = {36,36,36,36,36},
        pass_vel = {0,0,0,0,0},
        lane_send = {
            {0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, -- layer 1 : lanes 1-16
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
        }
    },
    -- input 3
    {
        note = 38,
        channel = 1,
        studio_velocity_floor = 0,
        studio_velocity_ceiling = 127,
        venue_velocity_floor = 0,
        venue_velocity_ceiling = 127,
        studio_trig_mask_timer = 0.05,
        studio_velocity_multiplier = 1,
        venue_trig_mask_timer = 0.05,
        venue_velocity_multiplier = 1,
        default_velocity_out = {70,70,70,70,70},
        machine = {2,1,1,1,1},
        meta_seq_len = {8,8,8,8,8},
        fixed_step = {36,36,36,36,36},
        pass_vel = {0,0,0,0,0},
        lane_send = {
            {0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0}, -- layer 1 : lanes 1-16
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
        }
    },
    -- input 4
    {
        note = 39,
        channel = 1,
        studio_velocity_floor = 0,
        studio_velocity_ceiling = 127,
        venue_velocity_floor = 0,
        venue_velocity_ceiling = 127,
        studio_trig_mask_timer = 0.05,
        studio_velocity_multiplier = 1,
        venue_trig_mask_timer = 0.05,
        venue_velocity_multiplier = 1,
        default_velocity_out = {70,70,70,70,70},
        machine = {2,1,1,1,1},
        meta_seq_len = {8,8,8,8,8},
        fixed_step = {36,36,36,36,36},
        pass_vel = {0,0,0,0,0},
        lane_send = {
            {0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0}, -- layer 1 : lanes 1-16
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
        }
    },
    -- input 5
    {
        note = 40,
        channel = 1,
        studio_velocity_floor = 0,
        studio_velocity_ceiling = 127,
        venue_velocity_floor = 0,
        venue_velocity_ceiling = 127,
        studio_trig_mask_timer = 0.05,
        studio_velocity_multiplier = 1,
        venue_trig_mask_timer = 0.05,
        venue_velocity_multiplier = 1,
        default_velocity_out = {70,70,70,70,70},
        machine = {2,1,1,1,1},
        meta_seq_len = {8,8,8,8,8},
        fixed_step = {36,36,36,36,36},
        pass_vel = {0,0,0,0,0},
        lane_send = {
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, -- layer 1 : lanes 1-16
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
        }
    },
    -- input 6
    {
        note = 41,
        channel = 1,
        studio_velocity_floor = 0,
        studio_velocity_ceiling = 127,
        venue_velocity_floor = 0,
        venue_velocity_ceiling = 127,
        studio_trig_mask_timer = 0.05,
        studio_velocity_multiplier = 1,
        venue_trig_mask_timer = 0.05,
        venue_velocity_multiplier = 1,
        default_velocity_out = {70,70,70,70,70},
        machine = {2,1,1,1,1},
        meta_seq_len = {8,8,8,8,8},
        fixed_step = {36,36,36,36,36},
        pass_vel = {0,0,0,0,0},
        lane_send = {
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, -- layer 1 : lanes 1-16
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
        }
    },
    -- input 7
    {
        note = 42,
        channel = 1,
        studio_velocity_floor = 0,
        studio_velocity_ceiling = 127,
        venue_velocity_floor = 0,
        venue_velocity_ceiling = 127,
        studio_trig_mask_timer = 0.05,
        studio_velocity_multiplier = 1,
        venue_trig_mask_timer = 0.05,
        venue_velocity_multiplier = 1,
        default_velocity_out = {70,70,70,70,70},
        machine = {2,1,1,1,1},
        meta_seq_len = {8,8,8,8,8},
        fixed_step = {36,36,36,36,36},
        pass_vel = {0,0,0,0,0},
        lane_send = {
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, -- layer 1 : lanes 1-16
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
        }
    },
    -- input 8
    {
        note = 43,
        channel = 1,
        studio_velocity_floor = 0,
        studio_velocity_ceiling = 127,
        venue_velocity_floor = 0,
        venue_velocity_ceiling = 127,
        studio_trig_mask_timer = 0.05,
        studio_velocity_multiplier = 1,
        venue_trig_mask_timer = 0.05,
        venue_velocity_multiplier = 1,
        default_velocity_out = {70,70,70,70,70},
        machine = {2,1,1,1,1},
        meta_seq_len = {8,8,8,8,8},
        fixed_step = {36,36,36,36,36},
        pass_vel = {0,0,0,0,0},
        lane_send = {
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, -- layer 1 : lanes 1-16
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
        }
    },
    -- input 9
    {
        note = 44,
        channel = 1,
        studio_velocity_floor = 0,
        studio_velocity_ceiling = 127,
        venue_velocity_floor = 0,
        venue_velocity_ceiling = 127,
        studio_trig_mask_timer = 0.05,
        studio_velocity_multiplier = 1,
        venue_trig_mask_timer = 0.05,
        venue_velocity_multiplier = 1,
        default_velocity_out = {70,70,70,70,70},
        machine = {2,1,1,1,1},
        meta_seq_len = {8,8,8,8,8},
        fixed_step = {36,36,36,36,36},
        pass_vel = {0,0,0,0,0},
        lane_send = {
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, -- layer 1 : lanes 1-16
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
        }
    },
    -- input 10
    {
        note = 45,
        channel = 1,
        studio_velocity_floor = 0,
        studio_velocity_ceiling = 127,
        venue_velocity_floor = 0,
        venue_velocity_ceiling = 127,
        studio_trig_mask_timer = 0.05,
        studio_velocity_multiplier = 1,
        venue_trig_mask_timer = 0.05,
        venue_velocity_multiplier = 1,
        default_velocity_out = {70,70,70,70,70},
        machine = {2,1,1,1,1},
        meta_seq_len = {8,8,8,8,8},
        fixed_step = {36,36,36,36,36},
        pass_vel = {0,0,0,0,0},
        lane_send = {
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, -- layer 1 : lanes 1-16
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
        }
    },
    -- input 11
    {
        note = 46,
        channel = 1,
        studio_velocity_floor = 0,
        studio_velocity_ceiling = 127,
        venue_velocity_floor = 0,
        venue_velocity_ceiling = 127,
        studio_trig_mask_timer = 0.05,
        studio_velocity_multiplier = 1,
        venue_trig_mask_timer = 0.05,
        venue_velocity_multiplier = 1,
        default_velocity_out = {70,70,70,70,70},
        machine = {2,1,1,1,1},
        meta_seq_len = {8,8,8,8,8},
        fixed_step = {36,36,36,36,36},
        pass_vel = {0,0,0,0,0},
        lane_send = {
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, -- layer 1 : lanes 1-16
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
        }
    },
    -- input 12
    {
        note = 47,
        channel = 1,
        studio_velocity_floor = 0,
        studio_velocity_ceiling = 127,
        venue_velocity_floor = 0,
        venue_velocity_ceiling = 127,
        studio_trig_mask_timer = 0.05,
        studio_velocity_multiplier = 1,
        venue_trig_mask_timer = 0.05,
        venue_velocity_multiplier = 1,
        default_velocity_out = {70,70,70,70,70},
        machine = {2,1,1,1,1},
        meta_seq_len = {8,8,8,8,8},
        fixed_step = {36,36,36,36,36},
        pass_vel = {0,0,0,0,0},
        lane_send = {
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, -- layer 1 : lanes 1-16
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
        }
    },
    -- input 13
    {
        note = 48,
        channel = 1,
        studio_velocity_floor = 0,
        studio_velocity_ceiling = 127,
        venue_velocity_floor = 0,
        venue_velocity_ceiling = 127,
        studio_trig_mask_timer = 0.05,
        studio_velocity_multiplier = 1,
        venue_trig_mask_timer = 0.05,
        venue_velocity_multiplier = 1,
        default_velocity_out = {70,70,70,70,70},
        machine = {2,1,1,1,1},
        meta_seq_len = {8,8,8,8,8},
        fixed_step = {36,36,36,36,36},
        pass_vel = {0,0,0,0,0},
        lane_send = {
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, -- layer 1 : lanes 1-16
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
        }
    },
    -- input 14
    {
        note = 49,
        channel = 1,
        studio_velocity_floor = 0,
        studio_velocity_ceiling = 127,
        venue_velocity_floor = 0,
        venue_velocity_ceiling = 127,
        studio_trig_mask_timer = 0.05,
        studio_velocity_multiplier = 1,
        venue_trig_mask_timer = 0.05,
        venue_velocity_multiplier = 1,
        default_velocity_out = {70,70,70,70,70},
        machine = {2,1,1,1,1},
        meta_seq_len = {8,8,8,8,8},
        fixed_step = {36,36,36,36,36},
        pass_vel = {0,0,0,0,0},
        lane_send = {
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, -- layer 1 : lanes 1-16
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
        }
    },
    -- input 15
    {
        note = 50,
        channel = 1,
        studio_velocity_floor = 0,
        studio_velocity_ceiling = 127,
        venue_velocity_floor = 0,
        venue_velocity_ceiling = 127,
        studio_trig_mask_timer = 0.05,
        studio_velocity_multiplier = 1,
        venue_trig_mask_timer = 0.05,
        venue_velocity_multiplier = 1,
        default_velocity_out = {70,70,70,70,70},
        machine = {2,1,1,1,1},
        meta_seq_len = {8,8,8,8,8},
        fixed_step = {36,36,36,36,36},
        pass_vel = {0,0,0,0,0},
        lane_send = {
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, -- layer 1 : lanes 1-16
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
        }
    },
    -- input 16
    {
        note = 51,
        channel = 1,
        studio_velocity_floor = 0,
        studio_velocity_ceiling = 127,
        venue_velocity_floor = 0,
        venue_velocity_ceiling = 127,
        studio_trig_mask_timer = 0.05,
        studio_velocity_multiplier = 1,
        venue_trig_mask_timer = 0.05,
        venue_velocity_multiplier = 1,
        default_velocity_out = {70,70,70,70,70},
        machine = {2,1,1,1,1},
        meta_seq_len = {8,8,8,8,8},
        fixed_step = {36,36,36,36,36},
        pass_vel = {0,0,0,0,0},
        lane_send = {
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, -- layer 1 : lanes 1-16
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
        }
    },
    -- layer 1 channels
    {
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, -- lane 1 channels
        {0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, -- lane 16 channels
    },
    -- layer 2 channels
    {
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, -- lane 1 channels
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, -- lane 16 channels
    },
    -- layer 3 channels
    {
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, -- lane 1 channels
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, -- lane 16 channels
    },
    -- layer 4 channels
    {
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, -- lane 1 channels
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, -- lane 16 channels
    },
    -- layer 5 channels
    {
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, -- lane 1 channels
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, -- lane 16 channels
    }
}

return config