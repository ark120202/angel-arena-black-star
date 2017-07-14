--[[Author: YOLOSPAGHETTI
	Date: March 28, 2016
	Applies the flak cannon modifier to the caster, and adds stacks based on the ability level]]
function ApplyModifier(keys)
	local caster = keys.caster
	local ability = keys.ability
	local stacks = ability:GetLevelSpecialValueFor( "max_attacks", ability:GetLevel() - 1 )

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_gyrocopter_flak_cannon_arena", {})
	caster:SetModifierStackCount("modifier_gyrocopter_flak_cannon_arena", ability, stacks)
end

--[[Author: YOLOSPAGHETTI
	Date: March 28, 2016
	Deals damage to every unit in range (except the main target)]]
function DealDamage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = caster:GetAverageTrueAttackDamage(target)
	ApplyDamage({
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = ability:GetAbilityDamageType(),
		damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
		ability = ability
	})
end

--[[Author: YOLOSPAGHETTI
	Date: March 28, 2016
	Gets the main target (the right-clicked target) of the attack]]
function CreateProjectiles(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local stacks = caster:GetModifierStackCount("modifier_gyrocopter_flak_cannon_arena", ability)

	ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_suicide_base.vpcf", PATTACH_ABSORIGIN, target)
	ApplyDamage({victim = target, attacker = caster, damage = ability:GetLevelSpecialValueFor("postattack_magic_damage", ability:GetLevel() - 1), damage_type = DAMAGE_TYPE_MAGICAL, ability = ability})
	if stacks == 1 then
		caster:RemoveModifierByName("modifier_gyrocopter_flak_cannon_arena")
	else
		caster:SetModifierStackCount("modifier_gyrocopter_flak_cannon_arena", ability, stacks - 1)
	end
	local split_shot_targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, ability:GetLevelSpecialValueFor("radius", ability:GetLevel() - 1), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false)
	for _,v in ipairs(split_shot_targets) do
		if v ~= target and not v:IsAttackImmune() then
			local projectile_info = GenerateAttackProjectile(caster, ability)
			projectile_info["Target"] = v
			projectile_info["iMoveSpeed"] = ability:GetLevelSpecialValueFor("projectile_speed", ability:GetLevel() - 1)
			ProjectileManager:CreateTrackingProjectile(projectile_info)
		end
	end
end

function ThinkScepter(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster:HasScepter() then
		local target = keys.target
		local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, ability:GetLevelSpecialValueFor("scepter_radius_scepter", ability:GetLevel() - 1), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false)
		if #units > 0 then
			PerformGlobalAttack(caster, units[RandomInt(1, #units)], true, true, true, false, true, false, false)
		end
	end
end
