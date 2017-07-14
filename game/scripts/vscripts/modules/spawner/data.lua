SPAWNER_CHAMPION_LEVELS = {
	[2] = {
		chance = 4,
		minute = 5,
		model_scale = 0.3,
	},
	[3] = {
		chance = 4,
		minute = 8,
		model_scale = 0.35,
	},
	[4] = {
		chance = 4,
		minute = 13,
		model_scale = 0.4,
	},
	[5] = {
		chance = 3,
		minute = 20,
		model_scale = 0.45,
	}
}

CHAMPIONS_BANNED_ABILITIES = {
	chen_holy_persuasion = true,
	item_iron_talon = true,
	item_helm_of_the_dominator = true,
	doom_bringer_devour_arena = true,
	shinobu_eat_oddity = true,
	clinkz_death_pact = true,
	item_hand_of_midas_arena = true,
}

CREEP_UPGRADE_FUNCTIONS = {
			   --[[ goldbounty  hp          damage      attackspeed movespeed   armor       xpbounty    ]]--
	easy = {
		[0]     = { 5,          20,         1,          5,          0.8,        1.0,        18          },
		[5]     = { 5,          20,         2,          1,          1,          0,          20          },
		[10]    = { 5,          25,         3,          2,          1.0,        0.5,        25          },
		[15]    = { 6,          35,         4,          2,          1.0,        0.5,        25          },
		[20]    = { 8,          45,         5,          0.4,        1.3,        1.0,        70          },
		[30]    = { 15,         85,         10,         0.45,       0.45,       1.0,        250         },
		[40]    = { 20,         100,        15,         0.6,        0.5,        1.0,        350         },
		[60]    = { 35,         120.5,      20,         0.5,        0.5,        0.5,        700         },
	},
	medium = {
		[0]     = { 3,          25,         2,          0,          2,          0,          5           },
		[5]     = { 3,          30,         3,          0,          2,          0,          10          },
		[10]    = { 3,          50,         5,          0.2,        2,          0.2,        15          },
		[15]    = { 4,          60,         7,          0.3,        2,          0.3,        30          },
		[20]    = { 6,          100,        7,          0.3,        2,          0.4,        40          },
		[30]    = { 12,         200,        12,         0.4,        2,          0.5,        200         },
		[40]    = { 20,         275,        15,         0.4,        2,          0.6,        300         },
		[60]    = { 40,         350,        30,         0.5,        2,          0.8,        500         },
	},
	hard = {
		[0]     = { 3,          55,         2.3,        0,          2,          0.1,        15          },
		[10]    = { 4,          70,         6,          0.5,        2,          0.2,        20          },
		[15]    = { 5,          100,        7,          0.5,        2,          0.3,        30          },
		[20]    = { 7,          150,        8,          0.6,        2,          0.4,        50          },
		[30]    = { 20,         250,        15,         0.7,        2,          0.5,        250         },
		[40]    = { 30,         350,        20,         0.7,        2,          0.6,        350         },
		[60]    = { 60,         500,        40,         0.8,        2,          0.7,        600         },
	},
}

