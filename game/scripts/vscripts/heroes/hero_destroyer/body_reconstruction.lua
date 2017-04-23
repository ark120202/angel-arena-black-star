function MaxHealth(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:SetHealth(caster:GetMaxHealth())
	caster:SetMana(caster:GetMaxMana())
	RefreshAbilities(caster, REFRESH_LIST_IGNORE_BODY_RECONSTRUCTION)
	RefreshItems(caster, REFRESH_LIST_IGNORE_BODY_RECONSTRUCTION)
end