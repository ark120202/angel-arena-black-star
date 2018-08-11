function IncreaseAbilityStacks(unit, ability)
	ModifyStacks(ability, unit, unit, "modifier_pudge_flesh_heap_arena_stack", 1, false)
	unit:CalculateStatBonus()
	local oldAbilityModelScale = ability.AdditionalModelScale or 0
	ability.AdditionalModelScale = math.min(ability:GetAbilitySpecial("model_scale_per_stack") * unit:GetModifierStackCount("modifier_pudge_flesh_heap_arena_stack", unit), ability:GetAbilitySpecial("model_scale_max"))
	unit:SetModelScale(unit:GetModelScale() + ability.AdditionalModelScale - oldAbilityModelScale)
	ParticleManager:SetParticleControl( ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_fleshheap_count.vpcf", PATTACH_OVERHEAD_FOLLOW, unit ), 1, Vector( 1, 0, 0 ) )
end

function OnKill(keys)
	local caster = keys.caster
	local unit = keys.unit
	local ability = keys.ability
	if unit:IsRealCreep() then

		ability.KilledCreeps = (ability.KilledCreeps or 0) + 1
		local creeps_killed_to_stack = ability:GetAbilitySpecial("creeps_killed_to_stack")
		if ability.KilledCreeps >= creeps_killed_to_stack then
			IncreaseAbilityStacks(caster, ability)
			ability.KilledCreeps = ability.KilledCreeps - creeps_killed_to_stack
		end
	end
end

function OnHeroDeath(keys)
	local caster = keys.caster
	local unit = keys.unit
	local ability = keys.ability
	if unit:IsRealHero() then
		IncreaseAbilityStacks(caster, ability)
	end
end

function OnUpgrade(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:RemoveModifierByNameAndCaster("modifier_pudge_flesh_heap_arena", caster)
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_pudge_flesh_heap_arena", {})
	local stacks = caster:GetModifierStackCount("modifier_pudge_flesh_heap_arena_stack", caster)
	caster:RemoveModifierByNameAndCaster("modifier_pudge_flesh_heap_arena_stack", caster)
	ModifyStacks(ability, caster, caster, "modifier_pudge_flesh_heap_arena_stack", stacks, false)
end
