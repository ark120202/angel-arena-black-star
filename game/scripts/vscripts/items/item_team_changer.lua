function ChangeTeam(keys)
	local caster = keys.caster
	local ability = keys.ability
	if not caster:IsRealHero() or Duel:IsDuelOngoing() then
		return
	end
	local playerID = caster:GetPlayerID()
	--TODO Меню для смены в мультитим режиме
	local targetTeam = DOTA_TEAM_BADGUYS
	local oldTeam = caster:GetTeamNumber()
	if oldTeam == targetTeam then
		targetTeam = DOTA_TEAM_GOODGUYS
	end
	if (GetTeamPlayerCount(targetTeam) >= GetTeamPlayerCount(oldTeam) or GetTeamHeroKills(targetTeam) >= GetTeamHeroKills(oldTeam)) and not IsInToolsMode() then
		return
	end
	PlayerTables:RemovePlayerSubscription("dynamic_minimap_points_" .. oldTeam, playerID)

	local gold = Gold:GetGold(caster)
	local playerPickData = {}
	local tableData = PlayerTables:GetTableValue("hero_selection", oldTeam)
	if tableData and tableData[playerID] then
		table.merge(playerPickData, tableData[playerID])
		tableData[playerID] = nil
		PlayerTables:SetTableValue("hero_selection", oldTeam, tableData)
	end

	for _,v in ipairs(FindAllOwnedUnits(caster:GetPlayerOwner())) do
		v:SetTeam(targetTeam)
	end
	caster:GetPlayerOwner():SetTeam(targetTeam)

	PlayerResource:UpdateTeamSlot(playerID, targetTeam, 1)
	PlayerResource:SetCustomTeamAssignment(playerID, targetTeam)
	local fountain = FindFountain(targetTeam)
	FindClearSpaceForUnit(caster, fountain:GetAbsOrigin(), true)

	local newTableData = PlayerTables:GetTableValue("hero_selection", targetTeam)
	if newTableData and playerPickData then
		newTableData[playerID] = playerPickData
		PlayerTables:SetTableValue("hero_selection", targetTeam, newTableData)
	end
	Gold:SetGold(caster, gold)
	for _, v in ipairs(Entities:FindAllByClassname("npc_dota_courier") ) do
		v:SetControllableByPlayer(playerID, v:GetTeamNumber() == targetTeam)
	end
	PlayerTables:RemovePlayerSubscription("dynamic_minimap_points_" .. oldTeam, playerID)
	PlayerTables:AddPlayerSubscription("dynamic_minimap_points_" .. targetTeam, playerID)
	CustomGameEventManager:Send_ServerToPlayer(caster:GetPlayerOwner(), "arena_team_changed_update", {})
	PlayerResource:RefreshSelection()
	
	SpendCharge(ability, 1)
end

function OnAttacked(keys)
	local ability = keys.ability
	local attacker = keys.attacker
	if attacker then
		local attacker_name = attacker:GetUnitName()
		if keys.Damage > 0 and ((attacker.IsControllableByAnyPlayer and attacker:IsControllableByAnyPlayer()) or IsBossEntity(attacker)) then
			ability:StartCooldown(ability:GetLevelSpecialValueFor("attacked_cooldown", ability:GetLevel() - 1))
		end
	end
end