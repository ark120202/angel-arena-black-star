SPAWNER_SETTINGS = {
	Cooldown = 60,
	easy = {
		SpawnedPerSpawn = 4,
		MaxUnits = 40,
		SpawnTypes = {
			[0] ={
				{
					[-1] = "npc_dota_neutral_easy_variant1",
					[0] = "models/creeps/item_creeps/i_creep_necro_warrior/necro_warrior.vmdl",
				}
			},
			--[[
			[1] ={
				{
					[-1] = "npc_dota_neutral_easy_variant1",
					[0] = "models/creeps/item_creeps/i_creep_necro_warrior/necro_warrior.vmdl",
				}
			},
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
					[0] = "models/creeps/neutral_creeps/n_creep_troll_skeleton/n_creep_skeleton_melee.vmdl",
					[30] = "models/creeps/lane_creeps/creep_bad_ranged_diretide/creep_bad_ranged_diretide.vmd",
					[60] = "models/creeps/lane_creeps/creep_bad_melee_diretide/creep_bad_melee_diretide.vmdl",					
				}
			},
			[1] ={
				{
					[-1] = "npc_dota_neutral_medium_variant1",
					[0] = "models/creeps/neutral_creeps/n_creep_beast/n_creep_beast.vmdl",
					[30] = "models/creeps/neutral_creeps/n_creep_furbolg/n_creep_furbolg_disrupter.vmd",
					[60] = "models/heroes/ursa/ursa.vmdl",					
				}
			},
			[2] ={
				{
					[-1] = "npc_dota_neutral_medium_variant1",
					[0] = "models/heroes/lone_druid/spirit_bear.vmdl",
					[30] = "models/items/lone_druid/bear/dark_wood_bear_white/dark_wood_bear_white.vmdl",
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

CASINO_COLORTABLE = {
	"red",
	"darkviolet",
	"magenta",
	"turquoise",
	"lightblue",
	"yellow",
	"palegoldenrod",
	"gold"
}

TEAM_NAMES = {}
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

TEAM_NAMES2 = {}
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

HERO_ASSIST_RANGE = 1300
DEFAULT_HP_PER_STR = 20
DEFAULT_HP_REGEN_PER_STR = 0.03
DEFAULT_MANA_PER_INT = 12
DEFAULT_MANA_REGEN_PER_INT = 0.04
DEFAULT_ARMOR_PER_AGI = 0.14
DEFAULT_ATKSPD_PER_AGI = 1
COURIER_RESPAWN_TIME = 180