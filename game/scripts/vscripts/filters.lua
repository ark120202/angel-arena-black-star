Events:Register("activate", function ()
	GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(GameMode, 'ExecuteOrderFilter'), GameRules)
	GameRules:GetGameModeEntity():SetDamageFilter(Dynamic_Wrap(GameMode, 'DamageFilter'), GameRules)
	GameRules:GetGameModeEntity():SetModifyGoldFilter(Dynamic_Wrap(GameMode, 'ModifyGoldFilter'), GameRules)
	GameRules:GetGameModeEntity():SetModifyExperienceFilter(Dynamic_Wrap(GameMode, 'ModifyExperienceFilter'), GameRules)
	GameRules:GetGameModeEntity():SetItemAddedToInventoryFilter(Dynamic_Wrap(GameMode, 'ItemAddedToInventoryFilter'), GameRules)
end)

function GameMode:ExecuteOrderFilter(filterTable)
	local order_type = filterTable.order_type
	local playerId = filterTable.issuer_player_id_const
	if order_type == DOTA_UNIT_ORDER_PURCHASE_ITEM then
		return false
	end
	local target = EntIndexToHScript(filterTable.entindex_target)
	local ability = EntIndexToHScript(filterTable.entindex_ability)
	local abilityname
	if ability and ability.GetAbilityName then
		abilityname = ability:GetAbilityName()
	end
	if order_type == DOTA_UNIT_ORDER_TRAIN_ABILITY and Options:IsEquals("EnableAbilityShop") then
		CustomAbilities:OnAbilityBuy(playerId, abilityname)
		return false
	end

	local unit = EntIndexToHScript(filterTable.units["0"])

	if unit and order_type == DOTA_UNIT_ORDER_SELL_ITEM and ability then
		PanoramaShop:SellItem(playerId, unit, ability)
		return false
	end

	if unit:IsCourier() and (
		order_type == DOTA_UNIT_ORDER_CAST_POSITION or
		order_type == DOTA_UNIT_ORDER_CAST_TARGET or
		order_type == DOTA_UNIT_ORDER_CAST_TARGET_TREE or
		order_type == DOTA_UNIT_ORDER_CAST_NO_TARGET or
		order_type == DOTA_UNIT_ORDER_CAST_TOGGLE
	) and ability.IsItem and ability:IsItem() then
		Containers:DisplayError(playerId, "dota_hud_error_courier_cant_use_item")
		return false
	end

	if not unit:IsConsideredHero() then return true end

	GameMode:TrackInventory(unit)
	if not ability then return true end

	if order_type == DOTA_UNIT_ORDER_CAST_POSITION then
		if not Duel:IsDuelOngoing() and ARENA_NOT_CASTABLE_ABILITIES[abilityname] then
			local orderVector = Vector(filterTable.position_x, filterTable.position_y, 0)
			if type(ARENA_NOT_CASTABLE_ABILITIES[abilityname]) == "number" then
				local ent1len = (orderVector - Entities:FindByName(nil, "target_mark_arena_team2"):GetAbsOrigin()):Length2D()
				local ent2len = (orderVector - Entities:FindByName(nil, "target_mark_arena_team3"):GetAbsOrigin()):Length2D()
				if ent1len <= ARENA_NOT_CASTABLE_ABILITIES[abilityname] + 200 or ent2len <= ARENA_NOT_CASTABLE_ABILITIES[abilityname] + 200 then
					Containers:DisplayError(playerId, "#arena_hud_error_cant_target_duel")
					return false
				end
			end
			if IsInBox(orderVector, Duel.BlockerBox[1], Duel.BlockerBox[2]) then
				Containers:DisplayError(playerId, "#arena_hud_error_cant_target_duel")
				return false
			end
		end
	elseif order_type == DOTA_UNIT_ORDER_CAST_TARGET and IsValidEntity(target) then
		if abilityname == "rubick_spell_steal" then
			if target == unit then
				Containers:DisplayError(playerId, "#dota_hud_error_cant_cast_on_self")
				return false
			end
			if target:HasAbility("doppelganger_mimic") then
				Containers:DisplayError(playerId, "#dota_hud_error_cant_steal_spell")
				return false
			end
		end
		if target:IsChampion() and CHAMPIONS_BANNED_ABILITIES[abilityname] then
			Containers:DisplayError(playerId, "#dota_hud_error_ability_cant_target_champion")
			return false
		end
		if target.SpawnerType == "jungle" and JUNGLE_BANNED_ABILITIES[abilityname] then
			Containers:DisplayError(playerId, "#dota_hud_error_ability_cant_target_jungle")
			return false
		end
		if target:IsBoss() and BOSS_BANNED_ABILITIES[abilityname] then
			Containers:DisplayError(playerId, "#dota_hud_error_ability_cant_target_boss")
			return false
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
				else
					multiplier = v
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
					if multiplier.LifestealPercentage then
						LifestealPercentage = math.max(LifestealPercentage, multiplier.LifestealPercentage)
					end
					if multiplier.damage then
						if type(multiplier.damage) == "function" then
							local damage = multiplier.damage(attacker, victim, inflictor, damage, damagetype_const)
							if damage then
								filterTable.damage = damage
								return true
							end
						else
							filterTable.damage = multiplier.damage
							return true
						end
					end
					if multiplier.multiplier then
						multiplier = multiplier.multiplier
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
			SendOverheadEventMessage(victim:GetPlayerOwner(), OVERHEAD_ALERT_BLOCK, victim, BlockedDamage, attacker:GetPlayerOwner())
			SendOverheadEventMessage(attacker:GetPlayerOwner(), OVERHEAD_ALERT_BLOCK, victim, BlockedDamage, victim:GetPlayerOwner())

			filterTable.damage = filterTable.damage - BlockedDamage
		end
		if LifestealPercentage > 0 then
			local lifesteal = filterTable.damage * LifestealPercentage * 0.01
			SafeHeal(attacker, lifesteal)
			ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)
		end
		if attacker.GetPlayerOwnerID then
			local attackerPlayerId = attacker:GetPlayerOwnerID()
			if attackerPlayerId > -1 then
				if victim:IsRealHero() then
					PlayerResource:ModifyPlayerStat(attackerPlayerId, "heroDamage", filterTable.damage)
				end
				if victim:IsBoss() then
					PlayerResource:ModifyPlayerStat(attackerPlayerId, "bossDamage", filterTable.damage)
					victim.DamageReceived = victim.DamageReceived or {}
					victim.DamageReceived[attackerPlayerId] = (victim.DamageReceived[attackerPlayerId] or 0) + filterTable.damage
				end
			end
		end
	end
	return true
end

function GameMode:ModifyGoldFilter(filterTable)
	if filterTable.reason_const >= DOTA_ModifyGold_HeroKill and filterTable.reason_const <= DOTA_ModifyGold_CourierKill then
		filterTable.gold = 0
		return false
	end
	print("[GameMode:ModifyGoldFilter]: Attempt to call default dota gold modify func... FIX IT - Reason: " .. filterTable.reason_const .."  --  Amount: " .. filterTable.gold)
	filterTable.gold = 0
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
	PLAYER_DATA[filterTable.player_id_const].AntiAFKLastXP = GameRules:GetGameTime() + PLAYER_ANTI_AFK_TIME
	if Duel.IsFirstDuel and Duel:IsDuelOngoing() then
		filterTable.experience = filterTable.experience * 0.1
	end
	return true
end

function GameMode:ItemAddedToInventoryFilter(filterTable)
	local item = EntIndexToHScript(filterTable.item_entindex_const)
	if item.suggestedSlot then
		filterTable.suggested_slot = item.suggestedSlot
		item.suggestedSlot = nil
	end
	return true
end
