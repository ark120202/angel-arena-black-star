WEARABLES_ATTACH_METHOD_DOTA = 0
WEARABLES_ATTACH_METHOD_ATTACHMENTS = 1

CUSTOM_WEARABLES = {
	--Default
	saber_excalibur = {
		particles = {
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
	kadash_ambient = {
		particles = {
			{
				name = "particles/econ/courier/courier_greevil_purple/courier_greevil_purple_ambient_3.vpcf",
				attach = PATTACH_ABSORIGIN_FOLLOW,
				bAttachToUnit = true,
				control_points = {
					{
						index = 0,
						attach = PATTACH_POINT_FOLLOW,
						attachment = "attach_horse_eye_l"
					},
					{
						index = 1,
						attach = PATTACH_POINT_FOLLOW,
						attachment = "attach_horse_eye_r"
					},
				}
			}
		},
		used_by_heroes = {"npc_arena_hero_kadash"},
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
						attachment = "attach_spirit5"
					},
					{
						index = 2,
						attach = PATTACH_POINT_FOLLOW,
						attachment = "attach_spirit7"
					},
					{
						index = 3,
						attach = PATTACH_POINT_FOLLOW,
						attachment = "attach_spirit2"
					},
					{
						index = 4,
						attach = PATTACH_POINT_FOLLOW,
						attachment = "attach_spirit8"
					},
					{
						index = 5,
						attach = PATTACH_POINT_FOLLOW,
						attachment = "attach_spirit4"
					},
					{
						index = 6,
						attach = PATTACH_POINT_FOLLOW,
						attachment = "attach_spirit6"
					},
					{
						index = 7,
						attach = PATTACH_POINT_FOLLOW,
						attachment = "attach_spirit3"
					},
				}
			}
		},
		used_by_heroes = {"npc_arena_hero_anakim"},
		IsDefault = true
	},
	maka_scythe = {
		model = "models/units/maka/maka_scythe.vmdl",
		used_by_heroes = {"npc_arena_hero_maka"},
		IsDefault = true,
		OnCreated = function(self)
			self:SetVisible(false)
		end
	},

	--Premium
	shinobu_umbrella = {
		model = "models/custom/umbrella_rainbow.vmdl",
		used_by_heroes = {"npc_arena_hero_shinobu"},
		attach_method = WEARABLES_ATTACH_METHOD_ATTACHMENTS,
		attachment = "attach_hitloc",
		--scale = 1.5
	},
}
