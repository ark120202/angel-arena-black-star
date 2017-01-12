ShopsData = {
	Secret = {
		"item_casino_drug_pill1",
		"item_casino_drug_pill2",
		"item_casino_drug_pill3",
		"item_casino_coin",
	},
	Duel = {
		{ item = "item_dust", cost = 900 },
		{ item = "item_ward_sentry", cost = 1800 },
		{ item = "item_tango_arena", cost = 550 },
	}
}
--[[
	item_soul_of_titan
	item_dark_blade
	item_phantom_bone
	item_moon_dust
	item_cursed_eye
	item_fallen_star
	item_demons_paw

	item_shard_primal_medium
	item_shard_primal_large
	item_shard_str_large
	item_shard_str_extreme
	item_shard_agi_large
	item_shard_agi_extreme
	item_shard_int_large
	item_shard_int_extreme

	item_shard_level
]]
SHARED_CONTAINERS_USABLE_ITEMS = {
	--["item_shard_level"] = false,
	--["item_heaven_hero_change"] = false,
	--["item_hell_hero_change"] = false,

	["item_shard_primal_medium"] = true,
	["item_shard_primal_large"] = true,
	["item_shard_str_large"] = true,
	["item_shard_str_extreme"] = true,
	["item_shard_agi_large"] = true,
	["item_shard_agi_extreme"] = true,
	["item_shard_int_large"] = true,
	["item_shard_int_extreme"] = true,
	["item_shard_level"] = true,
}

