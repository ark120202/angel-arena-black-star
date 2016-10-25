function StoneGaze(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if RollPercentage(ability:GetAbilitySpecial("stone_chance_pct")) then
		local stone_duration = ability:GetAbilitySpecial("stone_duration")
		if caster:IsIllusion() then
			stone_duration = ability:GetAbilitySpecial("stone_duration_illusion")
		elseif target:IsIllusion() then
			target:ForceKill(false)
		end
		target:EmitSound("Hero_Medusa.StoneGaze.Cast")
		ability:ApplyDataDrivenModifier(caster, target, "modifier_stone_gaze_stone_arena", {duration = stone_duration})
	end
end