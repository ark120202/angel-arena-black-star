function CustomAbilities:PostAbilityShopData()
	CustomGameEventManager:RegisterListener("ability_shop_buy", function(_, data)
		CustomAbilities:OnAbilityBuy(data.PlayerID, data.ability)
	end)
	CustomGameEventManager:RegisterListener("ability_shop_sell", Dynamic_Wrap(CustomAbilities, "OnAbilitySell"))
	CustomGameEventManager:RegisterListener("ability_shop_downgrade", Dynamic_Wrap(CustomAbilities, "OnAbilityDowngrade"))
	PlayerTables:CreateTable("ability_shop_data", CustomAbilities.ClientData, AllPlayersInterval)
end

function CustomAbilities:GetAbilityListInfo(abilityname)
	return CustomAbilities.AbilityInfo[abilityname]
end

function CustomAbilities:OnAbilityBuy(PlayerID, abilityname)
	local hero = PlayerResource:GetSelectedHeroEntity(PlayerID)
	if not hero then return end
	local abilityInfo = CustomAbilities:GetAbilityListInfo(abilityname)
	if not abilityInfo then return end

	local function Buy()
		local cost = abilityInfo.cost
		if not IsValidEntity(hero) or hero:GetAbilityPoints() < cost then return end
		for _,v in ipairs(abilityInfo.banned_with) do
			if hero:HasAbility(v) then return end
		end

		local abilityh = hero:FindAbilityByName(abilityname)
		if abilityh and not abilityh:IsHidden() then
			if abilityh:GetLevel() < abilityh:GetMaxLevel() then
				hero:SetAbilityPoints(hero:GetAbilityPoints() - cost)
				abilityh:SetLevel(abilityh:GetLevel() + 1)
			end
		elseif hero:HasAbility("ability_empty") then
			if abilityh and abilityh:IsHidden() then
				RemoveAbilityWithModifiers(hero, abilityh)
			end
			hero:SetAbilityPoints(hero:GetAbilityPoints() - cost)
			hero:RemoveAbility("ability_empty")
			GameMode:PrecacheUnitQueueed(abilityInfo.hero)
			local a, linked = hero:AddNewAbility(abilityname)
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
	if hero:HasAbility(abilityname) then
		Buy()
	else
		PrecacheItemByNameAsync(abilityname, Buy)
	end
end

function CustomAbilities:OnAbilitySell(data)
	local hero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
	local listDataInfo = CustomAbilities:GetAbilityListInfo(data.ability)
	if hero and hero:HasAbility(data.ability) and not hero:IsChanneling() and listDataInfo then
		local cost = listDataInfo.cost
		local abilityh = hero:FindAbilityByName(data.ability)
		local gold = CustomAbilities:CalculateDowngradeCost(data.ability, cost) * abilityh:GetLevel()
		if Gold:GetGold(data.PlayerID) >= gold and not abilityh:IsHidden() then
			Gold:RemoveGold(data.PlayerID, gold)
			hero:SetAbilityPoints(hero:GetAbilityPoints() + cost*abilityh:GetLevel())
			RemoveAbilityWithModifiers(hero, abilityh)
			local link = LINKED_ABILITIES[data.ability]
			if link then
				for _,v in ipairs(link) do
					hero:RemoveAbility(v)
				end
			end
			if data.ability == "puck_illusory_orb" then
				local etherealJaunt = hero:FindAbilityByName("puck_ethereal_jaunt")
				if etherealJaunt then etherealJaunt:SetActivated(false) end
			end
			hero:AddAbility("ability_empty")
		end
	end
	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(data.PlayerID), "dota_ability_changed", {})
end

function CustomAbilities:OnAbilityDowngrade(data)
	local hero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
	local listDataInfo = CustomAbilities:GetAbilityListInfo(data.ability)
	if hero and hero:HasAbility(data.ability) and listDataInfo then
		local cost = listDataInfo.cost
		local abilityh = hero:FindAbilityByName(data.ability)
		if abilityh:GetLevel() <= 1 then
			CustomAbilities:OnAbilitySell(data)
		else
			local gold = CustomAbilities:CalculateDowngradeCost(data.ability, cost)
			if Gold:GetGold(data.PlayerID) >= gold and not abilityh:IsHidden() then
				Gold:RemoveGold(data.PlayerID, gold)
				abilityh:SetLevel(abilityh:GetLevel() - 1)
				hero:SetAbilityPoints(hero:GetAbilityPoints() + cost)
			end
		end

	end
	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(data.PlayerID), "dota_ability_changed", {})
end

function CustomAbilities:CalculateDowngradeCost(abilityname, upgradecost)
	return (upgradecost*60) + (upgradecost*10*GetDOTATimeInMinutesFull())
end
