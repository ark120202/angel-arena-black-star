function DealDamage(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local per_stack_duration = keys.per_stack_duration
	for _,v in ipairs(FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, ability:GetSpecialValueFor("fire_spread_radius"), ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)) do
		if v ~= target then
			ModifyStacks(ability, caster, v, "modifier_huskar_burning_spear_arena_debuff", 1, true)
			Timers:CreateTimer(per_stack_duration, function()
				if IsValidEntity(ability) and IsValidEntity(v) then
					ModifyStacks(ability, caster, v, "modifier_huskar_burning_spear_arena_debuff", -1, true)
				end
			end)
		end
	end
	ApplyDamage({
		attacker = caster,
		victim = target,
		damage_type = ability:GetAbilityDamageType(),
		damage = keys.damage * target:GetModifierStackCount("modifier_huskar_burning_spear_arena_debuff", caster),
		ability = ability
	})
end

function DoHealthCost(keys)
	local caster = keys.caster
	caster:ModifyHealth(caster:GetHealth() - keys.health_cost, keys.ability, false, 0)
end