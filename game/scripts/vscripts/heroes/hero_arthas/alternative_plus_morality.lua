function OnHeroKill(keys)
	local caster = keys.caster
	ModifyStacks(keys.ability, caster, caster, keys.modifier, 1, false)
end