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

	if units[1] and order_type == DOTA_UNIT_ORDER_SELL_ITEM and ability and not units[1]:IsIllusion() and not units[1]:HasModifier("modifier_arc_warden_tempest_double") then
		local cost = ability:GetCost()
		if GameRules:GetGameTime() - ability:GetPurchaseTime() > 10 then
			cost = cost / 2
		end
		if abilityname == "item_pocket_riki" then
			cost = Kills:GetGoldForKill(ability.RikiContainer)
			TrueKill(units[1], ability, ability.RikiContainer)
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
	local damagetype_const = 	filterTable.damagetype_const
	local damage = 				filterTable.damage
	local inflictor
	if filterTable.entindex_inflictor_const then
		inflictor = EntIndexToHScript(filterTable.entindex_inflictor_const)
	end
	local attacker
	if filterTable.entindex_attacker_const then 
		attacker = 				EntIndexToHScript(filterTable.entindex_attacker_const)
	end
	local victim = 				EntIndexToHScript(filterTable.entindex_victim_const)
	if attacker then
		if inflictor and inflictor.GetAbilityName then
			local inflictorname = inflictor:GetAbilityName()

			if SPELL_AMPLIFY_NOT_SCALABLE_MODIFIERS[inflictorname] then
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
		
		for k,v in pairs(ON_DAMAGE_MODIFIER_PROCS) do
			if attacker.HasModifier and attacker:HasModifier(k) then
				v(attacker, victim, inflictor, damage, damagetype_const)
			end
		end
		for k,v in pairs(ON_DAMAGE_MODIFIER_PROCS_VICTIM) do
			if victim.HasModifier and victim:HasModifier(k) then
				v(attacker, victim, inflictor, damage, damagetype_const)
			end
		end
		for k,v in pairs(OUTGOING_DAMAGE_MODIFIERS) do
			if attacker.HasModifier and attacker:HasModifier(k) and	(not v.condition or (v.condition and v.condition(attacker, victim, inflictor, damage, damagetype_const))) then
				if v.multiplier then
					if type(v.multiplier) == "number" then
						filterTable.damage = filterTable.damage * v.multiplier
					elseif type(v.multiplier) == "function" then
						local multiplier = v.multiplier(attacker, victim, inflictor, damage, damagetype_const)
						if multiplier then
							filterTable.damage = filterTable.damage * multiplier
						end
					end
				end
			end
		end
		for k,v in pairs(INCOMING_DAMAGE_MODIFIERS) do
			if victim.HasModifier and victim:HasModifier(k) and	(not v.condition or (v.condition and v.condition(attacker, victim, inflictor, damage, damagetype_const))) then
				if v.multiplier then
					if type(v.multiplier) == "number" then
						filterTable.damage = filterTable.damage * v.multiplier
					elseif type(v.multiplier) == "function" then
						local multiplier = v.multiplier(attacker, victim, inflictor, damage, damagetype_const)
						if multiplier then
							filterTable.damage = filterTable.damage * multiplier
						end
					end
				end
			end
		end

		if (attacker.HasModifier and (attacker:HasModifier("modifier_crystal_maiden_glacier_tranqulity_buff") or attacker:HasModifier("modifier_crystal_maiden_glacier_tranqulity_debuff"))) or (victim.HasModifier and (victim:HasModifier("modifier_crystal_maiden_glacier_tranqulity_buff") or victim:HasModifier("modifier_crystal_maiden_glacier_tranqulity_debuff"))) then
			filterTable.damage = 0
			return false
		end
	end
	return true
end

function GameMode:ModifyGoldFilter(filterTable)
	if filterTable.reason_const >= DOTA_ModifyGold_HeroKill and filterTable.reason_const <= DOTA_ModifyGold_CourierKill then
		filterTable["gold"] = 0
		return false
	end
	filterTable["gold"] = 0
	print("[GameMode:ModifyGoldFilter]: Attempt to call default dota gold modify func... FIX IT - Reason: " .. filterTable.reason_const .."  --  Amount: " .. filterTable["gold"])
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
	return true
end