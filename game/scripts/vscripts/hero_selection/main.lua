if not HeroSelection then
	HeroSelection = class({})
	HeroSelection.SelectionEnd = false
	HeroSelection.RandomableHeroes = {}
	HeroSelection.EmptyStateData = {
		hero = "npc_dota_hero_abaddon",
		status = "hover"
	}
	HeroSelection.CurrentState = HERO_SELECTION_PHASE_NOT_STARTED
end

require("hero_selection/util")
require("hero_selection/linked")
require("hero_selection/hero_selection")
require("hero_selection/client_actions")

HERO_SELECTION_PHASE_NOT_STARTED = 0
HERO_SELECTION_PHASE_BANNING = 1
HERO_SELECTION_PHASE_HERO_PICK = 2
HERO_SELECTION_PHASE_STRATEGY = 3
HERO_SELECTION_PHASE_END = 4

HERO_SELECTION_PICK_TIME = 80
HERO_SELECTION_STRATEGY_TIME = 35 + 10000
HERO_SELECTION_BANNING_TIME = 25


function HeroSelection:Initialize()
	if not HeroSelection._initialized then
		HeroSelection._initialized = true
		GameRules:SetHeroSelectionTime(-1)
		GameRules:SetPreGameTime(HERO_SELECTION_PICK_TIME + HERO_SELECTION_STRATEGY_TIME + 3.75 + PRE_GAME_TIME)
		CustomGameEventManager:RegisterListener("hero_selection_player_hover", Dynamic_Wrap(HeroSelection, "OnHeroHover"))
		CustomGameEventManager:RegisterListener("hero_selection_player_select", Dynamic_Wrap(HeroSelection, "OnHeroSelectHero"))
		CustomGameEventManager:RegisterListener("hero_selection_player_random", Dynamic_Wrap(HeroSelection, "OnHeroRandomHero"))
		CustomGameEventManager:RegisterListener("hero_selection_minimap_set_spawnbox", Dynamic_Wrap(HeroSelection, "OnMinimapSetSpawnbox"))
		CustomGameEventManager:RegisterListener("hero_selection_player_repick", Dynamic_Wrap(HeroSelection, "OnHeroRepick"))
	end
	Convars:RegisterCommand("arena_hero_selection_skip_phase", function()
		if HeroSelection.CurrentState == HERO_SELECTION_PHASE_BANNING then
			HeroSelection:StartStateHeroPick()
		elseif HeroSelection.CurrentState == HERO_SELECTION_PHASE_HERO_PICK then
			HeroSelection:StartStateStrategy()
		elseif HeroSelection.CurrentState == HERO_SELECTION_PHASE_STRATEGY then
			HeroSelection:StartStateInGame({})
		end
	end, "Skips current phase", FCVAR_CHEAT)
end

function HeroSelection:PrepareTables()
	local data = {
		HeroSelectionState = HeroSelection.CurrentState,
		HeroTabs = {}
	}
	local heroesData = {}
	for name, baseData in pairs(NPC_HEROES_CUSTOM) do
		if baseData.Enabled ~= 0 then
			local heroTable = GetHeroTableByName(name)
			local tabIndex = heroTable.base_hero and 2 or 1
			local heroData = {
				model = heroTable.base_hero or name,
				custom_scene_camera = heroTable.SceneCamera,
				custom_scene_image = heroTable.SceneImage,
				attributes = HeroSelection:ExtractHeroStats(heroTable),
				tabIndex = tabIndex
			}

			if DOTA_ACTIVE_GAMEMODE_TYPE == DOTA_GAMEMODE_TYPE_ALLPICK then
				heroData.abilities = HeroSelection:ParseAbilitiesFromTable(heroTable)
				heroData.border_class = heroTable.BorderClass
				if heroTable.LinkedHero then
					heroData.linked_heroes = string.split(heroTable.LinkedHero, " | ")
				end
				if not heroData.border_class and heroTable.Changed == 1 and tabIndex == 1 then
					heroData.border_class = "Border_Changed"
				end
			end
			heroesData[name] = heroData
		end
	end
	for name,enabled in pairsByKeys(ENABLED_HEROES[ARENA_ACTIVE_GAMEMODE_MAP == ARENA_GAMEMODE_MAP_CUSTOM_ABILITIES and "NoAbilities" or "Selection"]) do
		if enabled == 1 then
			if not heroesData[name] then
				error("Hero from enabled hero list is not a valid hero")
			end
			local tabIndex = heroesData[name].tabIndex
			if not data.HeroTabs[tabIndex] then data.HeroTabs[tabIndex] = {} end
			table.insert(data.HeroTabs[tabIndex], name)
		end
	end
	for k,v in pairs(heroesData) do
		if not v.linked_heroes then
			table.insert(HeroSelection.RandomableHeroes, k)
		end
	end
	PlayerTables:CreateTable("hero_selection_heroes_data", heroesData, AllPlayersInterval)
	PlayerTables:CreateTable("hero_selection_available_heroes", data, AllPlayersInterval)
	--PlayerTables:CreateTable("hero_selection_repicked_players", {}, AllPlayersInterval)
