-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function GameMode:_InitGameMode()
	if GameMode._reentrantCheck or GAMEMODE_INITIALIZATION_STATUS[1] then
		return
	end
	GAMEMODE_INITIALIZATION_STATUS[1] = true

	ListenToGameEvent('entity_killed', Dynamic_Wrap(GameMode, '_OnEntityKilled'), self)
	ListenToGameEvent('player_connect_full', Dynamic_Wrap(GameMode, '_OnConnectFull'), self)
	ListenToGameEvent('dota_item_picked_up', Dynamic_Wrap(GameMode, 'OnItemPickedUp'), self)
	ListenToGameEvent('tree_cut', Dynamic_Wrap(GameMode, 'OnTreeCut'), self)
	ListenToGameEvent('dota_player_used_ability', Dynamic_Wrap(GameMode, 'OnAbilityUsed'), self)
	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(GameMode, '_OnGameRulesStateChange'), self)
	ListenToGameEvent('npc_spawned', Dynamic_Wrap(GameMode, '_OnNPCSpawned'), self)
	ListenToGameEvent('dota_team_kill_credit', Dynamic_Wrap(GameMode, 'OnTeamKillCredit'), self)
	ListenToGameEvent("dota_item_combined", Dynamic_Wrap(GameMode, 'OnItemCombined'), self)

	-- Change random seed
	local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '^0+','')
	math.randomseed(tonumber(timeTxt))

	GameMode._reentrantCheck = true
	GameMode:InitGameMode()
	GameMode._reentrantCheck = false
end
