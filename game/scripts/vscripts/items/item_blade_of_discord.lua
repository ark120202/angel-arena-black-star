function Damage(keys)
	local caster = keys.caster
	local ability = keys.ability

	ApplyDamage({
		attacker = caster,
		victim = keys.target,
		damage = math.max(0, (caster:GetAgility() + caster:GetIntellect() + caster:GetStrength()) * keys.debuff_stats_multiplier) + keys.debuff_damage_base,
		damage_type = ability:GetAbilityDamageType(),
		damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
		ability = ability,
	})
end