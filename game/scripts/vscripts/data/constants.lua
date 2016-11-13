_G.SPAWNER_SETTINGS = {
	Cooldown = 60,
	easy = {
		SpawnedPerSpawn = 4,
		MaxUnits = 40,
		SpawnTypes = {
			[0] ={
				{
					[-1] = "npc_dota_neutral_easy_variant1",
					[0] = "models/creeps/neutral_creeps/n_creep_troll_skeleton/n_creep_skeleton_melee.vmdl",
				}
			},
			[1] ={
				{
					[-1] = "npc_dota_neutral_easy_variant1",
					[0] = "models/creeps/item_creeps/i_creep_necro_warrior/necro_warrior.vmdl",
				}
			},
			--[[
			[2] ={
				{
					[-1] = "npc_dota_neutral_easy_variant1",
					[0] = "models/creeps/neutral_creeps/n_creep_satyr_b/n_creep_satyr_b.vmdl",
				}
			},
			[3] ={
				{
					[-1] = "npc_dota_neutral_easy_variant1",
					[0] = "models/creeps/neutral_creeps/n_creep_worg_large/n_creep_worg_large.vmdl",
				}
			},]]	
		},
	},
	medium = {
		SpawnedPerSpawn = 4,
		MaxUnits = 40,
		SpawnTypes = {
			[0] ={
				{
					[-1] = "npc_dota_neutral_medium_variant1",
					[0] = "models/creeps/neutral_creeps/n_creep_ogre_lrg/n_creep_ogre_lrg.vmdl",
				}
			},
			[1] ={
				{
					[-1] = "npc_dota_neutral_medium_variant1",
					[0] = "models/heroes/lone_druid/spirit_bear.vmdl",
				}
			},
			[2] ={
				{
					[-1] = "npc_dota_neutral_medium_variant1",
					[0] = "models/creeps/neutral_creeps/n_creep_vulture_a/n_creep_vulture_a.vmdl",
				}
			},
			[3] ={
				{
					[-1] = "npc_dota_neutral_medium_variant1",
					[0] = "models/creeps/neutral_creeps/n_creep_troll_skeleton/n_creep_skeleton_melee.vmdl",
				}
			},
			[4] ={
				{
					[-1] = "npc_dota_neutral_medium_variant1",
					[0] = "models/creeps/neutral_creeps/n_creep_centaur_lrg/n_creep_centaur_lrg.vmdl",
				}
			},
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
				}

			},
			--[[[1] ={
				{
					[-1] = "npc_dota_neutral_hard_variant1",
					[0] = "models/heroes/invoker/forge_spirit.vmdl",
				}

			},]]
		},
	},
}

BOSSES_SETTINGS = {
	heaven = {
		RespawnTime = 600,
		gold_overall = 50000,
	},
	hell = {
		RespawnTime = 600,
		gold_overall = 50000,
	},
}

_G.Trigger_arena = {
	position_x = -5780,
	scale_x = 1536,
	scale_x_additional = 0,
	position_y = -5588,
	scale_y = 2560,
	scale_y_additional = 0
}

_G.ARENA_SETTINGS = {
	DelayFromGameStart = 600,
	DelayFromLast = 300,
	DurationBase = 60,
	DurationForPlayer = 20,
	Duel1x1Duration = 90,
	GoldForWin = 1500
}

_G.THINGS_SETTINGS = {
	BurnRiverTime = 300,
	BurnCooldown = 300,
	GoldCost = 10000
}

_G.TEAM_NAMES = {}
TEAM_NAMES[DOTA_TEAM_GOODGUYS] = "#DOTA_GoodGuys"
TEAM_NAMES[DOTA_TEAM_BADGUYS]  = "#DOTA_BadGuys"
TEAM_NAMES[DOTA_TEAM_CUSTOM_1] = "#DOTA_Custom1"
TEAM_NAMES[DOTA_TEAM_CUSTOM_2] = "#DOTA_Custom2"
TEAM_NAMES[DOTA_TEAM_CUSTOM_3] = "#DOTA_Custom3"
TEAM_NAMES[DOTA_TEAM_CUSTOM_4] = "#DOTA_Custom4"
TEAM_NAMES[DOTA_TEAM_CUSTOM_5] = "#DOTA_Custom5"
TEAM_NAMES[DOTA_TEAM_CUSTOM_6] = "#DOTA_Custom6"
TEAM_NAMES[DOTA_TEAM_CUSTOM_7] = "#DOTA_Custom7"
TEAM_NAMES[DOTA_TEAM_CUSTOM_8] = "#DOTA_Custom8"

_G.TEAM_NAMES2 = {}
TEAM_NAMES2[DOTA_TEAM_GOODGUYS] = "#DOTA_GoodGuys_2"
TEAM_NAMES2[DOTA_TEAM_BADGUYS]  = "#DOTA_BadGuys_2"
TEAM_NAMES2[DOTA_TEAM_CUSTOM_1] = "#DOTA_Custom1_2"
TEAM_NAMES2[DOTA_TEAM_CUSTOM_2] = "#DOTA_Custom2_2"
TEAM_NAMES2[DOTA_TEAM_CUSTOM_3] = "#DOTA_Custom3_2"
TEAM_NAMES2[DOTA_TEAM_CUSTOM_4] = "#DOTA_Custom4_2"
TEAM_NAMES2[DOTA_TEAM_CUSTOM_5] = "#DOTA_Custom5_2"
TEAM_NAMES2[DOTA_TEAM_CUSTOM_6] = "#DOTA_Custom6_2"
TEAM_NAMES2[DOTA_TEAM_CUSTOM_7] = "#DOTA_Custom7_2"
TEAM_NAMES2[DOTA_TEAM_CUSTOM_8] = "#DOTA_Custom8_2"

GOLD_FOR_RANDOM_HERO = 375


DOTA_PLAYER_AUTOABANDON_TIME = 60*8

DOTA_KILL_GOAL_VOTE_MIN = 25
DOTA_KILL_GOAL_VOTE_MAX = 100
DOTA_KILL_GOAL_VOTE_STANDART = 75

CUSTOM_HERO_SELECTION_TIME = 80

HERO_ASSIST_RANGE = 1300
DEFAULT_HP_PER_STR = 20
DEFAULT_HP_REGEN_PER_STR = 0.03
DEFAULT_MANA_PER_INT = 12
DEFAULT_MANA_REGEN_PER_INT = 0.04
DEFAULT_ARMOR_PER_AGI = 0.14
DEFAULT_ATKSPD_PER_AGI = 1
COURIER_RESPAWN_TIME = 180