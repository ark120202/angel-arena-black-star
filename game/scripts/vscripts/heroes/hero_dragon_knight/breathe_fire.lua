function FireProjectile(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]
	local count = 1
	if caster:HasScepter() then
		count = 8
	end
	for i = 1, count do
		local pos = point
		if caster:HasScepter() then
			pos = RotatePosition(caster:GetAbsOrigin(),QAngle(0, 360/count*i, 0),point)
		end
		ProjectileManager:CreateLinearProjectile({
			Ability = ability,
			EffectName = "particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf",
			vSpawnOrigin = caster:GetAbsOrigin(),
			Source = caster,
			bHasFrontalCone = true,
			bReplaceExisting = false,
			fStartRadius = ability:GetAbilitySpecial("start_radius"),
			fEndRadius = ability:GetAbilitySpecial("end_radius"),
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,

			vVelocity = (pos - caster:GetAbsOrigin()):Normalized() * ability:GetAbilitySpecial("speed"),
			fDistance = ability:GetAbilitySpecial("range"),
			fExpireTime = GameRules:GetGameTime() + ability:GetAbilitySpecial("range")/ability:GetAbilitySpecial("speed"),
		--	bDeleteOnHit = false,
		})
	end
end