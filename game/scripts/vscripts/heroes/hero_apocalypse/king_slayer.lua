function ApplyDisarmor(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local disarmor = ability:GetLevelSpecialValueFor("armor_reduction_pct", ability:GetLevel() - 1) * 0.01
	local stacks = target:GetPhysicalArmorBaseValue() * disarmor
	local m = ability:ApplyDataDrivenModifier(caster, target, "modifier_apocalypse_king_slayer_knockback", nil)
	if m:GetStackCount() < stacks then
		m:SetStackCount(stacks)
	end
	ApplyDamage({
		victim = target,
		attacker = caster,
		damage = ability:GetAbilitySpecial("damage_per_armor") * stacks,
		damage_type = ability:GetAbilityDamageType(),
		damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
		ability = ability
	})
end
