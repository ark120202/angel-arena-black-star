function SplitShotLaunch( keys )
	local caster = keys.caster
	local ability = keys.ability

	local arrow_count = ability:GetLevelSpecialValueFor("arrow_count", ability:GetLevel() - 1)
	local attack_target = caster:GetAttackTarget()
	local split_shot_targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, caster:GetAttackRange(), ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_CLOSEST, false)
	for _,v in ipairs(split_shot_targets) do
		if v ~= attack_target and not v:IsAttackImmune() then
			local projectile_info = GenerateAttackProjectile(caster, ability)
			projectile_info["Target"] = v
			if keys.force_attack_projectile then
				projectile_info["EffectName"] = keys.force_attack_projectile
			end
			ProjectileManager:CreateTrackingProjectile(projectile_info)
			arrow_count = arrow_count - 1

			--Mystic Snake code part
			local medusa_mystic_snake_arena = caster:FindAbilityByName("medusa_mystic_snake_arena")
			if medusa_mystic_snake_arena and medusa_mystic_snake_arena:GetLevel() > 0 and medusa_mystic_snake_arena:IsCooldownReady() and not caster:PassivesDisabled() then
				caster:EmitSound("Hero_Medusa.MysticSnake.Cast")
				ParticleManager:CreateParticle("particles/units/heroes/hero_medusa/medusa_mystic_snake_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
				ProjectileManager:CreateTrackingProjectile({
					EffectName = "particles/units/heroes/hero_medusa/medusa_mystic_snake_projectile.vpcf",
					Ability = medusa_mystic_snake_arena,
					vSpawnOrigin = caster:GetAbsOrigin(),
					Target = v,
					Source = caster,
					bHasFrontalCone = false,
					iMoveSpeed = medusa_mystic_snake_arena:GetAbilitySpecial("initial_speed"),
					bReplaceExisting = false,
					bProvidesVision = true,
					iVisionRadius = medusa_mystic_snake_arena:GetAbilitySpecial("vision_radius"),
					iVisionTeamNumber = caster:GetTeam(),
					iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
				})
			end

			local medusa_stone_gaze_arena = caster:FindAbilityByName("medusa_stone_gaze_arena")
			if medusa_stone_gaze_arena and medusa_stone_gaze_arena:GetLevel() > 0 then
				if RollPercentage(medusa_stone_gaze_arena:GetAbilitySpecial("stone_chance_pct")) then
					local stone_duration = medusa_stone_gaze_arena:GetAbilitySpecial("stone_duration")
					if caster:IsIllusion() then
						stone_duration = medusa_stone_gaze_arena:GetAbilitySpecial("stone_duration_illusion")
					elseif v:IsIllusion() then
						v:ForceKill(false)
					end
					v:EmitSound("Hero_Medusa.StoneGaze.Cast")
					medusa_stone_gaze_arena:ApplyDataDrivenModifier(caster, v, "modifier_stone_gaze_stone_arena", {duration = stone_duration})
				end
			end
		end
		if arrow_count <= 0 then
			break
		end
	end
end

function SplitShotDamage( keys )
	local caster = keys.caster
	local target = keys.target

	if not caster:IsIllusion() then
		ApplyDamage({
			attacker = caster,
			victim = target,
			damage_type = keys.ability:GetAbilityDamageType(),
			damage = caster:GetAverageTrueAttackDamage(target),
			ability = keys.ability
		})
	end
end