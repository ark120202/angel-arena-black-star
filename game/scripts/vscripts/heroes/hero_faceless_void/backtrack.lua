function BacktrackHealth( keys )
	local caster = keys.caster
	local ability = keys.ability

	ability.caster_hp_old = ability.caster_hp_old or caster:GetMaxHealth()
	ability.caster_hp = ability.caster_hp or caster:GetMaxHealth()

	ability.caster_hp_old = ability.caster_hp
	ability.caster_hp = caster:GetHealth()
end

function BacktrackHeal( keys )
	local caster = keys.caster
	local ability = keys.ability
	local faceless_void_time_walk_arena = caster:FindAbilityByName("faceless_void_time_walk_arena")
	local chance = ability:GetLevelSpecialValueFor("dodge_chance_pct", ability:GetLevel() - 1)
	if (faceless_void_time_walk_arena and caster:HasModifier("modifier_faceless_void_time_walk_arena_backtrack")) then
		chance = chance + faceless_void_time_walk_arena:GetLevelSpecialValueFor("dodge_chance_time_walk_pct", faceless_void_time_walk_arena:GetLevel() - 1)
	end

	if RollPercentage(chance) and ability.caster_hp_old and (caster:IsAlive() or not caster:IsIllusion()) then
		caster:SetHealth(ability.caster_hp_old)
		ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_backtrack.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	end
end