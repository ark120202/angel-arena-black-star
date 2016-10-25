if HeroSelection == nil then
	_G.HeroSelection = class({})
	HeroSelection.SelectionEnd = false
	HeroSelection.HeroesData = {}
end

function HeroSelection:Initialize()
	if not HeroSelection._initialized then
		HeroSelection._initialized = true
		CustomGameEventManager:RegisterListener("hero_selection_player_hover", Dynamic_Wrap(HeroSelection, "OnHeroHover"))
		CustomGameEventManager:RegisterListener("hero_selection_player_select", Dynamic_Wrap(HeroSelection, "OnHeroSelectHero"))
		CustomGameEventManager:RegisterListener("hero_selection_player_random", Dynamic_Wrap(HeroSelection, "OnHeroRandomHero"))
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

function HeroSelection:PrepareTables()
	if DOTA_ACTIVE_GAMEMODE_TYPE == DOTA_GAMEMODE_TYPE_ALLPICK then
		local originalAbilitiesTable = {}
		local alternativeAbilitiesTable = {}
		local data = {
			GameModeType = "all_pick",
			SelectionTime = CUSTOM_HERO_SELECTION_TIME,
			HeroTabs = {
				{
					title = "#hero_selection_tab_heroes_normal",
					Heroes = {}
				},
				{
					title = "#hero_selection_tab_heroes_alternative",
					Heroes = {}
				}
			}
		}
		for name,enabled in pairsByKeys(HEROLIST) do
			if enabled == 1 then
				local heroTable = GetOriginalHeroTable(name)
				local abilities = {}
				for i = 1, 16 do
					local ability = heroTable["Ability" .. i]
					if ability and ability ~= "" and ability ~= "attribute_bonus" and ability ~= "attribute_bonus_arena" and not AbilityHasBehaviorByName(ability, DOTA_ABILITY_BEHAVIOR_HIDDEN) then
						table.insert(abilities, ability)
					end
				end
				originalAbilitiesTable[name] = abilities
			end
		end
		for name,_ in pairs(NPC_HEROES_ALTERNATIVE) do
			local heroTable = GetAlternativeHeroTable(name)
			local abilities = {}
			for i = 1, 16 do
				local ability = heroTable["Ability" .. i]
				if ability and ability ~= "" and ability ~= "attribute_bonus" and ability ~= "attribute_bonus_arena" and not AbilityHasBehaviorByName(ability, DOTA_ABILITY_BEHAVIOR_HIDDEN) then
					table.insert(abilities, ability)
				end
			end
			alternativeAbilitiesTable[name] = abilities
		end
		local players = GetAllPlayers(false)
		local teamsPlayers = {}
		for _,v in ipairs(players) do
			local playerId = v:GetPlayerID()
			local team = PlayerResource:GetTeam(playerId)
			if not teamsPlayers[team] then teamsPlayers[team] = {} end
			teamsPlayers[team][playerId] = {
				hero="npc_dota_hero_abaddon",
				status="hover",
			}
		end
		local HeroesHeaven = {}
		local HeroesHell = {}
		for category,contents in pairsByKeys(ENABLED_HEROES) do
			for name,enabled in pairsByKeys(contents) do
				if enabled == 1 then
					local heroTable
					local baseName = name
					local abilityTbl = originalAbilitiesTable
					local tabIndex = 1
					local isChanged = false
					if string.starts(baseName, "alternative_") then
						baseName = string.sub(baseName, 13)
						heroTable = GetAlternativeHeroTable(baseName)
						abilityTbl = alternativeAbilitiesTable
						tabIndex = 2
					else
						heroTable = GetOriginalHeroTable(name)
						isChanged = heroTable.Changed == 1
					end
					local heroData = {
						heroKey = name,
						model = heroTable.ModelUnitName or name,
						custom_scene_camera = heroTable.SceneCamera,
						custom_scene_image = heroTable.SceneImage,
						abilities = abilityTbl[baseName],
						isChanged = isChanged,
						attributes = HeroSelection:ExtractHeroStats(heroTable),
					}
					if category == "Selection" then
						table.insert(data.HeroTabs[tabIndex].Heroes, heroData)
					elseif category == "Heaven" then
						table.insert(HeroesHeaven, heroData)
					elseif category == "Hell" then
						table.insert(HeroesHell, heroData)
					end
				end
			end
		end
		PlayerTables:CreateTable("hero_selection_available_heroes_heaven", HeroesHeaven, {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23})
		PlayerTables:CreateTable("hero_selection_available_heroes_hell", HeroesHell, {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23})
		HeroSelection.ModeData = data
	elseif DOTA_ACTIVE_GAMEMODE_TYPE == DOTA_GAMEMODE_TYPE_RANDOM_OMG or DOTA_ACTIVE_GAMEMODE_TYPE == DOTA_GAMEMODE_TYPE_ABILITY_SHOP then
		local originalAbilitiesTable = {}
		local alternativeAbilitiesTable = {}
		local data = {
			GameModeType = "random_omg",
			SelectionTime = CUSTOM_HERO_SELECTION_TIME,
			HeroTabs = {
				{
					title = "#hero_selection_tab_heroes_normal",
					Heroes = {}
				}
			}
		}
		if DOTA_ACTIVE_GAMEMODE_TYPE == DOTA_GAMEMODE_TYPE_ABILITY_SHOP then
			data.GameModeType = "ability_shop"
		end
		local players = GetAllPlayers(false)
		local teamsPlayers = {}
		for _,v in ipairs(players) do
			local playerId = v:GetPlayerID()
			local team = PlayerResource:GetTeam(playerId)
			if not teamsPlayers[team] then teamsPlayers[team] = {} end
			teamsPlayers[team][playerId] = {
				hero="npc_dota_hero_abaddon",
				status="hover",
			}
		end
		if ENABLED_HEROES.NoAbilities then
			for name,enabled in pairsByKeys(ENABLED_HEROES.NoAbilities) do
				if enabled == 1 then
					local heroTable
					if string.starts(name, "alternative_") then
						heroTable = GetAlternativeHeroTable(string.sub(name, 13))
					else
						heroTable = GetOriginalHeroTable(name)
					end
					local heroData = {
						heroKey = name,
						model = heroTable.ModelUnitName or name,
						custom_scene_camera = heroTable.SceneCamera,
						custom_scene_image = heroTable.SceneImage,
						attributes = HeroSelection:ExtractHeroStats(heroTable),
					}
					table.insert(data.HeroTabs[1].Heroes, heroData)
				end
			end
		end
		PlayerTables:CreateTable("hero_selection_available_heroes_heaven", {disabled = true}, {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23})
		PlayerTables:CreateTable("hero_selection_available_heroes_hell", {disabled = true}, {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23})
		HeroSelection.ModeData = data
	end
