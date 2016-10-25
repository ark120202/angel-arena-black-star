function IncreaseStacks(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local modifier = "modifier_item_dark_flow_stack"
	if target:GetModifierStackCount(modifier, ability) >= ability:GetAbilitySpecial("max_stacks") then
		ability:ApplyDataDrivenModifier(caster, target, modifier, {})
	else
		ModifyStacks(ability, caster, target, modifier, -ability:GetAbilitySpecial("armor_per_hit"), true)
	end
end