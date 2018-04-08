function ReduceArmor(keys)
	local caster = keys.caster
	local unit = keys.target
	local ability = keys.ability
	if not unit:IsBoss() or RollPercentage(ability:GetAbilitySpecial("boss_armor_reduction_chance_pct")) then
		local stacks = ability:GetAbilitySpecial("armor_per_hit")
		ModifyStacks(ability, caster, unit, "modifier_stegius_desolating_touch_debuff", stacks, true)
		unit:EmitSound("Item_Desolator.Target")
		Timers:CreateTimer(ability:GetAbilitySpecial("duration"), function()
			if IsValidEntity(caster) and IsValidEntity(unit) then
				ModifyStacks(ability, caster, unit, "modifier_stegius_desolating_touch_debuff", -stacks)
			end
		end)
	end
end
