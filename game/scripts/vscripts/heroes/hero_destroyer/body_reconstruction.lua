local refreshIgnoreList = {
	item_refresher_arena = true,
	item_refresher_core = true,
	item_black_king_bar = true,
	item_titanium_bar = true,
	item_coffee_bean = true,

	destroyer_body_reconstruction = true,
}

function MaxHealth(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:SetHealth(caster:GetMaxHealth())
	caster:SetMana(caster:GetMaxMana())
	RefreshAbilities(caster, refreshIgnoreList)
	RefreshItems(caster, refreshIgnoreList)
end
