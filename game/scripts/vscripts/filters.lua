function GameMode:InitFilters()
	GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(GameMode, 'ExecuteOrderFilter'), self)
	GameRules:GetGameModeEntity():SetDamageFilter(Dynamic_Wrap(GameMode, 'DamageFilter'), self)
	GameRules:GetGameModeEntity():SetModifyGoldFilter(Dynamic_Wrap(GameMode, 'ModifyGoldFilter'), self)
	GameRules:GetGameModeEntity():SetModifyExperienceFilter(Dynamic_Wrap(GameMode, 'ModifyExperienceFilter'), self)
end

function GameMode:ExecuteOrderFilter(filterTable)
	local order_type = filterTable.order_type
	local issuer_player_id_const = filterTable.issuer_player_id_const
	if order_type == DOTA_UNIT_ORDER_PURCHASE_ITEM then
		return false
	end
	local target = EntIndexToHScript(filterTable.entindex_target)
	local ability = EntIndexToHScript(filterTable.entindex_ability)
	local abilityname
	if ability and ability.GetAbilityName then
		abilityname = ability:GetAbilityName()
	end
	local entindexes_units = filterTable.units
	local units = {}
	for _, v in pairs(entindexes_units) do
		local u = EntIndexToHScript(v)
		if u then
			table.insert(units, u)
		end
	end
	if order_type == DOTA_UNIT_ORDER_TRAIN_ABILITY and DOTA_ACTIVE_GAMEMODE_TYPE == DOTA_GAMEMODE_TYPE_ABILITY_SHOP then
		AbilityShop:OnAbilityBuy(issuer_player_id_const, abilityname)
		return false
	end

	if units[1] and order_type == DOTA_UNIT_ORDER_SELL_ITEM and ability and not units[1]:IsIllusion() and not units[1]:IsTempestDouble() then
		local cost = ability:GetCost()
		if GameRules:GetGameTime() - ability:GetPurchaseTime() > 10 then
			cost = cost / 2
		end
		if abilityname == "item_pocket_riki" then
			cost = Kills:GetGoldForKill(ability.RikiContainer)
			ability.RikiContainer:TrueKill(ability, units[1])
			Kills:ClearStreak(ability.RikiContainer:GetPlayerID())
			units[1]:RemoveItem(ability)
			units[1]:RemoveModifierByName("modifier_item_pocket_riki_invisibility_fade")
			units[1]:RemoveModifierByName("modifier_item_pocket_riki_permanent_invisibility")
			units[1]:RemoveModifierByName("modifier_invisible")
			GameRules:SendCustomMessage("#riki_pocket_riki_chat_notify_text", 0, units[1]:GetTeamNumber())
		end
		UTIL_Remove(ability)
		Gold:AddGoldWithMessage(units[1], cost, issuer_player_id_const)
		return false
	end
	for _,unit in ipairs(units) do
		if unit:IsHero() or unit:IsConsideredHero() then
			GameMode:TrackInventory(unit)
			if unit:IsRealHero() then
				if ability then
					if order_type == DOTA_UNIT_ORDER_CAST_POSITION then
						if not Duel:IsDuelOngoing() and ARENA_NOT_CASTABLE_ABILITIES[abilityname] then
							local orderVector = Vector(filterTable.position_x, filterTable.position_y, 0)
							if type(ARENA_NOT_CASTABLE_ABILITIES[abilityname]) == "number" then
								local ent1len = (orderVector - Entities:FindByName(nil, "target_mark_arena_team2"):GetAbsOrigin()):Length2D()
								local ent2len = (orderVector - Entities:FindByName(nil, "target_mark_arena_team3"):GetAbsOrigin()):Length2D()
								if ent1len <= ARENA_NOT_CASTABLE_ABILITIES[abilityname] + 200 or ent2len <= ARENA_NOT_CASTABLE_ABILITIES[abilityname] + 200 then
									return false
								end
							end
							if IsInBox(orderVector, Entities:FindByName(nil, "target_mark_arena_blocker_1"):GetAbsOrigin(), Entities:FindByName(nil, "target_mark_arena_blocker_2"):GetAbsOrigin()) then
								return false
							end
						end
					elseif order_type == DOTA_UNIT_ORDER_CAST_TARGET then
						if target:IsBoss() and table.contains(BOSS_BANNED_ABILITIES, abilityname) then
							Containers:DisplayError(issuer_player_id_const, "#dota_hud_error_ability_cant_target_boss")
							return false
						end

						if table.contains(ABILITY_INVULNERABLE_UNITS, target:GetUnitName()) and abilityname ~= "item_casino_coin" then
							filterTable.order_type = DOTA_UNIT_ORDER_MOVE_TO_TARGET
							return true
						end
					end
				end
				if filterTable.position_x ~= 0 and filterTable.position_y ~= 0 then
					if (RandomInt(0, 1) == 1 and (unit:HasModifier("modifier_item_casino_drug_pill3_debuff") or unit:GetModifierStackCount("modifier_item_casino_drug_pill3_addiction", unit) >= 8)) or unit:GetModifierStackCount("modifier_item_casino_drug_pill3_addiction", unit) >= 16 then
						local heroVector = unit:GetAbsOrigin()
						local orderVector = Vector(filterTable.position_x, filterTable.position_y, 0)
						local diff = orderVector - heroVector
						local newVector = heroVector + (diff * -1)
						filterTable.position_x = newVector.x
						filterTable.position_y = newVector.y
					end
				end
			end
		end
	end
	return true
