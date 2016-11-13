ShopsData = {
	Shards = {
		"item_casino_drug_pill1",
		"item_casino_drug_pill2",
		"item_casino_drug_pill3",
		"item_casino_coin",
	},
}

DROP_TABLE = {
	--[[["npc_arena_boss_fire"] = {
		{ Item = "item_soul_of_titan", DropChance = 35, },
		{ Item = "item_dark_blade", DropChance = 40, },
		{ Item = "item_phantom_bone", DropChance = 6, },
	},
	["npc_arena_boss_water"] = {
		{ Item = "item_soul_of_titan", DropChance = 35, },
		{ Item = "item_dark_blade", DropChance = 30, },
		{ Item = "item_phantom_bone", DropChance = 6, },
	},
	["npc_arena_boss_earth"] = {
		{ Item = "item_soul_of_titan", DropChance = 35, },
		{ Item = "item_dark_blade", DropChance = 30, },
		{ Item = "item_phantom_bone", DropChance = 50, },
	},
	["npc_arena_boss_wind"] = {
		{ Item = "item_soul_of_titan", DropChance = 35, },
		{ Item = "item_dark_blade", DropChance = 30, },
		{ Item = "item_phantom_bone", DropChance = 50, },
	},
	["npc_arena_boss_primal"] = {
		{ Item = "item_soul_of_titan", DropChance = 100, },
		{ Item = "item_dark_blade", DropChance = 100, },
		{ Item = "item_phantom_bone", DropChance = 100, },
	},]]
	["npc_arena_boss_1_dire"] = {
		{ Item = "item_hell_hero_change", DropChance = 100, },
		{ Item = "item_sacrificial_dagger", DropChance = 100, },
		{ Item = "item_soul_of_titan", DropChance = 35, },
		{ Item = "item_dark_blade", DropChance = 10, },
		{ Item = "item_phantom_bone", DropChance = 8, },
	},
	["npc_arena_boss_heaven"] = {
		{ Item = "item_heaven_hero_change", DropChance = 100, },
		{ Item = "item_consecrated_sword", DropChance = 100, },
		{ Item = "item_soul_of_titan", DropChance = 35, },
		{ Item = "item_dark_blade", DropChance = 10, },
		{ Item = "item_phantom_bone", DropChance = 8, },
	},
	["npc_arena_boss_hell"] = {
		{ Item = "item_hell_hero_change", DropChance = 100, },
		{ Item = "item_sacrificial_dagger", DropChance = 100, },
		{ Item = "item_soul_of_titan", DropChance = 35, },
		{ Item = "item_dark_blade", DropChance = 10, },
		{ Item = "item_phantom_bone", DropChance = 8, },
	},
	--[[["npc_arena_boss_roshan"] = {
		{ Item = "item_essence_aegis", DropChance = 100, },
		{ Item = "item_soul_of_titan", DropChance = 35, },
		{ Item = "item_dark_blade", DropChance = 5, },
	},]]
}

CRAFT_RECIPES = {
	{ -- playerID, unit, container
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
	}
}