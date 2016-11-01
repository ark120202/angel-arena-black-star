CUSTOM_WEARABLES_PLAYER_ITEMS = {
	[109792606] = {
		"item_hero_stargazer_helmet_of_the_sunray",
		"item_hero_omniknight_frozen_sword",
		"item_common_radio_car",
		"item_item_summoned_unit_kyuubey",
		"_______item_test",
		--"item_common_model_tree"
	},
	[82292900] = {
		"item_common_radio_car",
	}
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
	["item_common_model_tree"] = {
		base_model = "models/items/furion/treant_stump.vmdl",
		base_model_scale = 1.35,
		models = {
			{
				model = "models/items/sven/heavenly_sword.vmdl",
				attachPoint = "attach_attack1",
			},
		},
		hide_wearables = true,
	},
	["item_common_radio_car"] = {
		on_first_equip = function(self, unit)
			unit:AddItem(CreateItem("item_radio_car", unit, unit))
		end
	},
	["_______item_test"] = {
		base_model = "models/hero_madoka/madoka.vmdl",
		base_model_scale = 1.2,
		hide_wearables = true,
	},
	["item_item_summoned_unit_kyuubey"] = {
		PlayerKeys = {
			item_summoned_unit = {
				model = "models/custom/kyuubey.vmdl",
				model_scale = 4
			}
		}
	},
}