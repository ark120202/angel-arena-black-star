CUSTOM_TALENTS_DATA = {
	talent_wtf = {
		icon = "wtf", -- /custom_game/talents/<icon>.png
		cost = 1,
		group = 1,
		--requirement = "npc_dota_hero_abaddon", -- hero or ability name
		max_level = 6,
		special_values = {
			["damage"] = {111,222,333,444,555,666}
		},
		effect = {
			modifiers = {
				["modifier_talent_damage"] = "damage",
			},
		}
	},
	talent_hoooks = {
		icon = "wtf", -- /custom_game/talents/<icon>.png
		cost = 156, --ability points cost
		group = 4, -- level group
		requirement = "pudge_meat_hook_lua", -- hero or ability name
		special_values = {
			["hooks"] = 16
		}
	},
}

TALENT_GROUP_TO_LEVEL = {
	[1] = 0,
	[2] = 4,
	[3] = 8,
	[4] = 12,
	[5] = 16,
}