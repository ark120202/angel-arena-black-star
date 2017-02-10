if AbilityShop == nil then
	_G.AbilityShop = class({})
	AbilityShop.AbilityInfo = {}
	AbilityShop.ClientData = {{}, {}}
	AbilityShop.RandomOMG = {
		Ultimates = {},
		Abilities = {},
	}
end

function AbilityShop:PrepareData()
	local Heroes_all = {}
	table.merge(Heroes_all, NPC_HEROES_CUSTOM)
	for _,v in ipairs(ABILITY_SHOP_SKIP_HEROES) do
		Heroes_all[v] = nil
	end
	for a,vs in pairs(ABILITY_SHOP_BANNED) do
		if not ABILITY_SHOP_DATA[a] then
			ABILITY_SHOP_DATA[a] = {}
		end
		if not ABILITY_SHOP_DATA[a].banned_with then
			ABILITY_SHOP_DATA[a].banned_with = {}
		end
		for _,suba in ipairs(vs) do
			if not table.contains(ABILITY_SHOP_DATA[a].banned_with, suba) then table.insert(ABILITY_SHOP_DATA[a].banned_with, suba) end
			if not ABILITY_SHOP_DATA[suba] then
				ABILITY_SHOP_DATA[suba] = {}
			end
			if not ABILITY_SHOP_DATA[suba].banned_with then
				ABILITY_SHOP_DATA[suba].banned_with = {}
			end
			if not table.contains(ABILITY_SHOP_DATA[suba].banned_with, a) then table.insert(ABILITY_SHOP_DATA[suba].banned_with, a) end
		end
	end
	for _,group in pairs(ABILITY_SHOP_BANNED_GROUPS) do
		for _,a in ipairs(group) do
			if not ABILITY_SHOP_DATA[a] then
				ABILITY_SHOP_DATA[a] = {}
			end
			if not ABILITY_SHOP_DATA[a].banned_with then
				ABILITY_SHOP_DATA[a].banned_with = {}
			end
			for _,suba in ipairs(group) do
				if suba ~= a and not table.contains(ABILITY_SHOP_DATA[a].banned_with, suba) then
					table.insert(ABILITY_SHOP_DATA[a].banned_with, suba)
				end
			end
		end
	end
	for name,baseData in pairsByKeys(Heroes_all) do
		if baseData and baseData.Enabled ~= 0 then
			local heroTable = GetHeroTableByName(name)
			local tabIndex = 1
			if not NPC_HEROES[name] then
				tabIndex = 2
			end
			local abilityTbl = {}
			for i = 1, 24 do
				local at = heroTable["Ability" .. i]
				if at and at ~= "" and not AbilityHasBehaviorByName(at, "DOTA_ABILITY_BEHAVIOR_HIDDEN") and not table.contains(ABILITY_SHOP_SKIP_ABILITIES, at) then
					local cost = 1
					local banned_with = {}
					local is_ultimate = IsUltimateAbilityKV(at)
					if is_ultimate then
						cost = 8
					end
					local abitb = ABILITY_SHOP_DATA[at]
					if abitb then
						cost = abitb["cost"] or cost
						banned_with = abitb["banned_with"] or banned_with
					end
					table.insert(abilityTbl, {ability = at, cost = cost, banned_with = banned_with})
					AbilityShop.AbilityInfo[at] = {cost = cost, banned_with = banned_with, hero = name}
					table.insert(AbilityShop.RandomOMG[is_ultimate and "Ultimates" or "Abilities"], {ability = at, hero = name})
				end
			end
			local heroData = {
				heroKey = name,
				abilities = abilityTbl,
				isChanged = heroTable.Changed == 1 and tabIndex == 1,
				attribute_primary = _G[heroTable.AttributePrimary],
				team = heroTable.Team
			}
			table.insert(AbilityShop.ClientData[tabIndex], heroData)
		end
	end
end

function AbilityShop:PostAbilityData()
	CustomGameEventManager:RegisterListener("ability_shop_buy", function(_, data)
		AbilityShop:OnAbilityBuy(data.PlayerID, data.ability)
	end)
	CustomGameEventManager:RegisterListener("ability_shop_sell", Dynamic_Wrap(AbilityShop, "OnAbilitySell"))
	CustomGameEventManager:RegisterListener("ability_shop_downgrade", Dynamic_Wrap(AbilityShop, "OnAbilityDowngrade"))
	PlayerTables:CreateTable("ability_shop_data", AbilityShop.ClientData, {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23})
end

function AbilityShop:GetAbilityListInfo(abilityname)
	return AbilityShop.AbilityInfo[abilityname]
end

