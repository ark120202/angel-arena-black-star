CUSTOM_WEARABLES_PLAYER_ITEMS = {
	[109792606] = {
		"wearable_hero_stargazer_helmet_of_the_sunray",
		"wearable_hero_omniknight_frozen_sword",
		"wearable_item_summoned_unit_kyuubey",
		"wearable_hero_shinobu_umbrella",
		"wearable_developer"
	},
	[82292900] = {
		"wearable_hero_stargazer_helmet_of_the_sunray",
		"wearable_hero_omniknight_frozen_sword",
		"wearable_item_summoned_unit_kyuubey"
	}
}

CUSTOM_WEARABLES = {
	saber_excalibur = {
		particles = {
			--[[{
				name = "particles/arena/units/heroes/hero_saber/sword_glow.vpcf",
				attach = PATTACH_ABSORIGIN_FOLLOW,
				bAttachToUnit = true,
				control_points = {
					{
						index = 0,
						attach = PATTACH_POINT_FOLLOW,
						attachment = "attach_sword1"
					},
					{
						index = 1,
						attach = PATTACH_POINT_FOLLOW,
						attachment = "attach_sword2"
					},
				}
			},]]
			{
				name = "particles/arena/units/heroes/hero_saber/sword_glow2.vpcf",
				attach = PATTACH_ABSORIGIN_FOLLOW,
				bAttachToUnit = true,
				control_points = {
					{
						index = 0,
						attach = PATTACH_POINT_FOLLOW,
						attachment = "attach_sword1"
					},
					{
						index = 1,
						attach = PATTACH_POINT_FOLLOW,
						attachment = "attach_sword2"
					},
				}
			}
		},
		used_by_heroes = {"npc_arena_hero_saber"},
		IsDefault = true
	},
	anakim_wisps = {
		particles = {
			{
				name = "particles/arena/units/heroes/hero_anakim/attack_wisps.vpcf",
				attach = PATTACH_ABSORIGIN_FOLLOW,
				bAttachToUnit = true,
				control_points = {
					{
						index = 0,
						attach = PATTACH_POINT_FOLLOW,
						attachment = "attach_spirit1"
					},
					{
						index = 1,
						attach = PATTACH_POINT_FOLLOW,
						attachment = "attach_spirit2"
					},
					{
						index = 2,
						attach = PATTACH_POINT_FOLLOW,
						attachment = "attach_spirit3"
					},
					{
						index = 3,
						attach = PATTACH_POINT_FOLLOW,
						attachment = "attach_spirit4"
					},
					{
						index = 4,
						attach = PATTACH_POINT_FOLLOW,
						attachment = "attach_spirit5"
					},
					{
						index = 5,
						attach = PATTACH_POINT_FOLLOW,
						attachment = "attach_spirit6"
					},
					{
						index = 6,
						attach = PATTACH_POINT_FOLLOW,
						attachment = "attach_spirit7"
					},
					{
						index = 7,
						attach = PATTACH_POINT_FOLLOW,
						attachment = "attach_spirit8"
					},
				}
			}
		},
		used_by_heroes = {"npc_arena_hero_anakim"},
		IsDefault = true
	}
}

--[[CUSTOM_WEARABLES_ITEM_HANDLES = {
	["wearable_hero_stargazer_helmet_of_the_sunray"] = {
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
	["wearable_hero_omniknight_frozen_sword"] = {
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
	["wearable_common_model_tree"] = {
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
	["wearable_common_radio_car"] = {
		on_first_equip = function(self, unit)
			unit:AddItem(CreateItem("item_radio_car", unit, unit))
		end
	},
	["wearable_item_summoned_unit_kyuubey"] = {
		PlayerKeys = {
			item_summoned_unit = {
				model = "models/custom/kyuubey.vmdl",
				model_scale = 4
			}
		}
	},
	["wearable_hero_shinobu_umbrella"] = {
		
	},
	["wearable_developer"] = {}
}]]