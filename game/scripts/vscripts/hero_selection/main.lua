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
HERO_SELECTION_PHASE_ALLPICK = 2
HERO_SELECTION_PHASE_STRATEGY = 3
HERO_SELECTION_PHASE_END = 4

HERO_SELECTION_PICK_TIME = 80
HERO_SELECTION_STRATEGY_TIME = 35 + 10000


function HeroSelection:Initialize()
	if not HeroSelection._initialized then
		HeroSelection._initialized = true
		GameRules:SetHeroSelectionTime(-1)
		GameRules:SetPreGameTime(HERO_SELECTION_PICK_TIME + HERO_SELECTION_STRATEGY_TIME + 3.75 + PRE_GAME_TIME)
		CustomGameEventManager:RegisterListener("hero_selection_player_hover", Dynamic_Wrap(HeroSelection, "OnHeroHover"))
		CustomGameEventManager:RegisterListener("hero_selection_player_select", Dynamic_Wrap(HeroSelection, "OnHeroSelectHero"))
		CustomGameEventManager:RegisterListener("hero_selection_player_random", Dynamic_Wrap(HeroSelection, "OnHeroRandomHero"))
		CustomGameEventManager:RegisterListener("hero_selection_minimap_set_spawnbox", Dynamic_Wrap(HeroSelection, "OnMinimapSetSpawnbox"))
	end
end

function HeroSelection:PrepareTables()
	local data = {
		HeroSelectionState = HeroSelection.CurrentState,
		HeroTabs = {}
	}
	if DOTA_ACTIVE_GAMEMODE_TYPE == DOTA_GAMEMODE_TYPE_ALLPICK then
		for name,enabled in pairsByKeys(ENABLED_HEROES.Selection) do
			if enabled == 1 then
				local heroTable = GetHeroTableByName(name)
				local tabIndex = 1
				if heroTable.base_hero then
					tabIndex = 2
				end
				local heroData = {
					heroKey = name,
					model = heroTable.base_hero or name,
					custom_scene_camera = heroTable.SceneCamera,
					custom_scene_image = heroTable.SceneImage,
					abilities = HeroSelection:ParseAbilitiesFromTable(heroTable),
					border_class = heroTable.BorderClass,
					attributes = HeroSelection:ExtractHeroStats(heroTable)
				}
				if heroTable.LinkedHero then
					heroData.linked_heroes = string.split(heroTable.LinkedHero, " | ")
				end
				if not heroData.border_class and heroTable.Changed == 1 and tabIndex == 1 then
					heroData.border_class = "Border_Changed"
				end
				if not data.HeroTabs[tabIndex] then data.HeroTabs[tabIndex] = {} end
				table.insert(data.HeroTabs[tabIndex], heroData)
			end
		end
	elseif ARENA_ACTIVE_GAMEMODE_MAP == ARENA_GAMEMODE_MAP_CUSTOM_ABILITIES then
		if ENABLED_HEROES.NoAbilities then
			for name,enabled in pairsByKeys(ENABLED_HEROES.NoAbilities) do
				if enabled == 1 then
					local heroTable = GetHeroTableByName(name)
					local tabIndex = 1
					if heroTable.base_hero then
						tabIndex = 2
					end
					local heroData = {
						heroKey = name,
						model = heroTable.base_hero or name,
						custom_scene_camera = heroTable.SceneCamera,
						custom_scene_image = heroTable.SceneImage,
						attributes = HeroSelection:ExtractHeroStats(heroTable)
					}
					if not data.HeroTabs[tabIndex] then data.HeroTabs[tabIndex] = {} end
					table.insert(data.HeroTabs[tabIndex], heroData)
				end
			end
		end
	end
	HeroSelection.ModeData = data
	for _,v in ipairs(data.HeroTabs) do
		for _,ht in ipairs(v) do
			if not ht.linked_heroes then
				table.insert(HeroSelection.RandomableHeroes, ht)
			end
		end
	end
	PlayerTables:CreateTable("hero_selection_available_heroes", data, AllPlayersInterval)
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
	if BANNING_PHASE_ENABLED then --Ranked
		HeroSelection:SetState(HERO_SELECTION_PHASE_BANNING)
	else
		HeroSelection:SetState(HERO_SELECTION_PHASE_ALLPICK)
		self:SetTimerDuration(HERO_SELECTION_PICK_TIME)
		HeroSelection.GameStartTimer = Timers:CreateTimer(HERO_SELECTION_PICK_TIME, function()
			HeroSelection:PreformGameStart()
		end)
	end
end

function HeroSelection:PreformGameStart()
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
		HeroSelection:EndStrategyTime(toPrecache)
	end)
end

function HeroSelection:EndStrategyTime(toPrecache)
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