LinkLuaModifier("modifier_chronosphere_speed_lua", "heroes/hero_faceless_void/modifiers/modifier_chronosphere_speed_lua.lua", LUA_MODIFIER_MOTION_NONE)

function Chronosphere( keys )
	local caster = keys.caster
	local ability = keys.ability

	local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() - 1))

	caster:AddNewModifier(caster, ability, "modifier_chronosphere_speed_lua", {duration = duration})
	for _,v in ipairs(HeroList:GetAllHeroes()) do
		if v:IsAlive() and not (caster:HasScepter() and v:GetTeamNumber() == caster:GetTeamNumber()) then
			local dummy = CreateUnitByName("npc_dummy_blank", v:GetAbsOrigin(), false, nil, nil, caster:GetTeamNumber())
			ability:ApplyDataDrivenModifier(caster, dummy, "modifier_faceless_void_time_freeze_aura", {duration = duration})
			local radius_pfx = ability:GetLevelSpecialValueFor("radius_pfx", ability:GetLevel() - 1)
			CreateGlobalParticle("particles/units/heroes/hero_faceless_void/faceless_void_chronosphere.vpcf", function(particle)
				ParticleManager:SetParticleControl(particle, 0, v:GetAbsOrigin())
				ParticleManager:SetParticleControl(particle, 1, Vector(radius_pfx, radius_pfx, 0))
				Timers:CreateTimer(duration, function()
					ParticleManager:DestroyParticle(particle, false)
				end)
			end)
			AddFOWViewer(caster:GetTeamNumber(), v:GetAbsOrigin(), radius_pfx, duration, false)
			Timers:CreateTimer(duration, function()
				UTIL_Remove(dummy)
			end)
		end
	end
end

function ChronosphereAura( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local duration = ability:GetLevelSpecialValueFor("aura_interval", ability:GetLevel() - 1) + 0.03
	
	if caster:GetPlayerOwner() ~= target:GetPlayerOwner() then
		target:InterruptMotionControllers(false)
		ability:ApplyDataDrivenModifier(caster, target, "modifier_faceless_void_time_freeze", {duration = duration}) 
	end
end