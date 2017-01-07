function ReduceArmor(keys)
	local caster = keys.caster
	local unit = keys.target
	local ability = keys.ability
	local stacks = -(unit:IsBoss() and ability:GetAbilitySpecial("armor_per_hit_bosses") or ability:GetAbilitySpecial("armor_per_hit"))
	ModifyStacks(ability, caster, unit, "modifier_stegius_desolating_touch_debuff", stacks, true)
	Timers:CreateTimer(ability:GetAbilitySpecial("duration"), function()
		if IsValidEntity(caster) then
			ModifyStacks(ability, caster, unit, "modifier_stegius_desolating_touch_debuff", -stacks)
		end
	end)
end