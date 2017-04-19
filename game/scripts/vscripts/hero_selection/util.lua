function HeroSelection:CheckEndHeroSelection()
	local canEnd = not HeroSelection.SelectionEnd and GameRules:IsCheatMode()
	for team,_v in pairs(PlayerTables:GetAllTableValuesForReadOnly("hero_selection")) do
		for plyId,v in pairs(_v) do
			if v.status ~= "picked" then
				canEnd = false
				break
			end
		end
	end
	if canEnd then
		HeroSelection:StartStateStrategy()
	end
end

function HeroSelection:PreformRandomForNotPickedUnits()
	for team,_v in pairs(PlayerTables:GetAllTableValuesForReadOnly("hero_selection")) do
		for plyId,v in pairs(_v) do
			if v.status ~= "picked" then
				HeroSelection:PreformPlayerRandom(plyId)
			end
		end
	end
end

function HeroSelection:GetSelectedHeroName(playerID)
	local status = HeroSelection:GetPlayerStatus(playerID)
	if status and status.status == "picked" then
		return status.hero
	end
end

function HeroSelection:IsHeroSelected(heroName)
	for team,_v in pairs(PlayerTables:GetAllTableValuesForReadOnly("hero_selection")) do
		for plyId,v in pairs(_v) do
			if v.hero == heroName and v.status == "picked" then
				return true
			end
		end
	end
	return false
end

function HeroSelection:GetSelectedHeroPlayer(hero)
	for team,_v in pairs(PlayerTables:GetAllTableValuesForReadOnly("hero_selection")) do
		for plyId,v in pairs(_v) do
			if v.hero == hero and v.status == "picked" then
				return plyId
			end
		end
	end
end

function HeroSelection:ExtractHeroStats(heroTable)
	local attributes = {
		attribute_primary = _G[heroTable.AttributePrimary],
		attribute_base_0 = heroTable.AttributeBaseStrength,
		attribute_base_1 = heroTable.AttributeBaseAgility,
		attribute_base_2 = heroTable.AttributeBaseIntelligence,
		attribute_gain_0 = heroTable.AttributeStrengthGain,
		attribute_gain_1 = heroTable.AttributeAgilityGain,
		attribute_gain_2 = heroTable.AttributeIntelligenceGain,
		damage_min = tonumber(heroTable.AttackDamageMin),
		damage_max = tonumber(heroTable.AttackDamageMax),
		movespeed = heroTable.MovementSpeed,
		attackrate = heroTable.AttackRate,
		armor = heroTable.ArmorPhysical,
		team = heroTable.Team
	}
	attributes.damage_min = attributes.damage_min + attributes["attribute_base_" .. attributes.attribute_primary]
	attributes.damage_max = attributes.damage_max + attributes["attribute_base_" .. attributes.attribute_primary]
	attributes.armor = attributes.armor + math.round(attributes["attribute_base_1"] * DEFAULT_ARMOR_PER_AGI)
	return attributes
end

function TransformUnitClass(unit, classTable, skipAbilityRemap)
	if not skipAbilityRemap then
		for i = 0, unit:GetAbilityCount() - 1 do
			if unit:GetAbilityByIndex(i) then
				unit:RemoveAbility(unit:GetAbilityByIndex(i):GetName())
			end
		end
		if ARENA_ACTIVE_GAMEMODE_MAP ~= ARENA_GAMEMODE_MAP_CUSTOM_ABILITIES then
			for i = 1, 24 do
				if classTable["Ability" .. i] and classTable["Ability" .. i] ~= "" then
					PrecacheItemByNameAsync(classTable["Ability" .. i], function() end)
					AddNewAbility(unit, classTable["Ability" .. i])
				end
			end
		end
	end

	for key, value in pairs(classTable) do
		if key == "Level" then
			unit:SetLevel(value)
		elseif key == "Model" then
			unit.ModelOverride = value
			unit:SetModel(value)
			unit:SetOriginalModel(value)
		elseif key == "ModelScale" then
			unit:SetModelScale(value)
		elseif key == "ArmorPhysical" then
			unit:SetPhysicalArmorBaseValue(value)
		elseif key == "MagicalResistance" then
			unit:SetBaseMagicalResistanceValue(value)
		elseif key == "AttackCapabilities" then
			unit:SetAttackCapability(_G[value])
		elseif key == "AttackDamageMin" then
			unit:SetBaseDamageMin(value)
		elseif key == "AttackDamageMax" then
			unit:SetBaseDamageMax(value)
		elseif key == "AttackRate" then
			unit:SetBaseAttackTime(value)
		elseif key == "AttackAcquisitionRange" then
			unit:SetAcquisitionRange(value)
		elseif key == "ProjectileModel" then
			unit:SetRangedProjectileName(value)
		elseif key == "AttributePrimary" then
			Timers:CreateTimer(0.1, function()
				unit:SetPrimaryAttribute(_G[value])
			end)
		elseif key == "AttributeBaseStrength" then
			unit:SetBaseStrength(value)
		elseif key == "AttributeStrengthGain" then
			unit.CustomGain_Strength = value
			unit:SetNetworkableEntityInfo("AttributeStrengthGain", value)
		elseif key == "AttributeBaseIntelligence" then
			unit:SetBaseIntellect(value)
		elseif key == "AttributeIntelligenceGain" then
			unit.CustomGain_Intelligence = value
			unit:SetNetworkableEntityInfo("AttributeIntelligenceGain", value)
		elseif key == "AttributeBaseAgility" then
			unit:SetBaseAgility(value)
		elseif key == "AttributeAgilityGain" then
			unit.CustomGain_Agility = value
			unit:SetNetworkableEntityInfo("AttributeAgilityGain", value)
		elseif key == "BountyXP" then
			unit:SetDeathXP(value)
		elseif key == "BountyGoldMin" then
			unit:SetMinimumGoldBounty(value)
		elseif key == "BountyGoldMax" then
			unit:SetMaximumGoldBounty(value)
		elseif key == "RingRadius" then
			unit:SetHullRadius(value)
		elseif key == "MovementCapabilities" then
			unit:SetMoveCapability(value)
		elseif key == "MovementSpeed" then
			unit:SetBaseMoveSpeed(value)
		elseif key == "StatusHealth" then
			unit:SetBaseMaxHealth(value)
		elseif key == "StatusHealthRegen" then
			unit:SetBaseHealthRegen(value)
		elseif key == "StatusMana" then
			--TODO
			--unit:(value)
		elseif key == "StatusManaRegen" then
			unit:SetBaseManaRegen(value)
		elseif key == "VisionDaytimeRange" then
			unit:SetDayTimeVisionRange(value)
		elseif key == "VisionNighttimeRange" then
			unit:SetNightTimeVisionRange(value)
		elseif key == "HasInventory" then
			--TODO Check
			unit:SetHasInventory(toboolean(value))
		elseif key == "AttackRange" then
			unit:AddNewModifier(unit, nil, "modifier_set_attack_range", {AttackRange = value})
		end
	end
