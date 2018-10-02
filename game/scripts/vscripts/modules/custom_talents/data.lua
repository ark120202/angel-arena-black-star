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
			xp_per_minute = {600}
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
			xp_per_minute = {2500}
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
			gold_per_minute = {220}
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
			gold_per_minute = {460}
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
	talent_hero_sai_release_of_forge_bonus_respawn_time_reduction = {
		icon = "arena/sai_release_of_forge",
		cost = 10,
		group = 8,
		max_level = 4,
		requirement = "sai_release_of_forge",
		special_values = {
			reduction_pct = {25, 50, 75, 100}
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

-- A list of heroes, which have Changed flag, but some native talents for them are still relevant
-- Value should be a table, where irrelevant talents should have a `true` value
PARTIALLY_CHANGED_HEROES = {
	npc_dota_hero_ogre_magi = {},
	npc_dota_hero_huskar = {
		special_bonus_unique_huskar_2 = true,
	},
	npc_dota_hero_doom_bringer = {
		special_bonus_unique_doom_2 = true,
		special_bonus_unique_doom_3 = true,
	},
}

NATIVE_TALENTS_OVERRIDE = {
	special_bonus_unique_abaddon = {
		group = 4,
	},
	special_bonus_unique_abaddon_2 = {
		group = 4,
	},
	special_bonus_unique_abaddon_3 = {
		group = 6,
	},
	special_bonus_unique_alchemist = {
		group = 5,
	},
	special_bonus_unique_alchemist_2 = {
		group = 6,
	},
	special_bonus_unique_alchemist_3 = {
		group = 10,
	},
	special_bonus_unique_axe = {
		group = 6,
	},
	special_bonus_unique_axe_2 = {
		group = 5,
	},
	special_bonus_unique_axe_3 = {
		group = 3,
	},
	special_bonus_unique_beastmaster = {
		group = 8,
	},
	special_bonus_unique_beastmaster_2 = {
		group = 5,
	},
	special_bonus_unique_beastmaster_3 = {
		group = 4,
	},
	special_bonus_unique_beastmaster_4 = {
		group = 6,
	},
	special_bonus_unique_clinkz_1 = {
		group = 7,
	},
	special_bonus_unique_clinkz_2 = {
		group = 9,
	},
	special_bonus_unique_clinkz_3 = {
		group = 10,
	},
	special_bonus_unique_juggernaut = {
		group = 4,
	},
	special_bonus_unique_juggernaut_2 = {
		group = 9,
	},
	special_bonus_unique_juggernaut_3 = {
		group = 6,
	},
	special_bonus_unique_winter_wyvern_1 = {
		group = 9,
	},
	special_bonus_unique_winter_wyvern_2 = {
		group = 7,
	},
	special_bonus_unique_winter_wyvern_3 = {
		group = 8,
	},
	special_bonus_unique_winter_wyvern_4 = {
		group = 6,
	},
	special_bonus_unique_terrorblade = {
		group = 9,
	},
	special_bonus_unique_terrorblade_2 = {
		group = 8,
	},
	special_bonus_unique_terrorblade_3 = {
		group = 10,
	},
	special_bonus_unique_luna_1 = {
		group = 5,
	},
	special_bonus_unique_luna_2 = {
		group = 7,
	},
	special_bonus_unique_luna_3 = {
		group = 6,
	},
	special_bonus_unique_luna_5 = {
		group = 8,
	},
	special_bonus_unique_medusa = {
		group = 5,
	},
	special_bonus_unique_medusa_2 = {
		group = 10,
	},
	special_bonus_unique_medusa_3 = {
		group = 2,
	},
	special_bonus_unique_medusa_4 = false,
	special_bonus_unique_night_stalker = {
		group = 7,
	},
	special_bonus_unique_night_stalker_2 = {
		group = 6,
	},
	special_bonus_unique_nyx = {
		group = 8,
	},
	special_bonus_unique_nyx_2 = {
		group = 7,
	},
	special_bonus_unique_nyx_3 = {
		group = 9,
	},
	special_bonus_unique_weaver_1 = {
		group = 5,
	},
	special_bonus_unique_weaver_2 = {
		group = 9,
	},
	special_bonus_unique_weaver_3 = {
		group = 8,
	},
	special_bonus_unique_weaver_4 = {
		group = 7,
	},
	special_bonus_unique_weaver_5 = {
		group = 10,
	},
	special_bonus_unique_ursa = {
		group = 8,
	},
	special_bonus_unique_ursa_3 = {
		group = 6,
	},
	special_bonus_unique_ursa_4 = {
		group = 10,
	},
	special_bonus_unique_ursa_5 = {
		group = 5,
	},
	special_bonus_unique_chaos_knight = {
		group = 10,
	},
	special_bonus_unique_chaos_knight_2 = {
		group = 6,
	},
	special_bonus_unique_chaos_knight_3 = {
		group = 9,
	},
	special_bonus_unique_lycan_1 = {
		group = 10,
	},
	special_bonus_unique_lycan_2 = {
		group = 1,
	},
	special_bonus_unique_lycan_3 = {
		group = 5,
	},
	special_bonus_unique_lycan_4 = {
		group = 7,
	},
	special_bonus_unique_lycan_5 = {
		group = 6,
	},
	special_bonus_unique_windranger = {
		group = 9,
	},
	special_bonus_unique_windranger_2 = {
		group = 6,
	},
	special_bonus_unique_windranger_3 = {
		group = 7,
	},
	special_bonus_unique_windranger_4 = {
		group = 10,
	},
	special_bonus_unique_slark = {
		group = 9,
	},
	special_bonus_unique_slark_2 = {
		group = 6,
	},
	special_bonus_unique_slark_3 = {
		group = 10,
	},
	special_bonus_unique_slark_4 = {
		group = 11,
	},
	special_bonus_unique_spectre = {
		group = 9,
	},
	special_bonus_unique_spectre_2 = {
		group = 8,
	},
	special_bonus_unique_spectre_3 = {
		group = 7,
	},
	special_bonus_unique_spectre_4 = {
		group = 10,
	},
	special_bonus_unique_spectre_5 = {
		group = 11,
	},
	special_bonus_unique_spirit_breaker_1 = {
		group = 9,
	},
	special_bonus_unique_spirit_breaker_2 = {
		group = 8,
	},
	special_bonus_unique_spirit_breaker_3 = {
		group = 7,
	},
	special_bonus_unique_storm_spirit = {
		group = 9,
	},
	special_bonus_unique_storm_spirit_3 = {
		group = 11,
	},
	special_bonus_unique_storm_spirit_4 = {
		group = 10,
	},
	special_bonus_unique_storm_spirit_5 = false,
	special_bonus_unique_tidehunter = {
		group = 7,
	},
	special_bonus_unique_tidehunter_2 = {
		group = 9,
	},
	special_bonus_unique_tidehunter_3 = {
		group = 10,
	},
	special_bonus_unique_tidehunter_4 = {
		group = 8,
	},
	special_bonus_unique_tinker = {
		group = 9,
	},
	special_bonus_unique_tinker_2 = {
		group = 8,
	},
	special_bonus_unique_tinker_3 = {
		group = 10,
	},
	special_bonus_unique_tiny = {
		group = 7,
	},
	special_bonus_unique_tiny_2 = false,
	special_bonus_unique_tiny_3 = {
		group = 5,
	},
	special_bonus_unique_tiny_4 = {
		group = 5,
	},
	special_bonus_unique_tiny_5 = {
		group = 6,
	},
	special_bonus_unique_troll_warlord = {
		group = 9,
	},
	special_bonus_unique_troll_warlord_2 = {
		group = 8,
	},
	special_bonus_unique_troll_warlord_3 = {
		group = 7,
	},
	special_bonus_unique_troll_warlord_4 = {
		group = 10,
	},
	special_bonus_unique_undying = {
		group = 3,
	},
	special_bonus_unique_undying_2 = {
		group = 9,
	},
	special_bonus_unique_undying_3 = {
		group = 4,
	},
	special_bonus_unique_undying_4 = {
		group = 8,
	},
	special_bonus_unique_undying_5 = {
		group = 7,
	},
	special_bonus_unique_viper_1 = {
		group = 8,
	},
	special_bonus_unique_viper_2 = {
		group = 9,
	},
	special_bonus_unique_viper_3 = {
		group = 11,
	},
	special_bonus_unique_viper_4 = {
		group = 10,
	},
	special_bonus_unique_zeus = {
		group = 10,
	},
	special_bonus_unique_zeus_2 = {
		group = 8,
	},
	special_bonus_unique_zeus_3 = {
		group = 9,
	},
	special_bonus_unique_elder_titan = {
		group = 6,
	},
	special_bonus_unique_elder_titan_2 = {
		group = 5,
	},
	special_bonus_unique_elder_titan_3 = {
		group = 8,
	},
	special_bonus_unique_ember_spirit_1 = {
		group = 10,
	},
	special_bonus_unique_ember_spirit_2 = {
		group = 8,
	},
	special_bonus_unique_ember_spirit_3 = {
		group = 7,
	},
	special_bonus_unique_ember_spirit_4 = false,
	special_bonus_unique_ember_spirit_5 = {
		group = 9,
	},
	special_bonus_unique_lifestealer = {
		group = 10,
	},
	special_bonus_unique_lifestealer_2 = {
		group = 5,
	},
	special_bonus_unique_lifestealer_3 = false,
	special_bonus_unique_lion = {
		group = 6,
	},
	special_bonus_unique_lion_2 = {
		group = 9,
	},
	special_bonus_unique_lion_3 = {
		group = 10,
	},
	special_bonus_unique_lion_4 = {
		group = 11,
	},
	special_bonus_unique_skywrath = {
		group = 8,
	},
	special_bonus_unique_skywrath_2 = {
		group = 7,
	},
	special_bonus_unique_skywrath_3 = {
		group = 9,
	},
	special_bonus_unique_skywrath_4 = {
		group = 10,
	},
	special_bonus_unique_skywrath_5 = {
		group = 11,
	},
	special_bonus_unique_ogre_magi = {
		group = 7,
	},
	special_bonus_unique_ogre_magi_2 = {
		group = 8,
	},
	special_bonus_unique_silencer = {
		group = 6,
	},
	special_bonus_unique_silencer_2 = {
		group = 7,
	},
	special_bonus_unique_silencer_3 = {
		group = 9,
	},
	special_bonus_unique_silencer_4 = {
		group = 10,
	},
	special_bonus_unique_death_prophet = {
		group = 9,
	},
	special_bonus_unique_death_prophet_2 = {
		group = 7,
	},
	special_bonus_unique_death_prophet_3 = {
		group = 8,
	},
	special_bonus_unique_death_prophet_4 = {
		group = 10,
	},
	special_bonus_unique_phantom_assassin = {
		group = 8,
	},
	special_bonus_unique_phantom_assassin_2 = {
		group = 10,
	},
	special_bonus_unique_phantom_assassin_3 = {
		group = 9,
	},
	special_bonus_unique_phantom_lancer = {
		group = 3,
	},
	special_bonus_unique_phantom_lancer_2 = {
		group = 1,
	},
	special_bonus_unique_phantom_lancer_3 = {
		group = 5,
	},
	special_bonus_unique_phantom_lancer_4 = false,
	special_bonus_unique_riki_1 = {
		group = 10,
	},
	special_bonus_unique_riki_2 = {
		group = 8,
	},
	special_bonus_unique_riki_3 = {
		group = 9,
	},
	special_bonus_unique_riki_4 = {
		group = 11,
	},
	special_bonus_unique_riki_5 = {
		group = 12,
	},
	special_bonus_unique_tusk = false,
	special_bonus_unique_tusk_2 = {
		group = 5,
	},
	special_bonus_unique_tusk_3 = {
		group = 7,
	},
	special_bonus_unique_tusk_4 = {
		group = 10,
	},
	special_bonus_unique_tusk_5 = {
		group = 6,
	},
	special_bonus_unique_sniper_1 = {
		group = 8,
	},
	special_bonus_unique_sniper_2 = {
		group = 5,
	},
	special_bonus_unique_sniper_3 = {
		group = 9,
	},
	special_bonus_unique_sniper_4 = {
		group = 10,
	},
	special_bonus_unique_magnus_2 = {
		group = 10,
	},
	special_bonus_unique_magnus_3 = {
		group = 6,
	},
	special_bonus_unique_magnus_4 = {
		group = 5,
	},
	special_bonus_unique_magnus_5 = {
		group = 7,
	},
	special_bonus_unique_drow_ranger_1 = {
		group = 10,
	},
	special_bonus_unique_drow_ranger_2 = {
		group = 8,
	},
	special_bonus_unique_drow_ranger_3 = {
		group = 11,
	},
	special_bonus_unique_drow_ranger_4 = {
		group = 9,
	},
	special_bonus_unique_earth_spirit = {
		group = 5,
	},
	special_bonus_unique_earth_spirit_2 = {
		group = 8,
	},
	special_bonus_unique_earth_spirit_3 = {
		group = 6,
	},
	special_bonus_unique_huskar = {
		group = 9,
	},
	special_bonus_unique_naga_siren = {
		group = 9,
	},
	special_bonus_unique_naga_siren_2 = {
		group = 8,
	},
	special_bonus_unique_naga_siren_3 = {
		group = 6,
	},
	special_bonus_unique_oracle = {
		group = 9,
	},
	special_bonus_unique_oracle_2 = {
		group = 4,
	},
	special_bonus_unique_oracle_3 = {
		group = 10,
	},
	special_bonus_unique_oracle_4 = {
		group = 11,
	},
	special_bonus_unique_sand_king = {
		group = 8,
	},
	special_bonus_unique_sand_king_2 = {
		group = 7,
	},
	special_bonus_unique_sand_king_3 = {
		group = 5,
	},
	special_bonus_unique_sand_king_4 = {
		group = 4,
	},
	special_bonus_unique_shadow_demon_1 = {
		group = 11,
	},
	special_bonus_unique_shadow_demon_2 = {
		group = 10,
	},
	special_bonus_unique_shadow_demon_3 = {
		group = 8,
	},
	special_bonus_unique_shadow_demon_4 = {
		group = 9,
	},
	special_bonus_unique_slardar = {
		group = 8,
	},
	special_bonus_unique_slardar_2 = {
		group = 9,
	},
	special_bonus_unique_slardar_3 = false,
	special_bonus_unique_lina_1 = {
		group = 5,
	},
	special_bonus_unique_lina_2 = {
		group = 6,
	},
	special_bonus_unique_lina_3 = {
		group = 5,
	},
	special_bonus_unique_ancient_apparition_2 = {
		group = 6,
	},
	special_bonus_unique_ancient_apparition_3 = {
		group = 5,
	},
	special_bonus_unique_ancient_apparition_4 = {
		group = 4,
	},
	special_bonus_unique_ancient_apparition_5 = {
		group = 9,
	},
	special_bonus_unique_disruptor = false,
	special_bonus_unique_disruptor_2 = {
		group = 9,
	},
	special_bonus_unique_disruptor_3 = {
		group = 5,
	},
	special_bonus_unique_disruptor_4 = {
		group = 8,
	},
	special_bonus_unique_disruptor_5 = {
		group = 10,
	},
	special_bonus_unique_outworld_devourer = {
		group = 9,
	},
	special_bonus_unique_outworld_devourer_2 = {
		group = 8,
	},
	special_bonus_unique_outworld_devourer_3 = {
		group = 10,
	},
	special_bonus_unique_keeper_of_the_light = {
		group = 10,
	},
	special_bonus_unique_keeper_of_the_light_2 = {
		group = 9,
	},
	special_bonus_unique_keeper_of_the_light_3 = {
		group = 8,
	},
	special_bonus_unique_legion_commander = {
		group = 9,
	},
	special_bonus_unique_legion_commander_2 = {
		group = 7,
	},
	special_bonus_unique_legion_commander_3 = {
		group = 6,
	},
	special_bonus_unique_legion_commander_4 = {
		group = 5,
	},
	special_bonus_unique_puck = {
		group = 9,
	},
	special_bonus_unique_puck_2 = {
		group = 10,
	},
	special_bonus_unique_puck_3 = {
		group = 11,
	},
	special_bonus_unique_pugna_1 = {
		group = 9,
	},
	special_bonus_unique_pugna_2 = {
		group = 8,
	},
	special_bonus_unique_pugna_3 = {
		group = 10,
	},
	special_bonus_unique_pugna_4 = {
		group = 7,
	},
	special_bonus_unique_pugna_5 = {
		group = 6,
	},
	special_bonus_unique_pugna_6 = {
		group = 5,
	},
	special_bonus_unique_timbersaw = {
		group = 9,
	},
	special_bonus_unique_timbersaw_2 = {
		group = 4,
	},
	special_bonus_unique_timbersaw_3 = {
		group = 10,
	},
	special_bonus_unique_bloodseeker = {
		group = 6,
	},
	special_bonus_unique_bloodseeker_2 = {
		group = 7,
	},
	special_bonus_unique_bloodseeker_3 = {
		group = 10,
	},
	special_bonus_unique_bloodseeker_4 = {
		group = 11,
	},
	special_bonus_unique_broodmother_1 = {
		group = 10,
	},
	special_bonus_unique_broodmother_2 = {
		group = 2,
	},
	special_bonus_unique_broodmother_3 = {
		group = 6,
	},
	special_bonus_unique_broodmother_4 = {
		group = 3,
	},
	special_bonus_unique_chen_1 = {
		group = 7,
	},
	special_bonus_unique_chen_2 = {
		group = 9,
	},
	special_bonus_unique_chen_3 = {
		group = 8,
	},
	special_bonus_unique_chen_4 = {
		group = 6,
	},
	special_bonus_unique_lone_druid_4 = {
		group = 9,
	},
	special_bonus_unique_lone_druid_6 = {
		group = 8,
	},
	special_bonus_unique_lone_druid_7 = {
		group = 12,
	},
	special_bonus_unique_lone_druid_8 = {
		group = 10,
	},
	special_bonus_unique_lone_druid_9 = {
		group = 11,
	},
	special_bonus_unique_techies = {
		group = 8,
	},
	special_bonus_unique_techies_3 = {
		group = 7,
	},
	special_bonus_unique_techies_4 = {
		group = 9,
	},
	special_bonus_unique_arc_warden = {
		group = 6,
	},
	special_bonus_unique_meepo = {
		group = 10,
	},
	special_bonus_unique_meepo_2 = {
		group = 9,
	},
	special_bonus_unique_monkey_king = {
		group = 11,
	},
	special_bonus_unique_monkey_king_2 = {
		group = 10,
	},
	special_bonus_unique_monkey_king_3 = {
		group = 9,
	},
	special_bonus_unique_monkey_king_4 = {
		group = 12,
	},
	special_bonus_unique_monkey_king_5 = {
		group = 7,
	},
	special_bonus_unique_monkey_king_6 = {
		group = 13,
	},
	special_bonus_unique_monkey_king_7 = {
		group = 8,
	},
	special_bonus_unique_pangolier_2 = {
		group = 6,
	},
	special_bonus_unique_pangolier_3 = {
		group = 10,
	},
	special_bonus_unique_pangolier_4 = {
		group = 9,
	},
	special_bonus_unique_pangolier_5 = {
		group = 8,
	},
	special_bonus_unique_dark_willow_1 = {
		group = 8,
	},
	special_bonus_unique_dark_willow_2 = {
		group = 9,
	},
	special_bonus_unique_grimstroke_1 = {
		group = 3,
	},
	special_bonus_unique_grimstroke_2 = {
		group = 5,
	},
	special_bonus_unique_grimstroke_3 = {
		group = 6,
	},
	special_bonus_unique_grimstroke_4 = {
		group = 2,
	},
	special_bonus_unique_clockwerk = {
		group = 9,
	},
	special_bonus_unique_clockwerk_2 = {
		group = 5,
	},
	special_bonus_unique_clockwerk_3 = {
		group = 7,
	},
	special_bonus_unique_clockwerk_4 = {
		group = 6,
	},
	special_bonus_unique_centaur_1 = {
		group = 9,
	},
	special_bonus_unique_centaur_2 = {
		group = 5,
	},
	special_bonus_unique_centaur_3 = {
		group = 8,
	},
	special_bonus_unique_centaur_4 = {
		group = 7,
	},
	special_bonus_unique_witch_doctor_1 = {
		group = 9,
	},
	special_bonus_unique_witch_doctor_2 = {
		group = 10,
	},
	special_bonus_unique_witch_doctor_3 = {
		group = 8,
	},
	special_bonus_unique_witch_doctor_4 = {
		group = 11,
	},
	special_bonus_unique_witch_doctor_5 = {
		group = 12,
	},
	special_bonus_unique_necrophos = {
		group = 8,
	},
	special_bonus_unique_necrophos_2 = {
		group = 9,
	},
	special_bonus_unique_mirana_1 = {
		group = 6,
	},
	special_bonus_unique_mirana_2 = {
		group = 9,
	},
	special_bonus_unique_mirana_3 = {
		group = 5,
	},
	special_bonus_unique_mirana_4 = {
		group = 10,
	},
	special_bonus_unique_bounty_hunter = {
		group = 10,
	},
	special_bonus_unique_bounty_hunter_2 = {
		group = 6,
	},
	special_bonus_unique_bounty_hunter_3 = {
		group = 11,
	},
	special_bonus_unique_queen_of_pain = {
		group = 8,
	},
	special_bonus_unique_queen_of_pain_2 = {
		group = 9,
	},
	special_bonus_unique_underlord = {
		group = 6,
	},
	special_bonus_unique_underlord_2 = {
		group = 5,
	},
	special_bonus_unique_underlord_3 = {
		group = 3,
	},
	special_bonus_unique_treant = {
		group = 6,
	},
	special_bonus_unique_treant_2 = {
		group = 5,
	},
	special_bonus_unique_treant_3 = {
		group = 6,
	},
	special_bonus_unique_treant_4 = {
		group = 9,
	},
	special_bonus_unique_treant_5 = {
		group = 8,
	},
	special_bonus_unique_razor = {
		group = 9,
	},
	special_bonus_unique_razor_2 = {
		group = 11,
	},
	special_bonus_unique_razor_3 = {
		group = 8,
	},
	special_bonus_unique_razor_4 = {
		group = 10,
	},
	special_bonus_unique_visage_2 = {
		group = 7,
	},
	special_bonus_unique_visage_3 = {
		group = 9,
	},
	special_bonus_unique_visage_4 = {
		group = 8,
	},
	special_bonus_unique_visage_5 = {
		group = 10,
	},
	special_bonus_unique_visage_6 = {
		group = 6,
	},
	special_bonus_unique_earthshaker = {
		group = 8,
	},
	special_bonus_unique_earthshaker_2 = {
		group = 6,
	},
	special_bonus_unique_earthshaker_3 = {
		group = 4,
	},
	special_bonus_unique_lich_1 = {
		group = 8,
	},
	special_bonus_unique_lich_2 = {
		group = 9,
	},
	special_bonus_unique_lich_3 = {
		group = 7,
	},
	special_bonus_unique_rubick = {
		group = 8,
	},
	special_bonus_unique_rubick_2 = {
		group = 9,
	},
	special_bonus_unique_rubick_3 = {
		group = 11,
	},
	special_bonus_unique_rubick_4 = {
		group = 10,
	},
	special_bonus_unique_rubick_5 = {
		group = 12,
	},
	special_bonus_unique_sven = {
		group = 9,
	},
	special_bonus_unique_sven_2 = {
		group = 10,
	},
	special_bonus_unique_sven_3 = {
		group = 11,
	},
	special_bonus_unique_dark_seer = {
		group = 8,
	},
	special_bonus_unique_dark_seer_2 = {
		group = 9,
	},
	special_bonus_unique_dark_seer_3 = {
		group = 10,
	},
	special_bonus_unique_dark_seer_4 = {
		group = 11,
	},
	special_bonus_unique_dazzle_1 = {
		group = 8,
	},
	special_bonus_unique_dazzle_2 = {
		group = 9,
	},
	special_bonus_unique_dazzle_3 = {
		group = 7,
	},
	special_bonus_unique_dazzle_4 = {
		group = 10,
	},
	special_bonus_unique_shadow_shaman_1 = {
		group = 8,
	},
	special_bonus_unique_shadow_shaman_2 = {
		group = 9,
	},
	special_bonus_unique_shadow_shaman_3 = {
		group = 7,
	},
	special_bonus_unique_shadow_shaman_4 = {
		group = 6,
	},
	special_bonus_unique_shadow_shaman_5 = {
		group = 10,
	},
	special_bonus_unique_vengeful_spirit_1 = {
		group = 8,
	},
	special_bonus_unique_vengeful_spirit_2 = {
		group = 7,
	},
	special_bonus_unique_vengeful_spirit_3 = {
		group = 9,
	},
	special_bonus_unique_vengeful_spirit_4 = {
		group = 6,
	},
	special_bonus_unique_vengeful_spirit_5 = {
		group = 5,
	},
	special_bonus_unique_vengeful_spirit_6 = {
		group = 5,
	},
	special_bonus_unique_venomancer = {
		group = 6,
	},
	special_bonus_unique_venomancer_2 = {
		group = 8,
	},
	special_bonus_unique_venomancer_3 = {
		group = 7,
	},
	special_bonus_unique_venomancer_4 = {
		group = 10,
	},
	special_bonus_unique_venomancer_5 = {
		group = 9,
	},
	special_bonus_unique_venomancer_6 = {
		group = 11,
	},
	special_bonus_unique_morphling_1 = {
		group = 9,
	},
	special_bonus_unique_morphling_3 = {
		group = 8,
	},
	special_bonus_unique_morphling_4 = {
		group = 10,
	},
	special_bonus_unique_morphling_5 = {
		group = 11,
	},
	special_bonus_unique_morphling_6 = false,
	special_bonus_unique_morphling_8 = false,
	special_bonus_unique_leshrac_1 = {
		group = 8,
	},
	special_bonus_unique_leshrac_2 = {
		group = 9,
	},
	special_bonus_unique_leshrac_3 = {
		group = 10,
	},
	special_bonus_unique_jakiro = {
		group = 9,
	},
	special_bonus_unique_jakiro_2 = {
		group = 8,
	},
	special_bonus_unique_jakiro_3 = {
		group = 10,
	},
	special_bonus_unique_jakiro_4 = {
		group = 7,
	},
	special_bonus_unique_enigma = {
		group = 5,
	},
	special_bonus_unique_enigma_2 = {
		group = 8,
	},
	special_bonus_unique_enigma_3 = {
		group = 6,
	},
	special_bonus_unique_bane_1 = {
		group = 6,
	},
	special_bonus_unique_bane_2 = {
		group = 8,
	},
	special_bonus_unique_bane_3 = {
		group = 9,
	},
	special_bonus_unique_bane_4 = {
		group = 7,
	},
	special_bonus_unique_nevermore_1 = {
		group = 10,
	},
	special_bonus_unique_nevermore_2 = {
		group = 8,
	},
	special_bonus_unique_nevermore_3 = false,
	special_bonus_unique_templar_assassin = {
		group = 11,
	},
	special_bonus_unique_templar_assassin_2 = {
		group = 10,
	},
	special_bonus_unique_templar_assassin_3 = {
		group = 9,
	},
	special_bonus_unique_templar_assassin_4 = {
		group = 13,
	},
	special_bonus_unique_templar_assassin_5 = {
		group = 12,
	},
	special_bonus_unique_doom_1 = {
		group = 9,
	},
	special_bonus_unique_doom_4 = {
		group = 4,
	},
	special_bonus_unique_doom_5 = {
		group = 6,
	},
	special_bonus_unique_brewmaster = {
		group = 9,
	},
	special_bonus_unique_brewmaster_2 = {
		group = 10,
	},
	special_bonus_unique_brewmaster_3 = {
		group = 8,
	},
	special_bonus_unique_brewmaster_4 = {
		group = 11,
	},
	special_bonus_unique_bristleback = {
		group = 6,
	},
	special_bonus_unique_bristleback_2 = {
		group = 8,
	},
	special_bonus_unique_bristleback_3 = {
		group = 9,
	},
	special_bonus_unique_furion = {
		group = 6,
	},
	special_bonus_unique_furion_2 = {
		group = 7,
	},
	special_bonus_unique_furion_3 = {
		group = 10,
	},
	special_bonus_unique_furion_4 = {
		group = 8,
	},
	special_bonus_unique_phoenix_1 = {
		group = 9,
	},
	special_bonus_unique_phoenix_2 = {
		group = 10,
	},
	special_bonus_unique_phoenix_3 = {
		group = 7,
	},
	special_bonus_unique_phoenix_4 = {
		group = 8,
	},
	special_bonus_unique_phoenix_5 = {
		group = 11,
	},
	special_bonus_unique_enchantress_1 = {
		group = 4,
	},
	special_bonus_unique_enchantress_2 = {
		group = 8,
	},
	special_bonus_unique_enchantress_3 = {
		group = 9,
	},
	special_bonus_unique_enchantress_4 = {
		group = 10,
	},
	special_bonus_unique_enchantress_5 = {
		group = 7,
	},
	special_bonus_unique_batrider_1 = {
		group = 9,
	},
	special_bonus_unique_batrider_2 = {
		group = 8,
	},
	special_bonus_unique_batrider_3 = {
		group = 7,
	},
	special_bonus_unique_wraith_king_2 = false,
	special_bonus_unique_wraith_king_6 = {
		group = 2,
	},
	special_bonus_unique_wraith_king_1 = {
		group = 4,
	},
	special_bonus_unique_wraith_king_4 = {
		group = 9,
	},
	special_bonus_unique_wraith_king_8 = {
		group = 6,
	},
	special_bonus_unique_wraith_king_7 = {
		group = 1,
	},
	special_bonus_unique_kunkka_5 = {
		group = 9,
	},
	special_bonus_unique_kunkka = {
		group = 7,
	},
	special_bonus_unique_kunkka_2 = {
		group = 5,
	},
	special_bonus_unique_kunkka_3 = {
		group = 10,
	},
	special_bonus_unique_invoker_1 = {
		group = 6,
	},
	special_bonus_unique_invoker_2 = {
		group = 6,
	},
	special_bonus_unique_invoker_3 = {
		group = 13,
	},
	special_bonus_unique_invoker_4 = {
		group = 12,
	},
	special_bonus_unique_invoker_5 = {
		group = 11,
	},
	special_bonus_unique_invoker_6 = {
		group = 14,
	},
	special_bonus_unique_invoker_9 = {
		group = 9,
	},
	special_bonus_unique_invoker_8 = {
		group = 10,
	},
	special_bonus_unique_gyrocopter_1 = false,
	special_bonus_unique_gyrocopter_3 = {
		group = 6,
	},
	special_bonus_unique_gyrocopter_4 = {
		group = 5,
	},
	special_bonus_unique_gyrocopter_5 = {
		group = 4,
	},
	special_bonus_unique_underlord_4 = false,
	special_bonus_unique_dragon_knight_2 = false,
	special_bonus_unique_omniknight_1 = {
		group = 3,
	},
	special_bonus_unique_omniknight_3 = {
		group = 7,
	},
	special_bonus_unique_wisp_6 = {
		group = 7,
	},
	special_bonus_unique_wisp_5 = {
		group = 4,
	},
	special_bonus_unique_wisp_4 = {
		group = 3,
	},
	special_bonus_unique_crystal_maiden_2 = {
		group = 3,
	},
	special_bonus_unique_crystal_maiden_3 = {
		group = 3,
	},
	special_bonus_unique_crystal_maiden_4 = {
		group = 6,
	},
	special_bonus_unique_crystal_maiden_1 = {
		group = 2,
	},
	special_bonus_unique_warlock_2 = {
		group = 2,
	},
	special_bonus_unique_warlock_4 = {
		group = 3,
	},
	special_bonus_unique_warlock_5 = {
		group = 4,
	},
	special_bonus_unique_antimage_2 = {
		group = 2,
	},
	special_bonus_unique_antimage_3 = {
		group = 3,
	},
	special_bonus_unique_antimage_2 = {
		group = 4,
	},
	special_bonus_unique_antimage_5 = {
		group = 3,
	},
	special_bonus_unique_faceless_void = {
		group = 2,
	},
	special_bonus_unique_faceless_void_2 = {
		group = 3,
	},
	special_bonus_unique_faceless_void_3 = {
		group = 3,
	},
	special_bonus_unique_faceless_void_4 = {
		group = 6,
	},
}

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
	[12] = 65,
	[13] = 70,
	[14] = 75,
	[15] = 80,
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
