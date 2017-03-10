function StartAbility(keys)
	local caster = keys.caster
	local point = keys.target_points[1]
	local ability = keys.ability
	ability.thinker_dummy = CreateUnitByName("npc_dummy_unit", point, true, caster, nil, caster:GetTeam())
	ability:ApplyDataDrivenModifier(caster, ability.thinker_dummy, "modifier_zen_gehraz_mystic_twister_thinker", nil)
	ability.thinker_dummy.particle = ParticleManager:CreateParticle("particles/arena/units/heroes/hero_zen_gehraz/mystic_twister.vpcf", PATTACH_ABSORIGIN, ability.thinker_dummy)
	ParticleManager:SetParticleControl(ability.thinker_dummy.particle, 1, Vector(ability:GetAbilitySpecial("radius")))
	ability.thinker_dummy:EmitSound("Arena.Hero_ZenGehraz.MysticTwister")
end

function StopAbility(keys)
	local caster = keys.caster
	local ability = keys.ability
	ParticleManager:DestroyParticle(ability.thinker_dummy.particle, false)
	ability.thinker_dummy:StopSound("Arena.Hero_ZenGehraz.MysticTwister")
	ability.thinker_dummy:ForceKill(false)
	UTIL_Remove(ability.thinker_dummy)
	ability.thinker_dummy = nil
end