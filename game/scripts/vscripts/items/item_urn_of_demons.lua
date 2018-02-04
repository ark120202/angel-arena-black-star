function modifier_item_urn_of_demons_aura_on_death(keys)
	local urn_with_least_charges
	for i = 0, 5 do
		local current_item = keys.caster:GetItemInSlot(i)
		if current_item then
			local item_name = current_item:GetName()
			if item_name == keys.ability:GetName() then
				if not urn_with_least_charges then
					urn_with_least_charges = current_item
				elseif current_item:GetCurrentCharges() < urn_with_least_charges:GetCurrentCharges() then
					urn_with_least_charges = current_item
				end
			end
		end
	end

	if urn_with_least_charges then
		if urn_with_least_charges:GetCurrentCharges() == 0 then
			urn_with_least_charges:SetCurrentCharges(2)
		else
			urn_with_least_charges:SetCurrentCharges(urn_with_least_charges:GetCurrentCharges() + 1)
		end
	end
end

function modifier_item_urn_of_demons_damage_on_interval_think(keys)
	local ability = keys.ability
	local target = keys.target
	local damage_to_deal = keys.TotalHealthPct * 0.01 * target:GetMaxHealth() / keys.TotalDuration * keys.Interval
	local mana_to_burn = keys.TotalManaPct * 0.01 * target:GetMaxMana() / keys.TotalDuration * keys.Interval
	ApplyDamage({
		victim = target,
		attacker = keys.caster,
		damage = damage_to_deal,
		damage_type = ability:GetAbilityDamageType(),
		damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
		ability = ability
	})
	target:SetMana(target:GetMana() - mana_to_burn)
end

function modifier_item_urn_of_demons_heal_on_interval_think(keys)
	local target = keys.target
	local amount_to_heal = keys.TotalHealthPct * 0.01 * target:GetMaxHealth() / keys.TotalDuration * keys.Interval
	local mana_to_heal = keys.TotalManaPct * 0.01 * target:GetMaxMana() / keys.TotalDuration * keys.Interval
	SafeHeal(target, mana_to_heal)
	target:GiveMana(mana_to_heal)
end

function item_urn_of_demons_on_spell_start(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	target:EmitSound("DOTA_Item.UrnOfShadows.Activate")

	if caster:GetTeam() == target:GetTeam() then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_item_urn_of_demons_ally", nil)
	else
		ability:ApplyDataDrivenModifier(caster, target, "modifier_item_urn_of_demons_enemy", nil)
	end

	ability:SetCurrentCharges(ability:GetCurrentCharges() - 1)
end
