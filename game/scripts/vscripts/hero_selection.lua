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
		CustomGameEventManager:RegisterListener("hero_selection_minimap_set_spawnbox", Dynamic_Wrap(HeroSelection, "OnMinimapSetSpawnbox"))
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
	local data = {
		SelectionTime = CUSTOM_HERO_SELECTION_TIME
	}
	if DOTA_ACTIVE_GAMEMODE_TYPE == DOTA_GAMEMODE_TYPE_ALLPICK then
		data.HeroTabs = {{
				Heroes = {}
			},
			{
				Heroes = {}
			}
		}
		for category,contents in pairsByKeys(ENABLED_HEROES) do
			for name,enabled in pairsByKeys(contents) do
				if enabled == 1 and category == "Selection" then
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
						isChanged = heroTable.Changed == 1 and tabIndex == 1,
						attributes = HeroSelection:ExtractHeroStats(heroTable),
					}
					table.insert(data.HeroTabs[tabIndex].Heroes, heroData)
				end
			end
		end
		HeroSelection.ModeData = data
	elseif ARENA_ACTIVE_GAMEMODE_MAP == ARENA_GAMEMODE_MAP_CUSTOM_ABILITIES then
		data.HeroTabs = {
			{
				Heroes = {}
			}
		}
		if ENABLED_HEROES.NoAbilities then
			for name,enabled in pairsByKeys(ENABLED_HEROES.NoAbilities) do
				if enabled == 1 then
					local heroTable = GetHeroTableByName(name)
					local heroData = {
						heroKey = name,
						model = heroTable.base_hero or name,
						custom_scene_camera = heroTable.SceneCamera,
						custom_scene_image = heroTable.SceneImage,
						attributes = HeroSelection:ExtractHeroStats(heroTable),
					}
					table.insert(data.HeroTabs[1].Heroes, heroData)
				end
			end
		end
		HeroSelection.ModeData = data
	end
	PlayerTables:CreateTable("hero_selection_available_heroes", HeroSelection.ModeData, {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23})
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
	for i = 1, 16 do
		local ability = t["Ability" .. i]
		if ability and ability ~= "" and ability ~= "attribute_bonus" and ability ~= "attribute_bonus_arena" and not AbilityHasBehaviorByName(ability, "DOTA_ABILITY_BEHAVIOR_HIDDEN") then
			table.insert(abilities, ability)
		end
	end
	return abilities
end

function HeroSelection:HeroSelectionStart()
	GameRules:GetGameModeEntity():SetAnnouncerDisabled(true)
	PlayerTables:SetTableValue("hero_selection_available_heroes", "SelectionStartTime", GameRules:GetGameTime())
	HeroSelection.GameStartTimer = Timers:CreateTimer(CUSTOM_HERO_SELECTION_TIME, function()
		if not HeroSelection.SelectionEnd then
			HeroSelection:PreformGameStart()
		end
	end)
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
			PrecacheUnitByNameAsync(heroNameTransformed, function() toPrecache[heroNameTransformed] = true end, plyId)
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
			if not tableData[playerId] then tableData[playerId] = {} end
			tableData[playerId].hero = heroData.heroKey
			tableData[playerId].status = "picked"
			PlayerTables:SetTableValue("hero_selection", PlayerResource:GetTeam(playerId), tableData)
			Gold:ModifyGold(playerId, CUSTOM_GOLD_FOR_RANDOM_TOTAL)
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
	HeroSelection:SelectHero(playerId, heroKey, callback, bSkipPrecache)

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

