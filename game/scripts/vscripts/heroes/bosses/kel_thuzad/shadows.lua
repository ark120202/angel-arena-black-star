function Reflection(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = caster:GetAbsOrigin()
	local stacks = caster:GetModifierStackCount("modifier_boss_kel_thuzad_immortality", caster)
	local ic = caster:HasModifier("modifier_boss_kel_thuzad_immortality") and stacks <= ability:GetSpecialValueFor("reduced_stacks") and ability:GetSpecialValueFor("reduced_count") or 1
	local neutralTeam = caster:GetTeamNumber()
	for _,v in ipairs(FindUnitsInRadius(caster:GetTeamNumber(), point, nil, ability:GetCastRange(point, nil), ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)) do
		local illusions = Illusions:create({
			unit = v,
			owner = caster,
			count = ic,
			padding = 100,
			damageIncoming = 0,
			damageOutgoing = ability:GetSpecialValueFor("illusion_outgoing_tooltip"),
			duration = ability:GetSpecialValueFor("illusion_duration"),
		})

		for _, illusion in ipairs(illusions) do
			ability:ApplyDataDrivenModifier(caster, illusion, "modifier_boss_kel_thuzad_shadows", nil)
			illusion:SetForceAttackTarget(v)
			illusion:EmitSound("Hero_Terrorblade.Reflection")
		end
	end
end