SPAWNER_SETTINGS = {
	Cooldown = 60,
	easy = {
		SpawnedPerSpawn = 5,
		MaxUnits = 40,
		SpawnTypes = {
			[0] ={
				{
					[-1] = "npc_dota_neutral_easy_variant1",
					[0] = "models/items/broodmother/spiderling/virulent_matriarchs_spiderling/virulent_matriarchs_spiderling.vmdl",
					[10] = "models/heroes/broodmother/spiderling.vmdl",
					[20] = "models/items/broodmother/spiderling/amber_queen_spiderling_2/amber_queen_spiderling_2.vmdl",
					[30] = "models/items/broodmother/spiderling/araknarok_broodmother_araknarok_spiderling/araknarok_broodmother_araknarok_spiderling.vmdl",
					[40] = "models/items/broodmother/spiderling/spiderling_dlotus_red/spiderling_dlotus_red.vmdl",
					[50] = "models/items/broodmother/spiderling/thistle_crawler/thistle_crawler.vmdl",
					[60] = "models/items/broodmother/spiderling/perceptive_spiderling/perceptive_spiderling.vmdl",
				}
			},
		},
	},
	medium = {
		SpawnedPerSpawn = 4,
		MaxUnits = 40,
		SpawnTypes = {
			[0] ={
				{
					[-1] = "npc_dota_neutral_medium_variant1",
					[0] = "models/creeps/neutral_creeps/n_creep_troll_skeleton/n_creep_skeleton_melee.vmdl",
					[30] = "models/creeps/neutral_creeps/n_creep_ghost_a/n_creep_ghost_a.vmdl",
					[60] = "models/creeps/lane_creeps/creep_bad_melee_diretide/creep_bad_melee_diretide.vmdl",
				}
			},
			[1] ={
				{
					[-1] = "npc_dota_neutral_medium_variant1",
					[0] = "models/creeps/neutral_creeps/n_creep_beast/n_creep_beast.vmdl",
					[30] = "models/creeps/neutral_creeps/n_creep_furbolg/n_creep_furbolg_disrupter.vmdl",
					[60] = "models/heroes/ursa/ursa.vmdl",
				}
			},
			[2] ={
				{
					[-1] = "npc_dota_neutral_medium_variant1",
					[0] = "models/heroes/lone_druid/spirit_bear.vmdl",
					--[10] = "models/items/lone_druid/bear/dark_wood_bear_brown/dark_wood_bear_brown.vmdl",
					--[20] = "models/items/lone_druid/bear/dark_wood_bear_white/dark_wood_bear_white.vmdl",
					[20] = "models/items/lone_druid/bear/dark_wood_bear/dark_wood_bear.vmdl",
					--[40] = "models/items/lone_druid/bear/dark_wood_bear_white/dark_wood_bear_white.vmdl",
					[40] = "models/items/lone_druid/bear/spirit_of_anger/spirit_of_anger.vmdl",
					[60] = "models/items/lone_druid/bear/iron_claw_spirit_bear/iron_claw_spirit_bear.vmdl",
				}
			},
			[3] ={
				{
					[-1] = "npc_dota_neutral_medium_variant1",
					[0] = "models/items/beastmaster/boar/fotw_wolf/fotw_wolf.vmdl",
					[25] = "models/heroes/lycan/summon_wolves.vmdl",
					[40] = "models/heroes/lycan/lycan_wolf.vmdl",
					[60] = "models/items/lycan/ultimate/thegreatcalamityti4/thegreatcalamityti4.vmdl",

				}
			},
			--[[[4] ={
				{
					[-1] = "npc_dota_neutral_medium_variant1",
					[0] = "models/creeps/neutral_creeps/n_creep_centaur_lrg/n_creep_centaur_lrg.vmdl",
				}
			},]]
		},
	},
	hard = {
		SpawnedPerSpawn = 4,
		MaxUnits = 40,
		SpawnTypes = {
			[0] ={
				{
					[-1] = "npc_dota_neutral_hard_variant1",
					[0] = "models/creeps/neutral_creeps/n_creep_jungle_stalker/n_creep_gargoyle_jungle_stalker.vmdl",
					[10] = "models/creeps/neutral_creeps/n_creep_black_drake/n_creep_black_drake.vmdl",
					[20] = "models/creeps/neutral_creeps/n_creep_black_dragon/n_creep_black_dragon.vmdl",
					[30] = "models/items/dragon_knight/dragon_immortal_1/dragon_immortal_1.vmdl",
					[40] = "models/items/dragon_knight/fireborn_dragon/fireborn_dragon.vmdl",
					[50] = "models/heroes/dragon_knight/dragon_knight_dragon.vmdl",
					--[60] = "models/heroes/twin_headed_dragon/twin_headed_dragon.vmdl",
				}

			},
			[1] ={
				{
					[-1] = "npc_dota_neutral_hard_variant2",
					[0] = "models/creeps/neutral_creeps/n_creep_centaur_med/n_creep_centaur_med.vmdl",
					[30] = "models/creeps/neutral_creeps/n_creep_centaur_lrg/n_creep_centaur_lrg.vmdl",
					[60] = "models/heroes/centaur/centaur.vmdl",
				}

			},
		},
	},
}
