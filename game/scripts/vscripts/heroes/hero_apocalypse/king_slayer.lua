function ApplyDisarmor(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local stacks = target:GetPhysicalArmorBaseValue() / 2
	if target.GetAgility then
		stacks = stacks + ((target:GetAgility() * DEFAULT_ARMOR_PER_AGI) / 2)
	end
	local m = ability:ApplyDataDrivenModifier(caster, target, "modifier_apocalypse_king_slayer_knockback", nil)
	if m:GetStackCount() < stacks then
		m:SetStackCount(stacks)
	end
	ApplyDamage({
		victim = target,
		attacker = caster,
		damage = ability:GetAbilitySpecial("damage_per_armor") * stacks,
		damage_type = ability:GetAbilityDamageType(),
		ability = ability
	})
end