end

function GameMode:DamageFilter(filterTable)
	local damagetype_const = filterTable.damagetype_const
	local damage = filterTable.damage
	local inflictor
	if filterTable.entindex_inflictor_const then
		inflictor = EntIndexToHScript(filterTable.entindex_inflictor_const)
	end
	local attacker
	if filterTable.entindex_attacker_const then 
		attacker = EntIndexToHScript(filterTable.entindex_attacker_const)
	end
	local victim = EntIndexToHScript(filterTable.entindex_victim_const)

	if IsValidEntity(attacker) then
		if IsValidEntity(inflictor) and inflictor.GetAbilityName then
			local inflictorname = inflictor:GetAbilityName()

			if SPELL_AMPLIFY_NOT_SCALABLE_MODIFIERS[inflictorname] and attacker:IsHero() then
				filterTable.damage = GetNotScaledDamage(filterTable.damage, attacker)
			end
			local damage_from_current_health_pct = inflictor:GetAbilitySpecial("damage_from_current_health_pct")
			if victim and damage_from_current_health_pct then
				if PERCENT_DAMAGE_MODIFIERS[inflictorname] then
					damage_from_current_health_pct = damage_from_current_health_pct * PERCENT_DAMAGE_MODIFIERS[inflictorname]
				end
				filterTable.damage = filterTable.damage + (victim:GetHealth() * damage_from_current_health_pct * 0.01)
			end
			if BOSS_DAMAGE_ABILITY_MODIFIERS[inflictorname] and victim:IsBoss() then
				filterTable.damage = damage * BOSS_DAMAGE_ABILITY_MODIFIERS[inflictorname] * 0.01
			end
			if inflictorname == "templar_assassin_psi_blades" and victim:IsRealCreep() then
				filterTable.damage = damage * 0.5
			end
		end
		if victim:IsBoss() and (attacker:GetAbsOrigin() - victim:GetAbsOrigin()):Length2D() > 950 then
			filterTable.damage = filterTable.damage / 2
		end
		if (attacker.HasModifier and (attacker:HasModifier("modifier_crystal_maiden_glacier_tranqulity_buff") or attacker:HasModifier("modifier_crystal_maiden_glacier_tranqulity_debuff"))) or (victim.HasModifier and (victim:HasModifier("modifier_crystal_maiden_glacier_tranqulity_buff") or victim:HasModifier("modifier_crystal_maiden_glacier_tranqulity_debuff"))) then
			filterTable.damage = 0
			return false
		end

		local BlockedDamage = 0
		local LifestealPercentage = 0
		--local CriticalStrike = 0
		local function ProcessDamageModifier(v)
			local multiplier
			if type(v) == "function" then
				multiplier = v(attacker, victim, inflictor, damage, damagetype_const)
			elseif type(v) == "table" then
				if v.multiplier then
					if type(v.multiplier) == "function" then
						multiplier = v.multiplier(attacker, victim, inflictor, damage, damagetype_const)
					else
						multiplier = v.multiplier
					end
				end
			end
			if multiplier ~= nil then
				if type(multiplier) == "table" then
					if type(multiplier.reject) == "boolean" and not multiplier.reject then
						filterTable.damage = 0
						return false
					end
					if multiplier.BlockedDamage then
						BlockedDamage = math.max(BlockedDamage, multiplier.BlockedDamage)
					end
					if multiplier.multiplier then
						multiplier = multiplier.multiplier
					end
					if multiplier.LifestealPercentage then
						LifestealPercentage = math.max(LifestealPercentage, multiplier.LifestealPercentage)
					end
				end
				--print("Raw damage: " .. filterTable.damage .. ", after " .. k .. ": " .. filterTable.damage * multiplier .. " (multiplier: " .. multiplier .. ")")
				if type(multiplier) == "boolean" and not multiplier then
					filterTable.damage = 0
					return false
				elseif type(multiplier) == "number" then
					filterTable.damage = filterTable.damage * multiplier
				end
			end
		end

		if victim.HasModifier then
			for k,v in pairs(ON_DAMAGE_MODIFIER_PROCS_VICTIM) do
				if victim:HasModifier(k) then
					ProcessDamageModifier(v)
				end
			end
			for k,v in pairs(INCOMING_DAMAGE_MODIFIERS) do
				if victim:HasModifier(k) and (type(v) ~= "table" or not v.condition or (v.condition and v.condition(attacker, victim, inflictor, damage, damagetype_const))) then
					ProcessDamageModifier(v)
				end
			end
		end
		if attacker.HasModifier then
			for k,v in pairs(ON_DAMAGE_MODIFIER_PROCS) do
				if attacker:HasModifier(k) then
					ProcessDamageModifier(v)
				end
			end
			for k,v in pairs(OUTGOING_DAMAGE_MODIFIERS) do
				if attacker:HasModifier(k) and (type(v) ~= "table" or not v.condition or (v.condition and v.condition(attacker, victim, inflictor, damage, damagetype_const))) then
					ProcessDamageModifier(v)
				end
			end
		end
		if BlockedDamage > 0 then
			PopupDamageBlock(victim, math.round(BlockedDamage))
			--print("Raw damage: " .. filterTable.damage .. ", after blocking: " .. filterTable.damage - BlockedDamage .. " (blocked: " .. BlockedDamage .. ")")
			filterTable.damage = filterTable.damage - BlockedDamage
		end
		if LifestealPercentage > 0 then
			local lifesteal = filterTable.damage * LifestealPercentage * 0.01
			SafeHeal(attacker, lifesteal)
			SendOverheadEventMessage(attacker:GetPlayerOwner(), OVERHEAD_ALERT_HEAL, attacker, lifesteal, attacker:GetPlayerOwner())
			ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)
			--print("Lifestealing " .. lifesteal .. " health from " .. filterTable.damage .. " damage points (" .. LifestealPercentage .. "% lifesteal)")
		end

		if attacker.GetPlayerOwnerID then
			local attackerpid = attacker:GetPlayerOwnerID()
			if attackerpid > -1 then
				if victim:IsRealHero() then
					attacker:ModifyPlayerStat("DamageToEnemyHeroes", filterTable.damage)
				end
				if victim:IsBoss() then
					victim.DamageReceived = victim.DamageReceived or {}
					victim.DamageReceived[attackerpid] = (victim.DamageReceived[attackerpid] or 0) + filterTable.damage
				end
			end
		end
	end
	return true
