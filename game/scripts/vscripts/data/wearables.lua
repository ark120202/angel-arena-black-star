CUSTOM_WEARABLES_PLAYER_ITEMS = {
	[109792606] = {
		["alternative_npc_dota_hero_spectre"] = {
			"item_hero_stargazer_helmet_of_the_sunray",
		},
		["npc_dota_hero_omniknight"] = {
			"item_hero_omniknight_frozen_sword",
		},
		
	},
}

CUSTOM_WEARABLES_ITEM_HANDLES = {
	["item_hero_stargazer_helmet_of_the_sunray"] = {
		hero = "alternative_npc_dota_hero_spectre",
		models = {
			{
				model = "models/items/dragon_knight/helmet_01/helmet_01.vmdl",
				attachPoint = "attach_hitloc",
				scale = 1.7,
				--properties
			},
		},
		particles = {
			["particles/arena/units/heroes/hero_stargazer/gamma_ray_immortal1.vpcf"] = "particles/arena/econ/units/heroes/hero_stargazer/gamma_ray_sunray.vpcf",
		},
		hidden_slots = { "head" }
	},
	["item_hero_omniknight_frozen_sword"] = {
		hero = "npc_dota_hero_omniknight",
		models = {
			{
				model = "models/items/abaddon/sword_iceshard/sword_iceshard.vmdl",
				attachPoint = "attach_attack1",
			},
		},
		particles = {
			["particles/units/heroes/hero_omniknight/omniknight_purification.vpcf"] = "particles/arena/econ/units/heroes/hero_omniknight/omniknight_purification_frozen.vpcf",
		},
		hidden_slots = { "weapon" }
	},
}