DROP_TABLE = {
	["npc_arena_boss_freya"] = {
		--{ Item = "item_consecrated_sword", DropChance = 100, },
		{ Item = "item_god_transform_freya", DropChance = 100, },
		{ Item = "item_soul_of_titan", DropChance = 30, DamageWeightPct = 10, },
		{ Item = "item_dark_blade", DropChance = 50, },
		{ Item = "item_dark_blade", DropChance = 30, },
		{ Item = "item_dark_blade", DropChance = 10, },
		{ Item = "item_phantom_bone", DropChance = 40, },
		{ Item = "item_moon_dust", DropChance = 50, },
		{ Item = "item_moon_dust", DropChance = 40, },
		{ Item = "item_moon_dust", DropChance = 30, },
		{ Item = "item_cursed_eye", DropChance = 30, },
		{ Item = "item_fallen_star", DropChance = 25, },
		{ Item = "item_demons_paw", DropChance = 30, },

		{ Item = "item_shard_primal_large", DropChance = 30, },
		{ Item = "item_shard_str_extreme", DropChance = 40, },
		{ Item = "item_shard_agi_extreme", DropChance = 40, },
		{ Item = "item_shard_int_extreme", DropChance = 40, },
	},
	["npc_arena_boss_zaken"] = {
		--{ Item = "item_sacrificial_dagger", DropChance = 100, },
		{ Item = "item_god_transform_zaken", DropChance = 100, },
		{ Item = "item_soul_of_titan", DropChance = 30, },
		{ Item = "item_dark_blade", DropChance = 50, },
		{ Item = "item_dark_blade", DropChance = 30, },
		{ Item = "item_dark_blade", DropChance = 10, },
		{ Item = "item_phantom_bone", DropChance = 40, },
		{ Item = "item_moon_dust", DropChance = 50, },
		{ Item = "item_moon_dust", DropChance = 40, },
		{ Item = "item_moon_dust", DropChance = 30, },
		{ Item = "item_cursed_eye", DropChance = 30, },
		{ Item = "item_fallen_star", DropChance = 25, },
		{ Item = "item_demons_paw", DropChance = 30, },

		{ Item = "item_shard_primal_large", DropChance = 30, },
		{ Item = "item_shard_str_extreme", DropChance = 40, },
		{ Item = "item_shard_agi_extreme", DropChance = 40, },
		{ Item = "item_shard_int_extreme", DropChance = 40, },
	},
	["npc_arena_boss_central"] = {
		{ Item = "item_soul_of_titan", DropChance = 30, },
		{ Item = "item_dark_blade", DropChance = 50, },
		{ Item = "item_dark_blade", DropChance = 30, },
		{ Item = "item_dark_blade", DropChance = 10, },
		{ Item = "item_phantom_bone", DropChance = 40, },
		{ Item = "item_moon_dust", DropChance = 50, },
		{ Item = "item_moon_dust", DropChance = 40, },
		{ Item = "item_moon_dust", DropChance = 30, },
		{ Item = "item_cursed_eye", DropChance = 30, },
		{ Item = "item_fallen_star", DropChance = 25, },
		{ Item = "item_demons_paw", DropChance = 30, },

		{ Item = "item_shard_primal_large", DropChance = 30, },
		{ Item = "item_shard_str_extreme", DropChance = 40, },
		{ Item = "item_shard_agi_extreme", DropChance = 40, },
		{ Item = "item_shard_int_extreme", DropChance = 40, },
	},

	["npc_arena_boss_l1_v1"] = {
		{ Item = "item_soul_of_titan", DropChance = 15, },
		{ Item = "item_dark_blade", DropChance = 25, },
		{ Item = "item_phantom_bone", DropChance = 15, },
		{ Item = "item_moon_dust", DropChance = 25, },
		{ Item = "item_cursed_eye", DropChance = 10, },
		{ Item = "item_fallen_star", DropChance = 10, },
		{ Item = "item_demons_paw", DropChance = 14, },

		{ Item = "item_shard_primal_medium", DropChance = 30, },
		{ Item = "item_shard_str_large", DropChance = 35, },
		{ Item = "item_shard_agi_large", DropChance = 35, },
		{ Item = "item_shard_int_large", DropChance = 35, },
	},
	["npc_arena_boss_l1_v2"] = {
		{ Item = "item_soul_of_titan", DropChance = 15, },
		{ Item = "item_dark_blade", DropChance = 25, },
		{ Item = "item_phantom_bone", DropChance = 15, },
		{ Item = "item_moon_dust", DropChance = 25, },
		{ Item = "item_cursed_eye", DropChance = 10, },
		{ Item = "item_fallen_star", DropChance = 10, },
		{ Item = "item_demons_paw", DropChance = 14, },

		{ Item = "item_shard_primal_medium", DropChance = 30, },
		{ Item = "item_shard_str_large", DropChance = 35, },
		{ Item = "item_shard_agi_large", DropChance = 35, },
		{ Item = "item_shard_int_large", DropChance = 35, },
	},
	["npc_arena_boss_l2_v1"] = {
		{ Item = "item_soul_of_titan", DropChance = 25, },
		{ Item = "item_dark_blade", DropChance = 40, },
		{ Item = "item_dark_blade", DropChance = 20, },
		{ Item = "item_phantom_bone", DropChance = 35, },
		{ Item = "item_moon_dust", DropChance = 40, },
		{ Item = "item_moon_dust", DropChance = 40, },
		{ Item = "item_cursed_eye", DropChance = 20, },
		{ Item = "item_fallen_star", DropChance = 20, },
		{ Item = "item_demons_paw", DropChance = 25, },

		{ Item = "item_shard_primal_medium", DropChance = 10, },
		{ Item = "item_shard_str_large", DropChance = 12, },
		{ Item = "item_shard_agi_large", DropChance = 12, },
		{ Item = "item_shard_int_large", DropChance = 12, },
		{ Item = "item_shard_primal_large", DropChance = 16, },
		{ Item = "item_shard_str_extreme", DropChance = 20, },
		{ Item = "item_shard_agi_extreme", DropChance = 20, },
		{ Item = "item_shard_int_extreme", DropChance = 20, },
	},
	["npc_arena_boss_l2_v2"] = {
		{ Item = "item_soul_of_titan", DropChance = 25, },
		{ Item = "item_dark_blade", DropChance = 40, },
		{ Item = "item_dark_blade", DropChance = 20, },
		{ Item = "item_phantom_bone", DropChance = 35, },
		{ Item = "item_moon_dust", DropChance = 40, },
		{ Item = "item_moon_dust", DropChance = 40, },
		{ Item = "item_cursed_eye", DropChance = 20, },
		{ Item = "item_fallen_star", DropChance = 20, },
		{ Item = "item_demons_paw", DropChance = 25, },

		{ Item = "item_shard_primal_medium", DropChance = 10, },
		{ Item = "item_shard_str_large", DropChance = 12, },
		{ Item = "item_shard_agi_large", DropChance = 12, },
		{ Item = "item_shard_int_large", DropChance = 12, },
		{ Item = "item_shard_primal_large", DropChance = 16, },
		{ Item = "item_shard_str_extreme", DropChance = 20, },
		{ Item = "item_shard_agi_extreme", DropChance = 20, },
		{ Item = "item_shard_int_extreme", DropChance = 20, },
	},
}

CRAFT_RECIPES = {
	--[[{ -- playerID, unit, container
		results = "item_boss_control",
		condition = function(playerID, unit)
			return (PLAYER_DATA[playerID].Karma or 0) <= -10000
		end,
		recipe = {
			{"", "item_lucifers_claw", ""},
			{"", "item_essence_eternal", ""},
			{"", "", ""},
		},
		IsShapeless = true,
	}]]
}

BOSS_DROP_TABLE = {
	["npc_arena_boss_freya"] = {
		["item_dark_blade"] = {}
	}
}