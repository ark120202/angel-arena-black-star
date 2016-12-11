function ApplyShards(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = caster:GetAbsOrigin()
	for _, target in ipairs(FindUnitsInRadius(caster:GetTeamNumber(), point, nil, ability:GetCastRange(point, nil), ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)) do
		local dmg_pct =  ability:GetLevelSpecialValueFor("dmage_pct", ability:GetLevel() - 1) + (ability:GetLevelSpecialValueFor("stack_dmage_pct", ability:GetLevel() - 1) * target:GetModifierStackCount("modifier_boss_freya_sharp_ice_shards_stack", caster))
		ApplyDamage({
			attacker = caster,
			victim = target,
			damage_type = ability:GetAbilityDamageType(),
			damage = target:GetMaxHealth() * dmg_pct * 0.01,
			ability = ability
		})
		ModifyStacks(ability, caster, target, "modifier_boss_freya_sharp_ice_shards_stack", 1, true)
	end
end