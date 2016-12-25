function ReduceArmor(keys)
	local unit = keys.target
	local ability = keys.ability
	local stacks = unit:IsBoss() and ability:GetAbilitySpecial("armor_per_hit_bosses") or ability:GetAbilitySpecial("armor_per_hit")
	ModifyStacks(ability, keys.caster, unit, "modifier_stegius_desolating_touch_debuff", -stacks, true)
end