end

function HeroSelection:HeroSelectionStart()
	GameRules:GetGameModeEntity():SetAnnouncerDisabled(true)
	HeroSelection._TimerCounter = CUSTOM_HERO_SELECTION_TIME
	HeroSelection.GameStartTimer = Timers:CreateTimer(1, function()
		if HeroSelection._TimerCounter > 0 then
			HeroSelection._TimerCounter = HeroSelection._TimerCounter - 1
			PlayerTables:SetTableValue("hero_selection_available_heroes", "SelectionTime", HeroSelection._TimerCounter)
			return 1
		elseif not HeroSelection.SelectionEnd then
			HeroSelection:PreformGameStart()
		end
	end)
	PlayerTables:CreateTable("hero_selection_available_heroes", HeroSelection.ModeData, {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23})
end

function HeroSelection:PreformGameStart()
	if HeroSelection.SelectionEnd then
		return
	end
	print("PREFORMING GAME START!")
	HeroSelection.SelectionEnd = true
	Timers:RemoveTimer(HeroSelection.GameStartTimer)
	HeroSelection:PreformRandomForNotPickedUnits()
	local toPrecache = {}
	for team,_v in pairs(PlayerTables:GetAllTableValues("hero_selection")) do
		for plyId,v in pairs(_v) do
			local heroNameTransformed = v.hero
			if string.starts(heroNameTransformed, "alternative_") then
				heroNameTransformed = string.sub(heroNameTransformed, 13)
			end
			toPrecache[heroNameTransformed] = false
			PrecacheUnitByNameAsync(heroNameTransformed, function() toPrecache[heroNameTransformed] = true end, plyId)
			--HeroSelection:OnSelectHero(plyId, tostring(v.hero))
		end
	end
	GameRules:GetGameModeEntity():SetAnnouncerDisabled( DISABLE_ANNOUNCER )
	
	PauseGame(true)
	CustomGameEventManager:Send_ServerToAllClients("hero_selection_show_precache", {})
	Timers:CreateTimer({
		useGameTime = false,
		callback = function()
			local canEnd = true
			for k,v in pairs(toPrecache) do
				if not v then
					canEnd = false
				end
			end
			if canEnd then
				CustomGameEventManager:Send_ServerToAllClients("hero_selection_hide", {})
				Timers:CreateTimer({
					useGameTime = false,
					endTime = 3.75,
					callback = function()
						for team,_v in pairs(PlayerTables:GetAllTableValues("hero_selection")) do
							for plyId,v in pairs(_v) do
								HeroSelection:OnSelectHero(plyId, tostring(v.hero), nil, true)
							end
						end
						Tutorial:ForceGameStart()
						PauseGame(false)
						Timers:CreateTimer(4 - 3.75, function()
							CustomGameEventManager:Send_ServerToAllClients("time_show", {})
						end)
					end
				})
			else
				return 0.1
			end
		end
	})
