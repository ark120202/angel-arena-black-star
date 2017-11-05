function Cast(keys)
	local caster = keys.caster
	local point	= keys.target_points[1]
	local ability = keys.ability
	local dummy = CreateUnitByName("npc_dummy_unit", point, false, nil, nil, caster:GetTeamNumber())
	ability:ApplyDataDrivenModifier(caster, dummy, keys.modifier, {})
	dummy.pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_warlock/warlock_upheaval.vpcf", PATTACH_ABSORIGIN, dummy)
	ParticleManager:SetParticleControl(dummy.pfx, 1, Vector(ability:GetLevelSpecialValueFor("aoe", ability:GetLevel() - 1), 0, 0))
	dummy.elapsed_cast_time = 0
	Timers:CreateTimer(0.03, function()
		dummy:EmitSound("Arena.Hero_Warlock.Upheaval")
	end)
	Timers:CreateTimer(0.1, function()
		if dummy:IsAlive() then
			dummy.elapsed_cast_time = dummy.elapsed_cast_time + 0.1
			return 0.1
		end
	end)
end

function ApplyStacks(keys)
	local caster = keys.caster
	local dummy = keys.target
	local ability = keys.ability
	local slow_rate = ability:GetLevelSpecialValueFor("slow_rate", ability:GetLevel() - 1)
	local units = FindUnitsInRadius(dummy:GetTeamNumber(), dummy:GetAbsOrigin(), nil, ability:GetLevelSpecialValueFor("aoe", ability:GetLevel() - 1), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
	for _,v in ipairs(units) do
		ability:ApplyDataDrivenModifier(caster, v, keys.modifier, {})
		local stacks = math.floor(dummy.elapsed_cast_time) * slow_rate
		v:SetModifierStackCount(keys.modifier, ability, stacks)
	end
end

function DestroyParticle(keys)
	local dummy = keys.target
	dummy:StopSound("Arena.Hero_Warlock.Upheaval")
	ParticleManager:DestroyParticle(keys.target.pfx, false)
end

