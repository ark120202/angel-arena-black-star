function OnSpellStart(keys)
	local caster = keys.caster
	local target_point = keys.target_points[1]
	local ability = keys.ability
	local level = ability:GetLevel() - 1
	local projectile_speed = ability:GetLevelSpecialValueFor("projectile_speed", level)
	local velocity = (target_point - caster:GetAbsOrigin()):Normalized()
	local len = (target_point - caster:GetAbsOrigin()):Length2D()
	velocity.z = 0
	print(velocity * len)
	ProjectileManager:CreateLinearProjectile( {
		Ability = ability,
		vVelocity = velocity * projectile_speed,
		fDistance = len,
		EffectName = "particles/units/heroes/hero_techies/techies_base_attack_model.vpcf",
		vSpawnOrigin = caster:GetAbsOrigin(),
		Source = caster,
		bReplaceExisting = false,
		bDeleteOnHit = false,
	})
end