function ReduceArmor(keys)
	local caster = keys.caster
	local unit = keys.target
	local ability = keys.ability
	local stacks = ability:GetAbilitySpecial("armor_per_hit")
	if unit:IsBoss() then
		stacks = math.min(stacks, ability:GetAbilitySpecial("boss_max_armor") - unit:GetModifierStackCount("modifier_stegius_desolating_touch_debuff", ability))
	end

	ModifyStacks(ability, caster, unit, "modifier_stegius_desolating_touch_debuff", stacks, true)
	unit:EmitSound("Item_Desolator.Target")
	Timers:CreateTimer(ability:GetAbilitySpecial("duration"), function()
		if IsValidEntity(caster) and IsValidEntity(unit) then
			ModifyStacks(ability, caster, unit, "modifier_stegius_desolating_touch_debuff", -stacks)
		end
	end)
end
