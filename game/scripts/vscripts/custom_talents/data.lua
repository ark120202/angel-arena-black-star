CUSTOM_TALENTS_DATA = {
	talent_experience_pct = {
		icon = "talents/experience",
		cost = 2,
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
		icon = "talents/gold",
		cost = 2,
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
		icon = "talents/spell_amplify",
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
		icon = "talents/respawn_time_reduction",
		cost = 7,
		group = 5,
		max_level = 7,
		special_values = {
			respawn_time_reduction = {-10, -15, -20, -25, -30, -35, -40}
		},
		effect = {
			unit_keys = {
				respawn_time_reduction = "respawn_time_reduction",
			}
		}
	},
	talent_attack_damage = {
		icon = "talents/damage",
		cost = 8,
		group = 5,
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
		icon = "talents/evasion",
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
		icon = "talents/movespeed",
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
		icon = "talents/health",
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
	talent_mana = {
		icon = "talents/mana",
		cost = 2,
		group = 1,
		max_level = 12,
		special_values = {
			mana = {150, 300, 500, 800, 900, 1100, 1300, 1500, 1800, 2100, 2300, 2500}
		},
		effect = {
			calculate_stat_bonus = true,
			modifiers = {
				modifier_talent_mana = "mana",
			},
		}
	},
	talent_health_regen = {
		icon = "talents/health_regen",
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
		icon = "talents/armor",
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
		icon = "talents/magic_resistance",
		cost = 10,
		group = 6,
		max_level = 8,
		special_values = {
			magic_resistance_pct = {8, 12, 16, 20, 24, 28, 32, 36}
		},
		effect = {
			modifiers = {
				modifier_talent_magic_resistance_pct = "magic_resistance_pct",
			},
		}
	},
	talent_vision_day = {
		icon = "talents/day",
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
		icon = "talents/night",
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
		icon = "talents/cooldown_reduction",
		cost = 10,
		group = 4,
		max_level = 7,
		special_values = {
			cooldown_reduction_pct = {6, 10, 14, 18, 22, 26, 30}
		},
		effect = {
			modifiers = {
				modifier_talent_cooldown_reduction_pct = "cooldown_reduction_pct",
			},
		}
	},
	talent_movespeed_pct = {
		icon = "talents/movespeed",
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
	talent_passive_gold_income = {
		icon = "talents/gold",
		cost = 10,
		group = 2,
		max_level = 6,
		special_values = {
			gold_per_minute = {400, 800, 1200, 1600, 2000, 2400}
		},
		effect = {
			unit_keys = {
				bonus_gold_per_minute = "gold_per_minute",
			}
		}
	},
	talent_passive_experience_income = {
		icon = "talents/experience",
		cost = 10,
		group = 2,
		max_level = 6,
		special_values = {
			xp_per_minute = {400, 700, 1200, 1600, 2000, 2400}
		},
		effect = {
			unit_keys = {
				bonus_xp_per_minute = "xp_per_minute",
			}
		}
	},
	talent_true_strike = {
		icon = "talents/true_strike",
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
		icon = "talents/heroes/pudge_hook_splitter",
		cost = 48,
		group = 5,
		requirement = "pudge_meat_hook_lua",
		special_values = {
			hook_amount = 6
		}
	},
	talent_hero_arthas_vsolyanova_bunus_chance = {
		icon = "talents/heroes/arthas_vsolyanova_bunus_chance",
		cost = 25,
		group = 5,
		max_level = 5,
		requirement = "arthas_vsolyanova",
		special_values = {
			chance_multiplier = {1.1, 1.2, 1.3, 1.4, 1.5}
		}
	},
	talent_hero_arc_warden_double_spark = {
		icon = "talents/heroes/arc_warden_double_spark",
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
		icon = "talents/heroes/apocalypse_apocalypse_no_death",
		cost = 20,
		group = 6,
		requirement = "apocalypse_apocalypse",
	},
	talent_hero_skeleton_king_reincarnation_notime_stun = {
		icon = "talents/heroes/skeleton_king_reincarnation_notime_stun",
		cost = 32,
		group = 6,
		requirement = "skeleton_king_reincarnation_arena",
	},
	--[[talent_hero_sara_evolution_bonus_health = {
		icon = "talents/heroes/sara_evolution_bonus_health",
		cost = 4,
		group = 2,
		max_level = 8,
		special_values = {
			health = {300, 600, 900, 1200, 1500, 1800, 2100, 2400}
		},
		effect = {
			calculate_stat_bonus = true,
			special_values_multiplier = 1 / (1 - GetAbilitySpecial("sara_evolution", "health_reduction_pct") * 0.01),
			modifiers = {
				modifier_talent_health = "health",
			},
		}
	},]]
	--Tinker - Rearm = Purge
	
}

TALENT_GROUP_TO_LEVEL = {
	[1] = 2,
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