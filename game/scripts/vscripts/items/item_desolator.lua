function ApplyArmorReduction(keys)
	local caster = keys.caster
	local target = keys.target
	local modifier = keys.modifier
	if IsModifierStrongest(caster, string.gsub(modifier, "_corruption", ""), MODIFIER_PROC_PRIORITY.desolator) then
		target:EmitSound("Item_Desolator.Target")
		keys.ability:ApplyDataDrivenModifier(caster, target, modifier, nil)
	end
end
