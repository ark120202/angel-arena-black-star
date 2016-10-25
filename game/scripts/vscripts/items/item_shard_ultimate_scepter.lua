function ApplyScepter(keys)
	local caster = keys.caster
	local ability = keys.ability
	if not caster:HasModifier("modifier_item_ultimate_scepter") then
		caster:AddNewModifier(caster, ability, "modifier_item_ultimate_scepter", {duration = -1})
	end
end