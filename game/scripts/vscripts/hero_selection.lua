if HeroSelection == nil then
	_G.HeroSelection = class({})
	HeroSelection.SelectionEnd = false
	HeroSelection.RandomableHeroes = {}
end
local bStartGameOnAllPlayersSelected = GameRules:IsCheatMode()
local bDebugPrecacheScreen = false
local emptyStateData = {
	hero = "npc_dota_hero_abaddon",
	status = "hover"
}
HERO_SELECTION_STATE_NOT_STARTED = 0
HERO_SELECTION_STATE_ALLPICK = 1
HERO_SELECTION_STATE_END = 2

function HeroSelection:Initialize()
	if not HeroSelection._initialized then
		HeroSelection._initialized = true
		CustomGameEventManager:RegisterListener("hero_selection_player_hover", Dynamic_Wrap(HeroSelection, "OnHeroHover"))
		CustomGameEventManager:RegisterListener("hero_selection_player_select", Dynamic_Wrap(HeroSelection, "OnHeroSelectHero"))
		CustomGameEventManager:RegisterListener("hero_selection_player_random", Dynamic_Wrap(HeroSelection, "OnHeroRandomHero"))
		CustomGameEventManager:RegisterListener("hero_selection_minimap_set_spawnbox", Dynamic_Wrap(HeroSelection, "OnMinimapSetSpawnbox"))
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
					storageData[i] = emptyStateData
					PlayerTables:SetTableValue("hero_selection", team, storageData)
				end
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

