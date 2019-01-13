function CheckDust(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local pctMissing = 100 - caster:GetHealthPercent()
	local modifier = caster:FindModifierByName("modifier_item_vermillion_robe_dust")
	if pctMissing <= 0 then
		if modifier then
			modifier:Destroy()
		end
	else
		if not modifier then
			modifier = ability:ApplyDataDrivenModifier(caster, caster, "modifier_item_vermillion_robe_dust", nil)
		end
		if modifier then
			modifier:SetStackCount(pctMissing)
		end
	end
end
