function ReduceArmor(keys)
	local caster = keys.caster
	local unit = keys.target
	local ability = keys.ability
	local stacks = ability:GetAbilitySpecial("armor_per_hit")
	local modifier = unit:FindModifierByName("modifier_stegius_desolating_touch_debuff")
	ModifyStacks(ability, caster, unit, "modifier_stegius_desolating_touch_debuff", stacks, true)
	if unit:IsBoss() and modifier and modifier:GetStackCount() > ability:GetAbilitySpecial("boss_limit") then
		modifier:SetStackCount(ability:GetAbilitySpecial("boss_limit"))
	end
	unit:EmitSound("Item_Desolator.Target")
	Timers:CreateTimer(ability:GetAbilitySpecial("duration"), function()
		if IsValidEntity(caster) and IsValidEntity(unit) then
			ModifyStacks(ability, caster, unit, "modifier_stegius_desolating_touch_debuff", -stacks)
		end
	end)
end
