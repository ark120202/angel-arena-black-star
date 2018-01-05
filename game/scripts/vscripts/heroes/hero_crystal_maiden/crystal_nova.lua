function crystal_nova( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]
	local duration = ability:GetLevelSpecialValueFor( "vision_duration", ability:GetLevel() - 1 )
	local radius = ability:GetLevelSpecialValueFor( "vision_radius", ability:GetLevel() - 1)
	local hullRadius = ability:GetLevelSpecialValueFor( "block_hull_radius", ability:GetLevel() - 1)
	AddFOWViewer(caster:GetTeamNumber(), point, radius, duration, false)
	ability:ApplyDataDrivenModifier(caster, dummy, "modifier_crystal_nova_arena_dummy", {})
	for i = 0, 20 do
		local normal = (RotatePosition(point, QAngle(0, 18*i, 0), point + Vector(1, 1, 0)*(radius/2)) - point):Normalized()
		local p = point + normal*(radius/2)
		local modelDummy = CreateUnitByName("npc_dummy_unit", p, false, nil, nil, caster:GetTeamNumber())
		modelDummy:SetAbsOrigin(GetGroundPosition(modelDummy:GetAbsOrigin(), modelDummy))
		modelDummy:SetModel("models/particle/tusk_igloo1.vmdl")
		modelDummy:SetHullRadius(hullRadius)
		modelDummy:SetAbsOrigin(GetGroundPosition(p, modelDummy))
		modelDummy:SetForwardVector(point - p)
		for _,v in ipairs(FindUnitsInRadius(caster:GetTeamNumber(), modelDummy:GetAbsOrigin(), nil, hullRadius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)) do
			FindClearSpaceForUnit(v, v:GetAbsOrigin(), true)
		end
		Timers:CreateTimer(ability:GetLevelSpecialValueFor( "block_duration", ability:GetLevel() - 1), function()
			UTIL_Remove(modelDummy)
		end)
	end
end
