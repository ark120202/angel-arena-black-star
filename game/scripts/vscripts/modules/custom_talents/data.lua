CUSTOM_TALENTS_DATA = {
	talent_experience_pct1 = {
		icon = "talents/experience",
		cost = 1,
		group = 1,
		max_level = 1,
		special_values = {
			experience_pct = {10}
		},
		effect = {
			unit_keys = {
				bonus_experience_percentage = "experience_pct",
			}
		}
	},
	talent_experience_pct2 = {
		icon = "talents/experience",
		cost = 1,
		group = 2,
		max_level = 1,
		special_values = {
			experience_pct = {20}
		},
		effect = {
			unit_keys = {
				bonus_experience_percentage = "experience_pct",
			}
		}
	},
	talent_experience_pct3 = {
		icon = "talents/experience",
		cost = 1,
		group = 3,
		max_level = 1,
		special_values = {
			experience_pct = {30}
		},
		effect = {
			unit_keys = {
				bonus_experience_percentage = "experience_pct",
			}
		}
	},
	talent_bonus_creep_gold = {
		icon = "talents/gold10",
		cost = 1,
		group = 1,
		max_level = 1,
		special_values = {
			gold_for_creep = {10}
		},
		effect = {
			modifiers = {
				modifier_talent_creep_gold = "gold_for_creep",
			},
		}
	},
	talent_passive_experience_income1 = {
		icon = "talents/experience_per_minute",
		cost = 1,
		group = 1,
		max_level = 1,
		special_values = {
			xp_per_minute = {800}
		},
		effect = {
			unit_keys = {
				bonus_xp_per_minute = "xp_per_minute",
			}
		}
	},
	talent_passive_experience_income2 = {
		icon = "talents/experience_per_minute",
		cost = 1,
		group = 2,
		max_level = 1,
		special_values = {
			xp_per_minute = {1900}
		},
		effect = {
			unit_keys = {
				bonus_xp_per_minute = "xp_per_minute",
			}
		}
	},
	talent_passive_experience_income3 = {
		icon = "talents/experience_per_minute",
		cost = 1,
		group = 3,
		max_level = 1,
		special_values = {
			xp_per_minute = {3000}
		},
		effect = {
			unit_keys = {
				bonus_xp_per_minute = "xp_per_minute",
			}
		}
	},
	talent_passive_gold_income1 = {
		icon = "talents/gold_per_minute",
		cost = 1,
		group = 1,
		max_level = 1,
		special_values = {
			gold_per_minute = {180}
		},
		effect = {
			unit_keys = {
				bonus_gold_per_minute = "gold_per_minute",
			}
		}
	},
	talent_passive_gold_income2 = {
		icon = "talents/gold_per_minute",
		cost = 1,
		group = 2,
		max_level = 1,
		special_values = {
			gold_per_minute = {420}
		},
		effect = {
			unit_keys = {
				bonus_gold_per_minute = "gold_per_minute",
			}
		}
	},
	talent_passive_gold_income3 = {
		icon = "talents/gold_per_minute",
		cost = 1,
		group = 3,
		max_level = 1,
		special_values = {
			gold_per_minute = {660}
		},
		effect = {
			unit_keys = {
				bonus_gold_per_minute = "gold_per_minute",
			}
		}
	},
	talent_spell_amplify = {
		icon = "talents/spell_amplify",
		cost = 5,
		group = 7,
		max_level = 7,
		special_values = {
			spell_amplify = {10, 15, 20, 25, 30, 35, 40}
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
		cost = 5,
		group = 8,
		max_level = 15,
		special_values = {
			respawn_time_reduction = {-10, -15, -20, -25, -30, -35, -40, -45, -50, -55, -60, -65, -70, -75, -80}
		},
		effect = {
			unit_keys = {
				respawn_time_reduction = "respawn_time_reduction",
			}
		}
	},
	talent_attack_damage = {
		icon = "talents/damage",
		cost = 5,
		group = 7,
		max_level = 7,
		special_values = {
			damage = {70, 140, 210, 280, 350, 420, 490}
		},
		effect = {
			modifiers = {
				modifier_talent_damage = "damage",
			},
		}
	},
	talent_evasion = {
		icon = "talents/evasion",
		cost = 2,
		group = 4,
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
		cost = 3,
		group = 6,
		max_level = 3,
		special_values = {
			movespeed_limit = {575, 600, 625}
		},
		effect = {
			modifiers = {
				modifier_talent_movespeed_limit = "movespeed_limit",
			},
		}
	},
	talent_health = {
		icon = "talents/health",
		cost = 3,
		group = 5,
		max_level = 8,
		special_values = {
			health = {350, 700, 1050, 1400, 1750, 2100, 2450, 2800}
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
		cost = 1,
		group = 3,
		max_level = 5,
		special_values = {
			mana = {300, 600, 900, 1200, 1500}
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
		cost = 1,
		group = 3,
		max_level = 5,
		special_values = {
			health_regen = {10, 20, 30, 40, 50}
		},
		effect = {
			modifiers = {
				modifier_talent_health_regen = "health_regen",
			},
		}
	},
	talent_mana_regen = {
		icon = "talents/mana_regen",
		cost = 1,
		group = 2,
		max_level = 5,
		special_values = {
			mana_regen = {3, 6, 9, 12, 15}
		},
		effect = {
			modifiers = {
				modifier_talent_mana_regen = "mana_regen",
			},
		}
	},
	talent_lifesteal = {
		icon = "talents/lifesteal",
		cost = 1,
		group = 8,
		max_level = 1,
		special_values = {
			lifesteal = {15}
		},
		effect = {
			modifiers = {
				modifier_talent_lifesteal = "lifesteal",
			},
		}
	},
	talent_armor = {
		icon = "talents/armor",
		cost = 3,
		group = 5,
		max_level = 8,
		special_values = {
			armor = {4, 8, 12, 16, 20, 24, 28, 32}
		},
		effect = {
			modifiers = {
				modifier_talent_armor = "armor",
			},
		}
	},
	talent_magic_resistance_pct = {
		icon = "talents/magic_resistance",
		cost = 3,
		group = 5,
		max_level = 8,
		special_values = {
			magic_resistance_pct = {4, 8, 12, 16, 20, 24, 28, 32}
		},
		effect = {
			modifiers = {
				modifier_talent_magic_resistance_pct = "magic_resistance_pct",
			},
		}
	},
	talent_vision_day = {
		icon = "talents/day",
		cost = 3,
		group = 6,
		max_level = 3,
		special_values = {
			vision_day = {100, 200, 300}
		},
		effect = {
			modifiers = {
				modifier_talent_vision_day = "vision_day",
			},
		}
	},
	talent_vision_night = {
		icon = "talents/night",
		cost = 3,
		group = 6,
		max_level = 3,
		special_values = {
			vision_night = {100, 200, 300}
		},
		effect = {
			modifiers = {
				modifier_talent_vision_night = "vision_night",
			},
		}
	},
	talent_cooldown_reduction_pct = {
		icon = "talents/cooldown_reduction",
		cost = 2,
		group = 4,
		max_level = 7,
		special_values = {
			cooldown_reduction_pct = {5, 7.5, 10, 12.5, 15, 17.5, 20}
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
		group = 4,
		max_level = 7,
		special_values = {
			movespeed_pct = {5, 10, 15, 20, 25, 30, 35}
		},
		effect = {
			modifiers = {
				modifier_talent_movespeed_pct = "movespeed_pct",
			},
		}
	},
	talent_true_strike = {
		icon = "talents/true_strike",
		cost = 20,
		group = 9,
		effect = {
			modifiers = {
				"modifier_talent_true_strike"
			},
		}
	},

	--Unique
	talent_hero_pudge_hook_splitter = {
		icon = "talents/heroes/pudge_hook_splitter",
		cost = 1,
		group = 9,
		requirement = "pudge_meat_hook_lua",
		special_values = {
			hook_amount = 3
		}
	},
	talent_hero_arthas_vsolyanova_bunus_chance = {
		icon = "talents/heroes/arthas_vsolyanova_bunus_chance",
		cost = 5,
		group = 9,
		max_level = 5,
		requirement = "arthas_vsolyanova",
		special_values = {
			chance_multiplier = {1.1, 1.2, 1.3, 1.4, 1.5}
		}
	},
	talent_hero_arc_warden_double_spark = {
		icon = "talents/heroes/arc_warden_double_spark",
		cost = 5,
		group = 9,
		requirement = "arc_warden_spark_wraith",
		effect = {
			multicast_abilities = {
				arc_warden_spark_wraith = 2
			}
		}
	},
	talent_hero_apocalypse_apocalypse_no_death = {
		icon = "talents/heroes/apocalypse_apocalypse_no_death",
		cost = 1,
		group = 9,
		requirement = "apocalypse_apocalypse",
	},
	talent_hero_skeleton_king_reincarnation_notime_stun = {
		icon = "talents/heroes/skeleton_king_reincarnation_notime_stun",
		cost = 1,
		group = 9,
		requirement = "skeleton_king_reincarnation_arena",
	},
	talent_hero_sai_release_of_forge_bonus_respawn_time_reduction = {
		icon = "arena/sai_release_of_forge",
		cost = 10,
		group = 8,
		max_level = 4,
		requirement = "sai_release_of_forge",
		special_values = {
			reduction_pct = {12.5, 25, 37.5, 50}
		}
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

NATIVE_TALENTS_OVERRIDE = {}

TALENT_GROUP_TO_LEVEL = {
	[1] = 10,
	[2] = 15,
	[3] = 20,
	[4] = 25,
	[5] = 30,
	[6] = 35,
	[7] = 40,
	[8] = 45,
	[9] = 50,
	[10] = 55,
	[11] = 60,
	[13] = 70,
	[14] = 80,
	[15] = 90,
	[17] = 100,
	[18] = 140,
	[19] = 180,
	[20] = 245,
	[21] = 300,
	[22] = 340,
	[23] = 360,
	[24] = 380,
	[25] = 400,
	[26] = 430,
	[27] = 460,
	[28] = 490,
	[29] = 550,
}
	-- [1] = 10, exp;gold_creep;
	-- [2] = 15, mana;regen;gold_min;exp_min;
	-- [3] = 20, armor;mag_resist;
	-- [4] = 25, movespeed;spell_amp;
	-- [5] = 30, cd;evasion;
	-- [6] = 35, ms_limit;
	-- [7] = 40, day;night;
	-- [8] = 45, respawn_time;
	-- [9] = 50, damage;
	-- [10] = 55, truestrike
