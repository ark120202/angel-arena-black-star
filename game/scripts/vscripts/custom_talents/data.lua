CUSTOM_TALENTS_DATA = {
	talent_experience_pct = {
		icon = "experience",
		cost = 4,
		group = 1,
		max_level = 7,
		special_values = {
			experience_pct = {10, 15, 20, 25, 30, 35, 40}
		},
		effect = {
			unit_keys = {
				bonus_experience_percentage = "experience_pct",
			}
		}
	},
	talent_bonus_creep_gold = {
		icon = "gold",
		cost = 4,
		group = 1,
		max_level = 7,
		special_values = {
			gold_for_creep = {8, 18, 30, 60, 70, 90, 120}
		},
		effect = {
			modifiers = {
				modifier_talent_creep_gold = "gold_for_creep",
			},
		}
	},
	talent_spell_amplify = {
		icon = "spell_amplify",
		cost = 7,
		group = 4,
		max_level = 7,
		special_values = {
			spell_amplify = {15, 25, 35, 45, 55, 65, 75}
		},
		effect = {
			use_modifier_applier = true,
			modifiers = {
				modifier_talent_spell_amplify = "spell_amplify",
			},
		}
	},
	talent_respawn_time_reduction = {
		icon = "respawn_time_reduction",
		cost = 7,
		group = 5,
		max_level = 7,
		special_values = {
			respawn_time_reduction = { -10, -15, -20, -25, -30, -35, -40}
		},
		effect = {
			unit_keys = {
				respawn_time_reduction = "respawn_time_reduction",
			}
		}
	},
	talent_attack_damage = {
		icon = "damage",
		cost = 5,
		group = 4,
		max_level = 7,
		special_values = {
			damage = {200, 400, 600, 800, 1000, 1200, 1400}
		},
		effect = {
			modifiers = {
				modifier_talent_damage = "damage",
			},
		}
	},
	talent_evasion = {
		icon = "evasion",
		cost = 4,
		group = 3,
		max_level = 7,
		special_values = {
			evasion = {5, 10, 15, 20, 25, 30, 35}
		},
		effect = {
			modifiers = {
				modifier_talent_evasion = "evasion",
			},
		}
	},
	talent_movespeed_limit = {
		icon = "movespeed",
		cost = 27,
		group = 6,
		max_level = 3,
		special_values = {
			movespeed_limit = {600, 650, 700}
		},
		effect = {
			modifiers = {
				modifier_talent_movespeed_limit = "movespeed_limit",
			},
		}
	},
	talent_health = {
		icon = "health",
		cost = 2,
		group = 1,
		max_level = 12,
		special_values = {
			health = {150, 300, 500, 800, 900, 1100, 1300, 1500, 1800, 2100, 2300, 2500}
		},
		effect = {
			calculate_stat_bonus = true,
			modifiers = {
				modifier_talent_health = "health",
			},
		}
	},
	talent_health_regen = {
		icon = "health_regen",
		cost = 2,
		group = 2,
		max_level = 6,
		special_values = {
			health_regen = {8, 12, 18, 25, 32, 38}
		},
		effect = {
			modifiers = {
				modifier_talent_health_regen = "health_regen",
			},
		}
	},
	talent_armor = {
		icon = "armor",
		cost = 2,
		group = 2,
		max_level = 16,
		special_values = {
			armor = {2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32}
		},
		effect = {
			modifiers = {
				modifier_talent_armor = "armor",
			},
		}
	},
	talent_magic_resistance_pct = {
		icon = "magic_resistance",
		cost = 2,
		group = 1,
		max_level = 14,
		special_values = {
			magic_resistance_pct = {6, 9, 12, 15, 18, 21, 24, 27, 30, 33, 36, 39, 42, 45}
		},
		effect = {
			modifiers = {
				modifier_talent_magic_resistance_pct = "magic_resistance_pct",
			},
		}
	},
	talent_vision_day = {
		icon = "day",
		cost = 6,
		group = 2,
		max_level = 6,
		special_values = {
			vision_day = {100, 200, 300, 400, 500, 600}
		},
		effect = {
			modifiers = {
				modifier_talent_vision_day = "vision_day",
			},
		}
	},
	talent_vision_night = {
		icon = "night",
		cost = 6,
		group = 2,
		max_level = 9,
		special_values = {
			vision_night = {100, 200, 300, 400, 500, 600, 700, 800, 900}
		},
		effect = {
			modifiers = {
				modifier_talent_vision_night = "vision_night",
			},
		}
	},
	talent_cooldown_reduction_pct = {
		icon = "cooldown_reduction",
		cost = 8,
		group = 3,
		max_level = 11,
		special_values = {
			cooldown_reduction_pct = {4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24}
		},
		effect = {
			modifiers = {
				modifier_talent_cooldown_reduction_pct = "cooldown_reduction_pct",
			},
		}
	},
	talent_passive_gold_income = {
		icon = "gold",
		cost = 10,
		group = 5,
		max_level = 6,
		special_values = {
			gold_per_minute = {120, 240, 360, 480, 600, 720}
		},
		effect = {
			unit_keys = {
				bonus_gold_per_minute = "gold_per_minute",
			}
		}
	},
	talent_movespeed_pct = {
		icon = "movespeed",
		cost = 2,
		group = 3,
		max_level = 11,
		special_values = {
			movespeed_pct = {6, 9, 12, 15, 18, 21, 24, 27, 30, 33, 36}
		},
		effect = {
			modifiers = {
				modifier_talent_movespeed_pct = "movespeed_pct",
			},
		}
	},
	talent_passive_experience_income = {
		icon = "experience",
		cost = 10,
		group = 5,
		max_level = 6,
		special_values = {
			xp_per_minute = {200, 500, 800, 1100, 1400, 1700}
		},
		effect = {
			unit_keys = {
				bonus_xp_per_minute = "xp_per_minute",
			}
		}
	},
	talent_true_strike = {
		icon = "true_strike",
		cost = 40,
		group = 7,
		effect = {
			modifiers = {
				"modifier_talent_true_strike"
			},
		}
	},

	--Unique
	talent_hero_pudge_hook_splitter = {
		icon = "hero_pudge_hook_splitter",
		cost = 48,
		group = 5,
		requirement = "pudge_meat_hook_lua",
		special_values = {
			hook_amount = 10
		}
	},
	talent_hero_arthas_vsolyanova_bunus_chance = {
		icon = "hero_arthas_vsolyanova_bunus_chance",
		cost = 25,
		group = 5,
		max_level = 5,
		requirement = "arthas_vsolyanova",
		special_values = {
			chance_multiplier = {1.1, 1.2, 1.3, 1.4, 1.5}
		}
	},
	talent_hero_arc_warden_double_spark = {
		icon = "hero_arc_warden_double_spark",
		cost = 16,
		group = 5,
		requirement = "arc_warden_spark_wraith",
		effect = {
			multicast_abilities = {
				arc_warden_spark_wraith = 2
			}
		}
	},
	talent_hero_apocalypse_apocalypse_no_death = {
		icon = "hero_apocalypse_apocalypse_no_death",
		cost = 20,
		group = 6,
		requirement = "apocalypse_apocalypse",
	},
	talent_hero_skeleton_king_reincarnation_notime_stun = {
		icon = "hero_skeleton_king_reincarnation_notime_stun",
		cost = 32,
		group = 6,
		requirement = "skeleton_king_reincarnation_arena",
	},
}

TALENT_GROUP_TO_LEVEL = {
	[1] = 5,
	[2] = 10,
	[3] = 15,
	[4] = 20,
	[5] = 30,
	[6] = 50,
	[7] = 70,
	[8] = 90,
	[9] = 120,
	[10] = 140,
	[11] = 160,
	[13] = 180,
	[14] = 200,
	[15] = 220,
	[17] = 240,
	[18] = 260,
	[19] = 280,
	[20] = 300,
	[21] = 320,
	[22] = 340,
	[23] = 360,
	[24] = 380,
	[25] = 400,
	[26] = 430,
	[27] = 460,
	[28] = 490,
	[29] = 550,
}