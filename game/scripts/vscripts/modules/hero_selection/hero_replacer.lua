function HeroSelection:SelectHero(playerId, heroName, callback, bSkipPrecache)
	HeroSelection:UpdateStatusForPlayer(playerId, "picked", heroName)
	Timers:CreateTimer(function()
		local connectionState = PlayerResource:GetConnectionState(playerId)
		if connectionState == DOTA_CONNECTION_STATE_CONNECTED then
			local function SpawnHero()
				Timers:CreateTimer(function()
					connectionState = PlayerResource:GetConnectionState(playerId)
					if connectionState == DOTA_CONNECTION_STATE_CONNECTED then
						local heroTableCustom = NPC_HEROES_CUSTOM[heroName] or NPC_HEROES[heroName]
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
						if Options:IsEquals("EnableAbilityShop") then
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

function HeroSelection:ChangeHero(playerId, newHeroName, keepExp, duration, item, callback)
	local hero = PlayerResource:GetSelectedHeroEntity(playerId)
	hero.ChangingHeroProcessRunning = true
	ProjectileManager:ProjectileDodge(hero)
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
	for i = DOTA_ITEM_SLOT_1, DOTA_STASH_SLOT_6 do
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
	local duelData = {
		StatusBeforeArena = hero.StatusBeforeArena,
		OnDuel = hero.OnDuel,
		ArenaBeforeTpLocation = hero.ArenaBeforeTpLocation,
		DuelChecked = hero.DuelChecked,
	}
	for team,tab in pairs(Duel.heroes_teams_for_duel or {}) do
		for i,unit in pairs(tab) do
			if unit == hero then
				duelData.path = {team, i}
			end
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
		ClearSlotsFromDummy(newHero)

		for k,v in pairs(duelData) do
			if k ~= "path" then
				newHero[k] = v
			else
				Duel.heroes_teams_for_duel[v[1]][v[1]] = newHero
			end
		end
		Timers:CreateTimer(startTime + duration - GameRules:GetDOTATime(true, true), function()
			if IsValidEntity(newHero) then
				newHero:RemoveModifierByName("modifier_hero_selection_transformation")
			end
		end)
		if callback then callback(newHero) end
	end)
end
