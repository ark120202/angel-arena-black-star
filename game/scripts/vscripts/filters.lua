function GameMode:InitFilters()
	GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(GameMode, 'ExecuteOrderFilter'), self)
	GameRules:GetGameModeEntity():SetDamageFilter(Dynamic_Wrap(GameMode, 'DamageFilter'), self)
	GameRules:GetGameModeEntity():SetModifyGoldFilter(Dynamic_Wrap(GameMode, 'ModifyGoldFilter'), self)
	GameRules:GetGameModeEntity():SetModifyExperienceFilter(Dynamic_Wrap(GameMode, 'ModifyExperienceFilter'), self)
end

function GameMode:ExecuteOrderFilter(filterTable)
	local order_type = filterTable.order_type
	local issuer_player_id_const = filterTable.issuer_player_id_const
	if order_type == DOTA_UNIT_ORDER_SELL_ITEM or order_type == DOTA_UNIT_ORDER_PURCHASE_ITEM then
		return false
	end
	if order_type == DOTA_UNIT_ORDER_TRAIN_ABILITY and DOTA_ACTIVE_GAMEMODE_TYPE == DOTA_GAMEMODE_TYPE_ABILITY_SHOP then
		Containers:DisplayError(issuer_player_id_const, "#dota_hud_error_ability_inactive")
		return false
	end
	local target = EntIndexToHScript(filterTable.entindex_target)
	local ability = EntIndexToHScript(filterTable.entindex_ability)
	local abilityname
	if ability and ability.GetName then
		abilityname = ability:GetName()
	end
	local entindexes_units = filterTable.units
	local units = {}
	for _, v in pairs(entindexes_units) do
		local u = EntIndexToHScript(v)
		if u then
			table.insert(units, u)
		end
	end
	for _,unit in ipairs(units) do
		if unit:GetUnitName() == "npc_dota_courier" then
			local palyerTeam = PlayerResource:GetTeam(issuer_player_id_const)
			if order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION then
				PlayerTables:SetTableValue("arena", "courier_owner" .. palyerTeam, issuer_player_id_const)
				local point = Vector(filterTable.position_x, filterTable.position_y, 0)
				if CourierTimer[palyerTeam] then
					Timers:RemoveTimer(CourierTimer[palyerTeam])
				end
				CourierTimer[palyerTeam] = Timers:CreateTimer(function()
					if (unit:GetAbsOrigin() - point):Length2D() < 10 then
						PlayerTables:SetTableValue("arena", "courier_owner" .. palyerTeam, -1)
					else
						return 0.03
					end
				end)
			elseif order_type == DOTA_UNIT_ORDER_CAST_NO_TARGET and (abilityname == "courier_transfer_items" or abilityname == "courier_take_stash_and_transfer_items") then
				local hero = PlayerResource:GetSelectedHeroEntity(issuer_player_id_const)
				local can_continue = false
				if abilityname == "courier_take_stash_and_transfer_items" then
					for i = 6, 11 do
						local item = hero:GetItemInSlot(i)
						if item and item:GetOwner() == hero then
							can_continue = true
						end
					end
				end
				if not can_continue then
					for i = 0, 5 do
						local item = unit:GetItemInSlot(i)
						if item and item:GetPurchaser() == hero then
							can_continue = true
						end
					end
				end
				if can_continue then
					PlayerTables:SetTableValue("arena", "courier_owner" .. palyerTeam, issuer_player_id_const)
					if CourierTimer[palyerTeam] then
						Timers:RemoveTimer(CourierTimer[palyerTeam])
					end
					CourierTimer[palyerTeam] = Timers:CreateTimer(function()
						if (unit:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D() < 225 then
							PlayerTables:SetTableValue("arena", "courier_owner" .. palyerTeam, -1)
						else
							return 0.03
						end
					end)
				end
			elseif abilityname ~= "courier_burst" then
				PlayerTables:SetTableValue("arena", "courier_owner" .. palyerTeam, -1)
			end
		end
		if unit:IsHero() or unit:IsConsideredHero() then
			GameMode:TrackInventory(unit)
			if unit:IsRealHero() then
				if order_type == DOTA_UNIT_ORDER_CAST_TARGET then
					if ability then
						local abilityname = ability:GetName()
						if IsBossEntity(target) and table.contains(BOSS_BANNED_ABILITIES, abilityname) then
							filterTable.order_type = DOTA_UNIT_ORDER_ATTACK_TARGET
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
		if inflictor and inflictor.GetAbilityName then
			local inflictorname = inflictor:GetAbilityName()
			if BOSS_DAMAGE_ABILITY_MODIFIERS[inflictorname] and IsBossEntity(victim) then
				filterTable.damage = damage * BOSS_DAMAGE_ABILITY_MODIFIERS[inflictorname] * 0.01
			end
			local damage_from_current_health_pct = inflictor:GetAbilitySpecial("damage_from_current_health_pct")
			if victim and damage_from_current_health_pct then
				filterTable.damage = filterTable.damage + (victim:GetHealth() * damage_from_current_health_pct * 0.01)
			end
			if inflictorname == "templar_assassin_psi_blades" and victim:IsRealCreep() then
				filterTable.damage = damage * 0.5
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
	if hero and filterTable.reason_const == DOTA_ModifyXP_CreepKill then
		for _,v in ipairs(hero:FindAllModifiersByName("modifier_arena_rune_acceleration")) do
			if v.creep_xp_multiplier then
				filterTable.experience = filterTable.experience * v.creep_xp_multiplier
			end
		end
	end
	return true
end