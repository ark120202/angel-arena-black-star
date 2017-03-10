function PresenceOfDeath(keys)
	local caster = keys.caster
	local ability = keys.ability
	local stacks = caster:GetModifierStackCount("modifier_boss_kel_thuzad_immortality", caster)
	local dmg_pct = ability:GetSpecialValueFor(caster:HasModifier("modifier_boss_kel_thuzad_immortality") and stacks <= ability:GetSpecialValueFor("reduced_stacks") and "reduced_damage_pct" or "normal_damage_pct")
	for _,v in ipairs(FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, ability:GetSpecialValueFor("radius"), ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)) do
		ApplyDamage({
			attacker = caster,
			victim = v,
			damage_type = ability:GetAbilityDamageType(),
			damage = v:GetMaxHealth() * dmg_pct * 0.01,
			ability = ability
		})
	end
end