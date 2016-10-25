function CalculateStackBonus(keys)
	local ability = keys.ability
	local caster = keys.caster
	local modifierName = "modifier_tower_middle_protector_passive_stack"
	if not caster:HasModifier(modifierName) then ability:ApplyDataDrivenModifier(caster, caster, modifierName, {}) end
	if caster:GetModifierStackCount(modifierName, caster) < GetDOTATimeInMinutesFull() then
		caster:SetModifierStackCount(modifierName, caster, GetDOTATimeInMinutesFull())
	end
end

--[[Author: Pizzalol
	Date: 04.03.2015.
	Creates additional attack projectiles for units within the specified radius around the caster]]
function SplitShotLaunch( keys )
	local caster = keys.caster
	local caster_location = caster:GetAbsOrigin()
	local ability = keys.ability
	-- Targeting variables
	local attack_target = caster:GetAttackTarget()

	local projectile_speed = 750
	local split_shot_projectile
	if string.find(caster:GetModelName(), "tower_bad") then
		split_shot_projectile = "particles/base_attacks/ranged_tower_bad.vpcf"
	else 
		split_shot_projectile = "particles/base_attacks/ranged_tower_good.vpcf"
	end

	local split_shot_targets = FindUnitsInRadius(caster:GetTeam(), caster_location, nil, caster:GetAttackRange(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false)
	-- Create projectiles for units that are not the casters current attack target
	for _,v in ipairs(split_shot_targets) do
		if v ~= attack_target then
			local projectile_info = 
			{
				EffectName = split_shot_projectile,
				Ability = ability,
				vSpawnOrigin = caster_location,
				Target = v,
				Source = caster,
				bHasFrontalCone = false,
				iMoveSpeed = projectile_speed,
				bReplaceExisting = false,
				bProvidesVision = false
			}
			ProjectileManager:CreateTrackingProjectile(projectile_info)
		end
	end
end

-- Apply the auto attack damage to the hit unit
function SplitShotDamage( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	ApplyDamage({
		attacker = caster,
		victim = target,
		damage_type = DAMAGE_TYPE_PURE,
		damage = caster:GetAverageTrueAttackDamage(target),
		ability = ability
	})
end