end

function HeroSelection:SetTimerDuration(duration)
	PlayerTables:SetTableValue("hero_selection_available_heroes", "TimerEndTime", GameRules:GetGameTime() + duration)
end

function HeroSelection:SetState(state)
	HeroSelection.CurrentState = state
	PlayerTables:SetTableValue("hero_selection_available_heroes", "HeroSelectionState", state)
end

function HeroSelection:GetState()
	return HeroSelection.CurrentState
end

function HeroSelection:HeroSelectionStart()
	GameRules:GetGameModeEntity():SetAnnouncerDisabled(true)
	if DOTA_ACTIVE_GAMEMODE_TYPE == DOTA_GAMEMODE_TYPE_RANKED_ALLPICK then
		EmitAnnouncerSound("ann_custom_mode_05")
		HeroSelection:SetState(HERO_SELECTION_PHASE_BANNING)
		HeroSelection:SetTimerDuration(HERO_SELECTION_BANNING_TIME)
		HeroSelection.GameStartTimer = Timers:CreateTimer(HERO_SELECTION_BANNING_TIME, function()
			HeroSelection:StartStateHeroPick()
		end)
	else
		HeroSelection:StartStateHeroPick()
	end
end

function HeroSelection:StartStateHeroPick()
	EmitAnnouncerSound("ann_custom_draft_01")
	HeroSelection:SetState(HERO_SELECTION_PHASE_HERO_PICK)
	HeroSelection:SetTimerDuration(HERO_SELECTION_PICK_TIME)
	for _,sec in ipairs({30, 15, 10, 5}) do
		Timers:CreateTimer(HERO_SELECTION_PICK_TIME - sec, function()
			EmitAnnouncerSound("ann_custom_timer_sec_" .. sec)
		end)
	end
	HeroSelection.GameStartTimer = Timers:CreateTimer(HERO_SELECTION_PICK_TIME, function()
		HeroSelection:StartStateStrategy()
	end)
end

function HeroSelection:StartStateStrategy()
	if HeroSelection.SelectionEnd then
		return
	end
	HeroSelection.SelectionEnd = true
	Timers:RemoveTimer(HeroSelection.GameStartTimer)
	HeroSelection:PreformRandomForNotPickedUnits()
	local toPrecache = {}
	for team,_v in pairs(PlayerTables:GetAllTableValues("hero_selection")) do
		for plyId,v in pairs(_v) do
			local heroNameTransformed = GetKeyValue(v.hero, "base_hero") or v.hero
			toPrecache[heroNameTransformed] = false
			PrecacheUnitByNameAsync(heroNameTransformed, function()
				toPrecache[heroNameTransformed] = true
				--CustomGameEventManager:Send_ServerToAllClients("hero_selection_update_precache_progress", toPrecache)
			end, plyId)
		end
	end
	--CustomGameEventManager:Send_ServerToAllClients("hero_selection_update_precache_progress", toPrecache)
	GameRules:GetGameModeEntity():SetAnnouncerDisabled(DISABLE_ANNOUNCER)
	--CustomGameEventManager:Send_ServerToAllClients("hero_selection_show_precache", {})
	
	HeroSelection:SetTimerDuration(HERO_SELECTION_STRATEGY_TIME)
	HeroSelection:SetState(HERO_SELECTION_PHASE_STRATEGY)
	HeroSelection.GameStartTimer = Timers:CreateTimer(HERO_SELECTION_STRATEGY_TIME, function()
		HeroSelection:StartStateInGame(toPrecache)
	end)
end

function HeroSelection:StartStateInGame(toPrecache)
	DeepPrintTable(toPrecache)
	Timers:RemoveTimer(HeroSelection.GameStartTimer)

	--If for some reason even after that time heroes weren't precached
	Timers:CreateTimer({
		useGameTime = false,
		callback = function()
			PauseGame(true)
			local canEnd = true
			for k,v in pairs(toPrecache) do
				if not v then
					canEnd = false
					break
				end
			end
			if canEnd then
				--Actually enter in-game state
				HeroSelection:SetState(HERO_SELECTION_PHASE_END)
				Timers:CreateTimer({
					useGameTime = false,
					endTime = 3.75,
					callback = function()
						for team,_v in pairs(PlayerTables:GetAllTableValues("hero_selection")) do
							for plyId,v in pairs(_v) do
								HeroSelection:SelectHero(plyId, tostring(v.hero), nil, true)
							end
						end
						PauseGame(false)
						GameMode:OnHeroSelectionEnd()
					end
				})
			else
				return 0.1
			end
		end
	})
end