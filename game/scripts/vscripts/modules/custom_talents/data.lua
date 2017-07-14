CUSTOM_TALENTS_DATA = {
	talent_experience_pct = {
		icon = "talents/experience",
		cost = 1,
		group = 1,
		max_level = 4,
		special_values = {
			experience_pct = {15, 20, 25, 30}
		},
		effect = {
			unit_keys = {
				bonus_experience_percentage = "experience_pct",
			}
		}
	},
	talent_bonus_creep_gold = {
		icon = "talents/gold",
		cost = 1,
		group = 1,
		max_level = 4,
		special_values = {
			gold_for_creep = {8, 14, 20, 26}
		},
		effect = {
			modifiers = {
				modifier_talent_creep_gold = "gold_for_creep",
			},
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
		group = 9,
		max_level = 14,
		special_values = {
			respawn_time_reduction = {-10, -15, -20, -25, -30, -35, -40, -45, -50, -55, -60, -65, -70, -75}
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
			evasion = {5.0, 7.5, 10.0, 12.5, 15.0, 17.5, 20}
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
		max_level = 6,
		special_values = {
			mana = {250, 500, 750, 1000, 1250, 1500}
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
			health_regen = {10, 17, 24, 31, 38}
		},
		effect = {
			modifiers = {
				modifier_talent_health_regen = "health_regen",
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
			movespeed_pct = {15, 17.5, 20, 22.5, 25, 27.5, 30}
		},
		effect = {
			modifiers = {
				modifier_talent_movespeed_pct = "movespeed_pct",
			},
		}
	},
	talent_passive_gold_income = {
		icon = "talents/gold",
		cost = 1,
		group = 2,
		max_level = 5,
		special_values = {
			gold_per_minute = {180, 240, 300, 360, 420}
		},
		effect = {
			unit_keys = {
				bonus_gold_per_minute = "gold_per_minute",
			}
		}
	},
	talent_passive_experience_income = {
		icon = "talents/experience",
		cost = 1,
		group = 2,
		max_level = 5,
		special_values = {
			xp_per_minute = {600, 1000, 1400, 1800, 2200}
		},
		effect = {
			unit_keys = {
				bonus_xp_per_minute = "xp_per_minute",
			}
		}
	},
	talent_true_strike = {
		icon = "talents/true_strike",
		cost = 30,
		group = 8,
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
		cost = 20,
		group = 6,
		requirement = "apocalypse_apocalypse",
	},
	talent_hero_skeleton_king_reincarnation_notime_stun = {
		icon = "talents/heroes/skeleton_king_reincarnation_notime_stun",
		cost = 1,
		group = 10,
		requirement = "skeleton_king_reincarnation_arena",
	},
	talent_hero_sai_release_of_forge_bonus_respawn_time_reduction = {
		icon = "arena/sai_release_of_forge",
		cost = 5,
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






	--Default talents
	-- talent_hero_anitmage_blink_cd_reduction = {
	-- 	icon = "antimage_blink",
	-- 	cost = 1,
	-- 	group = 1,
	-- 	requirement = "antimage_blink",
	-- 	special_values = {value = 1},
	-- 	effect = {abilities = "special_bonus_unique_antimage"}
	-- },
	-- talent_hero_special_bonus_unique_antimage_2 = {
	-- 	icon = "antimage_mana_void",
	-- 	cost = 1,
	-- 	group = 1,
	-- 	requirement = "antimage_mana_void",
	-- 	special_values = {value = 50},
	-- 	effect = {abilities = "special_bonus_unique_antimage_2"}
	-- },
	talent_hero_axe_battle_hunger_dps = {
		icon = "axe_battle_hunger",
		cost = 1,
		group = 5,
		requirement = "axe_battle_hunger",
		special_values = {value = 100},
		effect = {abilities = "special_bonus_unique_axe"}
	},
	talent_hero_bane_enfeeble_reduction = {
		icon = "bane_enfeeble",
		cost = 1,
		group = 6,
		requirement = "bane_enfeeble",
		special_values = {value = 300},
		effect = {abilities = "special_bonus_unique_bane_1"}
	},
	talent_hero_bane_brain_sap_dmg = {
		icon = "bane_brain_sap",
		cost = 1,
		group = 5,
		requirement = "bane_brain_sap",
		special_values = {value = 200},
		effect = {abilities = "special_bonus_unique_bane_2"}
	},
	talent_hero_bloodseeker_blood_bath_dmg = {
		icon = "bloodseeker_blood_bath",
		cost = 1,
		group = 5,
		requirement = "bloodseeker_blood_bath",
		special_values = {value = 150},
		effect = {abilities = "special_bonus_unique_bloodseeker_2"}
	},
	talent_hero_bloodseeker_rupture_damage = {
		icon = "bloodseeker_rupture",
		cost = 1,
		group = 4,
		requirement = "bloodseeker_rupture",
		special_values = {value = 14},
		effect = {abilities = "special_bonus_unique_bloodseeker_3"}
	},
	talent_hero_bloodseeker_blood_bath_cooldown = {
		icon = "bloodseeker_blood_bath",
		cost = 1,
		group = 6,
		requirement = "bloodseeker_blood_bath",
		special_values = {value = 7},
		effect = {abilities = "special_bonus_unique_bloodseeker"}
	},
	-- talent_hero_crystal_maiden_freezing_field_damage = {
	-- 	icon = "crystal_maiden_freezing_field",
	-- 	cost = 1,
	-- 	group = 1,
	-- 	requirement = "crystal_maiden_freezing_field",
	-- 	special_values = {value = 300},
	-- 	effect = {abilities = "special_bonus_unique_crystal_maiden_3"}
	-- },
	-- talent_hero_crystal_maiden_frostbite_duration = {
	-- 	icon = "crystal_maiden_frostbite",
	-- 	cost = 1,
	-- 	group = 1,
	-- 	requirement = "crystal_maiden_frostbite",
	-- 	special_values = {value = 1.5},
	-- 	effect = {abilities = "special_bonus_unique_crystal_maiden_1"}
	-- },
	-- talent_hero_crystal_maiden_crystal_nova_damage = {
	-- 	icon = "crystal_maiden_crystal_nova",
	-- 	cost = 1,
	-- 	group = 1,
	-- 	requirement = "crystal_maiden_crystal_nova",
	-- 	special_values = {value = 300},
	-- 	effect = {abilities = "special_bonus_unique_crystal_maiden_2"}
	-- },
	talent_hero_drow_ranger_precision_aura_damage = {
		icon = "drow_ranger_trueshot",
		cost = 1,
		group = 6,
		requirement = "drow_ranger_trueshot",
		special_values = {value = 16},
		effect = {abilities = "special_bonus_unique_drow_ranger_1"}
	},
	talent_hero_drow_ranger_gust_distance = {
		icon = "drow_ranger_silence",
		cost = 1,
		group = 3,
		requirement = "drow_ranger_silence",
		special_values = {value = 400},
		effect = {abilities = "special_bonus_unique_drow_ranger_2"}
	},
	talent_hero_drow_ranger_marksmanship_agility = {
		icon = "drow_ranger_marksmanship",
		cost = 1,
		group = 9,
		requirement = "drow_ranger_marksmanship",
		special_values = {value = 100},
		effect = {abilities = "special_bonus_unique_drow_ranger_3"}
	},
	talent_hero_earthshaker_echo_slam_damage = {
		icon = "earthshaker_echo_slam",
		cost = 1,
		group = 6,
		requirement = "earthshaker_echo_slam",
		special_values = {value = 175},
		effect = {abilities = "special_bonus_unique_earthshaker_2"}
	},
	talent_hero_earthshaker_fissure_range = {
		icon = "earthshaker_fissure",
		cost = 1,
		group = 5,
		requirement = "earthshaker_fissure",
		special_values = {value = 600},
		effect = {abilities = "special_bonus_unique_earthshaker_3"}
	},
	talent_hero_earthshaker_enchant_totem_cooldown = {
		icon = "earthshaker_enchant_totem",
		cost = 1,
		group = 7,
		requirement = "earthshaker_enchant_totem",
		special_values = {value = 2},
		effect = {abilities = "special_bonus_unique_earthshaker"}
	},
	talent_hero_juggernaut_blade_fury_dps = {
		icon = "juggernaut_blade_fury",
		cost = 1,
		group = 6,
		requirement = "juggernaut_blade_fury",
		special_values = {value = 290},
		effect = {abilities = "special_bonus_unique_juggernaut"}
	},
	talent_hero_mirana_arrow_cooldown = {
		icon = "mirana_arrow",
		cost = 1,
		group = 7,
		requirement = "mirana_arrow",
		special_values = {value = 6},
		effect = {abilities = "special_bonus_unique_mirana_3"}
	},
	talent_hero_mirana_leap_attackspeed = {
		icon = "mirana_leap",
		cost = 1,
		group = 5,
		requirement = "mirana_leap",
		special_values = {value = 100},
		effect = {abilities = "special_bonus_unique_mirana_1"}
	},
	talent_hero_mirana_arrow_multi = {
		icon = "mirana_arrow",
		cost = 1,
		group = 6,
		requirement = "mirana_arrow",
		special_values = {value = 2},
		effect = {abilities = "special_bonus_unique_mirana_2"}
	},
	talent_hero_nevermore_necromastery_dmg = {
		icon = "nevermore_necromastery",
		cost = 1,
		group = 9,
		requirement = "nevermore_necromastery",
		special_values = {value = 2},
		effect = {abilities = "special_bonus_unique_nevermore_1"}
	},
	talent_hero_nevermore_shadowraze_dmg = {
		icon = "nevermore_shadowraze1",
		cost = 1,
		group = 6,
		requirement = "nevermore_shadowraze1",
		special_values = {value = 400},
		effect = {abilities = "special_bonus_unique_nevermore_2"}
	},
	talent_hero_morphling_waveform_range = {
		icon = "morphling_waveform",
		cost = 1,
		group = 5,
		requirement = "morphling_waveform",
		special_values = {value = 400},
		effect = {abilities = "special_bonus_unique_morphling_1"}
	},
	talent_hero_morphling_replicate_dmg = {
		icon = "morphling_replicate",
		cost = 1,
		group = 9,
		requirement = "morphling_replicate",
		special_values = {value = 120},
		effect = {abilities = "special_bonus_unique_morphling_2"}
	},
	-- talent_hero_phantom_lancer_spirit_lance_dmg = {
	-- 	icon = "phantom_lancer_spirit_lance",
	-- 	cost = 1,
	-- 	group = 1,
	-- 	requirement = "phantom_lancer_spirit_lance",
	-- 	special_values = {value = 75},
	-- 	effect = {abilities = "special_bonus_unique_phantom_lancer_2"}
	-- },
	-- talent_hero_phantom_lancer_phantom_edge_range = {
	-- 	icon = "phantom_lancer_phantom_edge",
	-- 	cost = 1,
	-- 	group = 1,
	-- 	requirement = "phantom_lancer_phantom_edge",
	-- 	special_values = {value = 600},
	-- 	effect = {abilities = "special_bonus_unique_phantom_lancer"}
	-- },
	talent_hero_puck_waning_rift_cd = {
		icon = "puck_waning_rift",
		cost = 1,
		group = 5,
		requirement = "puck_waning_rift",
		special_values = {value = 3},
		effect = {abilities = "special_bonus_unique_puck_2"}
	},
	talent_hero_puck_illusory_orb_distance = {
		icon = "puck_illusory_orb",
		cost = 1,
		group = 4,
		requirement = "puck_illusory_orb",
		special_values = {value = 75},
		effect = {abilities = "special_bonus_unique_puck"}
	},
	-- talent_hero_pudge_dismember_duration = {
	-- 	icon = "pudge_dismember",
	-- 	cost = 1,
	-- 	group = 1,
	-- 	requirement = "pudge_dismember",
	-- 	special_values = {value = 1},
	-- 	effect = {abilities = "special_bonus_unique_pudge_3"}
	-- },
	-- talent_hero_pudge_flesh_heap_str = {
	-- 	icon = "pudge_flesh_heap",
	-- 	cost = 1,
	-- 	group = 1,
	-- 	requirement = "pudge_flesh_heap",
	-- 	special_values = {value = 1.75},
	-- 	effect = {abilities = "special_bonus_unique_pudge_1"}
	-- },
	-- talent_hero_pudge_rot_damage = {
	-- 	icon = "pudge_rot",
	-- 	cost = 1,
	-- 	group = 1,
	-- 	requirement = "pudge_rot",
	-- 	special_values = {value = 120},
	-- 	effect = {abilities = "special_bonus_unique_pudge_2"}
	-- },
	talent_hero_razor_unstable_current_damage = {
		icon = "razor_unstable_current",
		cost = 1,
		group = 5,
		requirement = "razor_unstable_current",
		special_values = {value = 300},
		effect = {abilities = "special_bonus_unique_razor_2"}
	},
	talent_hero_razor_static_link_damage = {
		icon = "razor_static_link",
		cost = 1,
		group = 6,
		requirement = "razor_static_link",
		special_values = {value = 50},
		effect = {abilities = "special_bonus_unique_razor"}
	},
	talent_hero_sand_king_sand_storm_dps = {
		icon = "sandking_sand_storm",
		cost = 1,
		group = 5,
		requirement = "sandking_sand_storm",
		special_values = {value = 100},
		effect = {abilities = "special_bonus_unique_sand_king_2"}
	},
	talent_hero_sand_king_epicenter_attackslow = {
		icon = "sandking_epicenter",
		cost = 1,
		group = 6,
		requirement = "sandking_epicenter",
		special_values = {value = -110},
		effect = {abilities = "special_bonus_unique_sand_king_3"}
	},
	talent_hero_sand_king_epicenter_pulses = {
		icon = "sandking_epicenter",
		cost = 1,
		group = 7,
		requirement = "sandking_epicenter",
		special_values = {value = 6},
		effect = {abilities = "special_bonus_unique_sand_king"}
	},
	talent_hero_storm_spirit_electric_vortex_duration = {
		icon = "storm_spirit_electric_vortex",
		cost = 1,
		group = 5,
		requirement = "storm_spirit_electric_vortex",
		special_values = {value = 1.2},
		effect = {abilities = "special_bonus_unique_storm_spirit"}
	},
	talent_hero_sven_storm_bolt_cd = {
		icon = "sven_storm_bolt",
		cost = 1,
		group = 5,
		requirement = "sven_storm_bolt",
		special_values = {value = 8},
		effect = {abilities = "special_bonus_unique_sven"}
	},
	talent_hero_tiny_avalanche_dmg = {
		icon = "tiny_avalanche",
		cost = 1,
		group = 6,
		requirement = "tiny_avalanche",
		special_values = {value = 300},
		effect = {abilities = "special_bonus_unique_tiny"}
	},
	talent_hero_vengefulspirit_magic_missile_damage = {
		icon = "vengefulspirit_magic_missile",
		cost = 1,
		group = 6,
		requirement = "vengefulspirit_magic_missile",
		special_values = {value = 400},
		effect = {abilities = "special_bonus_unique_vengeful_spirit_1"}
	},
	talent_hero_vengefulspirit_command_aura_damage = {
		icon = "vengefulspirit_command_aura",
		cost = 1,
		group = 7,
		requirement = "vengefulspirit_command_aura",
		special_values = {value = 20},
		effect = {abilities = "special_bonus_unique_vengeful_spirit_2"}
	},
	talent_hero_vengefulspirit_magic_missile_immune = {
		icon = "vengefulspirit_magic_missile",
		cost = 1,
		group = 8,
		requirement = "vengefulspirit_magic_missile",
		special_values = {value = 0},
		effect = {abilities = "special_bonus_unique_vengeful_spirit_3"}
	},
	talent_hero_windrunner_windrun_slow = {
		icon = "windrunner_windrun",
		cost = 1,
		group = 4,
		requirement = "windrunner_windrun",
		special_values = {value = 30},
		effect = {abilities = "special_bonus_unique_windranger_2"}
	},
	talent_hero_windrunner_windrun_invis = {
		icon = "windrunner_windrun",
		cost = 1,
		group = 5,
		requirement = "windrunner_windrun",
		special_values = {value = 1},
		effect = {abilities = "special_bonus_unique_windranger"}
	},
	talent_hero_windrunner_powershot_damage = {
		icon = "windrunner_powershot",
		cost = 1,
		group = 6,
		requirement = "windrunner_powershot",
		special_values = {value = 434},
		effect = {abilities = "special_bonus_unique_windranger_3"}
	},
	talent_hero_zuus_arc_lightning_dmg = {
		icon = "zuus_arc_lightning",
		cost = 1,
		group = 5,
		requirement = "zuus_arc_lightning",
		special_values = {value = 160},
		effect = {abilities = "special_bonus_unique_zeus_2"}
	},
	talent_hero_zuus_lightning_bolt_ministun = {
		icon = "zuus_lightning_bolt",
		cost = 1,
		group = 4,
		requirement = "zuus_lightning_bolt",
		special_values = {value = 0.5},
		effect = {abilities = "special_bonus_unique_zeus_3"}
	},
	talent_hero_zuus_static_field_damage = {
		icon = "zuus_static_field",
		cost = 1,
		group = 6,
		requirement = "zuus_static_field",
		special_values = {value = 2.0},
		effect = {abilities = "special_bonus_unique_zeus"}
	},
	talent_hero_kunkka_torrent_damage = {
		icon = "kunkka_torrent",
		cost = 1,
		group = 7,
		requirement = "kunkka_torrent",
		special_values = {value = 400},
		effect = {abilities = "special_bonus_unique_kunkka_2"}
	},
	talent_hero_kunkka_torrent_aoe = {
		icon = "kunkka_torrent",
		cost = 1,
		group = 8,
		requirement = "kunkka_torrent",
		special_values = {value = 200},
		effect = {abilities = "special_bonus_unique_kunkka"}
	},
	talent_hero_lina_light_strike_array_damage = {
		icon = "lina_light_strike_array",
		cost = 1,
		group = 5,
		requirement = "lina_light_strike_damage",
		special_values = {value = 300},
		effect = {abilities = "special_bonus_unique_lina_3"}
	},
	talent_hero_lina_dragon_slave_cooldown = {
		icon = "lina_dragon_slave",
		cost = 1,
		group = 6,
		requirement = "lina_dragon_slave",
		special_values = {value = 4},
		effect = {abilities = "special_bonus_unique_lina_1"}
	},
	talent_hero_lina_fiery_soul_stack = {
		icon = "lina_fiery_soul",
		cost = 1,
		group = 5,
		requirement = "lina_fiery_soul",
		special_values = {value = 40},
		effect = {abilities = "special_bonus_unique_lina_2"}
	},
	talent_hero_lich_frost_nova_cd = {
		icon = "lich_frost_nova",
		cost = 1,
		group = 6,
		requirement = "lich_frost_nova",
		special_values = {value = 4},
		effect = {abilities = "special_bonus_unique_lich_3"}
	},
	talent_hero_lich_frost_armor_structure = {
		icon = "lich_frost_armor",
		cost = 1,
		group = 3,
		requirement = "lich_frost_armor",
		special_values = {value = 35},
		effect = {abilities = "special_bonus_unique_lich_1"}
	},
	talent_hero_npc_dota_hero_lich_slow = {
		icon = "lich/shearing_deposition/lich_frost_nova",
		cost = 1,
		group = 6,
		requirement = "npc_dota_hero_lich",
		special_values = {value = 30},
		effect = {abilities = "special_bonus_unique_lich_2"}
	},
	talent_hero_lion_impale_damage = {
		icon = "lion_impale",
		cost = 1,
		group = 6,
		requirement = "lion_impale",
		special_values = {value = 300},
		effect = {abilities = "special_bonus_unique_lion_2"}
	},
	talent_hero_lion_mana_drain_multi = {
		icon = "lion_mana_drain",
		cost = 1,
		group = 5,
		requirement = "lion_mana_drain",
		special_values = {value = 3},
		effect = {abilities = "special_bonus_unique_lion"}
	},
	talent_hero_shadow_shaman_mass_serpent_ward_summon = {
		icon = "shadow_shaman_mass_serpent_ward",
		cost = 1,
		group = 4,
		requirement = "shadow_shaman_mass_serpent_ward",
		special_values = {value = 4},
		effect = {abilities = "special_bonus_unique_shadow_shaman_4"}
	},
	talent_hero_shadow_shaman_shackles_duration = {
		icon = "shadow_shaman_shackles",
		cost = 1,
		group = 7,
		requirement = "shadow_shaman_shackles",
		special_values = {value = 1.5},
		effect = {abilities = "special_bonus_unique_shadow_shaman_2"}
	},
	talent_hero_shadow_shaman_mass_serpent_ward_attacks = {
		icon = "shadow_shaman_mass_serpent_ward",
		cost = 1,
		group = 3,
		requirement = "shadow_shaman_mass_serpent_ward",
		special_values = {value = 1},
		effect = {abilities = "special_bonus_unique_shadow_shaman_1"}
	},
	talent_hero_shadow_shaman_ether_shock_damage = {
		icon = "shadow_shaman_ether_shock",
		cost = 1,
		group = 6,
		requirement = "shadow_shaman_ether_shock",
		special_values = {value = 350},
		effect = {abilities = "special_bonus_unique_shadow_shaman_3"}
	},
	talent_hero_slardar_bash_chance = {
		icon = "slardar_bash",
		cost = 1,
		group = 7,
		requirement = "slardar_bash",
		special_values = {value = 10},
		effect = {abilities = "special_bonus_unique_slardar"}
	},
	talent_hero_tidehunter_gush_armor = {
		icon = "tidehunter_gush",
		cost = 1,
		group = 5,
		requirement = "tidehunter_gush",
		special_values = {value = 9},
		effect = {abilities = "special_bonus_unique_tidehunter"}
	},
	talent_hero_witch_doctor_paralyzing_cask_bounces = {
		icon = "witch_doctor_paralyzing_cask",
		cost = 1,
		group = 6,
		requirement = "witch_doctor_paralyzing_cask",
		special_values = {value = 6},
		effect = {abilities = "special_bonus_unique_witch_doctor_3"}
	},
	talent_hero_witch_doctor_death_ward_atkrange = {
		icon = "witch_doctor_death_ward",
		cost = 1,
		group = 7,
		requirement = "witch_doctor_death_ward",
		special_values = {value = 175},
		effect = {abilities = "special_bonus_unique_witch_doctor_1"}
	},
	talent_hero_witch_doctor_voodoo_restoration_heal = {
		icon = "witch_doctor_voodoo_restoration",
		cost = 1,
		group = 5,
		requirement = "witch_doctor_voodoo_restoration",
		special_values = {value = 80},
		effect = {abilities = "special_bonus_unique_witch_doctor_2"}
	},
	talent_hero_riki_permanent_invisibility_multiplier = {
		icon = "riki_permanent_invisibility",
		cost = 1,
		group = 6,
		requirement = "riki_permanent_invisibility",
		special_values = {value = 40},
		effect = {abilities = "special_bonus_unique_riki_1"}
	},
	talent_hero_riki_smoke_screen_cooldown = {
		icon = "riki_smoke_screen",
		cost = 1,
		group = 5,
		requirement = "riki_smoke_screen",
		special_values = {value = 4},
		effect = {abilities = "special_bonus_unique_riki_2"}
	},
	talent_hero_enigma_malefice_instance = {
		icon = "enigma_malefice",
		cost = 1,
		group = 6,
		requirement = "enigma_malefice",
		special_values = {value = 2},
		effect = {abilities = "special_bonus_unique_enigma_2"}
	},
	talent_hero_enigma_demonic_conversion_eidolons = {
		icon = "enigma_demonic_conversion",
		cost = 1,
		group = 3,
		requirement = "enigma_demonic_conversion",
		special_values = {value = 8},
		effect = {abilities = "special_bonus_unique_enigma"}
	},
	talent_hero_tinker_laser_damage = {
		icon = "tinker_laser",
		cost = 1,
		group = 7,
		requirement = "tinker_laser",
		special_values = {value = 400},
		effect = {abilities = "special_bonus_unique_tinker"}
	},
	talent_hero_sniper_shrapnel_dps = {
		icon = "sniper_shrapnel",
		cost = 1,
		group = 6,
		requirement = "sniper_shrapnel",
		special_values = {value = 100},
		effect = {abilities = "special_bonus_unique_sniper_1"}
	},
	talent_hero_sniper_shrapnel_charges = {
		icon = "sniper_shrapnel",
		cost = 1,
		group = 8,
		requirement = "sniper_shrapnel",
		special_values = {value = 4},
		effect = {abilities = "special_bonus_unique_sniper_2"}
	},
	talent_hero_necrolyte_death_pulse_cooldown = {
		icon = "necrolyte_death_pulse",
		cost = 1,
		group = 6,
		requirement = "necrolyte_death_pulse",
		special_values = {value = 3},
		effect = {abilities = "special_bonus_unique_necrophos"}
	},
	talent_hero_beastmaster_wild_axes_damage = {
		icon = "beastmaster_wild_axes",
		cost = 1,
		group = 5,
		requirement = "beastmaster_wild_axes",
		special_values = {value = 400},
		effect = {abilities = "special_bonus_unique_beastmaster"}
	},
	talent_hero_queenofpain_shadow_strike_aoe = {
		icon = "queenofpain_shadow_strike",
		cost = 1,
		group = 5,
		requirement = "queenofpain_shadow_strike",
		special_values = {value = 600},
		effect = {abilities = "special_bonus_unique_queen_of_pain"}
	},
	talent_hero_venomancer_poison_sting_slow = {
		icon = "venomancer_poison_sting",
		cost = 1,
		group = 5,
		requirement = "venomancer_poison_sting",
		special_values = {value = -14},
		effect = {abilities = "special_bonus_unique_venomancer_2"}
	},
	talent_hero_venomancer_plague_ward_hpdamage = {
		icon = "venomancer_plague_ward",
		cost = 1,
		group = 4,
		requirement = "venomancer_plague_ward",
		special_values = {value = 3},
		effect = {abilities = "special_bonus_unique_venomancer"}
	},
	-- talent_hero_faceless_void_time_walk_range = {
	-- 	icon = "faceless_void_time_walk",
	-- 	cost = 1,
	-- 	group = 1,
	-- 	requirement = "faceless_void_time_walk",
	-- 	special_values = {value = 600},
	-- 	effect = {abilities = "special_bonus_unique_faceless_void"}
	-- },
	talent_hero_skeleton_king_hellfire_blast_dps = {
		icon = "skeleton_king_hellfire_blast",
		cost = 1,
		group = 5,
		requirement = "skeleton_king_hellfire_blast",
		special_values = {value = 300},
		effect = {abilities = "special_bonus_unique_wraith_king_3"}
	},
	talent_hero_skeleton_king_vampiric_aura_lifesteal = {
		icon = "skeleton_king_vampiric_aura",
		cost = 1,
		group = 6,
		requirement = "skeleton_king_vampiric_aura",
		special_values = {value = 15},
		effect = {abilities = "special_bonus_unique_wraith_king_2"}
	},
	-- talent_hero_skeleton_king_reincarnation_manacost = {
	-- 	icon = "skeleton_king_reincarnation",
	-- 	cost = 1,
	-- 	group = 4,
	-- 	requirement = "skeleton_king_reincarnation",
	-- 	special_values = {value = 0},
	-- 	effect = {abilities = "special_bonus_unique_wraith_king_1"}
	-- },
	-- talent_hero_skeleton_king_reincarnation_blast = {
	-- 	icon = "skeleton_king_reincarnation",
	-- 	cost = 1,
	-- 	group = 5,
	-- 	requirement = "skeleton_king_reincarnation",
	-- 	special_values = {value = 1},
	-- 	effect = {abilities = "special_bonus_unique_wraith_king_4"}
	-- },
	talent_hero_death_prophet_carrion_swarm_cooldown = {
		icon = "death_prophet_carrion_swarm",
		cost = 1,
		group = 5,
		requirement = "death_prophet_carrion_swarm",
		special_values = {value = 1.5},
		effect = {abilities = "special_bonus_unique_death_prophet_2"}
	},
	talent_hero_death_prophet_exorcism_spirits = {
		icon = "death_prophet_exorcism",
		cost = 1,
		group = 8,
		requirement = "death_prophet_exorcism",
		special_values = {value = 22},
		effect = {abilities = "special_bonus_unique_death_prophet"}
	},
	talent_hero_phantom_assassin_stifling_dagger_double = {
		icon = "phantom_assassin_stifling_dagger",
		cost = 1,
		group = 5,
		requirement = "phantom_assassin_stifling_dagger",
		special_values = {value = 2},
		effect = {abilities = "special_bonus_unique_phantom_assassin"}
	},
	talent_hero_pugna_decrepify_duration = {
		icon = "pugna_decrepify",
		cost = 1,
		group = 4,
		requirement = "pugna_decrepify",
		special_values = {value = 1},
		effect = {abilities = "special_bonus_unique_pugna_5"}
	},
	talent_hero_pugna_netherblast_cooldown = {
		icon = "pugna_nether_blast",
		cost = 1,
		group = 5,
		requirement = "pugna_nether_blast",
		special_values = {value = 2},
		effect = {abilities = "special_bonus_unique_pugna_4"}
	},
	talent_hero_pugna_nether_ward_damage_mana = {
		icon = "pugna_nether_ward",
		cost = 1,
		group = 8,
		requirement = "pugna_nether_ward",
		special_values = {value = 0.75},
		effect = {abilities = "special_bonus_unique_pugna_3"}
	},
	talent_hero_pugna_life_drain_heal = {
		icon = "pugna_life_drain",
		cost = 1,
		group = 7,
		requirement = "pugna_life_drain",
		special_values = {value = 200},
		effect = {abilities = "special_bonus_unique_pugna_1"}
	},
	talent_hero_pugna_nether_blast_damage = {
		icon = "pugna_nether_blast",
		cost = 1,
		group = 6,
		requirement = "pugna_nether_blast",
		special_values = {value = 400},
		effect = {abilities = "special_bonus_unique_pugna_2"}
	},
	talent_hero_templar_assassin_meld_armor = {
		icon = "templar_assassin_meld",
		cost = 1,
		group = 6,
		requirement = "templar_assassin_meld",
		special_values = {value = -15},
		effect = {abilities = "special_bonus_unique_templar_assassin_2"}
	},
	talent_hero_templar_assassin_refraction_instances = {
		icon = "templar_assassin_refraction",
		cost = 1,
		group = 5,
		requirement = "templar_assassin_refraction",
		special_values = {value = 3},
		effect = {abilities = "special_bonus_unique_templar_assassin"}
	},
	talent_hero_viper_poison_attack_buildings = {
		icon = "viper_poison_attack",
		cost = 1,
		group = 2,
		requirement = "viper_poison_attack",
		special_values = {value = 0},
		effect = {abilities = "special_bonus_unique_viper_1"}
	},
	talent_hero_viper_viper_strike_dps = {
		icon = "viper_viper_strike",
		cost = 1,
		group = 9,
		requirement = "viper_viper_strike",
		special_values = {value = 400},
		effect = {abilities = "special_bonus_unique_viper_2"}
	},
	talent_hero_luna_lucent_beam_damage = {
		icon = "luna_lucent_beam",
		cost = 1,
		group = 5,
		requirement = "luna_lucent_beam",
		special_values = {value = 250},
		effect = {abilities = "special_bonus_unique_luna_1"}
	},
	talent_hero_luna_lucent_beam_cooldown = {
		icon = "luna_lucent_beam",
		cost = 1,
		group = 6,
		requirement = "luna_lucent_beam",
		special_values = {value = 4},
		effect = {abilities = "special_bonus_unique_luna_2"}
	},
	-- talent_hero_knight_dragon_blood_hp_regen_armor = {
	-- 	icon = "blood_hp_regen_armor",
	-- 	cost = 1,
	-- 	group = 1,
	-- 	requirement = "blood_hp_regen_armor",
	-- 	special_values = {value = 2},
	-- 	effect = {abilities = "special_bonus_unique_dragon_knight"}
	-- },
	talent_hero_dazzle_poison_touch_dps = {
		icon = "dazzle_poison_touch",
		cost = 1,
		group = 4,
		requirement = "dazzle_poison_touch",
		special_values = {value = 40},
		effect = {abilities = "special_bonus_unique_dazzle_3"}
	},
	talent_hero_dazzle_poison_touch_cooldown = {
		icon = "dazzle_poison_touch",
		cost = 1,
		group = 6,
		requirement = "dazzle_poison_touch",
		special_values = {value = 4},
		effect = {abilities = "special_bonus_unique_dazzle_1"}
	},
	talent_hero_dazzle_weave_heal = {
		icon = "dazzle_weave",
		cost = 1,
		group = 5,
		requirement = "dazzle_weave",
		special_values = {value = 400},
		effect = {abilities = "special_bonus_unique_dazzle_2"}
	},
	talent_hero_rattletrap_rocket_flare_damage = {
		icon = "rattletrap_rocket_flare",
		cost = 1,
		group = 5,
		requirement = "rattletrap_rocket_flare",
		special_values = {value = 250},
		effect = {abilities = "special_bonus_unique_clockwerk_2"}
	},
	talent_hero_rattletrap_battery_assault_damage = {
		icon = "rattletrap_battery_assault",
		cost = 1,
		group = 6,
		requirement = "rattletrap_battery_assault",
		special_values = {value = 40},
		effect = {abilities = "special_bonus_unique_clockwerk_3"}
	},
	talent_hero_rattletrap_battery_assault_duration = {
		icon = "rattletrap_battery_assault",
		cost = 1,
		group = 7,
		requirement = "rattletrap_battery_assault",
		special_values = {value = 5},
		effect = {abilities = "special_bonus_unique_clockwerk"}
	},
	talent_hero_leshrac_diabolic_edict_explosions = {
		icon = "leshrac_diabolic_edict",
		cost = 1,
		group = 7,
		requirement = "leshrac_diabolic_edict",
		special_values = {value = 160},
		effect = {abilities = "special_bonus_unique_leshrac_1"}
	},
	talent_hero_leshrac_lightning_storm_duration = {
		icon = "leshrac_lightning_storm",
		cost = 1,
		group = 6,
		requirement = "leshrac_lightning_storm",
		special_values = {value = 1},
		effect = {abilities = "special_bonus_unique_leshrac_2"}
	},
	-- talent_hero_furion_force_of_nature_summon = {
	-- 	icon = "furion_force_of_nature",
	-- 	cost = 1,
	-- 	group = 4,
	-- 	requirement = "furion_force_of_nature",
	-- 	special_values = {value = 4},
	-- 	effect = {abilities = "special_bonus_unique_furion_2"}
	-- },
	talent_hero_furion_teleportation_nocd = {
		icon = "furion_teleportation",
		cost = 1,
		group = 9,
		requirement = "furion_teleportation",
		special_values = {value = 1},
		effect = {abilities = "special_bonus_unique_furion_3"}
	},
	-- talent_hero_furion_force_of_nature_treants = {
	-- 	icon = "furion_force_of_nature",
	-- 	cost = 1,
	-- 	group = 3,
	-- 	requirement = "furion_force_of_nature",
	-- 	special_values = {value = 6},
	-- 	effect = {abilities = "special_bonus_unique_furion"}
	-- },
	talent_hero_life_stealer_rage_duration = {
		icon = "life_stealer_rage",
		cost = 1,
		group = 9,
		requirement = "life_stealer_rage",
		special_values = {value = 2},
		effect = {abilities = "special_bonus_unique_lifestealer"}
	},
	talent_hero_dark_seer_vacuum_aoe = {
		icon = "dark_seer_vacuum",
		cost = 1,
		group = 3,
		requirement = "dark_seer_vacuum",
		special_values = {value = 75},
		effect = {abilities = "special_bonus_unique_dark_seer_2"}
	},
	talent_hero_dark_seer_ion_shell_dmg = {
		icon = "dark_seer_ion_shell",
		cost = 1,
		group = 6,
		requirement = "dark_seer_ion_shell",
		special_values = {value = 220},
		effect = {abilities = "special_bonus_unique_dark_seer"}
	},
	talent_hero_clinkz_searing_arrows_dmg = {
		icon = "clinkz_searing_arrows",
		cost = 1,
		group = 6,
		requirement = "clinkz_searing_arrows",
		special_values = {value = 110},
		effect = {abilities = "special_bonus_unique_clinkz_1"}
	},
	talent_hero_clinkz_strafe_as = {
		icon = "clinkz_strafe",
		cost = 1,
		group = 5,
		requirement = "clinkz_strafe",
		special_values = {value = 70},
		effect = {abilities = "special_bonus_unique_clinkz_2"}
	},
	-- talent_hero_omniknight_purification_dmg = {
	-- 	icon = "omniknight_purification",
	-- 	cost = 1,
	-- 	group = 1,
	-- 	requirement = "omniknight_purification",
	-- 	special_values = {value = 200},
	-- 	effect = {abilities = "special_bonus_unique_omniknight_1"}
	-- },
	-- talent_hero_omniknight_degen_aura_slow = {
	-- 	icon = "omniknight_degen_aura",
	-- 	cost = 1,
	-- 	group = 1,
	-- 	requirement = "omniknight_degen_aura",
	-- 	special_values = {value = -16},
	-- 	effect = {abilities = "special_bonus_unique_omniknight_2"}
	-- },
	talent_hero_enchantress_natures_attendants_wisps = {
		icon = "enchantress_natures_attendants",
		cost = 1,
		group = 4,
		requirement = "enchantress_natures_attendants",
		special_values = {value = 8},
		effect = {abilities = "special_bonus_unique_enchantress_2"}
	},
	talent_hero_enchantress_untouchable_slow = {
		icon = "enchantress_untouchable",
		cost = 1,
		group = 7,
		requirement = "enchantress_untouchable",
		special_values = {value = 350},
		effect = {abilities = "special_bonus_unique_enchantress_3"}
	},
	talent_hero_enchantress_impetus_dmg = {
		icon = "enchantress_impetus",
		cost = 1,
		group = 6,
		requirement = "enchantress_impetus",
		special_values = {value = 20},
		effect = {abilities = "special_bonus_unique_enchantress_4"}
	},
	talent_hero_enchantress_enchant_ancients = {
		icon = "enchantress_enchant",
		cost = 1,
		group = 5,
		requirement = "enchantress_enchant",
		special_values = {value = 1},
		effect = {abilities = "special_bonus_unique_enchantress_1"}
	},
	talent_hero_huskar_life_break_castrange = {
		icon = "huskar_life_break",
		cost = 1,
		group = 6,
		requirement = "huskar_life_break",
		special_values = {value = 500},
		effect = {abilities = "special_bonus_unique_huskar"}
	},
	talent_hero_night_stalker_crippling_fear_cd = {
		icon = "night_stalker_crippling_fear",
		cost = 1,
		group = 8,
		requirement = "night_stalker_crippling_fear",
		special_values = {value = 8},
		effect = {abilities = "special_bonus_unique_night_stalker"}
	},
	talent_hero_broodmother_spawn_spiderlings_dmg = {
		icon = "broodmother_spawn_spiderlings",
		cost = 1,
		group = 5,
		requirement = "broodmother_spawn_spiderlings",
		special_values = {value = 300},
		effect = {abilities = "special_bonus_unique_broodmother_3"}
	},
	talent_hero_broodmother_spawn_spiderite_dmg = {
		icon = "broodmother_spawn_spiderite",
		cost = 1,
		group = 6,
		requirement = "broodmother_spawn_spiderite",
		special_values = {value = 12},
		effect = {abilities = "special_bonus_unique_broodmother_4"}
	},
	talent_hero_broodmother_spin_web_count = {
		icon = "broodmother_spin_web",
		cost = 1,
		group = 8,
		requirement = "broodmother_spin_web",
		special_values = {value = 19},
		effect = {abilities = "special_bonus_unique_broodmother_1"}
	},
	talent_hero_broodmother_spawn_spiderite_hp = {
		icon = "broodmother_spawn_spiderite",
		cost = 1,
		group = 3,
		requirement = "broodmother_spawn_spiderite",
		special_values = {value = 225},
		effect = {abilities = "special_bonus_unique_broodmother_2"}
	},
	talent_hero_bounty_hunter_shuriken_toss_dmg = {
		icon = "bounty_hunter_shuriken_toss",
		cost = 1,
		group = 6,
		requirement = "bounty_hunter_shuriken_toss",
		special_values = {value = 300},
		effect = {abilities = "special_bonus_unique_bounty_hunter_2"}
	},
	talent_hero_bounty_hunter_jinada_cd = {
		icon = "bounty_hunter_jinada",
		cost = 1,
		group = 8,
		requirement = "bounty_hunter_jinada",
		special_values = {value = 3.5},
		effect = {abilities = "special_bonus_unique_bounty_hunter"}
	},
	talent_hero_weaver_shukuchi_dmg = {
		icon = "weaver_shukuchi",
		cost = 1,
		group = 5,
		requirement = "weaver_shukuchi",
		special_values = {value = 200},
		effect = {abilities = "special_bonus_unique_weaver_1"}
	},
	talent_hero_weaver_shukuchi_speed = {
		icon = "weaver_shukuchi",
		cost = 1,
		group = 6,
		requirement = "weaver_shukuchi",
		special_values = {value = 200},
		effect = {abilities = "special_bonus_unique_weaver_2"}
	},
	talent_hero_jakiro_dual_breath_dmg = {
		icon = "jakiro_dual_breath",
		cost = 1,
		group = 6,
		requirement = "jakiro_dual_breath",
		special_values = {value = 100},
		effect = {abilities = "special_bonus_unique_jakiro_2"}
	},
	talent_hero_jakiro_macropyre_pure = {
		icon = "jakiro_macropyre",
		cost = 1,
		group = 9,
		requirement = "jakiro_macropyre",
		special_values = {value = 1},
		effect = {abilities = "special_bonus_unique_jakiro_3"}
	},
	talent_hero_jakiro_ice_path_duration = {
		icon = "jakiro_ice_path",
		cost = 1,
		group = 4,
		requirement = "jakiro_ice_path",
		special_values = {value = 1.25},
		effect = {abilities = "special_bonus_unique_jakiro"}
	},
	talent_hero_batrider_firefly_duration = {
		icon = "batrider_firefly",
		cost = 1,
		group = 5,
		requirement = "batrider_firefly",
		special_values = {value = 8},
		effect = {abilities = "special_bonus_unique_batrider_1"}
	},
	talent_hero_batrider_flamebreak_aoe = {
		icon = "batrider_flamebreak",
		cost = 1,
		group = 6,
		requirement = "batrider_flamebreak",
		special_values = {value = 300},
		effect = {abilities = "special_bonus_unique_batrider_2"}
	},
	talent_hero_chen_test_of_faith_cd = {
		icon = "chen_test_of_faith",
		cost = 1,
		group = 4,
		requirement = "chen_test_of_faith",
		special_values = {value = 8},
		effect = {abilities = "special_bonus_unique_chen_3"}
	},
	talent_hero_chen_holy_persuasion_hp = {
		icon = "chen_holy_persuasion",
		cost = 1,
		group = 6,
		requirement = "chen_holy_persuasion",
		special_values = {value = 7500},
		effect = {abilities = "special_bonus_unique_chen_4"}
	},
	talent_hero_chen_holy_persuasion_count = {
		icon = "chen_holy_persuasion",
		cost = 1,
		group = 5,
		requirement = "chen_holy_persuasion",
		special_values = {value = 2},
		effect = {abilities = "special_bonus_unique_chen_1"}
	},
	talent_hero_chen_hand_of_god_heal = {
		icon = "chen_hand_of_god",
		cost = 1,
		group = 9,
		requirement = "chen_hand_of_god",
		special_values = {value = 15000},
		effect = {abilities = "special_bonus_unique_chen_2"}
	},
	talent_hero_spectre_spectral_dagger_cd = {
		icon = "spectre_spectral_dagger",
		cost = 1,
		group = 6,
		requirement = "spectre_spectral_dagger",
		special_values = {value = 7},
		effect = {abilities = "special_bonus_unique_spectre"}
	},
	-- talent_hero_special_bonus_unique_doom_3 = {
	-- 	icon = "special_bonus_unique_doom_3",
	-- 	cost = 1,
	-- 	group = 1,
	-- 	requirement = "special_bonus_unique_doom_3",
	-- 	special_values = {value = 80},
	-- 	effect = {abilities = "special_bonus_unique_doom_3"}
	-- },
	talent_hero_doom_bringer_scorched_earth_dmg = {
		icon = "doom_bringer_scorched_earth",
		cost = 1,
		group = 8,
		requirement = "doom_bringer_scorched_earth",
		special_values = {value = 130},
		effect = {abilities = "special_bonus_unique_doom_4"}
	},
	talent_hero_doom_bringer_doom_dps = {
		icon = "doom_bringer_doom",
		cost = 1,
		group = 6,
		requirement = "doom_bringer_doom",
		special_values = {value = 100},
		effect = {abilities = "special_bonus_unique_doom_5"}
	},
	-- talent_hero_special_bonus_unique_doom_2 = {
	-- 	icon = "special_bonus_unique_doom_2",
	-- 	cost = 1,
	-- 	group = 1,
	-- 	requirement = "special_bonus_unique_doom_2",
	-- 	special_values = {value = 0},
	-- 	effect = {abilities = "special_bonus_unique_doom_2"}
	-- },
	talent_hero_doom_bringer_infernal_blade_dmg = {
		icon = "doom_bringer_infernal_blade",
		cost = 1,
		group = 5,
		requirement = "doom_bringer_infernal_blade",
		special_values = {value = 2},
		effect = {abilities = "special_bonus_unique_doom_1"}
	},
	talent_hero_ancient_apparition_ice_vortex_cd = {
		icon = "ancient_apparition_ice_vortex",
		cost = 1,
		group = 6,
		requirement = "ancient_apparition_ice_vortex",
		special_values = {value = 1},
		effect = {abilities = "special_bonus_unique_ancient_apparition_3"}
	},
	talent_hero_ancient_apparition_ice_vortex_slow = {
		icon = "ancient_apparition_ice_vortex",
		cost = 1,
		group = 5,
		requirement = "ancient_apparition_ice_vortex",
		special_values = {value = -12},
		effect = {abilities = "special_bonus_unique_ancient_apparition_4"}
	},
	talent_hero_ancient_apparition_cold_feet_charges = {
		icon = "ancient_apparition_cold_feet",
		cost = 1,
		group = 5,
		requirement = "ancient_apparition_cold_feet",
		special_values = {value = 4},
		effect = {abilities = "special_bonus_unique_ancient_apparition_1"}
	},
	talent_hero_ancient_apparition_chilling_touch_dmg = {
		icon = "ancient_apparition_chilling_touch",
		cost = 1,
		group = 8,
		requirement = "ancient_apparition_chilling_touch",
		special_values = {value = 300},
		effect = {abilities = "special_bonus_unique_ancient_apparition_2"}
	},
	talent_hero_ursa_fury_swipes_dmg = {
		icon = "ursa_fury_swipes",
		cost = 1,
		group = 6,
		requirement = "ursa_fury_swipes",
		special_values = {value = 35},
		effect = {abilities = "special_bonus_unique_ursa"}
	},
	talent_hero_spirit_breaker_greater_bash_dmg = {
		icon = "spirit_breaker_greater_bash",
		cost = 1,
		group = 6,
		requirement = "spirit_breaker_greater_bash",
		special_values = {value = 30},
		effect = {abilities = "special_bonus_unique_spirit_breaker_3"}
	},
	talent_hero_spirit_breaker_greater_bash_chance = {
		icon = "spirit_breaker_greater_bash",
		cost = 1,
		group = 8,
		requirement = "spirit_breaker_greater_bash",
		special_values = {value = 17},
		effect = {abilities = "special_bonus_unique_spirit_breaker_1"}
	},
	talent_hero_spirit_breaker_charge_of_darkness_charge = {
		icon = "spirit_breaker_charge_of_darkness",
		cost = 1,
		group = 5,
		requirement = "spirit_breaker_charge_of_darkness",
		special_values = {value = 500},
		effect = {abilities = "special_bonus_unique_spirit_breaker_2"}
	},
	-- talent_hero_special_bonus_unique_gyrocopter_1 = {
	-- 	icon = "special_bonus_unique_gyrocopter_1",
	-- 	cost = 1,
	-- 	group = 1,
	-- 	requirement = "special_bonus_unique_gyrocopter_1",
	-- 	special_values = {value = 3},
	-- 	effect = {abilities = "special_bonus_unique_gyrocopter_1"}
	-- },
	-- talent_hero_special_bonus_unique_gyrocopter_2 = {
	-- 	icon = "special_bonus_unique_gyrocopter_2",
	-- 	cost = 1,
	-- 	group = 1,
	-- 	requirement = "special_bonus_unique_gyrocopter_2",
	-- 	special_values = {value = 4},
	-- 	effect = {abilities = "special_bonus_unique_gyrocopter_2"}
	-- },
	talent_hero_alchemist_unstable_concoction_dmg = {
		icon = "alchemist_unstable_concoction",
		cost = 1,
		group = 6,
		requirement = "alchemist_unstable_concoction",
		special_values = {value = 300},
		effect = {abilities = "special_bonus_unique_alchemist_2"}
	},
	talent_hero_alchemist_acid_spray_armor = {
		icon = "alchemist_acid_spray",
		cost = 1,
		group = 5,
		requirement = "alchemist_acid_spray",
		special_values = {value = 12},
		effect = {abilities = "special_bonus_unique_alchemist"}
	},
	talent_hero_invoker_forge_spirit_summon = {
		icon = "invoker_forge_spirit",
		cost = 1,
		group = 4,
		requirement = "invoker_forge_spirit",
		special_values = {value = 3},
		effect = {abilities = "special_bonus_unique_invoker_1"}
	},
	talent_hero_invoker_deafening_blast_aoe = {
		icon = "invoker_deafening_blast",
		cost = 1,
		group = 6,
		requirement = "invoker_deafening_blast",
		special_values = {value = 0},
		effect = {abilities = "special_bonus_unique_invoker_2"}
	},
	talent_hero_invoker_tornado_cd = {
  		icon = "invoker_tornado",
 		cost = 1,
  		group = 7,
  		requirement = "invoker_tornado",
  		special_values = {value = 14},
 		effect = {abilities = "special_bonus_unique_invoker_3"}
 	},
	talent_hero_silencer_curse_of_the_silent_slow = {
		icon = "silencer_curse_of_the_silent",
		cost = 1,
		group = 5,
		requirement = "silencer_curse_of_the_silent",
		special_values = {value = -10},
		effect = {abilities = "special_bonus_unique_silencer"}
	},
	talent_hero_obsidian_destroyer_arcane_orb_steal = {
		icon = "obsidian_destroyer_arcane_orb",
		cost = 1,
		group = 9,
		requirement = "obsidian_destroyer_arcane_orb",
		special_values = {value = 60},
		effect = {abilities = "special_bonus_unique_outworld_devourer"}
	},
	talent_hero_lycan_feral_impulse_regen = {
		icon = "lycan_feral_impulse",
		cost = 1,
		group = 6,
		requirement = "lycan_feral_impulse",
		special_values = {value = 32},
		effect = {abilities = "special_bonus_unique_lycan_3"}
	},
	talent_hero_lycan_shapeshift_duration = {
		icon = "lycan_shapeshift",
		cost = 1,
		group = 9,
		requirement = "lycan_shapeshift",
		special_values = {value = 10},
		effect = {abilities = "special_bonus_unique_lycan_1"}
	},
	-- talent_hero_special_bonus_unique_lycan_2 = {
	-- 	icon = "special_bonus_unique_lycan_2",
	-- 	cost = 1,
	-- 	group = 1,
	-- 	requirement = "special_bonus_unique_lycan_2",
	-- 	special_values = {value = 2},
	-- 	effect = {abilities = "special_bonus_unique_lycan_2"}
	-- },
	talent_hero_brewmaster_thunder_clap_dmg = {
		icon = "brewmaster_thunder_clap",
		cost = 1,
		group = 6,
		requirement = "brewmaster_thunder_clap",
		special_values = {value = 400},
		effect = {abilities = "special_bonus_unique_brewmaster_2"}
	},
	talent_hero_brewmaster_thunder_clap_slow = {
		icon = "brewmaster_thunder_clap",
		cost = 1,
		group = 5,
		requirement = "brewmaster_thunder_clap",
		special_values = {value = 2},
		effect = {abilities = "special_bonus_unique_brewmaster_3"}
	},
	talent_hero_brewmaster_primal_split_health = {
		icon = "brewmaster_primal_split",
		cost = 1,
		group = 7,
		requirement = "brewmaster_primal_split",
		special_values = {value = 2000},
		effect = {abilities = "special_bonus_unique_brewmaster"}
	},
	talent_hero_shadow_demon_shadow_poison_cd = {
		icon = "shadow_demon_shadow_poison",
		cost = 1,
		group = 7,
		requirement = "shadow_demon_shadow_poison",
		special_values = {value = 1.5},
		effect = {abilities = "special_bonus_unique_shadow_demon_3"}
	},
	talent_hero_shadow_demon_demonic_purge_dmg = {
		icon = "shadow_demon_demonic_purge",
		cost = 1,
		group = 8,
		requirement = "shadow_demon_demonic_purge",
		special_values = {value = 400},
		effect = {abilities = "special_bonus_unique_shadow_demon_1"}
	},
	talent_hero_shadow_demon_soul_catcher_cd = {
		icon = "shadow_demon_soul_catcher",
		cost = 1,
		group = 6,
		requirement = "shadow_demon_soul_catcher",
		special_values = {value = 10},
		effect = {abilities = "special_bonus_unique_shadow_demon_2"}
	},
	talent_hero_lone_druid_spirit_bear_dmg = {
		icon = "lone_druid_spirit_bear",
		cost = 1,
		group = 6,
		requirement = "lone_druid_spirit_bear",
		special_values = {value = 150},
		effect = {abilities = "special_bonus_unique_lone_druid_1"}
	},
	talent_hero_lone_druid_spirit_bear_armor = {
		icon = "lone_druid_spirit_bear",
		cost = 1,
		group = 5,
		requirement = "lone_druid_spirit_bear",
		special_values = {value = 12},
		effect = {abilities = "special_bonus_unique_lone_druid_2"}
	},
	talent_hero_lone_druid_spirit_bear_resist = {
		icon = "lone_druid_spirit_bear",
		cost = 1,
		group = 7,
		requirement = "lone_druid_spirit_bear",
		special_values = {value = 50},
		effect = {abilities = "special_bonus_unique_lone_druid_5"}
	},
	talent_hero_lone_druid_spirit_bear_duration = {
		icon = "lone_druid_spirit_bear",
		cost = 1,
		group = 8,
		requirement = "lone_druid_spirit_bear",
		special_values = {value = 1},
		effect = {abilities = "special_bonus_unique_lone_druid_3"}
	},
	talent_hero_lone_druid_savage_roar_cd = {
		icon = "lone_druid_savage_roar",
		cost = 1,
		group = 9,
		requirement = "lone_druid_savage_roar",
		special_values = {value = 10},
		effect = {abilities = "special_bonus_unique_lone_druid_4"}
	},
	talent_hero_chaos_knight_reality_rift_immune = {
		icon = "chaos_knight_reality_rift",
		cost = 1,
		group = 9,
		requirement = "chaos_knight_reality_rift",
		special_values = {value = 0},
		effect = {abilities = "special_bonus_unique_chaos_knight"}
	},
	talent_hero_meepo_poof_cd = {
		icon = "meepo_poof",
		cost = 1,
		group = 8,
		requirement = "meepo_poof",
		special_values = {value = 3},
		effect = {abilities = "special_bonus_unique_meepo"}
	},
	talent_hero_treant_leech_seed_dmg = {
		icon = "treant_leech_seed",
		cost = 1,
		group = 6,
		requirement = "treant_leech_seed",
		special_values = {value = 200},
		effect = {abilities = "special_bonus_unique_treant_2"}
	},
	talent_hero_treant_living_armor_instances = {
		icon = "treant_living_armor",
		cost = 1,
		group = 5,
		requirement = "treant_living_armor",
		special_values = {value = 15},
		effect = {abilities = "special_bonus_unique_treant"}
	},
	talent_hero_ogre_magi_bloodlust_as = {
		icon = "ogre_magi_bloodlust",
		cost = 1,
		group = 5,
		requirement = "ogre_magi_bloodlust",
		special_values = {value = 110},
		effect = {abilities = "special_bonus_unique_ogre_magi"}
	},
	talent_hero_undying_tombstone_dmg = {
		icon = "undying_tombstone",
		cost = 1,
		group = 3,
		requirement = "undying_tombstone",
		special_values = {value = 50},
		effect = {abilities = "special_bonus_unique_undying"}
	},
	talent_hero_undying_decay_cd = {
		icon = "undying_decay",
		cost = 1,
		group = 6,
		requirement = "undying_decay",
		special_values = {value = 2},
		effect = {abilities = "special_bonus_unique_undying_2"}
	},
	-- talent_hero_special_bonus_unique_rubick = {
	-- 	icon = "special_bonus_unique_rubick",
	-- 	cost = 1,
	-- 	group = 1,
	-- 	requirement = "special_bonus_unique_rubick",
	-- 	special_values = {value = 400},
	-- 	effect = {abilities = "special_bonus_unique_rubick"}
	-- },
	talent_hero_disruptor_kinetic_field_cd = {
		icon = "disruptor_kinetic_field",
		cost = 1,
		group = 5,
		requirement = "disruptor_kinetic_field",
		special_values = {value = 3},
		effect = {abilities = "special_bonus_unique_disruptor_2"}
	},
	talent_hero_disruptor_thunder_strike_dmg = {
		icon = "disruptor_thunder_strike",
		cost = 1,
		group = 6,
		requirement = "disruptor_thunder_strike",
		special_values = {value = 200},
		effect = {abilities = "special_bonus_unique_disruptor_3"}
	},
	talent_hero_disruptor_thunder_strike_hits = {
		icon = "disruptor_thunder_strike",
		cost = 1,
		group = 7,
		requirement = "disruptor_thunder_strike",
		special_values = {value = 4},
		effect = {abilities = "special_bonus_unique_disruptor"}
	},
	talent_hero_nyx_assassin_impale_dmg = {
		icon = "nyx_assassin_impale",
		cost = 1,
		group = 7,
		requirement = "nyx_assassin_impale",
		special_values = {value = 400},
		effect = {abilities = "special_bonus_unique_nyx_2"}
	},
	talent_hero_nyx_assassin_spiked_carapace_dmg = {
		icon = "nyx_assassin_spiked_carapace",
		cost = 1,
		group = 6,
		requirement = "nyx_assassin_spiked_carapace",
		special_values = {value = 200},
		effect = {abilities = "special_bonus_unique_nyx"}
	},
	talent_hero_naga_siren_ensnare_cd = {
		icon = "naga_siren_ensnare",
		cost = 1,
		group = 6,
		requirement = "naga_siren_ensnare",
		special_values = {value = 3},
		effect = {abilities = "special_bonus_unique_naga_siren_2"}
	},
	talent_hero_naga_siren_mirror_image_illu = {
		icon = "naga_siren_mirror_image",
		cost = 1,
		group = 9,
		requirement = "naga_siren_mirror_image",
		special_values = {value = 1},
		effect = {abilities = "special_bonus_unique_naga_siren"}
	},
	talent_hero_keeper_of_the_light_chakra_magic_mana = {
		icon = "keeper_of_the_light_chakra_magic",
		cost = 1,
		group = 9,
		requirement = "keeper_of_the_light_chakra_magic",
		special_values = {value = 3000},
		effect = {abilities = "special_bonus_unique_keeper_of_the_light_2"}
	},
	talent_hero_keeper_of_the_light_illuminate_dmg = {
		icon = "keeper_of_the_light_illuminate",
		cost = 1,
		group = 8,
		requirement = "keeper_of_the_light_illuminate",
		special_values = {value = 500},
		effect = {abilities = "special_bonus_unique_keeper_of_the_light"}
	},
	-- talent_hero_special_bonus_unique_wisp_2 = {
	-- 	icon = "special_bonus_unique_wisp_2",
	-- 	cost = 1,
	-- 	group = 1,
	-- 	requirement = "special_bonus_unique_wisp_2",
	-- 	special_values = {value = 1},
	-- 	effect = {abilities = "special_bonus_unique_wisp_2"}
	-- },
	-- talent_hero_special_bonus_unique_wisp = {
	-- 	icon = "special_bonus_unique_wisp",
	-- 	cost = 1,
	-- 	group = 1,
	-- 	requirement = "special_bonus_unique_wisp",
	-- 	special_values = {value = 150},
	-- 	effect = {abilities = "special_bonus_unique_wisp"}
	-- },
	talent_hero_visage_soul_assumption_double = {
		icon = "visage_soul_assumption",
		cost = 1,
		group = 6,
		requirement = "visage_soul_assumption",
		special_values = {value = 2},
		effect = {abilities = "special_bonus_unique_visage_3"}
	},
	talent_hero_visage_summon_familiars_speed = {
		icon = "visage_summon_familiars",
		cost = 1,
		group = 5,
		requirement = "visage_summon_familiars",
		special_values = {value = 120},
		effect = {abilities = "special_bonus_unique_visage_2"}
	},
	talent_hero_slark_pounce_duration = {
		icon = "slark_pounce",
		cost = 1,
		group = 5,
		requirement = "slark_pounce",
		special_values = {value = 1.5},
		effect = {abilities = "special_bonus_unique_slark"}
	},
	-- talent_hero_special_bonus_unique_medusa_2 = {
	-- 	icon = "special_bonus_unique_medusa_2",
	-- 	cost = 1,
	-- 	group = 1,
	-- 	requirement = "special_bonus_unique_medusa_2",
	-- 	special_values = {value = 1},
	-- 	effect = {abilities = "special_bonus_unique_medusa_2"}
	-- },
	-- talent_hero_special_bonus_unique_medusa = {
	-- 	icon = "special_bonus_unique_medusa",
	-- 	cost = 1,
	-- 	group = 1,
	-- 	requirement = "special_bonus_unique_medusa",
	-- 	special_values = {value = 2},
	-- 	effect = {abilities = "special_bonus_unique_medusa"}
	-- },
	talent_hero_troll_warlord_whirling_axes_melee_cd = {
		icon = "troll_warlord_whirling_axes_melee",
		cost = 1,
		group = 5,
		requirement = "troll_warlord_whirling_axes_melee",
		special_values = {value = 7},
		effect = {abilities = "special_bonus_unique_troll_warlord"}
	},
	talent_hero_centaur_return_aura = {
		icon = "centaur_return",
		cost = 1,
		group = 9,
		requirement = "centaur_return",
		special_values = {value = 1},
		effect = {abilities = "special_bonus_unique_centaur_1"}
	},
	talent_hero_centaur_hoof_stomp_duration = {
		icon = "centaur_hoof_stomp",
		cost = 1,
		group = 6,
		requirement = "centaur_hoof_stomp",
		special_values = {value = 1},
		effect = {abilities = "special_bonus_unique_centaur_2"}
	},
	talent_hero_magnataur_empower_dmg = {
		icon = "magnataur_empower",
		cost = 1,
		group = 6,
		requirement = "magnataur_empower",
		special_values = {value = 15},
		effect = {abilities = "special_bonus_unique_magnus_2"}
	},
	talent_hero_magnataur_skewer_range = {
		icon = "magnataur_skewer",
		cost = 1,
		group = 5,
		requirement = "magnataur_skewer",
		special_values = {value = 500},
		effect = {abilities = "special_bonus_unique_magnus_3"}
	},
	talent_hero_shredder_whirling_death_attribute = {
		icon = "shredder_whirling_death",
		cost = 1,
		group = 6,
		requirement = "shredder_whirling_death",
		special_values = {value = 6},
		effect = {abilities = "special_bonus_unique_timbersaw"}
	},
	talent_hero_bristleback_viscous_nasal_goo_count = {
		icon = "bristleback_viscous_nasal_goo",
		cost = 1,
		group = 6,
		requirement = "bristleback_viscous_nasal_goo",
		special_values = {value = 4},
		effect = {abilities = "special_bonus_unique_bristleback"}
	},
	talent_hero_bristleback_quill_spray_dmg = {
		icon = "bristleback_quill_spray",
		cost = 1,
		group = 6,
		requirement = "bristleback_quill_spray",
		special_values = {value = 120},
		effect = {abilities = "special_bonus_unique_bristleback_2"}
	},
	talent_hero_tusk_snowball_dmg = {
		icon = "tusk_snowball",
		cost = 1,
		group = 6,
		requirement = "tusk_snowball",
		special_values = {value = 400},
		effect = {abilities = "special_bonus_unique_tusk_2"}
	},
	talent_hero_tusk_walrus_punch_crit = {
		icon = "tusk_walrus_punch",
		cost = 1,
		group = 9,
		requirement = "tusk_walrus_punch",
		special_values = {value = 150},
		effect = {abilities = "special_bonus_unique_tusk"}
	},
	talent_hero_skywrath_mage_ancient_seal_cd = {
		icon = "skywrath_mage_ancient_seal",
		cost = 1,
		group = 6,
		requirement = "skywrath_mage_ancient_seal",
		special_values = {value = 4},
		effect = {abilities = "special_bonus_unique_skywrath"}
	},
	talent_hero_abaddon_aphotic_shield_dmg = {
		icon = "abaddon_aphotic_shield",
		cost = 1,
		group = 6,
		requirement = "abaddon_aphotic_shield",
		special_values = {value = 600},
		effect = {abilities = "special_bonus_unique_abaddon"}
	},
	talent_hero_elder_titan_echo_stomp_dmg = {
		icon = "elder_titan_echo_stomp",
		cost = 1,
		group = 6,
		requirement = "elder_titan_echo_stomp",
		special_values = {value = 300},
		effect = {abilities = "special_bonus_unique_elder_titan_2"}
	},
	talent_hero_elder_titan_ancestral_spirit_attack = {
		icon = "elder_titan_ancestral_spirit",
		cost = 1,
		group = 4,
		requirement = "elder_titan_ancestral_spirit",
		special_values = {value = 100},
		effect = {abilities = "special_bonus_unique_elder_titan"}
	},
	talent_hero_legion_commander_moment_of_courage_chance = {
		icon = "legion_commander_moment_of_courage",
		cost = 1,
		group = 5,
		requirement = "legion_commander_moment_of_courage",
		special_values = {value = 10},
		effect = {abilities = "special_bonus_unique_legion_commander_3"}
	},
	talent_hero_legion_commander_duel_bonus = {
		icon = "legion_commander_duel",
		cost = 1,
		group = 9,
		requirement = "legion_commander_duel",
		special_values = {value = 40},
		effect = {abilities = "special_bonus_unique_legion_commander"}
	},
	talent_hero_legion_commander_press_the_attack_cd = {
		icon = "legion_commander_press_the_attack",
		cost = 1,
		group = 6,
		requirement = "legion_commander_press_the_attack",
		special_values = {value = 8},
		effect = {abilities = "special_bonus_unique_legion_commander_2"}
	},
	talent_hero_ember_spirit_flame_guard_absorb = {
		icon = "ember_spirit_flame_guard",
		cost = 1,
		group = 5,
		requirement = "ember_spirit_flame_guard",
		special_values = {value = 900},
		effect = {abilities = "special_bonus_unique_ember_spirit_1"}
	},
	talent_hero_ember_spirit_searing_chains_count = {
		icon = "ember_spirit_searing_chains",
		cost = 1,
		group = 6,
		requirement = "ember_spirit_searing_chains",
		special_values = {value = 1},
		effect = {abilities = "special_bonus_unique_ember_spirit_2"}
	},
	talent_hero_earth_spirit_geomagnetic_grip_allies = {
		icon = "earth_spirit_geomagnetic_grip",
		cost = 1,
		group = 6,
		requirement = "earth_spirit_geomagnetic_grip",
		special_values = {value = 0},
		effect = {abilities = "special_bonus_unique_earth_spirit_2"}
	},
	talent_hero_earth_spirit_boulder_smash_dmg = {
		icon = "earth_spirit_boulder_smash",
		cost = 1,
		group = 7,
		requirement = "earth_spirit_boulder_smash",
		special_values = {value = 450},
		effect = {abilities = "special_bonus_unique_earth_spirit"}
	},
	talent_hero_terrorblade_sunder_cd = {
		icon = "terrorblade_sunder",
		cost = 1,
		group = 9,
		requirement = "terrorblade_sunder",
		special_values = {value = 30},
		effect = {abilities = "special_bonus_unique_terrorblade"}
	},
	talent_hero_phoenix_fire_spirits_dps = {
		icon = "phoenix_fire_spirits",
		cost = 1,
		group = 6,
		requirement = "phoenix_fire_spirits",
		special_values = {value = 200},
		effect = {abilities = "special_bonus_unique_phoenix_3"}
	},
	talent_hero_phoenix_supernova_count = {
		icon = "phoenix_supernova",
		cost = 10,
		group = 9,
		requirement = "phoenix_supernova",
		special_values = {value = 10},
		effect = {abilities = "special_bonus_unique_phoenix_1"}
	},
	talent_hero_phoenix_supernova_duration = {
		icon = "phoenix_supernova",
		cost = 5,
		group = 9,
		requirement = "phoenix_supernova",
		special_values = {value = 1},
		effect = {abilities = "special_bonus_unique_phoenix_2"}
	},
	talent_hero_oracle_fortunes_end_duration = {
		icon = "oracle_fortunes_end",
		cost = 1,
		group = 5,
		requirement = "oracle_fortunes_end",
		special_values = {value = 0.75},
		effect = {abilities = "special_bonus_unique_oracle_2"}
	},
	talent_hero_oracle_false_promise_duration = {
		icon = "oracle_false_promise",
		cost = 1,
		group = 9,
		requirement = "oracle_false_promise",
		special_values = {value = 2},
		effect = {abilities = "special_bonus_unique_oracle"}
	},
	talent_hero_techies_suicide_dmg = {
		icon = "techies_suicide",
		cost = 1,
		group = 6,
		requirement = "techies_suicide",
		special_values = {value = 900},
		effect = {abilities = "special_bonus_unique_techies"}
	},
	talent_hero_winter_wyvern_cold_embrace_duration = {
		icon = "winter_wyvern_cold_embrace",
		cost = 1,
		group = 4,
		requirement = "winter_wyvern_cold_embrace",
		special_values = {value = 1},
		effect = {abilities = "special_bonus_unique_winter_wyvern_3"}
	},
	talent_hero_winter_wyvern_arctic_burn_slow = {
		icon = "winter_wyvern_arctic_burn",
		cost = 1,
		group = 5,
		requirement = "winter_wyvern_arctic_burn",
		special_values = {value = 15},
		effect = {abilities = "special_bonus_unique_winter_wyvern_1"}
	},
	talent_hero_winter_wyvern_splinter_blast_cd = {
		icon = "winter_wyvern_splinter_blast",
		cost = 1,
		group = 6,
		requirement = "winter_wyvern_splinter_blast",
		special_values = {value = 3},
		effect = {abilities = "special_bonus_unique_winter_wyvern_2"}
	},
	talent_hero_arc_warden_flux_dps = {
		icon = "arc_warden_flux",
		cost = 1,
		group = 6,
		requirement = "arc_warden_flux",
		special_values = {value = 200},
		effect = {abilities = "special_bonus_unique_arc_warden_2"}
	},
	talent_hero_arc_warden_spark_wraith_dmg = {
		icon = "arc_warden_spark_wraith",
		cost = 1,
		group = 7,
		requirement = "arc_warden_spark_wraith",
		special_values = {value = 440},
		effect = {abilities = "special_bonus_unique_arc_warden"}
	},
	talent_hero_abyssal_underlord_pit_of_malice_duration = {
		icon = "abyssal_underlord_pit_of_malice",
		cost = 1,
		group = 5,
		requirement = "abyssal_underlord_pit_of_malice",
		special_values = {value = 0.4},
		effect = {abilities = "special_bonus_unique_underlord"}
	},
	talent_hero_monkey_king_jingu_mastery_dmg = {
		icon = "monkey_king_jingu_mastery",
		cost = 1,
		group = 6,
		requirement = "monkey_king_jingu_mastery",
		special_values = {value = 150},
		effect = {abilities = "special_bonus_unique_monkey_king_2"}
	},
	talent_hero_monkey_king_boundless_strike_crit = {
		icon = "monkey_king_boundless_strike",
		cost = 1,
		group = 9,
		requirement = "monkey_king_boundless_strike",
		special_values = {value = 100},
		effect = {abilities = "special_bonus_unique_monkey_king"}
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
