function AddTruesight(keys)
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel()-1)
	local duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel()-1)
	local dummy = CreateUnitByName("npc_dummy_flying", keys.target_points[1], false, nil, nil, caster:GetTeamNumber())
	dummy:SetDayTimeVisionRange(0)
	dummy:SetNightTimeVisionRange(0)
	dummy:AddNewModifier(caster, ability, "modifier_item_ward_true_sight", {true_sight_range=radius, duration = duration})
	local pfx = ParticleManager:CreateParticleForTeam("particles/arena/items_fx/ray_of_fate.vpcf", PATTACH_ABSORIGIN, dummy, caster:GetTeamNumber())
	ParticleManager:SetParticleControl(pfx, 1, Vector(radius, 0, 0))
	Timers:CreateTimer(duration, function()
		UTIL_Remove(dummy)
	end)
end