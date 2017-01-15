function DarkWhale(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]
	local level = ability:GetLevel() - 1
	
	local damage_min = ability:GetLevelSpecialValueFor("damage_min", level)
	local damage_max = ability:GetLevelSpecialValueFor("damage_max", level)
	local stun_min = ability:GetLevelSpecialValueFor("stun_min", level)
	local stun_max = ability:GetLevelSpecialValueFor("stun_max", level)
	local radius = ability:GetLevelSpecialValueFor("aoe_radius", level)
	local pfx = ParticleManager:CreateParticle("particles/arena/units/heroes/hero_poseidon/dark_whale.vpcf", PATTACH_ABSORIGIN, caster)

	ParticleManager:SetParticleControl(pfx, 0, point)
	ParticleManager:SetParticleControl(pfx, 5, Vector(radius))
	EmitSoundOnLocationWithCaster(point, "Arena.Hero_Poseidon.DarkWhale", caster)
	
	for _,v in ipairs(FindUnitsInRadius(caster:GetTeam(), point, nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)) do
		local targetPosition = v:GetAbsOrigin()
		local lenToBorder = radius - (point - targetPosition):Length2D()
		local damage = damage_min + (damage_max - damage_min) / radius * lenToBorder
		local stun = stun_min + (stun_max - stun_min) / radius * lenToBorder
		ApplyDamage({
			victim = v,
			attacker = caster,
			damage = damage,
			damage_type = ability:GetAbilityDamageType(),
			ability = ability
		})
		if not v:IsMagicImmune() then
			v:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun})
		end
	end
end