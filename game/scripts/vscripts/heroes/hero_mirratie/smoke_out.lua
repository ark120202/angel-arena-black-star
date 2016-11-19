function SmokeOut(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]

	ProjectileManager:ProjectileDodge(caster)
	ParticleManager:CreateParticle("particles/items_fx/blink_dagger_start.vpcf", PATTACH_ABSORIGIN, caster)
	ability:ApplyDataDrivenThinker(caster, caster:GetAbsOrigin(), "modifier_mirratie_smoke_out", nil)
	ability:CreateVisibilityNode(caster:GetAbsOrigin(), 10, ability:GetAbilitySpecial("duration"))
	FindClearSpaceForUnit(caster, point, true)
	ParticleManager:CreateParticle("particles/items_fx/blink_dagger_end.vpcf", PATTACH_ABSORIGIN, caster)
end