function SplitShotLaunch( keys )
	local caster = keys.caster
	local caster_location = caster:GetAbsOrigin()
	local ability = keys.ability
	local attack_target = caster:GetAttackTarget()

	local radius = ability:GetSpecialValueFor("splash_range")
	local projectile_speed = caster:GetKeyValue("ProjectileSpeed")
	local split_shot_projectile = caster:GetKeyValue("ProjectileModel")
	
	for _,v in ipairs(FindUnitsInRadius(caster:GetTeam(), caster_location, nil, caster:GetAttackRange(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false)) do
		if v ~= attack_target then
			ProjectileManager:CreateTrackingProjectile({
				EffectName = split_shot_projectile,
				Ability = ability,
				vSpawnOrigin = caster_location,
				Target = v,
				Source = caster,
				bHasFrontalCone = false,
				iMoveSpeed = projectile_speed,
				bReplaceExisting = false,
				bProvidesVision = false
			})
		end
	end
end

function SplitShotDamage( keys )
	local caster = keys.caster
	local target = keys.target

	ApplyDamage({
		attacker = caster,
		victim = target,
		damage_type = DAMAGE_TYPE_PHYSICAL,
		damage = caster:GetAverageTrueAttackDamage(target),
		ability = keys.ability
	})
end

function CheckPosition(keys)
	local caster = keys.caster

	if caster.ai and caster.ai.spawnPos and (caster:GetAbsOrigin()-caster.ai.spawnPos):Length2D() >= 50 then
		FindClearSpaceForUnit(caster, caster.ai.spawnPos, true)
	end
end