end

function GameMode:ModifyGoldFilter(filterTable)
	if filterTable.reason_const >= DOTA_ModifyGold_HeroKill and filterTable.reason_const <= DOTA_ModifyGold_CourierKill then
		filterTable["gold"] = 0
		return false
	end
	print("[GameMode:ModifyGoldFilter]: Attempt to call default dota gold modify func... FIX IT - Reason: " .. filterTable.reason_const .."  --  Amount: " .. filterTable["gold"])
	filterTable["gold"] = 0
	return false
end


function GameMode:ModifyExperienceFilter(filterTable)
	local hero = PlayerResource:GetSelectedHeroEntity(filterTable.player_id_const)
	if hero then
		for _,v in ipairs(hero:FindAllModifiersByName("modifier_arena_rune_acceleration")) do
			if v.xp_multiplier then
				filterTable.experience = filterTable.experience * v.xp_multiplier
			end
		end
		if hero.talent_keys and hero.talent_keys.bonus_experience_percentage then
			filterTable.experience = filterTable.experience * (1 + hero.talent_keys.bonus_experience_percentage * 0.01)
		end
	end
	if Duel.IsFirstDuel and Duel:IsDuelOngoing() then
		filterTable.experience = filterTable.experience * 0.1
	end
	return true
end

function GameMode:CustomChatFilter(playerID, text, teamonly)
	if string.starts(text, "-") then
		local cmd = {}
		for v in string.gmatch(string.sub(text, 2), "%S+") do table.insert(cmd, v) end
		local hero = PlayerResource:GetSelectedHeroEntity(playerID)
		if CustomWearables:HasWearable(playerID, "wearable_developer") then
			if cmd[1] == "debugallcalls" then
				DebugAllCalls()
			end
			if cmd[1] == "printplayers" then
				local playerinfo = {}
				for pID = 0, DOTA_MAX_TEAM_PLAYERS - 1  do
					if PlayerResource:IsValidPlayerID(pID) then
						playerinfo[pID] = {
							nick = PlayerResource:GetPlayerName(pID),
							hero = PlayerResource:GetSelectedHeroEntity(pID):GetFullName(),
							team = PlayerResource:GetTeam(pID),
							steamID32 = PlayerResource:GetSteamAccountID(playerID)
						}
					end
				end
				CPrintTable(playerinfo)
			end
			if cmd[1] == "dcs" then
				_G.DebugConnectionStates = not DebugConnectionStates
			end
			if cmd[1] == "cprint" then
				_G.SendDebugInfoToClient = not SendDebugInfoToClient
			end
			if cmd[1] == "model" then
				hero:SetModel(cmd[2])
				hero:SetOriginalModel(cmd[2])
			end
			if cmd[1] == "lua" then
				local str = ""
				for i = 2, #cmd do
					str = str .. cmd[i] .. " "
				end
				EvalString(str)
			end
		end
		if GameRules:IsCheatMode() then
			if cmd[1] == "gold" then
				Gold:ModifyGold(hero, tonumber(cmd[2]))
			end
			if cmd[1] == "ban" then
				if PlayerResource:IsValidPlayerID(tonumber(cmd[2])) then
					MakePlayerAbandoned(tonumber(cmd[2]))
				end
			end
			if cmd[1] == "spawnrune" then
				CustomRunes:SpawnRunes()
			end
			if cmd[1] == "t" then
				for i = 2, 50 do
					if XP_PER_LEVEL_TABLE[hero:GetLevel()] and XP_PER_LEVEL_TABLE[hero:GetLevel() + 1] then
						hero:AddExperience(XP_PER_LEVEL_TABLE[hero:GetLevel() + 1] - XP_PER_LEVEL_TABLE[hero:GetLevel()], 0, false, false)
					else
						break
					end
				end
				hero:AddItem(CreateItem("item_rapier", hero, hero))
				hero:AddItem(CreateItem("item_blink_arena", hero, hero))
				SendToServerConsole("dota_ability_debug 1")
			end
			if cmd[1] == "godmode" then
				hero:AddExperience(1000000000, 0, false, true)
				Gold:ModifyGold(playerID, 999999)
				hero:ModifyAgility(1000000)
				hero:ModifyStrength(1000000)
				hero:ModifyIntellect(1000000)
			end
			if cmd[1] == "disablegodmode" then
				Gold:ModifyGold(playerID, -999999)
				hero:ModifyAgility(-1000000)
				hero:ModifyStrength(-1000000)
				hero:ModifyIntellect(-1000000)
			end
			if cmd[1] == "startduel" then
				Duel.TimeUntilDuel = 0
			end
			if cmd[1] == "endduel" then
				Duel.TimeUntilDuelEnd = 1
			end
			if cmd[1] == "killcreeps" then
				local units = FindUnitsInRadius(hero:GetTeamNumber(), Vector(0, 0, 0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
				for _,v in ipairs(units) do
					v:ForceKill(true)
				end
			end
			if cmd[1] == "reset" then
				for i = 0, hero:GetAbilityCount() - 1 do
					local ability = hero:GetAbilityByIndex(i)
					if ability then
						local n = ability:GetAbilityName()
						hero:SetAbilityPoints(hero:GetAbilityPoints() + ability:GetLevel())
						hero:RemoveAbility(n)
						hero:AddAbility(n)
					end
				end
			end
			if cmd[1] == "runetest" then
				for i = ARENA_RUNE_FIRST, ARENA_RUNE_LAST do
					CustomRunes:CreateRune(hero:GetAbsOrigin() + RandomVector(RandomInt(90, 300)), i)
				end
			end
			if cmd[1] == "createcreep" then
				local sName = tostring(cmd[2]) or "medium"
				local SpawnerType = tonumber(cmd[3]) or 0
				local time = tonumber(cmd[4]) or 0
				local unitRootTable = SPAWNER_SETTINGS[sName].SpawnTypes[SpawnerType]
				PrintTable(SPAWNER_SETTINGS[sName])
				local unit = CreateUnitByName(unitRootTable[1][-1], hero:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_NEUTRALS)
				unit.SpawnerIndex = SpawnerType
				unit.SpawnerType = sName
				unit.SSpawner = -1
				unit.SLevel = time
				Spawner:UpgradeCreep(unit, unit.SpawnerType, unit.SLevel, unit.SpawnerIndex)
			end
			if cmd[1] == "a_createhero" then
				local heroName = cmd[2]
				local heroTableCustom = NPC_HEROES_CUSTOM[heroName]
				local baseNewHero = heroTableCustom.base_hero or heroName
				local h = CreateHeroForPlayer(baseNewHero, PlayerResource:GetPlayer(playerID))
				h:SetTeam(PlayerResource:GetTeam(playerID) == 2 and 3 or 2)
				h:SetAbsOrigin(hero:GetAbsOrigin())
				h:SetControllableByPlayer(playerID, true)
				for i = 1, 300 do
					h:HeroLevelUp(false)
				end
				if heroTableCustom.base_hero then
					TransformUnitClass(h, heroTableCustom)
					h.UnitName = heroName
				end
			end
			if cmd[1] == "talents_clear" then
				hero:ClearTalents()
			end
			if cmd[1] == "equip" then
				hero:EquipWearable(tonumber(cmd[2]))
			end
			if cmd[1] == "reattach" then
				hero:RemoveAllWearables()
				hero:EquipItemsFromPlayerSelectionOrDefault()
			end
		end
		return false
	end
	return true
end