function HeroSelection:PrepareTables()
	local data = {
		SelectionTime = HERO_SELECTION_TIME,
		HeroSelectionState = HERO_SELECTION_STATE_ALLPICK,
	}
	if DOTA_ACTIVE_GAMEMODE_TYPE == DOTA_GAMEMODE_TYPE_ALLPICK then
		data.HeroTabs = {{
				Heroes = {}
			}, {
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
	for _,v in ipairs(HeroSelection.ModeData.HeroTabs) do
		for _,ht in ipairs(v.Heroes) do
			table.insert(self.RandomableHeroes, ht)
		end
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
	for i = 1, 24 do
		local ability = t["Ability" .. i]
		if ability and ability ~= "" and not AbilityHasBehaviorByName(ability, "DOTA_ABILITY_BEHAVIOR_HIDDEN") then
			table.insert(abilities, ability)
		end
	end
	return abilities
end

function HeroSelection:HeroSelectionStart()
	GameRules:GetGameModeEntity():SetAnnouncerDisabled(true)
	PlayerTables:SetTableValue("hero_selection_available_heroes", "SelectionStartTime", GameRules:GetGameTime())
	HeroSelection.GameStartTimer = Timers:CreateTimer(HERO_SELECTION_TIME, function()
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
			PrecacheUnitByNameAsync(heroNameTransformed, function()
				toPrecache[heroNameTransformed] = true
				CustomGameEventManager:Send_ServerToAllClients("hero_selection_update_precache_progress", toPrecache)
			end, plyId)
		end
	end
	CustomGameEventManager:Send_ServerToAllClients("hero_selection_update_precache_progress", toPrecache)
	GameRules:GetGameModeEntity():SetAnnouncerDisabled( DISABLE_ANNOUNCER )
	PauseGame(true)
	CustomGameEventManager:Send_ServerToAllClients("hero_selection_show_precache", {})
	Timers:CreateTimer({
		useGameTime = false,
		callback = function()
			PauseGame(true)
			local canEnd = not bDebugPrecacheScreen
			for k,v in pairs(toPrecache) do
				if not v then
					canEnd = false
					break
				end
			end
			if canEnd then
				--CustomGameEventManager:Send_ServerToAllClients("hero_selection_hide", {})
				PlayerTables:SetTableValue("hero_selection_available_heroes", "HeroSelectionState", HERO_SELECTION_STATE_END)
				Timers:CreateTimer({
					useGameTime = false,
					endTime = 3.75,
					callback = function()
						for team,_v in pairs(PlayerTables:GetAllTableValues("hero_selection")) do
							for plyId,v in pairs(_v) do
								HeroSelection:SelectHero(plyId, tostring(v.hero), nil, true)
							end
						end
						--Tutorial:ForceGameStart()
						PauseGame(false)
						GameMode:OnHeroSelectionEnd()
					end
				})
			else
				return 0.1
			end
		end
	})
end

function HeroSelection:CheckEndHeroSelection()
	local canEnd = not HeroSelection.SelectionEnd and bStartGameOnAllPlayersSelected
	for team,_v in pairs(PlayerTables:GetAllTableValuesForReadOnly("hero_selection")) do
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

function HeroSelection:PreformRandomForNotPickedUnits()
	for team,_v in pairs(PlayerTables:GetAllTableValuesForReadOnly("hero_selection")) do
		for plyId,v in pairs(_v) do
			if v.status ~= "picked" then
				HeroSelection:PreformPlayerRandom(plyId)
			end
		end
	end
end

function HeroSelection:PreformPlayerRandom(playerId)
	while true do
		local heroKey = self.RandomableHeroes[RandomInt(1, #self.RandomableHeroes)].heroKey
		if not HeroSelection:IsHeroSelected(heroKey) then
			self:UpdateStatusForPlayer(playerId, "picked", heroKey)
			Gold:ModifyGold(playerId, CUSTOM_GOLD_FOR_RANDOM_TOTAL)
			break
		end
	end
end

function HeroSelection:GetPlayerStatus(playerId)
	local td = PlayerTables:GetTableValueForReadOnly("hero_selection", PlayerResource:GetTeam(playerId))
	if td and td[playerId] then
		return table.deepcopy(td[playerId])
	end
	return table.deepcopy(emptyStateData)
end

function HeroSelection:UpdateStatusForPlayer(playerId, status, hero, bForNotPicked)
	local tableData = PlayerTables:GetTableValue("hero_selection", PlayerResource:GetTeam(playerId))
	if tableData and (not bForNotPicked or not tableData[playerId] or tableData[playerId].status ~= "picked") then
		if not tableData[playerId] then tableData[playerId] = {} end
		tableData[playerId].hero = hero
		tableData[playerId].status = status
		PlayerTables:SetTableValue("hero_selection", PlayerResource:GetTeam(playerId), tableData)
		return true
	end
	return false
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

function HeroSelection:GetLinkedHeroLockedAlly(hero, desiredTeam)
	for team,_v in pairs(PlayerTables:GetAllTableValuesForReadOnly("hero_selection")) do
		if team == desiredTeam then
			for plyId,v in pairs(_v) do
				if v.hero == hero and v.status == "locked" then
					return plyId
				end
			end
		end
	end
end

function HeroSelection:OnHeroSelectHero(data)
	local hero = tostring(data.hero)
	if not HeroSelection.SelectionEnd and not self:IsHeroSelected(hero) and self:VerifyHeroGroup(hero, "Selection") then
		local playerID = data.PlayerID
		local linked = GetKeyValue(hero, "LinkedHero")
		local newStatus = "picked"
		if linked then
			local team = PlayerResource:GetTeam()
			linked = string.split(linked, " | ")
			local areLinkedPicked = true
			local linkedMap = {}
			for _,v in ipairs(linked) do
				linkedMap[v] = HeroSelection:GetLinkedHeroLockedAlly(v, team)
				if linkedMap[v] == nil then
					areLinkedPicked = false
					break
				end
			end
			if areLinkedPicked then
				for hero, heroplayer in ipairs(linkedMap) do
					self:UpdateStatusForPlayer(heroplayer, "picked", hero)
				end
			else
				newStatus = "locked"
			end
		end
		if self:UpdateStatusForPlayer(playerID, newStatus, hero, true) and newStatus == "picked" then
			PrecacheUnitByNameAsync(GetKeyValue(hero, "base_hero") or hero, function() end, playerID)
			Gold:ModifyGold(playerID, CUSTOM_STARTING_GOLD)
			self:CheckEndHeroSelection()
		end
	end

end

function HeroSelection:OnHeroHover(data)
	if not HeroSelection.SelectionEnd then
		self:UpdateStatusForPlayer(data.PlayerID, "hover", tostring(data.hero), true)
	end
end

function HeroSelection:OnHeroRandomHero(data)
	local team = PlayerResource:GetTeam(data.PlayerID)
	if not HeroSelection.SelectionEnd and HeroSelection:GetPlayerStatus(data.PlayerID).status ~= "picked" then
		HeroSelection:PreformPlayerRandom(data.PlayerID)
	end

	HeroSelection:CheckEndHeroSelection()
end

function HeroSelection:SelectHero(playerId, heroName, callback, bSkipPrecache)
	self:UpdateStatusForPlayer(playerId, "picked", heroName)
	Timers:CreateTimer(function()
		local connectionState = PlayerResource:GetConnectionState(playerId)
		if connectionState == DOTA_CONNECTION_STATE_CONNECTED then
			local function SpawnHero()
				Timers:CreateTimer(function()
					connectionState = PlayerResource:GetConnectionState(playerId)
					if connectionState == DOTA_CONNECTION_STATE_CONNECTED then
						local heroTableCustom = NPC_HEROES_CUSTOM[heroName]
						local oldhero = PlayerResource:GetSelectedHeroEntity(playerId)
						local hero
						local baseNewHero = heroTableCustom.base_hero or heroName
						
						if oldhero then
							Timers:CreateTimer(0.03, function()
								oldhero:ClearNetworkableEntityInfo()
								UTIL_Remove(oldhero)
							end)
							if oldhero:GetUnitName() == baseNewHero then -- Base unit equals, ReplaceHeroWith won't do anything
								local temp = PlayerResource:ReplaceHeroWith(playerId, FORCE_PICKED_HERO, 0, 0)
								Timers:CreateTimer(0.03, function()
									temp:ClearNetworkableEntityInfo()
									UTIL_Remove(temp)
								end)
							end
							hero = PlayerResource:ReplaceHeroWith(playerId, baseNewHero, 0, 0)
						else
							print("[HeroSelection] For some reason player " .. playerId .. " has no hero. This player can't get a hero. Returning")
							return
						end
						HeroSelection:InitializeHeroClass(hero, heroTableCustom)
						if heroTableCustom.base_hero then
							TransformUnitClass(hero, heroTableCustom)
							hero.UnitName = heroName
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
				PrecacheUnitByNameAsync(GetKeyValue(heroName, "base_hero") or heroName, SpawnHero, playerId)
			end
		else
			return 0.1
		end
	end)
end

function HeroSelection:ChangeHero(playerId, newHeroName, keepExp, duration, item)
	local hero = PlayerResource:GetSelectedHeroEntity(playerId)
	if hero.PocketItem then
		hero.PocketHostEntity = nil
		UTIL_Remove(hero.PocketItem)
		hero.PocketItem = nil
	end
	hero:DestroyAllModifiers()
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
	RemoveAllOwnedUnits(playerId)
	local startTime = GameRules:GetDOTATime(true, true)
	HeroSelection:SelectHero(playerId, newHeroName, function(newHero)
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
			if IsValidEntity(newHero) then
				newHero:RemoveModifierByName("modifier_hero_selection_transformation")
			end
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