function MaxHealth(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:SetHealth(caster:GetMaxHealth())
	caster:SetMana(caster:GetMaxMana())
	RefreshAbilities(caster, REFRESH_LIST_IGNORE_REFRESHER)
	RefreshItems(caster, REFRESH_LIST_IGNORE_REFRESHER)
end