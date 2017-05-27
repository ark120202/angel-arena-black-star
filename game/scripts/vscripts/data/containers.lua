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
