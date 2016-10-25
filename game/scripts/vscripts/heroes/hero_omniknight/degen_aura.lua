function IncreaseStacks(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	ModifyStacks(ability, caster, target, "modifier_omniknight_degen_aura_arena_stack", keys.amount or 1, true)
end