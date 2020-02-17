function SpendChargeRight(keys)
	keys.ability:SpendCharge()
end

function SetMaxLevel(keys)
	local ability = keys.ability
	ability:SetLevel(ability:GetMaxLevel())
end

function HideTarget(keys)
	local target = keys.target or keys.caster
	target:AddNoDraw()
end

function ShowTarget(keys)
	local target = keys.target or keys.caster
	target:RemoveNoDraw()
end

function SetFirstLevel(keys)
	keys.ability:SetLevel(1)
end

function DropItem(keys)
	local caster = keys.caster
	if not caster:IsIllusion() and not caster:IsTempestDouble() then
		caster:DropItemAtPositionImmediate(keys.ability, caster:GetAbsOrigin())
	end
end

function StopEndableSound(keys)
	local target = keys.target or keys.caster
	if keys.modifier then
		local canDestroy = true
		for i in string.gmatch(keys.modifier, "%S+") do
			if target:HasModifier(i) then
				canDestroy = false
			end
		end
		if canDestroy then
			keys.target:StopSound(keys.sound)
		end
	else
		keys.target:StopSound(keys.sound)
	end
end

function SwapToItem(keys)
	local caster = keys.caster
	local ability = keys.ability
	local itemName = keys.itemName
	if itemName then
		local newItem = CreateItem(itemName, caster, caster)
		newItem:SetPurchaseTime(ability:GetPurchaseTime())
		newItem:SetPurchaser(ability:GetPurchaser())
		newItem:SetOwner(ability:GetOwner())
		if keys.ShareCoolodwn == 1 then
			newItem:StartCooldown(ability:GetCooldownTimeRemaining())
		end
		swap_to_item(caster, ability, newItem)
	end
end

function IllusionModifierCleaner(keys)
	local caster = keys.caster
	Timers:NextTick(function()
		if keys.modifier and IsValidEntity(caster) and (caster:IsIllusion() or caster:IsWukongsSummon()) then
			caster:RemoveModifierByName(keys.modifier)
		end
	end)
end

function LinkedAbilitiesSync(keys)
	local caster = keys.caster
	local ability = keys.ability
	local linked_ability = caster:FindAbilityByName(keys.linked_ability)
	if linked_ability then
		if linked_ability:GetLevel() > ability:GetLevel() then
			ability:SetLevel(linked_ability:GetLevel())
		elseif linked_ability:GetLevel() < ability:GetLevel() then
			linked_ability:SetLevel(ability:GetLevel())
		end
	end
end

function UpgradeChargeBasedAbility(keys)
	local caster = keys.caster
	local ability = keys.ability
	local max_charges = keys.max_charges
	if keys.max_charges_scepter and caster:HasScepter() then
		max_charges = keys.max_charges_scepter
	end
	local modifiers = caster:FindAllModifiersByName("modifier_charges")
	if #modifiers == 0 then
		caster:AddNewModifier(caster, ability, "modifier_charges", {
			max_count = max_charges,
			start_count = max_charges,
			replenish_time = keys.charge_replenish_time
		})
	else
		for _,v in ipairs(modifiers) do
			if v:GetAbility() == ability then
				v.kv.replenish_time = keys.charge_replenish_time
				v:SetMaxStackCount(max_charges)
			end
		end
	end
end

function SummonUnit(keys)
	local caster = keys.caster
	local ability = keys.ability
	local team = (keys.team or caster):GetTeamNumber()
	local max_units = keys.max_units
	for i = 1, keys.amount or 1 do
		local pos = (keys.position or caster):GetAbsOrigin()
		if keys.summon_random_radius then
			pos = pos + RandomVector(RandomInt(0, keys.summon_random_radius))
		end
		local unit = CreateUnitByName(keys.summoned, pos, true, caster, caster:GetPlayerOwner(), team)
		if not unit then
			error("kv.SummonUnit: Unit with name " .. keys.summoned .. " not found.")
		end
		FindClearSpaceForUnit(unit, pos, true)
		unit:SetControllableByPlayer(caster:GetPlayerID(), true)
		unit:SetOwner(caster)
		if keys.modifiers_datadriven then
			for _,v in ipairs(string.split(keys.modifiers_datadriven)) do
				ability:ApplyDataDrivenModifier(caster, unit, v, nil)
			end
		end
		if keys.health then
			unit:SetBaseMaxHealth(keys.health)
			unit:SetMaxHealth(keys.health)
			unit:SetHealth(keys.health)
		end
		if keys.damage then
			unit:SetBaseDamageMin(keys.damage)
			unit:SetBaseDamageMax(keys.damage)
		end
		if keys.base_attack_time then
			unit:SetBaseAttackTime(keys.base_attack_time)
		end
		if keys.health_regeneration then
			unit:SetBaseHealthRegen(keys.health_regeneration)
		end
		if keys.armor then
			unit:SetPhysicalArmorBaseValue(keys.armor)
		end
		if keys.gold then
			unit:SetMinimumGoldBounty(keys.gold)
			unit:SetMaximumGoldBounty(keys.gold)
		end
		if keys.xp then
			unit:SetDeathXP(keys.xp)
		end
		if keys.movespeed then
			unit:SetBaseMoveSpeed(keys.movespeed)
		end
		if keys.duration then
			unit:AddNewModifier(caster, ability, "modifier_kill", {duration = keys.duration})
		end
		local ability_name = ability:GetAbilityName()
		local units_summoned = caster["custom_summoned_unit_ability_" .. ability_name]
		if max_units and max_units >= 1 then
			if not units_summoned then
				caster["custom_summoned_unit_ability_" .. ability_name] = {}
				units_summoned = caster["custom_summoned_unit_ability_" .. ability_name]
			end
			table.insert(units_summoned, unit)
			if #units_summoned - 1 >= max_units then
				local u = table.remove(units_summoned, 1)
				if u and not u:IsNull() and u:IsAlive() then
					u:ForceKill(false)
				end
			end
		end
	end
