if CustomAbilities == nil then
	_G.CustomAbilities = class({})
	CustomAbilities.AbilityInfo = {}
	CustomAbilities.ClientData = {{}, {}}
	CustomAbilities.RandomOMG = {
		Ultimates = {},
		Abilities = {},
	}
end

ModuleRequire(..., "ability_shop")
ModuleRequire(..., "random_omg")

function CustomAbilities:PrepareData()
	for a,vs in pairs(ABILITY_SHOP_BANNED) do
		if not ABILITY_SHOP_DATA[a] then
			ABILITY_SHOP_DATA[a] = {}
		end
		if not ABILITY_SHOP_DATA[a].banned_with then
			ABILITY_SHOP_DATA[a].banned_with = {}
		end
		for _,suba in ipairs(vs) do
			if not table.includes(ABILITY_SHOP_DATA[a].banned_with, suba) then table.insert(ABILITY_SHOP_DATA[a].banned_with, suba) end
			if not ABILITY_SHOP_DATA[suba] then
				ABILITY_SHOP_DATA[suba] = {}
			end
			if not ABILITY_SHOP_DATA[suba].banned_with then
				ABILITY_SHOP_DATA[suba].banned_with = {}
			end
			if not table.includes(ABILITY_SHOP_DATA[suba].banned_with, a) then table.insert(ABILITY_SHOP_DATA[suba].banned_with, a) end
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
				if suba ~= a and not table.includes(ABILITY_SHOP_DATA[a].banned_with, suba) then
					table.insert(ABILITY_SHOP_DATA[a].banned_with, suba)
				end
			end
		end
	end
	for name, baseData in pairsByKeys(NPC_HEROES_CUSTOM) do
		if baseData.Enabled ~= 0 and not ABILITY_SHOP_SKIP_HEROES[name] then
			local heroTable = GetHeroTableByName(name)
			local tabIndex = NPC_HEROES[name] and 1 or 2
			local abilityTbl = {}
			for i = 1, 24 do
				local at = heroTable["Ability" .. i]
				if at and
					at ~= "" and
					not string.starts(at, "special_bonus_") and
					not AbilityHasBehaviorByName(at, "DOTA_ABILITY_BEHAVIOR_HIDDEN") and
					not table.includes(ABILITY_SHOP_SKIP_ABILITIES, at) then
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
					CustomAbilities.AbilityInfo[at] = {cost = cost, banned_with = banned_with, hero = name}
					table.insert(CustomAbilities.RandomOMG[is_ultimate and "Ultimates" or "Abilities"], {ability = at, hero = name})
				end
			end
			local heroData = {
				heroKey = name,
				abilities = abilityTbl,
				isChanged = heroTable.Changed == 1 and tabIndex == 1,
				attribute_primary = _G[heroTable.AttributePrimary]
			}
			table.insert(CustomAbilities.ClientData[tabIndex], heroData)
		end
	end
end
