function ConjureImage(event)
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local illusion = Illusions:create({
		unit = caster,
		ability = ability,
		origin = caster:GetAbsOrigin(),
		incomingDamage = ability:GetSpecialValueFor("illusion_incoming_damage"),
		outgoingDamage = ability:GetSpecialValueFor("illusion_outgoing_damage"),
		duration = ability:GetSpecialValueFor("illusion_duration")
	})
	FindClearSpaceForUnit(caster, target:GetAbsOrigin() + RandomVector(100), true)
	caster:MoveToTargetToAttack(target)
end