function AbilityShop:OnAbilityBuy(PlayerID, abilityname)
	local hero = PlayerResource:GetSelectedHeroEntity(PlayerID)
	local abilityInfo = AbilityShop:GetAbilityListInfo(abilityname)
	if not abilityInfo then
		return
	end
	local cost = abilityInfo.cost
	local banned_with =  abilityInfo.banned_with
	for _,v in ipairs(banned_with) do
		if hero:HasAbility(v) then
			return
		end
	end
	if hero and cost and hero:GetAbilityPoints() >= cost then
		local function Buy()
			if IsValidEntity(hero) and hero:GetAbilityPoints() >= cost then
				if hero:HasAbility(abilityname) then
					local abilityh = hero:FindAbilityByName(abilityname)
					if abilityh then
						if abilityh:GetLevel() < abilityh:GetMaxLevel() then
							hero:SetAbilityPoints(hero:GetAbilityPoints() - cost)
							abilityh:SetLevel(abilityh:GetLevel() + 1)
						end
					end
				elseif hero:HasAbility("ability_empty") then
					hero:SetAbilityPoints(hero:GetAbilityPoints() - cost)
					hero:RemoveAbility("ability_empty")
					GameMode:PrecacheUnitQueueed(abilityInfo.hero)
					local a, linked = AddNewAbility(hero, abilityname)
					a:SetLevel(1)
					if linked then
						for _,v in ipairs(linked) do
							if v:GetAbilityName() == "phoenix_launch_fire_spirit" then
								v:SetLevel(1)
							end
						end
					end
					hero:CalculateStatBonus()
					CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(PlayerID), "dota_ability_changed", {})
				end
			end
		end
		if hero:HasAbility(abilityname) then
			Buy()
		else
			PrecacheItemByNameAsync(abilityname, Buy)
		end
	end
end

function AbilityShop:OnAbilitySell(data)
	local hero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
	local listDataInfo = AbilityShop:GetAbilityListInfo(data.ability)
	if hero and hero:HasAbility(data.ability) and not hero:IsChanneling() and listDataInfo then
		local cost = listDataInfo.cost
		local abilityh = hero:FindAbilityByName(data.ability)

		local gold = AbilityShop:CalculateDowngradeCost(data.ability, cost) * abilityh:GetLevel()
		if Gold:GetGold(data.PlayerID) >= gold then
			Gold:RemoveGold(data.PlayerID, gold)
			hero:SetAbilityPoints(hero:GetAbilityPoints() + cost*abilityh:GetLevel())
			RemoveAbilityWithModifiers(hero, abilityh)
			local link = LINKED_ABILITIES[data.ability]
			if link then
				for _,v in ipairs(link) do
					hero:RemoveAbility(v)
				end
			end
			hero:AddAbility("ability_empty")
		end
	end
	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(data.PlayerID), "dota_ability_changed", {})
end

function AbilityShop:OnAbilityDowngrade(data)
	local hero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
	local listDataInfo = AbilityShop:GetAbilityListInfo(data.ability)
	if hero and hero:HasAbility(data.ability) and listDataInfo then
		local cost = listDataInfo.cost
		local abilityh = hero:FindAbilityByName(data.ability)
		if abilityh:GetLevel() <= 1 then
			AbilityShop:OnAbilitySell(data)
		else
			local gold = AbilityShop:CalculateDowngradeCost(data.ability, cost)
			if Gold:GetGold(data.PlayerID) >= gold then
				Gold:RemoveGold(data.PlayerID, gold)
				abilityh:SetLevel(abilityh:GetLevel() - 1)
				hero:SetAbilityPoints(hero:GetAbilityPoints() + cost)
			end
		end

	end
	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(data.PlayerID), "dota_ability_changed", {})
end

function AbilityShop:CalculateDowngradeCost(abilityname, upgradecost)
	return (upgradecost*60) + (upgradecost*10*GetDOTATimeInMinutesFull())
end

function AbilityShop:RandomOMGRollAbilities(unit)
	if DOTA_ACTIVE_GAMEMODE_TYPE == DOTA_GAMEMODE_TYPE_RANDOM_OMG then
		local ability_count = 6
		local ultimate_count = 2
		for i = 0, unit:GetAbilityCount() - 1 do
			local ability = unit:GetAbilityByIndex(i)
			if ability then
				for _,v in ipairs(unit:FindAllModifiers()) do
					if v:GetAbility() and v:GetAbility() == ability then
						v:Destroy()
					end
				end
				unit:RemoveAbility(ability:GetName())
			end
		end
		
		local has_abilities = 0
		while has_abilities < ability_count - ultimate_count do
			local abilityTable = AbilityShop.RandomOMG.Abilities[RandomInt(1, #AbilityShop.RandomOMG.Abilities)]
			local ability = abilityTable.ability
			if ability and not unit:HasAbility(ability) then
				PrecacheItemByNameAsync(ability, function() end)
				GameMode:PrecacheUnitQueueed(abilityTable.hero)
				AddNewAbility(unit, ability)
				has_abilities = has_abilities + 1
			end
		end
		local has_ultimates = 0
		while has_ultimates < ultimate_count do
			local abilityTable = AbilityShop.RandomOMG.Ultimates[RandomInt(1, #AbilityShop.RandomOMG.Ultimates)]
			local ability = abilityTable.ability
			if ability and not unit:HasAbility(ability) then
				PrecacheItemByNameAsync(ability, function() end)
				GameMode:PrecacheUnitQueueed(abilityTable.hero)
				AddNewAbility(unit, ability)
				has_ultimates = has_ultimates + 1
			end
		end
		unit:ResetAbilityPoints()
	end
end