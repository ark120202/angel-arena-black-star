function ReduceArmor(keys)
	local caster = keys.caster
	local unit = keys.target
	local ability = keys.ability
	ModifyStacks(ability, caster, unit, "modifier_stegius_desolating_touch_debuff", -ability:GetAbilitySpecial("armor_per_hit"), true)
end