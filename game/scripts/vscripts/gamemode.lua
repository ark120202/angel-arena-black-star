ARENA_VERSION = "1.5"
GAMEMODE_INITIALIZATION_STATUS = {}

if not GameMode then
	_G.GameMode = class({})
end

local requirements = {
	"libraries/keyvalues",
	"libraries/timers",
	"libraries/physics",
	"libraries/projectiles",
	"libraries/notifications",
	"libraries/animations",
	"libraries/attachments",
	"libraries/playertables",
	"libraries/containers",
	"libraries/modmaker",
	"libraries/pathgraph",
	"libraries/selection",
	"libraries/worldpanels",
	"libraries/CosmeticLib",
	"libraries/PopupNumbers",
	"libraries/statcollection/init",
	--------------------------------------------------
	"data/constants",
	"data/globals",
	"data/containers",
	"data/kv_data",
	"data/modifiers",
	"data/shop",
	"data/itembuilds",
	"data/abilities",
	"data/ability_functions",
	"data/ability_shop",
	"data/commands",
	--------------------------------------------------
	"internal/gamemode",
	"internal/events",
	--------------------------------------------------
	"events",
	"custom_events",
	"filters",

	"modules/index"
}

local modifiers = {
	modifier_item_shard_attackspeed_stack = "items/lua/modifiers/modifier_item_shard_attackspeed_stack",
	modifier_apocalypse_apocalypse = "heroes/hero_apocalypse/modifier_apocalypse_apocalypse",
	modifier_set_attack_range = "modifiers/modifier_set_attack_range",
	modifier_charges = "modifiers/modifier_charges",
	modifier_hero_selection_transformation = "modifiers/modifier_hero_selection_transformation",
	modifier_fountain_aura_arena = "modifiers/modifier_fountain_aura_arena",
	modifier_max_attack_range = "modifiers/modifier_max_attack_range",
	modifier_arena_hero = "modifiers/modifier_arena_hero",
	modifier_item_demon_king_bar_curse = "items/modifier_item_demon_king_bar_curse",
	modifier_hero_out_of_game = "modifiers/modifier_hero_out_of_game"
}

for k,v in pairs(modifiers) do
	LinkLuaModifier(k, v, LUA_MODIFIER_MOTION_NONE)
end

AllPlayersInterval = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23}

for i = 1, #requirements do
	require(requirements[i])
end
JSON = require("libraries/json")

Options:Preload()

function GameMode:InitGameMode()
	GameMode = self
	if GAMEMODE_INITIALIZATION_STATUS[2] then
		return
	end
	GAMEMODE_INITIALIZATION_STATUS[2] = true

	GameMode:InitFilters()
	HeroSelection:Initialize()
	GameMode:RegisterCustomListeners()
	DynamicWearables:Init()
	HeroSelection:PrepareTables()
	PanoramaShop:InitializeItemTable()
	Structures:AddHealers()
	Structures:CreateShops()

	Containers:SetItemLimit(50)
	Containers:UsePanoramaInventory(false)
	StatsClient:Init()
	PlayerTables:CreateTable("arena", {
		gold = {},
		players_abandoned = {},
	}, AllPlayersInterval)
	PlayerTables:CreateTable("player_hero_indexes", {}, AllPlayersInterval)
	PlayerTables:CreateTable("stats_client", {}, AllPlayersInterval)
	PlayerTables:CreateTable("disable_help_data", {[0] = {}, [1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {}, [6] = {}, [7] = {}, [8] = {}, [9] = {}, [10] = {}, [11] = {}, [12] = {}, [13] = {}, [14] = {}, [15] = {}, [16] = {}, [17] = {}, [18] = {}, [19] = {}, [20] = {}, [21] = {}, [22] = {}, [23] = {}}, AllPlayersInterval)
end

function GameMode:PostLoadPrecache()

end

function GameMode:OnFirstPlayerLoaded()
	if Options:IsEquals("MainHeroList", "NoAbilities") then
		AbilityShop:PrepareData()
	end
end

function GameMode:OnAllPlayersLoaded()
	if GAMEMODE_INITIALIZATION_STATUS[4] then
		return
	end
	GAMEMODE_INITIALIZATION_STATUS[4] = true
	DynamicMinimap:Init()
	Spawner:PreloadSpawners()
	Bosses:InitAllBosses()
	CustomRunes:Init()
	CustomTalents:Init()
end

function GameMode:OnHeroSelectionEnd()
	Timers:CreateTimer(CUSTOM_GOLD_TICK_TIME, Dynamic_Wrap(GameMode, "GameModeThink"))
	--Timers:CreateTimer(1/30, Dynamic_Wrap(GameMode, "QuickGameModeThink"))
	PanoramaShop:StartItemStocks()
	Duel:CreateGlobalTimer()
end

function GameMode:OnHeroInGame(hero)
	Timers:CreateTimer(function()
		if IsValidEntity(hero) and hero:IsTrueHero() then
			if not TEAMS_COURIERS[hero:GetTeamNumber()] then
				Structures:GiveCourier(hero)
			end
			HeroVoice:OnHeroInGame(hero)
		end
	end)
end

function GameMode:OnGameInProgress()
	if GAMEMODE_INITIALIZATION_STATUS[3] then
		return
	end
	GAMEMODE_INITIALIZATION_STATUS[3] = true
	Spawner:RegisterTimers()
	Timers:CreateTimer(function()
		CustomRunes:SpawnRunes()
		return CUSTOM_RUNE_SPAWN_TIME
	end)
end

function CDOTAGamerules:SetKillGoal(iGoal)
	KILLS_TO_END_GAME_FOR_TEAM = iGoal
	PlayerTables:SetTableValue("arena", "kill_goal", KILLS_TO_END_GAME_FOR_TEAM)
end

function CDOTAGamerules:GetKillGoal()
	return KILLS_TO_END_GAME_FOR_TEAM
end

function GameMode:PrecacheUnitQueueed(name)
	if not table.contains(RANDOM_OMG_PRECACHED_HEROES, name) then
		if not IS_PRECACHE_PROCESS_RUNNING then
			IS_PRECACHE_PROCESS_RUNNING = true
			table.insert(RANDOM_OMG_PRECACHED_HEROES, name)
			PrecacheUnitByNameAsync(name, function()
				IS_PRECACHE_PROCESS_RUNNING = nil
			end)
		else
			Timers:CreateTimer(0.5, function()
				GameMode:PrecacheUnitQueueed(name)
			end)
		end
	end
end

function GameMode:GameModeThink()
	for i = 0, 23 do
		if PlayerResource:IsValidPlayerID(i) then
			local playerData = PLAYER_DATA[i]
			local hero = PlayerResource:GetSelectedHeroEntity(i)
			if hero then
				hero:SetNetworkableEntityInfo("unit_name", hero:GetFullName())
				MeepoFixes:ShareItems(hero)
			end
			if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
				local gold_per_tick = CUSTOM_GOLD_PER_TICK
				if hero then
					if hero.talent_keys and hero.talent_keys.bonus_gold_per_minute then
						gold_per_tick = gold_per_tick + hero.talent_keys.bonus_gold_per_minute / 60 * CUSTOM_GOLD_TICK_TIME
					end
					if hero.talent_keys and hero.talent_keys.bonus_xp_per_minute then
						hero:AddExperience(hero.talent_keys.bonus_xp_per_minute / 60 * CUSTOM_GOLD_TICK_TIME, 0, false, false)
					end
				end
				Gold:AddGold(i, gold_per_tick)
			end
			AntiAFK:Think(i)
		end
	end
	return CUSTOM_GOLD_TICK_TIME
end
