function ShowLocation(keys)
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel()-1)
	local dummy = CreateUnitByName("npc_dummy_flying", keys.target_points[1], false, nil, nil, caster:GetTeamNumber())
	dummy:SetDayTimeVisionRange(radius)
	dummy:SetNightTimeVisionRange(radius)
	local pfx = ParticleManager:CreateParticleForTeam("particles/arena/items_fx/eye_of_the_prophet.vpcf", PATTACH_ABSORIGIN, dummy, caster:GetTeamNumber())
	ParticleManager:SetParticleControl(pfx, 1, Vector(radius, 0, 0))
	Timers:CreateTimer(ability:GetLevelSpecialValueFor("duration", ability:GetLevel()-1), function()
		UTIL_Remove(dummy)
	end)
end