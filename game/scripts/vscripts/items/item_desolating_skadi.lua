function ApplyDesolatingSkadiModifier(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if not caster:IsIllusion() then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_item_desolating_skadi_debuff", {})
	end
end