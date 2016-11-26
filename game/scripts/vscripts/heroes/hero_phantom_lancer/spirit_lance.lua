function ConjureImage(event)
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local illusion = CreateIllusion(caster, ability, caster:GetAbsOrigin(), ability:GetLevelSpecialValueFor("illusion_incoming_damage", ability:GetLevel()-1) - 100, ability:GetLevelSpecialValueFor("illusion_outgoing_damage", ability:GetLevel()-1) - 100, ability:GetLevelSpecialValueFor( "illusion_duration", ability:GetLevel() - 1 ))
	illusion:SetForwardVector(caster:GetForwardVector())
	FindClearSpaceForUnit(caster, target:GetAbsOrigin() + RandomVector(100), true)
	caster:MoveToTargetToAttack(target)
end