end

function HeroSelection:PreformRandomForNotPickedUnits()
	for team,_v in pairs(PlayerTables:GetAllTableValues("hero_selection")) do
		for plyId,v in pairs(_v) do
			if v.status ~= "picked" then
				HeroSelection:PreformPlayerRandom(plyId)
			end
		end
	end
end

function HeroSelection:PreformPlayerRandom(playerId)
	local heroes = {}

	for _,v in ipairs(HeroSelection.ModeData.HeroTabs) do
		for _,ht in ipairs(v.Heroes) do
			table.insert(heroes, ht)
		end
	end

	while true do
		local heroData = heroes[RandomInt(1, #heroes)]

		if not HeroSelection:IsHeroSelected(heroData.heroKey) then
			local tableData = PlayerTables:GetTableValue("hero_selection", PlayerResource:GetTeam(playerId))
			tableData[playerId] = {
				hero=heroData.heroKey,
				status="picked", 
			}
			PlayerTables:SetTableValue("hero_selection", PlayerResource:GetTeam(playerId), tableData)
			Gold:ModifyGold(playerId, GOLD_FOR_RANDOM_HERO, true)
			break
		end
	end
end

function HeroSelection:IsHeroSelected(heroName)
	for team,_v in pairs(PlayerTables:GetAllTableValues("hero_selection")) do
		for plyId,v in pairs(_v) do
			if v.status == "picked" and v.hero == heroName then
				return true
			end
		end
	end
	return false
end

function HeroSelection:OnSelectHero(playerId, heroKey, callback, bSkipPrecache)
	local newHeroName = heroKey
	local alternative = false
	if string.starts(newHeroName, "alternative_") then
		alternative = true
		newHeroName = string.sub(newHeroName, 13)
	end
	HeroSelection:SelectHero(playerId, newHeroName, alternative, callback, bSkipPrecache)

	local team = PlayerResource:GetTeam(playerId)
	local tableData = PlayerTables:GetTableValue("hero_selection", team)
	if not HeroSelection:IsHeroSelected(heroKey) and tableData and tableData[playerId] then
		tableData[playerId] = {
			hero=heroKey,
			status="picked"
		}
		PlayerTables:SetTableValue("hero_selection", team, tableData)
	end
end

function HeroSelection:SelectHero(playerId, heroName, bAlternative, callback, bSkipPrecache)
	Timers:CreateTimer(function()
		local connectionState = PlayerResource:GetConnectionState(playerId)
		if connectionState == DOTA_CONNECTION_STATE_CONNECTED then

			local function SpawnHero()
				Timers:CreateTimer(function()
					connectionState = PlayerResource:GetConnectionState(playerId)
					if connectionState == DOTA_CONNECTION_STATE_CONNECTED then
						local oldhero = PlayerResource:GetSelectedHeroEntity(playerId)
						local hero
						if oldhero then
							hero = PlayerResource:ReplaceHeroWith(playerId, heroName, 0, 0)
						else
							hero = CreateHeroForPlayer(heroName, PlayerResource:GetPlayer(playerId))
						end
					--	hero:RespawnHero(false, true, false)
						local heroTableAlternative = NPC_HEROES_ALTERNATIVE[heroName]
						if bAlternative and heroTableAlternative and heroTableAlternative["Enabled"] ~= 0 then
							TransformUnitClass(hero, heroTableAlternative)
							hero.IsAlternative = true
						end
						if DOTA_ACTIVE_GAMEMODE_TYPE == DOTA_GAMEMODE_TYPE_ABILITY_SHOP then
							for i = 0, hero:GetAbilityCount() - 1 do
								if hero:GetAbilityByIndex(i) then
									hero:RemoveAbility(hero:GetAbilityByIndex(i):GetName())
								end
							end
							hero:AddAbility("ability_empty")
							hero:AddAbility("ability_empty")
							hero:AddAbility("ability_empty")
							hero:AddAbility("ability_empty")
							hero:AddAbility("ability_empty")
							hero:AddAbility("ability_empty")
						end
						if callback then callback(hero) end
					else
						return 0.1
					end
				end)
			end

			if bSkipPrecache then
				SpawnHero()
			else
				PrecacheUnitByNameAsync(heroName, SpawnHero, playerId)
			end
		else
			return 0.1
		end
	end)
end

function HeroSelection:RemoveAllOwnedUnits(playerId)
	local player = PlayerResource:GetPlayer(playerId)
	local hero = PlayerResource:GetSelectedHeroEntity(playerId)
	for _,v in ipairs(FindAllOwnedUnits(player)) do
		if v ~= hero then
			v:ForceKill(false)
			UTIL_Remove(v)
		end
	end
end

function HeroSelection:OnHeroHover(data)
	local tableData = PlayerTables:GetTableValue("hero_selection", PlayerResource:GetTeam(data.playerId))
	if not HeroSelection.SelectionEnd and tableData[data.playerId].status ~= "picked" then
		tableData[data.playerId] = {
			hero=data.hero,
			status="hover"
		}
	end
	PlayerTables:SetTableValue("hero_selection", PlayerResource:GetTeam(data.playerId), tableData)
end

function HeroSelection:OnHeroRandomHero(data)
	local team = PlayerResource:GetTeam(data.playerId)
	local tableData = PlayerTables:GetTableValue("hero_selection", PlayerResource:GetTeam(data.playerId))
	if not HeroSelection.SelectionEnd and tableData and tableData[data.playerId] and tableData[data.playerId].status and tableData[data.playerId].status ~= "picked" then
		HeroSelection:PreformPlayerRandom(data.playerId)
	end

	local canEnd = not HeroSelection.SelectionEnd
	for team,_v in pairs(PlayerTables:GetAllTableValues("hero_selection")) do
		for plyId,v in pairs(_v) do
			if v.status ~= "picked" then
				canEnd = false
				break
			end
		end
	end
	if canEnd then
		HeroSelection:PreformGameStart()
	end
end

function HeroSelection:OnHeroSelectHero(data)
	local team = PlayerResource:GetTeam(data.playerId)
	local tableData = PlayerTables:GetTableValue("hero_selection", PlayerResource:GetTeam(data.playerId))
	if not HeroSelection.SelectionEnd and not HeroSelection:IsHeroSelected(tostring(data.hero)) and tableData and tableData[data.playerId] and tableData[data.playerId].status and tableData[data.playerId].status ~= "picked" then
		tableData[data.playerId] = {
			hero=data.hero,
			status="picked"
		}
		PlayerTables:SetTableValue("hero_selection", PlayerResource:GetTeam(data.playerId), tableData)
		local newHeroName = data.hero
		if string.starts(data.hero, "alternative_") then
			newHeroName = string.sub(data.hero, 13)
		end
		PrecacheUnitByNameAsync(newHeroName, function() end, data.playerId)
	end

	local canEnd = not HeroSelection.SelectionEnd
	for team,_v in pairs(PlayerTables:GetAllTableValues("hero_selection")) do
		for plyId,v in pairs(_v) do
			if v.status ~= "picked" then
				canEnd = false
				break
			end
		end
	end
	if canEnd then
		HeroSelection:PreformGameStart()
	end
end

function HeroSelection:CollectPD()
	PlayerTables:CreateTable("hero_selection", {}, {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23})
	for i = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:IsValidPlayerID(i) and PlayerResource:IsValidTeamPlayer(i) then
			local team = PlayerResource:GetTeam(i)
			if team and team >= 2 then
				local storageData = PlayerTables:GetTableValue("hero_selection", team)
				if not storageData then storageData = {} end
				if not storageData[i] then
					storageData[i] = {
						hero="npc_dota_hero_abaddon",
						status="hover",
					}
					PlayerTables:SetTableValue("hero_selection", team, storageData)
				end
			end
		end
	end
end

function HeroSelection:ChangeHero(playerId, newHeroName, keepGold, keepExp, duration, item, transformationModifierName)
	local hero = PlayerResource:GetSelectedHeroEntity(playerId)
	if hero.PocketItem then
		hero.PocketHostEntity = nil
		UTIL_Remove(hero.PocketItem)
		hero.PocketItem = nil
	end
	for _,v in ipairs(hero:FindAllModifiers()) do
		v:Destroy()
	end
	item:ApplyDataDrivenModifier(hero, hero, transformationModifierName, {})
	local gold = hero:GetGold()
	local xp = hero:GetCurrentXP()
	local fountatin = FindFountain(PlayerResource:GetTeam(playerId))
	local location = hero:GetAbsOrigin()
	if fountatin then location = location or fountatin:GetAbsOrigin() end
	local items = {}
	for i = 0, 11 do
		local citem  = hero:GetItemInSlot(i)
		if citem and citem ~= item then
			local newItem = CreateItem(citem:GetName(), nil, nil)
			if citem:GetPurchaser() ~= hero then
				newItem.NotPurchasedByOwner = true
				newItem:SetPurchaser(citem:GetPurchaser())
			end
			newItem:SetPurchaseTime(citem:GetPurchaseTime())
			newItem:SetCurrentCharges(citem:GetCurrentCharges())
			if citem:GetCooldownTimeRemaining() > 0 then
				newItem.SavedCooldown = citem:GetCooldownTimeRemaining()
			end
			table.insert(items, newItem)
		else
			table.insert(items, CreateItem("item_dummy", hero, hero))
		end
	end
	HeroSelection:RemoveAllOwnedUnits(playerId)
	local startTime = GameRules:GetDOTATime(true, true)
	HeroSelection:OnSelectHero(playerId, newHeroName, function(newHero)
		item:ApplyDataDrivenModifier(newHero, newHero, transformationModifierName, {})
		if keepGold then
			newHero:SetGold(gold, true)
		end
		FindClearSpaceForUnit(newHero, location, true)
		if keepExp then
			newHero:AddExperience(xp, 0, true, true)
		end
		for _,v in ipairs(items) do
			v:SetOwner(newHero)
			if not v.NotPurchasedByOwner then
				v:SetPurchaser(newHero)
				v.NotPurchasedByOwner = nil
			end
			if v.SavedCooldown then
				v:StartCooldown(v.SavedCooldown)
				v.SavedCooldown = nil
			end
			newHero:AddItem(v)
		end
		for i = 0, 11 do
			local citem = newHero:GetItemInSlot(i)
			if citem and citem:GetName() == "item_dummy" then
				UTIL_Remove(citem)
			end
		end
		Timers:CreateTimer(duration - (GameRules:GetDOTATime(true, true) - startTime), function()
			newHero:RemoveModifierByName(transformationModifierName)
		end)
	end)
end

--[[
		"AttackDamageType"		"DAMAGE_TYPE_ArmorPhysical"
		"AttackAnimationPoint"		"0.750000"
		"AttackRange"		"600"
		"ProjectileSpeed"		"900"
		"BoundsHullName"		"DOTA_HULL_SIZE_HERO"
		"MovementTurnRate"		"0.500000"			
		"HealthBarOffset"		"-1"
]]
function TransformUnitClass(unit, classTable)
	for i = 0, unit:GetAbilityCount() - 1 do
		if unit:GetAbilityByIndex(i) then
			unit:RemoveAbility(unit:GetAbilityByIndex(i):GetName())
		end
	end
	if DOTA_ACTIVE_GAMEMODE_TYPE ~= DOTA_GAMEMODE_TYPE_RANDOM_OMG and DOTA_ACTIVE_GAMEMODE_TYPE ~= DOTA_GAMEMODE_TYPE_ABILITY_SHOP then
		for i = 1, 16 do
			if classTable["Ability" .. i] and classTable["Ability" .. i] ~= "" then
				PrecacheItemByNameAsync(classTable["Ability" .. i], function() end)
				AddNewAbility(unit, classTable["Ability" .. i])
			end
		end
	end

	--TODO Make sure that it works
	for key, value in pairs(classTable) do
		if key == "Level" then
			unit:SetLevel(value)
		elseif key == "Model" then
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
			--TODO
			--unit:(value)
		elseif key == "AttributeBaseIntelligence" then
			unit:SetBaseIntellect(value)
		elseif key == "AttributeIntelligenceGain" then
			--unit:(value)
		elseif key == "AttributeBaseAgility" then
			unit:SetBaseAgility(value)
		elseif key == "AttributeAgilityGain" then
			--unit:(value)
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
			if value == 150 then
				unit:AddNewModifier(unit, nil, "modifier_custom_attack_range_melee", nil)
			end
		elseif key == "HideWearables" and value == 1 then
			unit.WearablesRemoved = true
			for _,v in pairs(unit:GetChildren()) do
				if v:GetClassname() == "dota_item_wearable" then
					v:SetModel("models/development/invisiblebox.vmdl")
					--child:RemoveSelf()
				end
			end
		end
	end
end