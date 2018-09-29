WEARABLES_ATTACH_STRATEGY_BONE_MERGE = 0
WEARABLES_ATTACH_STRATEGY_ATTACHMENTS = 1

CUSTOM_WEARABLES = {
	saber_excalibur = {
		slot = "ambient",
		heroes = {"npc_arena_hero_saber"},
		default = true,
		particles = {
			{
				name = "particles/arena/units/heroes/hero_saber/sword_glow2.vpcf",
				attach = PATTACH_ABSORIGIN_FOLLOW,
				target = "unit",
				controlPoints = {
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
	},
	kadash_ambient = {
		slot = "ambient",
		heroes = {"npc_arena_hero_kadash"},
		default = true,
		particles = {
			{
				name = "particles/econ/courier/courier_greevil_purple/courier_greevil_purple_ambient_3.vpcf",
				attach = PATTACH_ABSORIGIN_FOLLOW,
				target = "unit",
				controlPoints = {
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
	},
	anakim_wisps = {
		slot = "ambient",
		heroes = {"npc_arena_hero_anakim"},
		default = true,
		particles = {
			{
				name = "particles/arena/units/heroes/hero_anakim/attack_wisps.vpcf",
				attach = PATTACH_ABSORIGIN_FOLLOW,
				target = "unit",
				controlPoints = {
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
	},
}
