function Initialize(keys)
	local caster = keys.caster
	caster:AddItem(CreateItem("item_greater_crit", caster, caster))
	caster:AddItem(CreateItem("item_greater_crit", caster, caster))
	caster:AddItem(CreateItem("item_satanic", caster, caster))
end

function RecalculateGrowBonus(keys)
	local caster = keys.caster
	local ability = keys.ability
	local damage = keys.damage
	if not ability.DamageCounter then ability.DamageCounter = 0 end
	if damage and damage > 0 then
		ability.DamageCounter = ability.DamageCounter + damage
		if ability.DamageCounter >= 100 then
			repeat
				ability.DamageCounter = ability.DamageCounter - 100
				ModifyStacks(ability, caster, caster, "modifier_earth_grow_bonus_stack", 1, false)
			until ability.DamageCounter < 100
		end
		caster:SetModelScale(caster:GetModelScale() + (damage / 60000))
	end
end