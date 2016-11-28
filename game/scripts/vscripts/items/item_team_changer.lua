function ChangeTeam(keys)
	local caster = keys.caster
	local ability = keys.ability
	local playerID = caster:GetPlayerID()
	if not caster:IsRealHero() or PLAYER_DATA[playerID].ChangedTeam or Duel:IsDuelOngoing() then
		return
	end
	--TODO Меню для смены в мультитим режиме
	local targetTeam = DOTA_TEAM_BADGUYS
	if caster:GetTeamNumber() == targetTeam then
		targetTeam = DOTA_TEAM_GOODGUYS
	end

	if GetTeamPlayerCount(targetTeam) >= GetTeamPlayerCount(caster:GetTeamNumber()) then
		return
	end
	PlayerTables:RemovePlayerSubscription("dynamic_minimap_points_" .. caster:GetTeamNumber(), playerID)

	PLAYER_DATA[playerID].ChangedTeam = true
	local gold = caster:GetGold()
	local playerPickData
	local tableData = PlayerTables:GetTableValue("hero_selection", caster:GetTeamNumber())
	if tableData and tableData[playerID] then
		playerPickData = tableData[playerID]
		tableData[playerID] = nil
		PlayerTables:SetTableValue("hero_selection", caster:GetTeamNumber(), tableData)
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
	if newTableData and newTableData[playerID] then
		newTableData[playerID] = playerPickData
		PlayerTables:SetTableValue("hero_selection", targetTeam, newTableData)
	end
	Gold:SetGold(caster, gold)

	local couriers = Entities:FindAllByName("npc_dota_courier") 
	if couriers then
		for i, v in ipairs(couriers) do
			if v and v:GetTeamNumber() == targetTeam then
				v:SetControllableByPlayer(playerID, true)
			end
		end
	end
	PlayerTables:AddPlayerSubscription("dynamic_minimap_points_" .. targetTeam, playerID)
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