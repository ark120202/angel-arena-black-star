function OnSpellStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]
	local level = ability:GetLevel() - 1
	local radius = math.min(ability:GetLevelSpecialValueFor("base_radius", level) + (caster:GetIntellect() * (ability:GetLevelSpecialValueFor("int_to_radius_pct", level) * 0.01)), ability:GetAbilitySpecial("max_radius"))
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, enemy in ipairs(enemies) do
		ApplyDamage({
			victim = enemy,
			attacker = caster,
			damage = math.min(ability:GetLevelSpecialValueFor("base_damage", level) + (caster:GetIntellect() * (ability:GetLevelSpecialValueFor("int_to_dmg_pct", level) * 0.01)), ability:GetAbilitySpecial("max_damage")),
			damage_type = ability:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
			ability = ability
		})
	end
	local dummy = CreateUnitByName("npc_dummy_unit", point, false, nil, nil, caster:GetTeamNumber())
	dummy:EmitSound("Arena.Hero_Stargazer.GammaRay.Cast")
	local particle = ParticleManager:CreateParticle("particles/arena/units/heroes/hero_stargazer/gamma_ray_immortal1.vpcf", PATTACH_ABSORIGIN_FOLLOW, dummy, caster)
	ParticleManager:SetParticleControl(particle, 1, Vector(radius, radius, radius))
	Timers:CreateTimer(0.5, function()
		dummy:RemoveSelf()
	end)
end
