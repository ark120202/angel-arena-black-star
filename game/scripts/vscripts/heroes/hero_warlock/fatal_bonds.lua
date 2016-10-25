LinkLuaModifier("modifier_fatal_bonds_lua", "heroes/hero_warlock/modifier_fatal_bonds_lua.lua", LUA_MODIFIER_MOTION_NONE)

function OnSpellStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local level = ability:GetLevel() - 1
	local search_aoe = ability:GetLevelSpecialValueFor("search_aoe", level)
	ability.hit_pfx = keys.hit_pfx
	local targets = {target}
	local counter = ability:GetLevelSpecialValueFor("count", level) - 1
	--основная цель сразу в таблице, чтобы она 100% попала
	for _,v in ipairs(FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, search_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false)) do
		if counter >= 1 and not table.contains(targets, v) then
			counter = counter - 1
			table.insert(targets, v)
		end
	end

	for _,v in ipairs(targets) do
		v.FatalBondsBoundUnits = targets
		v:AddNewModifier(caster, ability, "modifier_fatal_bonds_lua", {duration = ability:GetLevelSpecialValueFor("duration", level)})
		for _,subv in ipairs(targets) do
			local p = ParticleManager:CreateParticle(keys.pulse_pfx, PATTACH_ABSORIGIN_FOLLOW, v)
			ParticleManager:SetParticleControl(p, 01, subv:GetAbsOrigin() + Vector(0,0,64))
		end
	end
end