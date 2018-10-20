return function(lockModifierName, radiusSpecialName, projectileSpeedSpecialName)
	return function(attacker, target, ability)
		if not attacker:IsRangedUnit() then return end

		if lockModifierName then
			local lockName = "_lock_" .. lockModifierName
			if attacker[lockName] then return end
			attacker[lockName] = true
			Timers:NextTick(function() attacker[lockName] = false end)
		end

		local radius = ability:GetSpecialValueFor(radiusSpecialName)
		local targets = FindUnitsInRadius(
			attacker:GetTeam(),
			target:GetAbsOrigin(),
			nil,
			radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
			FIND_CLOSEST,
			false
		)

		local projInfo = GenerateAttackProjectile(attacker, ability)
		for _,v in ipairs(targets) do
			if v ~= target and not v:IsAttackImmune() then
				projInfo.Target = v
				if projectileSpeedSpecialName then
					projInfo.iMoveSpeed = ability:GetSpecialValueFor(projectileSpeedSpecialName)
				end

				ProjectileManager:CreateTrackingProjectile(projInfo)
			end
		end
	end
end
