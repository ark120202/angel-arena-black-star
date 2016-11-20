function SplitShotLaunch( keys )
	local caster = keys.caster
	if IsRangedUnit(caster) or keys.melee then
		local caster_location = caster:GetAbsOrigin()
		local ability = keys.ability
		local attack_target = caster:GetAttackTarget()
		local radius = ability:GetSpecialValueFor("range")
		local split_shot_targets = FindUnitsInRadius(caster:GetTeam(), keys.target:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
		for _,v in ipairs(split_shot_targets) do
			if v ~= attack_target and not v:IsAttackImmune() then
				local projectile_info = GenerateAttackProjectile(caster, ability)
				projectile_info["Target"] = v
				if keys.force_attack_projectile then
					projectile_info["EffectName"] = keys.force_attack_projectile
				end
				ProjectileManager:CreateTrackingProjectile(projectile_info)
			end
		end
	end
end

function SplitShotDamage( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage_percent = keys.Damage_percent

	local itemcount = 0
	for i = 0, 5 do
		local item = caster:GetItemInSlot(i)
		if item and item:GetName() == ability:GetName() then
			itemcount = itemcount + 1
		end
	end
	if not caster:IsIllusion() then
		ApplyDamage({
			attacker = caster,
			victim = target,
			damage_type = DAMAGE_TYPE_PHYSICAL,
			damage = caster:GetAverageTrueAttackDamage(target) * (damage_percent / 100) * itemcount,
			ability = ability
		})
	end
end

function AttackRandomTarget(keys)
	local caster = keys.caster
	local ability = keys.ability
	local units = FindUnitsInRadius(caster:GetTeamNumber(), Vector(0, 0, 0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	local projectile_info = GenerateAttackProjectile(caster, ability)
	local unit = units[RandomInt(1, #units)]
	projectile_info["Target"] = unit
	projectile_info["bProvidesVision"] = true
	projectile_info["iVisionRadius"] = 250
	projectile_info["iVisionTeamNumber"] = caster:GetTeamNumber()
	ProjectileManager:CreateTrackingProjectile(projectile_info)
end