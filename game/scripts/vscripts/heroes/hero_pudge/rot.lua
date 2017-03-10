function Rot(keys)
	local caster = keys.caster
	local ability = keys.ability
	local damage = ability:GetLevelSpecialValueFor("rot_damage", ability:GetLevel() - 1) * ability:GetLevelSpecialValueFor("rot_tick", ability:GetLevel() - 1)
	local radius = ability:GetAbilitySpecial("rot_radius")
	local passive_stacks = caster:GetModifierStackCount("modifier_pudge_flesh_heap_arena_stack", caster)
	if passive_stacks and passive_stacks > 0 then
		local flesh_heap = caster:FindAbilityByName("pudge_flesh_heap_arena")
		if flesh_heap and flesh_heap:GetLevel() > 0 then
			radius = math.min(ability:GetAbilitySpecial("rot_radius_limit"), radius + (ability:GetAbilitySpecial("rot_radius_per_stack") * passive_stacks))
		end
	end
	ApplyDamage({attacker = caster, victim = caster, damage = damage, damage_type = ability:GetAbilityDamageType(), ability = ability})
	for _,v in ipairs(FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)) do
		ApplyDamage({attacker = caster, victim = v, damage = damage, damage_type = ability:GetAbilityDamageType(), ability = ability})
		ability:ApplyDataDrivenModifier(caster, v, "modifier_pudge_rot_arena_slow", {})
	end
end

function CreateParticles(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local radius = ability:GetAbilitySpecial("rot_radius")
	local passive_stacks = caster:GetModifierStackCount("modifier_pudge_flesh_heap_arena_stack", caster)
	if passive_stacks and passive_stacks > 0 then
		local flesh_heap = caster:FindAbilityByName("pudge_flesh_heap_arena")
		if flesh_heap and flesh_heap:GetLevel() > 0 then
			radius = math.min(ability:GetAbilitySpecial("rot_radius_limit"), radius + (ability:GetAbilitySpecial("rot_radius_per_stack") * passive_stacks))
		end
	end
	ability.rotPfx = ParticleManager:CreateParticle(keys.particle, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(ability.rotPfx, 1, Vector(radius,0,0) )
end

function StopRot(keys)
	local caster = keys.caster
	local ability = keys.ability
	if ability.rotPfx then
		ParticleManager:DestroyParticle(ability.rotPfx, false)
		ability.rotPfx = nil
	end
	caster:StopSound("Hero_Pudge.Rot")
end