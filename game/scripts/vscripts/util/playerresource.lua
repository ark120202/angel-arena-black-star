function CDOTA_PlayerResource:SetPlayerStat(PlayerID, key, value)
	local pd = PLAYER_DATA[PlayerID]
	if not pd.HeroStats then pd.HeroStats = {} end
	pd.HeroStats[key] = value
end

function CDOTA_PlayerResource:GetPlayerStat(PlayerID, key)
	local pd = PLAYER_DATA[PlayerID]
	return pd.HeroStats == nil and 0 or (pd.HeroStats[key] or 0)
end

function CDOTA_PlayerResource:ModifyPlayerStat(PlayerID, key, value)
	local v = PlayerResource:GetPlayerStat(PlayerID, key) + value
	PlayerResource:SetPlayerStat(PlayerID, key, v)
	return v
end

function CDOTA_PlayerResource:SetPlayerTeam(playerId, newTeam)
	local oldTeam = PlayerResource:GetTeam(playerId)
	local hero = PlayerResource:GetSelectedHeroEntity(playerId)
	PlayerTables:RemovePlayerSubscription("dynamic_minimap_points_" .. oldTeam, playerId)
	local playerPickData = {}
	local tableData = PlayerTables:GetTableValue("hero_selection", oldTeam)
	if tableData and tableData[playerId] then
		table.merge(playerPickData, tableData[playerId])
		tableData[playerId] = nil
		PlayerTables:SetTableValue("hero_selection", oldTeam, tableData)
	end

	GameRules:SetCustomGameTeamMaxPlayers(newTeam, GameRules:GetCustomGameTeamMaxPlayers(newTeam) + 1)
	for _,v in ipairs(FindAllOwnedUnits(playerId)) do
		v:SetTeam(newTeam)
	end
	PlayerResource:UpdateTeamSlot(playerId, newTeam, 1)
	PlayerResource:SetCustomTeamAssignment(playerId, newTeam)
	GameRules:SetCustomGameTeamMaxPlayers(oldTeam, GameRules:GetCustomGameTeamMaxPlayers(oldTeam) - 1)

	local newTableData = PlayerTables:GetTableValue("hero_selection", newTeam)
	if newTableData and playerPickData then
		newTableData[playerId] = playerPickData
		PlayerTables:SetTableValue("hero_selection", newTeam, newTableData)
	end

	PlayerTables:RemovePlayerSubscription("dynamic_minimap_points_" .. oldTeam, playerId)
	PlayerTables:AddPlayerSubscription("dynamic_minimap_points_" .. newTeam, playerId)

	for i = 0, hero:GetAbilityCount() - 1 do
		local skill = hero:GetAbilityByIndex(i)
		if skill then
			--print(skill.GetIntrinsicModifierName and skill:GetIntrinsicModifierName())
			if (
				skill.GetIntrinsicModifierName and
				skill:GetIntrinsicModifierName() and
				skill:GetAbilityName() ~= "meepo_divided_we_stand"
		 	) then
				RecreateAbility(hero, skill)
			end
		end
	end

	Teams:RecalculateKillWeight(oldTeam)
	Teams:RecalculateKillWeight(newTeam)

	local player = PlayerResource:GetPlayer(playerId)
	if player then
		CustomGameEventManager:Send_ServerToPlayer(player, "arena_team_changed_update", {})
	end
end

function CDOTA_PlayerResource:SetDisableHelpForPlayerID(nPlayerID, nOtherPlayerID, disabled)
	if nPlayerID == nOtherPlayerID then return end
	-- TODO: Add all other share masks
	PlayerResource:SetUnitShareMaskForPlayer(nPlayerID, nOtherPlayerID, 4, disabled)

	local disable_help_data = PlayerTables:GetTableValue("disable_help_data", nPlayerID)
	disable_help_data[nOtherPlayerID] = PLAYER_DATA[nPlayerID][nOtherPlayerID]
	PlayerTables:SetTableValue("disable_help_data", disable_help_data)
end

-- Unused
function CDOTA_PlayerResource:IsDisableHelpSetForPlayerID(nPlayerID, nOtherPlayerID)
	return (
		PlayerResource:GetTeam(nPlayerID) == PlayerResource:GetTeam(nOtherPlayerID) and
		bit.band(PlayerResource:GetUnitShareMaskForPlayer(nPlayerID, nOtherPlayerID), 4) == 4
	)
end

function CDOTA_PlayerResource:KickPlayer(playerId)
	-- userid is always playerId + 1
	SendToServerConsole("kickid " .. playerId + 1)
end

function CDOTA_PlayerResource:IsPlayerAbandoned(playerId)
	return PLAYER_DATA[playerId].IsAbandoned == true
end

function CDOTA_PlayerResource:IsBanned(playerId)
	return PLAYER_DATA[playerId].isBanned == true
end

function CDOTA_PlayerResource:MakePlayerAbandoned(playerId)
	if PlayerResource:IsPlayerAbandoned(playerId) then return end
	PlayerResource:RemoveAllUnits(playerId)
	local heroname = HeroSelection:GetSelectedHeroName(playerId)
	--local notLinked = true
	if heroname then
		Notifications:TopToAll({hero=heroname, duration=10})
		Notifications:TopToAll({text=PlayerResource:GetPlayerName(playerId), continue=true, style={color=ColorTableToCss(PLAYER_DATA[playerId].Color or {0, 0, 0})}})
		Notifications:TopToAll({text="#game_player_abandoned_game", continue=true})

		for _,v in ipairs(HeroSelection:GetLinkedHeroNames(heroname)) do
			local linkedHeroOwner = HeroSelection:GetSelectedHeroPlayer(v)
			if linkedHeroOwner then
				HeroSelection:ForceChangePlayerHeroMenu(linkedHeroOwner)
			end
		end
	end
	--if notLinked then
		HeroSelection:UpdateStatusForPlayer(playerId, "hover", "npc_dota_hero_abaddon")
	--end
	PLAYER_DATA[playerId].IsAbandoned = true
	PlayerTables:SetTableValue("players_abandoned", playerId, true)
	Teams:RecalculateKillWeight(PlayerResource:GetTeam(playerId))
	if not GameRules:IsCheatMode() then
		local teamLeft = GetOneRemainingTeam()
		if teamLeft then
			Timers:CreateTimer(30, function()
				local teamLeft = GetOneRemainingTeam()
				if teamLeft then
					GameMode:OnOneTeamLeft(teamLeft)
				end
			end)
		end
	end

	Duel:EndIfFinished()
end

function CDOTA_PlayerResource:RemoveAllUnits(playerId)
	RemoveAllOwnedUnits(playerId)

	local hero = PlayerResource:GetSelectedHeroEntity(playerId)
	if not IsValidEntity(hero) then return end
	if not hero:IsAlive() then
		hero:RespawnHero(false, false)
	end

	hero:ClearNetworkableEntityInfo()
	hero:Stop()

	for i = 0, hero:GetAbilityCount() - 1 do
		local ability = hero:GetAbilityByIndex(i)
		if ability then
			if ability:GetKeyValue("NoAbandonCleanup") ~= 1 then
				ability:SetLevel(0)
			end
			ability:SetHidden(true)
			ability:SetActivated(false)
		end
	end

	hero:InterruptMotionControllers(false)
	hero:DestroyAllModifiers()
	hero:AddNewModifier(hero, nil, "modifier_hero_out_of_game", nil)
end

function CDOTA_PlayerResource:GetRealSteamID(PlayerID)
	local id = tostring(PlayerResource:GetSteamID(PlayerID))
	return id == "0" and tostring(PlayerID) or id
end
