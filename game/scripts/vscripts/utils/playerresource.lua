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
	local v = self:GetPlayerStat(PlayerID, key) + value
	self:SetPlayerStat(PlayerID, key, v)
	return v
end

function CDOTA_PlayerResource:SetPlayerTeam(playerID, newTeam)
	local oldTeam = self:GetTeam(playerID)
	local player = self:GetPlayer(playerID)
	local hero = self:GetSelectedHeroEntity(playerID)
	PlayerTables:RemovePlayerSubscription("dynamic_minimap_points_" .. oldTeam, playerID)
	local playerPickData = {}
	local tableData = PlayerTables:GetTableValue("hero_selection", oldTeam)
	if tableData and tableData[playerID] then
		table.merge(playerPickData, tableData[playerID])
		tableData[playerID] = nil
		PlayerTables:SetTableValue("hero_selection", oldTeam, tableData)
	end

	for _,v in ipairs(FindAllOwnedUnits(player)) do
		v:SetTeam(newTeam)
	end
	player:SetTeam(newTeam)

	PlayerResource:UpdateTeamSlot(playerID, newTeam, 1)
	PlayerResource:SetCustomTeamAssignment(playerID, newTeam)

	local newTableData = PlayerTables:GetTableValue("hero_selection", newTeam)
	if newTableData and playerPickData then
		newTableData[playerID] = playerPickData
		PlayerTables:SetTableValue("hero_selection", newTeam, newTableData)
	end
	--[[for _, v in ipairs(Entities:FindAllByClassname("npc_dota_courier") ) do
		v:SetControllableByPlayer(playerID, v:GetTeamNumber() == newTeam)
	end]]
	--FindCourier(oldTeam):SetControllableByPlayer(playerID, false)
	local targetCour = FindCourier(newTeam)
	if IsValidEntity(targetCour) then
		targetCour:SetControllableByPlayer(playerID, true)
	end
	PlayerTables:RemovePlayerSubscription("dynamic_minimap_points_" .. oldTeam, playerID)
	PlayerTables:AddPlayerSubscription("dynamic_minimap_points_" .. newTeam, playerID)

	for i = 0, hero:GetAbilityCount() - 1 do
		local skill = hero:GetAbilityByIndex(i)
		if skill then
			--print(skill.GetIntrinsicModifierName and skill:GetIntrinsicModifierName())
			if skill.GetIntrinsicModifierName and skill:GetIntrinsicModifierName() then
				RecreateAbility(hero, skill)
			end
		end
	end

	CustomGameEventManager:Send_ServerToPlayer(player, "arena_team_changed_update", {})
	PlayerResource:RefreshSelection()
end

function CDOTA_PlayerResource:SetDisableHelpForPlayerID(nPlayerID, nOtherPlayerID, disabled)
	if nPlayerID ~= nOtherPlayerID then
		if not PLAYER_DATA[nPlayerID].DisableHelp then
			PLAYER_DATA[nPlayerID].DisableHelp = {}
		end
		PLAYER_DATA[nPlayerID].DisableHelp[nOtherPlayerID] = disabled

		local disable_help_data = PlayerTables:GetTableValue("disable_help_data", nPlayerID)
		disable_help_data[nOtherPlayerID] = PLAYER_DATA[nPlayerID][nOtherPlayerID]
		PlayerTables:SetTableValue("disable_help_data", disable_help_data)
	end
end

function CDOTA_PlayerResource:IsDisableHelpSetForPlayerID(nPlayerID, nOtherPlayerID)
	return PLAYER_DATA[nPlayerID] ~= nil and PLAYER_DATA[nPlayerID].DisableHelp ~= nil and PLAYER_DATA[nPlayerID].DisableHelp[nOtherPlayerID] and PlayerResource:GetTeam(nPlayerID) == PlayerResource:GetTeam(nOtherPlayerID)
end

function CDOTA_PlayerResource:KickPlayer(nPlayerID)
	local usid = PLAYER_DATA[nPlayerID].UserID
	if usid then
		SendToServerConsole("kickid " .. usid)
		return true
	end
	return false
end
