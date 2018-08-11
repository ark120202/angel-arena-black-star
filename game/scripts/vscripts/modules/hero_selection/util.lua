function HeroSelection:CheckEndHeroSelection()
	local canEnd = false --HeroSelection:GetState() < HERO_SELECTION_PHASE_END and GameRules:IsCheatMode()
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

function HeroSelection:GetSelectedHeroName(playerId)
	local status = HeroSelection:GetPlayerStatus(playerId)
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
	--TODO: Get hero's unique growth
	local armorForFirstLevel = Attributes:GetTotalPropValue(attributes["attribute_base_1"], "armor")
	attributes.armor = attributes.armor + math.round(armorForFirstLevel)
	return attributes
end

function TransformUnitClass(unit, classTable, skipAbilityRemap)
	if not skipAbilityRemap then
		for i = 0, unit:GetAbilityCount() - 1 do
			if unit:GetAbilityByIndex(i) then
				unit:RemoveAbility(unit:GetAbilityByIndex(i):GetName())
			end
		end
		if Options:IsEquals("EnableAbilityShop", false) and Options:IsEquals("EnableRandomAbilities", false) then
			for i = 1, 24 do
				if classTable["Ability" .. i] and classTable["Ability" .. i] ~= "" then
					PrecacheItemByNameAsync(classTable["Ability" .. i], function() end)
					unit:AddNewAbility(classTable["Ability" .. i])
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
			unit:SetNetworkableEntityInfo("AttackRate", value)
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
		if key == "RenderColor" then
			local r,g,b = unpack(string.split(value))
			r,g,b = tonumber(r), tonumber(g), tonumber(b)
			unit:SetRenderColor(r, g, b)
			for _, child in ipairs(unit:GetChildren()) do
				if child:GetClassname() == "dota_item_wearable" and child:GetModelName() ~= "" then
					child:SetRenderColor(r, g, b)
				end
			end
		end
	end
end

function HeroSelection:ForceChangePlayerHeroMenu(playerId)
	PlayerResource:ModifyPlayerStat(playerId, "ChangedHeroAmount", 1)
	HeroSelection:ChangeHero(playerId, FORCE_PICKED_HERO, true, 0, nil, function(hero)
		hero:AddNoDraw()
		FindClearSpaceForUnit(hero, FindFountain(PlayerResource:GetTeam(playerId)):GetAbsOrigin(), true)
		hero:AddNewModifier(hero, nil, "modifier_hero_selection_transformation", nil)
		hero.ForcedHeroChange = true
		Timers:CreateTimer(function()
			local player = PlayerResource:GetPlayer(playerId)
			if not PlayerResource:IsPlayerAbandoned(playerId) and player and IsValidEntity(hero) and not hero.ChangingHeroProcessRunning then
				CustomGameEventManager:Send_ServerToPlayer(player, "metamorphosis_elixir_show_menu", {forced = true})
				return 0.5
			end
		end)
	end)
end

function HeroSelection:VerifyHeroGroup(hero)
	local herolist = ENABLED_HEROES[Options:GetValue("MainHeroList")]
	if herolist then
		return herolist[hero] == 1
	end
	return false
end

function HeroSelection:ParseAbilitiesFromTable(t)
	local abilities = {}
	for i = 1, 24 do
		local ability = t["Ability" .. i]
		if ability and
			ability ~= "" and
			not string.starts(ability, "special_bonus_") and
			not AbilityHasBehaviorByName(ability, "DOTA_ABILITY_BEHAVIOR_HIDDEN") then
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
		local hero = HeroSelection.RandomableHeroes[RandomInt(1, #HeroSelection.RandomableHeroes)]
		if not HeroSelection:IsHeroSelected(hero) and
			not HeroSelection:IsHeroBanned(hero) and
			not HeroSelection:IsHeroDisabledInRanked(hero) then
			HeroSelection:UpdateStatusForPlayer(playerId, "picked", hero)
			Chat:SendSystemMessage({
				localizable = "DOTA_Chat_Random",
				variables = {
					["%s1"] = "{player}",
					["%s2"] = hero
				},
				player = playerId
			}, PlayerResource:GetTeam(playerId))
			Gold:ModifyGold(playerId, CUSTOM_GOLD_FOR_RANDOM_TOTAL)
			break
		end
	end
end

function HeroSelection:NominateHeroForBan(playerId, hero)
	if not HeroSelection:IsHeroBanned(hero) then
		Chat:SendSystemMessage({
			localizable = "DOTA_Chat_AD_NominatedBan",
			variables = {
				["%s1"] = hero
			}
		})

		PLAYER_DATA[playerId].HeroSelectionBanned = true
		PlayerTables:SetTableValue("hero_selection_banning_phase", hero, playerId)
	end
end

function HeroSelection:IsHeroBanned(hero)
	return PlayerTables:GetTableValueForReadOnly("hero_selection_banning_phase", hero) ~= nil
end

function HeroSelection:IsHeroDisabledInRanked(hero)
	return Options:IsEquals("EnableRatingAffection") and GetKeyValue(hero, "DisabledInRanked") == 1
end

function HeroSelection:IsHeroUnreleased(hero)
	return GetKeyValue(hero, "Unreleased") == 1
end

function HeroSelection:IsHeroPickAvaliable(hero)
	return not HeroSelection:IsHeroSelected(hero) and
		not HeroSelection:IsHeroBanned(hero) and
		not HeroSelection:IsHeroDisabledInRanked() and
		not HeroSelection:IsHeroUnreleased() and
		HeroSelection:VerifyHeroGroup(hero)
end

function HeroSelection:GetLinkedHeroNames(hero)
	local linked = GetKeyValue(hero, "LinkedHero")
	return linked and string.split(linked, " | ") or {}
end
