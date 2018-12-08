SPAWNER_CHAMPION_LEVELS = {
	[2] = {
		chance = 4,
		minute = 5,
		model_scale = 0.3,
	},
	[3] = {
		chance = 3,
		minute = 8,
		model_scale = 0.35,
	},
	[4] = {
		chance = 2,
		minute = 11,
		model_scale = 0.4,
	},
	[5] = {
		chance = 1,
		minute = 14,
		model_scale = 0.45,
	}
}

CHAMPIONS_BANNED_ABILITIES = {
	chen_holy_persuasion = true,
	item_helm_of_the_dominator = true,
	doom_bringer_devour_arena = true,
	shinobu_eat_oddity = true,
	clinkz_death_pact = true,
	enchantress_enchant = true,
}

JUNGLE_BANNED_ABILITIES = {
	item_helm_of_the_dominator = true,
	item_lucifers_claw = true,
	item_hand_of_midas_arena = true,
	item_hand_of_midas_2_arena = true,
	item_hand_of_midas_3_arena = true,
	item_blink_staff = true,
	item_force_staff = true,
	item_hurricane_pike = true,

	chen_holy_persuasion = true,
	doom_bringer_devour_arena = true,
	shinobu_eat_oddity = true,
	clinkz_death_pact = true,
	enchantress_enchant = true,
	earth_spirit_boulder_smash = true,
	batrider_flaming_lasso = true,
	tusk_walrus_kick = true,
	vengefulspirit_nether_swap = true,
	life_stealer_infest = true,
}

CREEP_UPGRADE_FUNCTIONS = {
			   --[[ goldbounty  hp          damage      attackspeed movespeed   armor       xpbounty    ]]--
	easy = {
		[0]     = { 7,          20,         1,          1,          0.8,        0,	        23          },
		[5]     = { 7,          20,         1,          1,          1,          0,          26          },
		[10]    = { 10,         25,         2,          2,          1.0,        0.5,        36          },
		[15]    = { 9,          25,         3,          2,          1.0,        0.5,        45          },
		[20]    = { 13,         30,         4,          0.4,        1.3,        0.5,        55          },
		[30]    = { 16,         45,         6,          0.45,       0.45,       0.5,        95          },
		[40]    = { 20,         60,         10,         0.6,        0.5,        0.5,        155         },
		[60]    = { 25,         80.5,       15,         0.5,        0.5,        0.5,        305         },
	},
	medium = {
		[0]     = { 2,          25,         2,          0,          2,          0,          9           },
		[5]     = { 2,          30,         2,          0,          2,          0,          12           },
		[10]    = { 2,          50,         3,          0.2,        2,          0.2,        14           },
		[15]    = { 3,          60,         4,          0.3,        2,          0.2,        20          },
		[20]    = { 4,          70,         5,          0.3,        2,          0.2,        35          },
		[30]    = { 8,          90,         7,          0.4,        2,          0.3,        75          },
		[40]    = { 11,         120,        10,         0.4,        2,          0.4,        135         },
		[60]    = { 16,         200,        20,         0.5,        2,          0.4,        255         },
	},
	hard = {
		[0]     = { 1,          55,         2.3,        0,          2,          0.1,        5          },
		[10]    = { 1,          70,         6,          0.5,        2,          0.1,        10          },
		[15]    = { 2,          90,         7,          0.5,        2,          0.1,        20          },
		[20]    = { 3,          120,        8,          0.6,        2,          0.2,        35          },
		[30]    = { 5,          180,        11,         0.7,        2,          0.3,        75          },
		[40]    = { 8,          230,        16,         0.7,        2,          0.4,        125         },
		[60]    = { 20,         400,        25,         0.8,        2,          0.4,        200         },
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
		SpawnedPerSpawn = 5,
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
					[40] = "models/items/lycan/wolves/blood_moon_hunter_wolves/blood_moon_hunter_wolves.vmdl",
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
		SpawnedPerSpawn = 5,
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
			[2] ={
				{
					[-1] = "npc_dota_neutral_hard_variant3",
					[0] = "models/creeps/roshan/roshan.vmdl",
					[30] = "models/heroes/tidehunter/tidehunter.vmdl",
				}
			},
		},
	},
	jungle = {
		SpawnedPerSpawn = 3,
		SpawnTypes = {
			[0] ={
				{
					[-1] = "npc_dota_neutral_jungle_variant1",
					[0] = "models/heroes/lone_druid/spirit_bear.vmdl",
					--[10] = "models/items/lone_druid/bear/dark_wood_bear_brown/dark_wood_bear_brown.vmdl",
					--[20] = "models/items/lone_druid/bear/dark_wood_bear_white/dark_wood_bear_white.vmdl",
					[20] = "models/items/lone_druid/bear/dark_wood_bear/dark_wood_bear.vmdl",
					--[40] = "models/items/lone_druid/bear/dark_wood_bear_white/dark_wood_bear_white.vmdl",
					[40] = "models/items/lone_druid/bear/spirit_of_anger/spirit_of_anger.vmdl",
					[60] = "models/items/lone_druid/bear/iron_claw_spirit_bear/iron_claw_spirit_bear.vmdl",
				}
			},
		},
	},
}
