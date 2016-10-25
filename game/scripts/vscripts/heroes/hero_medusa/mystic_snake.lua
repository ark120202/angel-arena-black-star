--[[Author: Pizzalol
	Date: 07.03.2015.
	Handles all the targeting and other actions logic]]
function MysticSnake( keys )
	local caster = keys.caster
	local target = keys.target
	target:EmitSound("Hero_Medusa.MysticSnake.Target")
	local particle_enemy = ParticleManager:CreateParticle("particles/units/heroes/hero_medusa/medusa_mystic_snake_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(particle_enemy, 0, target:GetAbsOrigin()) 
	ParticleManager:SetParticleControl(particle_enemy, 1, target:GetAbsOrigin())
	if not caster:IsIllusion() then
		local ability = keys.ability
		local base_mana = ability:GetAbilitySpecial("snake_mana_steal")

		if target:GetMaxMana() > 0 then
			target:ReduceMana(base_mana)
			caster:GiveMana(base_mana)
		end
		ApplyDamage({
			attacker = caster,
			victim = target,
			ability = ability,
			damage = ability:GetAbilitySpecial("snake_damage"),
			damage_type = ability:GetAbilityDamageType(),
		})
	end
end

function CreateProjectiles(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	caster:EmitSound("Hero_Medusa.MysticSnake.Cast")
	ParticleManager:CreateParticle("particles/units/heroes/hero_medusa/medusa_mystic_snake_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ProjectileManager:CreateTrackingProjectile({
		EffectName = "particles/units/heroes/hero_medusa/medusa_mystic_snake_projectile.vpcf",
		Ability = ability,
		vSpawnOrigin = caster:GetAbsOrigin(),
		Target = target,
		Source = caster,
		bHasFrontalCone = false,
		iMoveSpeed = ability:GetAbilitySpecial("initial_speed"),
		bReplaceExisting = false,
		bProvidesVision = true,
		iVisionRadius = ability:GetAbilitySpecial("vision_radius"),
		iVisionTeamNumber = caster:GetTeam(),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
	})
end