COURIER_HEALTH_BASE = 200
COURIER_HEALTH_GROWTH = 50

HEALER_HEALTH_BASE = 50
HEALER_HEALTH_GROWTH = 4

TEAM_HEALER_MODELS = {
	[DOTA_TEAM_GOODGUYS] = {
		mdl = "models/props_structures/radiant_statue001.vmdl",
		active = "particles/world_shrine/radiant_shrine_active.vpcf",
		ambient = "particles/world_shrine/radiant_shrine_ambient.vpcf"
	},
	[DOTA_TEAM_BADGUYS] = {
		mdl = "models/props_structures/dire_statue002.vmdl",
		active = "particles/world_shrine/dire_shrine_active.vpcf",
		ambient = "particles/world_shrine/dire_shrine_ambient.vpcf"
	},
}

ShopsData = {
	Duel = {
		{ item = "item_dust", cost = 360 },
		{ item = "item_ward_sentry", cost = 300 },
		{ item = "item_tango_arena", cost = 240 },
	}
}
