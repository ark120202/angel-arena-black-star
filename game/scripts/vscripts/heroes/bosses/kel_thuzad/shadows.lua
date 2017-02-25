function Reflection(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = caster:GetAbsOrigin()
	local stacks = caster:GetModifierStackCount("modifier_boss_kel_thuzad_immortality", caster)
	local ic = caster:HasModifier("modifier_boss_kel_thuzad_immortality") and stacks <= ability:GetSpecialValueFor("reduced_stacks") and ability:GetSpecialValueFor("reduced_count") or 1
	local neutralTeam = caster:GetTeamNumber()
	for _,v in ipairs(FindUnitsInRadius(caster:GetTeamNumber(), point, nil, ability:GetCastRange(point, nil), ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)) do
		for i = 1, ic do
			local illusion = CreateIllusion(v, ability, v:GetAbsOrigin() + RandomVector(100), 0, ability:GetSpecialValueFor( "illusion_outgoing_damage"), ability:GetSpecialValueFor( "illusion_duration"))
			illusion:SetTeam(neutralTeam)
			ability:ApplyDataDrivenModifier(caster, illusion, "modifier_boss_kel_thuzad_shadows", nil)
			illusion:SetForceAttackTarget(v)
			illusion:EmitSound("Hero_Terrorblade.Reflection")
		end
	end
end