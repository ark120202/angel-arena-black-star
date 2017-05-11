ARENA_VERSION = "1.4.7"

BAREBONES_VERSION = "1.00"

BAREBONES_DEBUG_SPEW = false 
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
	--------------------------------------------------
	"data/globals",
	"data/constants",
	"data/containers",
	"data/kv_data",
	"data/modifiers",
	"data/shop",
	"data/itembuilds",
	"data/abilities",
	"data/ability_functions",
	"data/ability_shop",
	"data/commands",
	"data/neutrals",
	--------------------------------------------------
	"internal/gamemode",
	"internal/events",
	--------------------------------------------------
	"events",
	"custom_events",
	"spawner",
	"bosses",
	"duel",
	"hero_selection/main",
	"internal/containers",
	"herovoice",
	"gold",
	"kills",
	"panorama_shop",
	"options",
	"statcollection/init",
	"SimpleAI",
	"dynamic_minimap",
	"custom_runes/custom_runes",
	"stats_client",
	"filters",
	"ability_shop",
	"custom_talents/custom_talents",
	"dynamic_wearables/dynamic_wearables",
	"data/wearables",
}
local modifiers = {
	["modifier_item_shard_attackspeed_stack"] = "items/lua/modifiers/modifier_item_shard_attackspeed_stack",
	["modifier_apocalypse_apocalypse"] = "heroes/hero_apocalypse/modifier_apocalypse_apocalypse.lua",
	["modifier_set_attack_range"] = "modifiers/modifier_set_attack_range.lua",
	["modifier_charges"] = "libraries/modifiers/modifier_charges.lua",
	["modifier_hero_selection_transformation"] = "modifiers/modifier_hero_selection_transformation.lua",
	["modifier_fountain_aura_arena"] = "modifiers/modifier_fountain_aura_arena.lua",
	["modifier_max_attack_range"] = "modifiers/modifier_max_attack_range.lua",
	["modifier_arena_courier"] = "modifiers/modifier_arena_courier.lua",
	["modifier_arena_hero"] = "modifiers/modifier_arena_hero.lua",
	["modifier_neutral_champion"] = "modifiers/modifier_neutral_champion.lua",
	["modifier_item_demon_king_bar_curse"] = "items/modifier_item_demon_king_bar_curse"
}
AllPlayersInterval = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23}

for i = 1, #requirements do
	require(requirements[i])
end
JSON = require("libraries/json")
for k,v in pairs(modifiers) do
	LinkLuaModifier(k, v, LUA_MODIFIER_MOTION_NONE)
end
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
	
	Containers:SetItemLimit(50)
	Containers:UsePanoramaInventory(false)
	StatsClient:Init()
	PlayerTables:CreateTable("arena", {
		gold = {},
		players_abandoned = {},
	}, AllPlayersInterval)
	PlayerTables:CreateTable("player_hero_indexes", {}, AllPlayersInterval)
	PlayerTables:CreateTable("disable_help_data", {[0] = {}, [1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {}, [6] = {}, [7] = {}, [8] = {}, [9] = {}, [10] = {}, [11] = {}, [12] = {}, [13] = {}, [14] = {}, [15] = {}, [16] = {}, [17] = {}, [18] = {}, [19] = {}, [20] = {}, [21] = {}, [22] = {}, [23] = {}}, AllPlayersInterval)
end

function GameMode:PostLoadPrecache()

end

function GameMode:OnFirstPlayerLoaded()
	if Options:IsEquals("EnableAbilityShop") then
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
				local pid = hero:GetPlayerID()
				local tn = hero:GetTeamNumber()
				local cour_item = hero:AddItem(CreateItem("item_courier", hero, hero))
				TEAMS_COURIERS[hero:GetTeamNumber()] = true
				Timers:CreateTimer(0.03, function()
					for _,courier in ipairs(Entities:FindAllByClassname("npc_dota_courier")) do
						local owner = courier:GetOwner()
						if IsValidEntity(owner) and owner:GetPlayerID() == pid then
							courier:UpgradeToFlyingCourier()
							courier:SetOwner(nil)
							courier:AddNewModifier(courier, nil, "modifier_arena_courier", nil)
							courier:RemoveAbility("courier_burst")
							TEAMS_COURIERS[tn] = courier
							courier:SetBaseMaxHealth(200)
							courier:SetMaxHealth(200)
							courier:SetHealth(200)
							Timers:CreateTimer(60, function()
								courier:SetBaseMaxHealth(courier:GetBaseMaxHealth() + 200)
								courier:SetMaxHealth(courier:GetMaxHealth() + 200)
								return 60
							end)
						end
					end
				end)
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
	ContainersHelper:CreateShops()
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
				hero:SetNetworkableEntityInfo("unit_name", GetFullHeroName(hero))
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
			if not IsPlayerAbandoned(i) then
				if GetConnectionState(i) == DOTA_CONNECTION_STATE_CONNECTED then
					PLAYER_DATA[i].AutoAbandonGameTime = nil
				elseif GetConnectionState(i) == DOTA_CONNECTION_STATE_DISCONNECTED then
					if not PLAYER_DATA[i].AutoAbandonGameTime then
						PLAYER_DATA[i].AutoAbandonGameTime = GameRules:GetGameTime() + DOTA_PLAYER_AUTOABANDON_TIME
						--GameRules:SendCustomMessage("#DOTA_Chat_DisconnectWaitForReconnect", i, -1)
					end
					local timeLeft = PLAYER_DATA[i].AutoAbandonGameTime - GameRules:GetGameTime()
					if not PLAYER_DATA[i].LastLeftNotify or timeLeft < PLAYER_DATA[i].LastLeftNotify - 60 then
						PLAYER_DATA[i].LastLeftNotify = timeLeft
						--GameRules:SendCustomMessage("#DOTA_Chat_DisconnectTimeRemainingPlural", i, math.round(timeLeft/60))
					end
					if timeLeft <= 0 then
						--GameRules:SendCustomMessage("#DOTA_Chat_PlayerAbandonedDisconnectedTooLong", i, -1)
						MakePlayerAbandoned(i)
					end
				elseif GetConnectionState(i) == DOTA_CONNECTION_STATE_ABANDONED then
					--GameRules:SendCustomMessage("#DOTA_Chat_PlayerAbandoned", i, -1)
					MakePlayerAbandoned(i)
				end
			else
				local gold = Gold:GetGold(i)
				local allyCount = GetTeamPlayerCount(PlayerResource:GetTeam(i))
				local goldPerAlly = math.floor(gold/allyCount)
				Gold:RemoveGold(i, goldPerAlly * allyCount)
				for ally = 0, 23 do
					if PlayerResource:IsValidPlayerID(ally) and not IsPlayerAbandoned(ally) then
						if PlayerResource:GetTeam(ally) == PlayerResource:GetTeam(i) then
							Gold:ModifyGold(ally, goldPerAlly)
						end
					end
				end
			end
		end
	end
	return CUSTOM_GOLD_TICK_TIME
end