function HeroSelection:SelectHero(playerId, heroName, callback, bSkipPrecache)
	Timers:CreateTimer(function()
		local connectionState = PlayerResource:GetConnectionState(playerId)
		if connectionState == DOTA_CONNECTION_STATE_CONNECTED then
			local function SpawnHero()
				Timers:CreateTimer(function()
					connectionState = PlayerResource:GetConnectionState(playerId)
					if connectionState == DOTA_CONNECTION_STATE_CONNECTED then
--Start block
						local heroTableCustom = NPC_HEROES_CUSTOM[heroName]
						local oldhero = PlayerResource:GetSelectedHeroEntity(playerId)
						local hero
						local baseNewHero = heroTableCustom.base_hero or heroName
						if oldhero then
							if oldhero:GetUnitName() == baseNewHero then -- Base unit equals, ReplaceHeroWith won't do anything
								local temp = PlayerResource:ReplaceHeroWith(playerId, FORCE_PICKED_HERO, 0, 0)
								temp:AddNoDraw()
								hero = PlayerResource:ReplaceHeroWith(playerId, baseNewHero, 0, 0)
								Timers:CreateTimer(0.03, function()
									UTIL_Remove(temp)
								end)
							else
								hero = PlayerResource:ReplaceHeroWith(playerId, baseNewHero, 0, 0)
							end
						else
							hero = CreateHeroForPlayer(baseNewHero, PlayerResource:GetPlayer(playerId))
						end
						if heroTableCustom.base_hero then
							TransformUnitClass(hero, heroTableCustom)
							hero.UnitName = heroName
						end
--End block
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
				PrecacheUnitByNameAsync(GetKeyValue(heroName, "base_hero") or heroName, SpawnHero, playerId)
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
	local tableData = PlayerTables:GetTableValue("hero_selection", PlayerResource:GetTeam(data.PlayerID))
	if not HeroSelection.SelectionEnd and tableData[data.PlayerID].status ~= "picked" then
		if not tableData[data.PlayerID] then tableData[data.PlayerID] = {} end
		tableData[data.PlayerID].hero = data.hero
		tableData[data.PlayerID].status = "hover"
	end
	PlayerTables:SetTableValue("hero_selection", PlayerResource:GetTeam(data.PlayerID), tableData)
end

function HeroSelection:OnHeroRandomHero(data)
	local team = PlayerResource:GetTeam(data.PlayerID)
	local tableData = PlayerTables:GetTableValue("hero_selection", PlayerResource:GetTeam(data.PlayerID))
	if not HeroSelection.SelectionEnd and tableData and tableData[data.PlayerID] and tableData[data.PlayerID].status and tableData[data.PlayerID].status ~= "picked" then
		HeroSelection:PreformPlayerRandom(data.PlayerID)
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
	local team = PlayerResource:GetTeam(data.PlayerID)
	local tableData = PlayerTables:GetTableValue("hero_selection", PlayerResource:GetTeam(data.PlayerID))
	if not HeroSelection.SelectionEnd and not HeroSelection:IsHeroSelected(tostring(data.hero)) and tableData and tableData[data.PlayerID] and tableData[data.PlayerID].status and tableData[data.PlayerID].status ~= "picked" and HeroSelection:VerifyHeroGroup(tostring(data.hero), "Selection") then
		if not tableData[data.PlayerID] then tableData[data.PlayerID] = {} end
		tableData[data.PlayerID].hero = data.hero
		tableData[data.PlayerID].status = "picked"
		PlayerTables:SetTableValue("hero_selection", PlayerResource:GetTeam(data.PlayerID), tableData)
		local newHeroName = data.hero
		if string.starts(data.hero, "alternative_") then
			newHeroName = string.sub(data.hero, 13)
		end
		PrecacheUnitByNameAsync(newHeroName, function() end, data.PlayerID)
		Gold:ModifyGold(data.PlayerID, CUSTOM_STARTING_GOLD)
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

function HeroSelection:ChangeHero(playerId, newHeroName, keepExp, duration, item)
	local hero = PlayerResource:GetSelectedHeroEntity(playerId)
	if hero.PocketItem then
		hero.PocketHostEntity = nil
		UTIL_Remove(hero.PocketItem)
		hero.PocketItem = nil
	end
	for _,v in ipairs(hero:FindAllModifiers()) do
		v:Destroy()
	end
	hero:AddNewModifier(hero, nil, "modifier_hero_selection_transformation", nil)
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
		newHero:AddNewModifier(newHero, nil, "modifier_hero_selection_transformation", nil)
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
			newHero:RemoveModifierByName("modifier_hero_selection_transformation")
		end)
	end)
end

function HeroSelection:OnMinimapSetSpawnbox(data)
	local team = PlayerResource:GetTeam(data.PlayerID)

	local tableData = PlayerTables:GetTableValue("hero_selection", PlayerResource:GetTeam(data.PlayerID))
	if not HeroSelection.SelectionEnd then
		local SpawnBoxes = tableData[data.PlayerID].SpawnBoxes or {}
		local nd = (data.team or 2) .. "_" .. (data.level or 1) .. "_" .. (data.index or 0)
		if not table.contains(SpawnBoxes, nd) then
			if #SpawnBoxes >= MAX_SPAWNBOXES_SELECTED then
				table.remove(SpawnBoxes, 1)
			end
			table.insert(SpawnBoxes, nd)
		else
			table.removeByValue(SpawnBoxes, nd)
		end
		tableData[data.PlayerID].SpawnBoxes = SpawnBoxes
	end
	PlayerTables:SetTableValue("hero_selection", PlayerResource:GetTeam(data.PlayerID), tableData)
end




--[[
		"AttackDamageType"		"DAMAGE_TYPE_ArmorPhysical"
		"AttackAnimationPoint"		"0.750000"
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
	if ARENA_ACTIVE_GAMEMODE_MAP ~= ARENA_GAMEMODE_MAP_CUSTOM_ABILITIES then
		for i = 1, 24 do
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
			unit:AddNewModifier(unit, nil, "modifier_set_attack_range", {AttackRange = value})
		elseif key == "HideWearables" and value == 1 then
			unit.WearablesRemoved = true
			CustomWearables:RemoveDotaWearables(unit)
		end
	end
end