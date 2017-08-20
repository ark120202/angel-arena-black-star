function DealDamage(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	ApplyDamage({
		attacker = caster,
		victim = target,
		damage_type = ability:GetAbilityDamageType(),
		damage = (keys.damage + (caster:GetMaxHealth() - caster:GetHealth()) * keys.missing_hp_damage_pct * 0.01) * target:GetModifierStackCount("modifier_huskar_burning_spear_arena_debuff", caster),
		ability = ability
	})
end

function DoHealthCost(keys)
	local caster = keys.caster
	local cost = (keys.damage + (caster:GetMaxHealth() - caster:GetHealth()) * keys.missing_hp_damage_pct * 0.01) * keys.health_cost_pct * 0.01
	caster:ModifyHealth(caster:GetHealth() - cost, keys.ability, false, 0)
end

function ThinkHealth(keys)
	local ability = keys.ability
	local caster = keys.caster
	if caster:GetHealthPercent() <= keys.aura_trigger_health_pct and not caster:HasModifier("modifier_huskar_burning_spear_arena_aura") then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_huskar_burning_spear_arena_aura", nil)
	elseif caster:GetHealthPercent() > keys.aura_trigger_health_pct and caster:HasModifier("modifier_huskar_burning_spear_arena_aura") then
		caster:RemoveModifierByName("modifier_huskar_burning_spear_arena_aura")
	end
end

function ThinkAura(keys)
	local ability = keys.ability
	local caster = keys.caster
	local per_stack_duration = keys.per_stack_duration
	for _,v in ipairs(FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, keys.aura_radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)) do
		if RollPercentage(keys.aura_burn_chance_pct) then
			ModifyStacks(ability, caster, v, "modifier_huskar_burning_spear_arena_debuff", 1, true)
			Timers:CreateTimer(per_stack_duration, function()
				if IsValidEntity(ability) and IsValidEntity(v) then
					ModifyStacks(ability, caster, v, "modifier_huskar_burning_spear_arena_debuff", -1, true)
				end
			end)
		end
	end
end
