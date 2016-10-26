if AbilityShop == nil then
	_G.AbilityShop = class({})
	AbilityShop.AbilityInfo = {}
end
function AbilityShop:PostAbilityData()
	CustomGameEventManager:RegisterListener("ability_shop_buy", Dynamic_Wrap(AbilityShop, "OnAbilityBuy"))
	CustomGameEventManager:RegisterListener("ability_shop_sell", Dynamic_Wrap(AbilityShop, "OnAbilitySell"))
	CustomGameEventManager:RegisterListener("ability_shop_downgrade", Dynamic_Wrap(AbilityShop, "OnAbilityDowngrade"))
	local data = {{}, {}}
	local Heroes_all = {}
	table.merge(Heroes_all, ENABLED_HEROES.Selection)
	table.merge(Heroes_all, ENABLED_HEROES.Heaven)
	table.merge(Heroes_all, ENABLED_HEROES.Hell)
	for _,v in ipairs(ABILITY_SHOP_SKIP_HEROES) do
		Heroes_all[v] = nil
	end

	for name,enabled in pairsByKeys(Heroes_all) do
		if enabled == 1 then
			local heroTable
			local tabIndex = 1
			local isChanged = false
			if string.starts(name, "alternative_") then
				heroTable = GetAlternativeHeroTable(string.sub(name, 13))
				tabIndex = 2
			else
				heroTable = GetOriginalHeroTable(name)
				isChanged = heroTable.Changed == 1
			end
			local abilityTbl = {}
			for i = 1, 16 do
				local at = heroTable["Ability" .. i]
				if at and at ~= "" and at ~= "attribute_bonus_arena" and not AbilityHasBehaviorByName(at, DOTA_ABILITY_BEHAVIOR_HIDDEN) and not table.contains(ABILITY_SHOP_SKIP_ABILITIES, at) then
					local cost = 1
					local banned_with = {}
					if IsUltimateAbilityKV(at) then
						cost = 8
					end
					local abitb = ABILITY_SHOP_DATA[at]
					if abitb then
						cost = abitb["cost"] or cost
						banned_with = abitb["banned_with"] or banned_with
					end
					table.insert(abilityTbl, {ability = at, cost = cost, banned_with = banned_with})
					AbilityShop.AbilityInfo[at] = {cost = cost, banned_with = banned_with, hero = name}
				end
			end
			local heroData = {
				heroKey = name,
				abilities = abilityTbl,
				isChanged = isChanged,
				attribute_primary = _G[heroTable.AttributePrimary],
				team = heroTable.Team
			}
			table.insert(data[tabIndex], heroData)
		end
	end
	PlayerTables:CreateTable("ability_shop_data", data, {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23})
end
--AbilityShop:PostAbilityData()
function AbilityShop:GetAbilityListInfo(abilityname)
	if AbilityShop.AbilityInfo[abilityname] then
		return AbilityShop.AbilityInfo[abilityname]
	end
end

function AbilityShop:OnAbilityBuy(data)
	local hero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
	local abilityInfo = AbilityShop:GetAbilityListInfo(data.ability)
	if not abilityInfo then
		abilityInfo = { cost = 1, banned_with = {}}
	end
	local cost = abilityInfo.cost
	local banned_with =  abilityInfo.banned_with
	for i = 0, hero:GetAbilityCount() - 1 do
		local a = hero:GetAbilityByIndex(i)
		local listDataInfo = AbilityShop:GetAbilityListInfo(data.ability)
		if listDataInfo then
			local abanned_with = listDataInfo.banned_with
			if abanned_with then
				if table.contains(abanned_with, data.ability) then
					return
				end
			end
		end
	end
	for _,v in ipairs(banned_with) do
		if hero:HasAbility(v) then
			return
		end
	end
	if hero and cost and hero:GetAbilityPoints() >= cost then
		if data.ability == "attribute_bonus_arena" then
			hero:SetAbilityPoints(hero:GetAbilityPoints() - cost)
			local abilityh = hero:FindAbilityByName("attribute_bonus_arena")
			if not abilityh then
				abilityh = AddNewAbility(hero, "attribute_bonus_arena")
				abilityh:SetLevel(1)
			end
			abilityh:SetLevel(abilityh:GetLevel() + 1)
		else
			PrecacheItemByNameAsync(data.ability, function()
				if hero:GetAbilityPoints() >= cost then
					if hero:HasAbility(data.ability) then
						local abilityh = hero:FindAbilityByName(data.ability)
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
						local a, linked = AddNewAbility(hero, data.ability)
						a:SetLevel(1)
						if linked then
							for _,v in ipairs(linked) do
								if v:GetAbilityName() == "phoenix_launch_fire_spirit" then
									v:SetLevel(1)
								end
							end
						end
						hero:CalculateStatBonus()
						CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(data.PlayerID), "dota_ability_changed", {})
					end
				end
			end)
		end
	end
end

function AbilityShop:OnAbilitySell(data)
	local hero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
	if hero and hero:HasAbility(data.ability) and not hero:IsChanneling() then
		local listDataInfo = AbilityShop:GetAbilityListInfo(data.ability)
		local cost = 1
		if listDataInfo then
			cost = listDataInfo.cost
		end
		local abilityh = hero:FindAbilityByName(data.ability)

		local gold = AbilityShop:CalculateDowngradeCost(data.ability, cost)
		if data.ability == "attribute_bonus_arena" then
			gold = gold * (abilityh:GetLevel() - 1)
		else
			gold = gold * abilityh:GetLevel()
		end
		if Gold:GetGold(data.PlayerID) >= gold then
			Gold:RemoveGold(data.PlayerID, gold)
			for _,v in ipairs(hero:FindAllModifiers()) do
				if v:GetAbility() == abilityh then
					v:Destroy()
				end
			end
			if data.ability == "attribute_bonus_arena" then
				hero:SetAbilityPoints(hero:GetAbilityPoints() + cost*(abilityh:GetLevel()-1))
			else
				hero:SetAbilityPoints(hero:GetAbilityPoints() + cost*abilityh:GetLevel())
			end
			hero:RemoveAbility(data.ability)
			local link = LINKED_ABILITIES[data.ability]
			if link then
				for _,v in ipairs(link) do
					hero:RemoveAbility(v)
				end
			end
			if data.ability ~= "attribute_bonus_arena" then
				hero:AddAbility("ability_empty")
			end
		end
	end
	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(data.PlayerID), "dota_ability_changed", {})
end

function AbilityShop:OnAbilityDowngrade(data)
	local hero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
	print(data.ability, "downgrade", hero:HasAbility(data.ability))

	if hero and hero:HasAbility(data.ability) then
		local listDataInfo = AbilityShop:GetAbilityListInfo(data.ability)
		local cost = 1
		if listDataInfo then
			cost = listDataInfo.cost
		end
		local abilityh = hero:FindAbilityByName(data.ability)
		if (data.ability ~= "attribute_bonus_arena" and abilityh:GetLevel() <= 1) or (data.ability == "attribute_bonus_arena" and  abilityh:GetLevel() <= 2) then
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