end

function HeroSelection:InitializeHeroClass(unit, classTable)
	for key, value in pairs(classTable) do
		if key == "Modifiers" then
			for _,v in ipairs(string.split(value)) do
				unit:AddNewModifier(unit, nil, v, nil)
			end
		end
	end
end

function HeroSelection:ForceChangePlayerHeroMenu(playerID)
	HeroSelection:ChangeHero(playerID, FORCE_PICKED_HERO, true, 0, nil, function(hero)
		hero:AddNoDraw()
		FindClearSpaceForUnit(hero, FindFountain(PlayerResource:GetTeam(playerID)):GetAbsOrigin(), true)
		hero:AddNewModifier(hero, nil, "modifier_hero_selection_transformation", nil)
		hero.ForcedHeroChange = true
		Timers:CreateTimer(function()
			local player = PlayerResource:GetPlayer(playerID)
			if not IsPlayerAbandoned(playerID) and player and IsValidEntity(hero) and not hero.ChangingHeroProcessRunning then
				CustomGameEventManager:Send_ServerToPlayer(player, "metamorphosis_elixir_show_menu", {forced = true})
				return 0.5
			end
		end)
	end)
end

function HeroSelection:VerifyHeroGroup(hero, group)
	if ARENA_ACTIVE_GAMEMODE_MAP == ARENA_GAMEMODE_MAP_CUSTOM_ABILITIES then
		return ENABLED_HEROES.NoAbilities[hero] == 1
	else
		local herolist = ENABLED_HEROES[group]
		if herolist then
			return herolist[hero] == 1
		end
	end
end

function HeroSelection:ParseAbilitiesFromTable(t)
	local abilities = {}
	for i = 1, 24 do
		local ability = t["Ability" .. i]
		if ability and ability ~= "" and not AbilityHasBehaviorByName(ability, "DOTA_ABILITY_BEHAVIOR_HIDDEN") then
			table.insert(abilities, ability)
		end
	end
	return abilities
end

function HeroSelection:CollectPD()
	PlayerTables:CreateTable("hero_selection", {}, AllPlayersInterval)
	for i = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:IsValidPlayerID(i) and PlayerResource:IsValidTeamPlayer(i) then
			local team = PlayerResource:GetTeam(i)
			if team and team >= 2 then
				local storageData = PlayerTables:GetTableValue("hero_selection", team)
				if not storageData then storageData = {} end
				if not storageData[i] then
					storageData[i] = HeroSelection.EmptyStateData
					PlayerTables:SetTableValue("hero_selection", team, storageData)
				end
			end
		end
	end
end

function HeroSelection:GetPlayerStatus(playerId)
	local td = PlayerTables:GetTableValueForReadOnly("hero_selection", PlayerResource:GetTeam(playerId))
	if td and td[playerId] then
		return table.deepcopy(td[playerId])
	end
	return table.deepcopy(HeroSelection.EmptyStateData)
end

function HeroSelection:UpdateStatusForPlayer(playerId, status, hero, bForNotPicked)
	local tableData = PlayerTables:GetTableValue("hero_selection", PlayerResource:GetTeam(playerId))
	if tableData and (not bForNotPicked or not tableData[playerId] or tableData[playerId].status ~= "picked") then
		if not tableData[playerId] then tableData[playerId] = {} end
		if hero then
			tableData[playerId].hero = hero
		end
		if status then
			tableData[playerId].status = status
		end
		PlayerTables:SetTableValue("hero_selection", PlayerResource:GetTeam(playerId), tableData)
		return true
	end
	return false
end

function HeroSelection:PreformPlayerRandom(playerId)
	while true do
		local heroKey = HeroSelection.RandomableHeroes[RandomInt(1, #HeroSelection.RandomableHeroes)].heroKey
		if not HeroSelection:IsHeroSelected(heroKey) then
			HeroSelection:UpdateStatusForPlayer(playerId, "picked", heroKey)
			Gold:ModifyGold(playerId, CUSTOM_GOLD_FOR_RANDOM_TOTAL)
			break
		end
	end
end