end

function IncreaseStacks(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local modifier = keys.modifier
	local stacks = keys.stacks or 1
	local max_stacks = keys.max_stacks
	local per_stack_duration = keys.per_stack_duration
	if keys.NoBosses ~= 1 or not target:IsBoss() then
		if per_stack_duration then
			ModifyStacks(ability, caster, target, modifier, stacks, true)
			Timers:CreateTimer(per_stack_duration, function()
				if IsValidEntity(ability) and IsValidEntity(target) then
					ModifyStacks(ability, caster, target, modifier, -stacks, true)
				end
			end)
		else
			if max_stacks and target:GetModifierStackCount(modifier, ability) >= max_stacks then
				ability:ApplyDataDrivenModifier(caster, target, modifier, {})
			else
				ModifyStacks(ability, caster, target, modifier, stacks, true)
			end
		end
	end
end

function ApplyModifierWithoutRefresh(keys)
	local target = keys.target or keys.caster
	if ((keys.HeroOnly == 1 and target:IsHero()) or (keys.HeroOnly ~= 1)) and not target:HasModifier(keys.modifier) then
		if keys.lua == 1 then
			target:AddNewModifier(keys.caster, keys.ability, keys.modifier, {duration = keys.duration})
		else
			keys.ability:ApplyDataDrivenModifier(keys.caster, target, keys.modifier, {duration = keys.duration})
		end
	end
end

function ScepterOnlyPassiveModifierThink(keys)
	local caster = keys.caster
	local ability = keys.ability
	local modifier = keys.modifier
	if caster:HasScepter() and not caster:HasModifier(modifier) then
		ability:ApplyDataDrivenModifier(caster, caster, modifier, {})
	elseif not caster:HasScepter() and caster:HasModifier(modifier) then
		caster:RemoveModifierByName(modifier)
	end
end

function PercentDamage(keys)
	local ability = keys.ability
	local target = keys.target
	local damage = keys.Damage or 0
	if ability then
		if keys.MaxHealthPercent then damage = damage + (keys.MaxHealthPercent*0.01*target:GetMaxHealth()) end
		if keys.CurrnetHealthPercent then damage = damage + (keys.CurrnetHealthPercent*0.01*target:GetHealth()) end
		if keys.multiplier then damage = damage * keys.multiplier end
		ApplyDamage({
			victim = target,
			attacker = keys.caster,
			damage = damage,
			damage_type = ability:GetAbilityDamageType(),
			damage_flags = keys.CalculateSpellDamageTooltip == 0 and DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION or DOTA_DAMAGE_FLAG_NONE,
			ability = ability
		})
	end
end

function KVPurge(keys)
	(keys.target or keys.caster):Purge(keys.RemovePositiveBuffs == 1, keys.RemoveDebuffs == 1, false, keys.RemoveStuns == 1, false)
end

function UpdateAttackProjectile(keys)
	keys.caster:UpdateAttackProjectile()
end

function ModifyCreepDamage(keys)
	local caster = keys.caster
	local target = keys.target
	if target:IsRealCreep() then
		local ability = keys.ability
		local damage_bonus = keys.damage_bonus_ranged ~= nil and caster:IsRangedUnit() and keys.damage_bonus_ranged or keys.damage_bonus

		-- If not specified, assume that constant values are given
		local damage = keys.damage and
			(keys.damage * (damage_bonus * 0.01 - 1)) or
			damage_bonus

		ApplyDamage({
			attacker = caster,
			victim = target,
			damage = damage,
			damage_type = DAMAGE_TYPE_PURE,
			damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
			ability = keys.ability
		})
	end
end
