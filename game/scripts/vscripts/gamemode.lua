GameMode = GameMode or class({})
ARENA_VERSION = LoadKeyValues("addoninfo.txt").version

GAMEMODE_INITIALIZATION_STATUS = {}

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
	-- "libraries/modmaker",
	-- "libraries/pathgraph",
	"libraries/selection",
	"libraries/worldpanels",
	"libraries/CosmeticLib",
	"libraries/PopupNumbers",
	"libraries/statcollection/init",
	--------------------------------------------------
	"data/constants",
	"data/globals",
	"data/kv_data",
	"data/modifiers",
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
	modifier_apocalypse_apocalypse = "heroes/hero_apocalypse/modifier_apocalypse_apocalypse",
	modifier_saitama_limiter = "heroes/hero_saitama/modifier_saitama_limiter",
	modifier_set_attack_range = "modifiers/modifier_set_attack_range",
	modifier_charges = "modifiers/modifier_charges",
	modifier_hero_selection_transformation = "modifiers/modifier_hero_selection_transformation",
	modifier_max_attack_range = "modifiers/modifier_max_attack_range",
	modifier_arena_hero = "modifiers/modifier_arena_hero",
	modifier_item_demon_king_bar_curse = "items/modifier_item_demon_king_bar_curse",
	modifier_hero_out_of_game = "modifiers/modifier_hero_out_of_game",

	modifier_item_shard_attackspeed_stack = "modifiers/modifier_item_shard_attackspeed_stack",
	modifier_item_casino_drug_pill1_addiction = "modifiers/modifier_item_casino_drug_pill1_addiction",
	modifier_item_casino_drug_pill2_addiction = "modifiers/modifier_item_casino_drug_pill2_addiction",
	modifier_item_casino_drug_pill3_addiction = "modifiers/modifier_item_casino_drug_pill3_addiction",
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
	Teams:Initialize()
	PlayerTables:CreateTable("arena", {}, AllPlayersInterval)
	PlayerTables:CreateTable("player_hero_indexes", {}, AllPlayersInterval)
	PlayerTables:CreateTable("players_abandoned", {}, AllPlayersInterval)
	PlayerTables:CreateTable("gold", {}, AllPlayersInterval)
	PlayerTables:CreateTable("disable_help_data", {[0] = {}, [1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {}, [6] = {}, [7] = {}, [8] = {}, [9] = {}, [10] = {}, [11] = {}, [12] = {}, [13] = {}, [14] = {}, [15] = {}, [16] = {}, [17] = {}, [18] = {}, [19] = {}, [20] = {}, [21] = {}, [22] = {}, [23] = {}}, AllPlayersInterval)
end

function GameMode:PostLoadPrecache()

end

function GameMode:OnFirstPlayerLoaded()
	if Options:IsEquals("MainHeroList", "NoAbilities") then
		CustomAbilities:PrepareData()
	end
	StatsClient:FetchTopPlayers()
end

function GameMode:OnAllPlayersLoaded()
	if GAMEMODE_INITIALIZATION_STATUS[4] then
		return
	end
	GAMEMODE_INITIALIZATION_STATUS[4] = true
	StatsClient:FetchPreGameData()
	Events:Emit("AllPlayersLoaded")
end

function GameMode:OnHeroSelectionStart()
	Teams:PostInitialize()
	Options:CalculateVotes()
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

	Timers:CreateTimer(10, function()
		for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
			if PlayerResource:IsValidPlayerID(playerID) and not PlayerResource:IsFakeClient(playerID) and GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then
				local heroName = HeroSelection:GetSelectedHeroName(playerID) or ""
				if heroName == "" or heroName == FORCE_PICKED_HERO then
					GameMode:BreakGame()
					return
				end
			end
		end
	end)
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

function GameMode:BreakGame()
	GameMode.Broken = true
	Tutorial:ForceGameStart()
	GameMode:OnOneTeamLeft(-1)
end
