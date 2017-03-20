function CheckAbility(keys)
	local caster = keys.caster
	local ability = keys.ability
	if ability:IsCooldownReady() then
		local stats_per_cycle = ability:GetLevelSpecialValueFor("stats_per_cycle", ability:GetLevel() - 1)
		caster:ModifyStrength(stats_per_cycle)
		caster:ModifyAgility(stats_per_cycle)
		caster:ModifyIntellect(stats_per_cycle)
		ability:AutoStartCooldown()
		caster:EmitSound("Arena.Hero_Stargazer.CosmicCountdown.Cast")
		ParticleManager:CreateParticle("particles/arena/units/heroes/hero_stargazer/cosmic_countdown.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	end
end