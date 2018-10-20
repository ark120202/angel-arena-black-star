-- The overall game state has changed
function GameMode:_OnGameRulesStateChange(keys)
	if GameMode._reentrantCheck then
		return
	end

	local newState = GameRules:State_Get()
	if newState == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		GameMode:OnAllPlayersLoaded()
	elseif newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		GameMode:OnGameInProgress()
	end

	GameMode._reentrantCheck = true
	GameMode:OnGameRulesStateChange(keys)
	GameMode._reentrantCheck = false
end

-- An NPC has spawned somewhere in game.  This includes heroes
function GameMode:_OnNPCSpawned(keys)
	if GameMode._reentrantCheck then
		return
	end

	local npc = EntIndexToHScript(keys.entindex)

	if npc:IsRealHero() and npc.bFirstSpawned == nil and HeroSelection:GetState() >= HERO_SELECTION_PHASE_END then
		npc.bFirstSpawned = true
		GameMode:OnHeroInGame(npc)
	end

	GameMode._reentrantCheck = true
	GameMode:OnNPCSpawned(keys)
	GameMode._reentrantCheck = false
end

-- An entity died
function GameMode:_OnEntityKilled(keys)
	if GameMode._reentrantCheck then
		return
	end

	GameMode._reentrantCheck = true
	DebugCallFunction(function()
		GameMode:OnEntityKilled(keys)
	end)
	GameMode._reentrantCheck = false
end

local firstPlayerLoaded = false
-- This function is called once when the player fully connects and becomes "Ready" during Loading
function GameMode:_OnConnectFull(keys)
	if GameMode._reentrantCheck then
		return
	end

	if not firstPlayerLoaded then
		self:OnFirstPlayerLoaded()
		firstPlayerLoaded = true
	end

	local userID = keys.userid
	-- TODO: is keys.index-1 player id?
	local entIndex = keys.index+1
	local ply = EntIndexToHScript(entIndex)
	PLAYER_DATA[ply:GetPlayerID()].UserID = userID

	GameMode._reentrantCheck = true
	GameMode:OnConnectFull(keys)
	GameMode._reentrantCheck = false
end
