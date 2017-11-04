function RocketBarrage(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:SpendMana(keys.mana * keys.interval, ability)
	if caster:GetMana() < keys.mana * keys.interval then
		ability:ToggleAbility()
		caster:RemoveModifierByName("modifier_gyrocopter_rocket_barrage_arena")
	end
	local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, ability:GetLevelSpecialValueFor("radius", ability:GetLevel() - 1), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)
	if #units > 0 then
		if not caster:HasModifier("modifier_gyrocopter_flak_cannon_arena") or not caster:HasScepter() then
			units = {units[RandomInt(1, #units)]}
		end
		for _,v in ipairs(units) do
			caster:EmitSound("Hero_Gyrocopter.Rocket_Barrage.Launch")
			ProjectileManager:CreateTrackingProjectile({
				Target = v,
				EffectName = "particles/units/heroes/hero_gyrocopter/gyro_rocket_barrage.vpcf",
				Ability = ability,
				vSpawnOrigin = caster:GetAbsOrigin(),
				Source = caster,
				bHasFrontalCone = false,
				iMoveSpeed = 1000,
				bReplaceExisting = false,
				bProvidesVision = false,
				bDodgeable = false,
				bProvidesVision = false,
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
			})
		end
	end
end
