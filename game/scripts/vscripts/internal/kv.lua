function SpendChargeRight(keys)
	SpendCharge(keys.ability, 1)
end

function SetMaxLevel(keys)
	local ability = keys.ability
	ability:SetLevel(ability:GetMaxLevel())
end

function HideCaster(keys)
	keys.caster:AddNoDraw()
end

function ShowCaster(keys)
	keys.caster:RemoveNoDraw()
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
	if not caster:IsIllusion() and not caster:HasModifier("modifier_arc_warden_tempest_double") then
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

function MeepoCleaner(keys)
	if keys.modifier and keys.caster.OwnerMeepo then
		keys.caster:RemoveModifierByName(keys.modifier)
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
	Timers:CreateTimer(0.03, function()
		if keys.modifier and keys.caster:IsIllusion() then
			keys.caster:RemoveModifierByName(keys.modifier)
		end
	end)
end

function ReplaceAbilityWith(keys)
	local caster = keys.caster
	local ability = keys.ability
	if keys.new then
		ReplaceAbilities(caster, ability:GetAbilityName(), keys.new, true, false)
	end
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

function KillTarget(keys)
	if keys.target:IsAlive() then
		TrueKill(keys.caster, keys.ability, keys.target)
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
	local pos = (keys.position or caster):GetAbsOrigin()
	if keys.summon_random_radius then
		pos = RandomPositionAroundPoint(pos, keys.summon_random_radius)
	end
	local unit = CreateUnitByName(keys.summoned, pos, true, caster, nil, team)
	unit:SetControllableByPlayer(caster:GetPlayerID(), true)
	unit:SetOwner(caster)
	if keys.modifiers_datadriven then
		for _,v in ipairs(string.split(keys.modifiers_datadriven)) do
			ability:ApplyDataDrivenModifier(caster, unit, v, nil)
		end
	end
	local units_summoned = caster["custom_summoned_unit_ability_" .. ability:GetAbilityName()]
	if max_units and max_units >= 1 then
		if not units_summoned then
			caster["custom_summoned_unit_ability_" .. ability:GetAbilityName()] = {}
			units_summoned = caster["custom_summoned_unit_ability_" .. ability:GetAbilityName()]
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

function IncreaseStacks(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local modifier = keys.modifier
	local max_stacks = keys.max_stacks
	if (keys.NoBosses ~= 1 or not IsBossEntity(target)) then
		if max_stacks and target:GetModifierStackCount(modifier, ability) >= max_stacks then
			ability:ApplyDataDrivenModifier(caster, target, modifier, {})
		else
			ModifyStacks(ability, caster, target, modifier, keys.stacks or 1, true)
		end
	end
end

function ApplyModifierWithoutRefresh(keys)
	local target = keys.target or keys.caster
	if ((keys.HeroOnly == 1 and target:IsHero()) or (keys.HeroOnly ~= 1)) and not target:HasModifier(keys.modifier) then
		keys.ability:ApplyDataDrivenModifier(keys.caster, target, keys.modifier, nil)
	end
end

function SetAbilityActivated(keys)
	keys.ability:SetActivated(keys.Activated == 1)
end

function ScepterOnlyPassiveModifierThink(keys)
	local caster = keys.caster
	local ability = keys.ability
	local modifier = keys.modifier
	if HasScepter(caster) and not caster:HasModifier(modifier) then
		ability:ApplyDataDrivenModifier(caster, caster, modifier, {})
	elseif not HasScepter(caster) and caster:HasModifier(modifier) then
		caster:RemoveModifierByName(modifier)
	end
end

function PercentDamage(keys)
	local ability = keys.ability
	local target = keys.target
	local damage = keys.Damage or 0
	if keys.MaxHealthPercent then damage = damage + (keys.MaxHealthPercent*0.01*target:GetMaxHealth()) end
	if keys.CurrnetHealthPercent then damage = damage + (keys.CurrnetHealthPercent*0.01*target:GetHealth()) end
	if keys.multiplier then damage = damage * keys.multiplier end
	ApplyDamage({victim = target, attacker = keys.caster, damage = damage, damage_type = ability:GetAbilityDamageType(), ability = ability})
end