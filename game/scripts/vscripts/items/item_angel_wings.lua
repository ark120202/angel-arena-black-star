function ChackAndSpendMana(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local mana = keys.mana_per_second_pct*keys.mana_per_second_think*caster:GetMaxMana()*0.01
	if caster:GetMana() >= mana then
		caster:SpendMana(mana, ability)
	else
		local newItem = CreateItem("item_angel_wings", caster, caster)
		newItem:SetPurchaseTime(ability:GetPurchaseTime())
		newItem:SetPurchaser(ability:GetPurchaser())
		newItem:SetOwner(ability:GetOwner())
		swap_to_item(caster, ability, newItem)
	end
end