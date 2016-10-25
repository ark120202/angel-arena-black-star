function OnModifierDestroy(keys)
	local ability = keys.ability
	if ability.modifier_zen_gehraz_divine_intervention_destroy then
		ability.modifier_zen_gehraz_divine_intervention_destroy(keys)
	end
end