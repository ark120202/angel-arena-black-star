if AbilityShop == nil then
	_G.AbilityShop = class({})
	AbilityShop.AbilityInfo = {
		["attribute_bonus_arena"] = {cost = 1, banned_with = {}}
	}
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
	for name,enabled in pairsByKeys(Heroes_all) do
		if enabled == 1 then
			local heroTable = GetHeroTableByName(name)
			local tabIndex = 1
			if not NPC_HEROES[name] then
				tabIndex = 2
			end
			local abilityTbl = {}
			for i = 1, 17 do
				local at = heroTable["Ability" .. i]
				if at and at ~= "" and at ~= "attribute_bonus_arena" and not AbilityHasBehaviorByName(at, "DOTA_ABILITY_BEHAVIOR_HIDDEN") and not table.contains(ABILITY_SHOP_SKIP_ABILITIES, at) then
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
				isChanged = heroTable.Changed == 1 and tabIndex == 1,
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
	local listDataInfo = AbilityShop:GetAbilityListInfo(data.ability)
	if hero and hero:HasAbility(data.ability) and not hero:IsChanneling() and listDataInfo then
		local cost = listDataInfo.cost
		local abilityh = hero:FindAbilityByName(data.ability)

		local gold = AbilityShop:CalculateDowngradeCost(data.ability, cost)
		if data.ability == "attribute_bonus_arena" then
			gold = gold * (abilityh:GetLevel() - 1)
		else
			gold = gold * abilityh:GetLevel()
		end
		if Gold:GetGold(data.PlayerID) >= gold then
			Gold:RemoveGold(data.PlayerID, gold)
			if data.ability == "attribute_bonus_arena" then
				hero:SetAbilityPoints(hero:GetAbilityPoints() + cost*(abilityh:GetLevel()-1))
			else
				hero:SetAbilityPoints(hero:GetAbilityPoints() + cost*abilityh:GetLevel())
			end
			RemoveAbilityWithModifiers(hero, abilityh)
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
	local listDataInfo = AbilityShop:GetAbilityListInfo(data.ability)
	if hero and hero:HasAbility(data.ability) and listDataInfo then
		local cost = listDataInfo.cost
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