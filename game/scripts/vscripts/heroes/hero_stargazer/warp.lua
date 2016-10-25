function OnSpellStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local level = ability:GetLevel() - 1
	local dummy = CreateUnitByName("npc_dummy_unit", caster:GetAbsOrigin(), false, nil, nil, caster:GetTeamNumber())
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_pugna/pugna_ward_attack.vpcf", PATTACH_ABSORIGIN_FOLLOW, dummy)
	Timers:CreateTimer(0.3, function()
		UTIL_Remove(dummy)
	end)

	local blink_range = math.min(ability:GetLevelSpecialValueFor("base_range", ability:GetLevel() - 1) + (caster:GetAgility() * (ability:GetLevelSpecialValueFor("agi_to_range_pct", ability:GetLevel() - 1) * 0.01)), ability:GetAbilitySpecial("max_range"))
	local point = keys.target_points[1]
	local origin_point = caster:GetAbsOrigin()
	local difference_vector = point - origin_point

	if difference_vector:Length2D() > blink_range then
		point = origin_point + (point - origin_point):Normalized() * blink_range
	end

	ParticleManager:SetParticleControl(particle, 1, point)

	FindClearSpaceForUnit(caster, point, true)
end