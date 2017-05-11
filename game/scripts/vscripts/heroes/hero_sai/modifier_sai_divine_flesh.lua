modifier_sai_divine_flesh_on = class({})
function modifier_sai_divine_flesh_on:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
	}
end
function modifier_sai_divine_flesh_on:GetModifierPhysicalArmorBonus()
	local ability = self:GetAbility()
	return ability:GetSpecialValueFor("armor")
end
function modifier_sai_divine_flesh_on:GetModifierMagicalResistanceBonus()
	local ability = self:GetAbility()
	return ability:GetSpecialValueFor("resistange")
end

modifier_sai_divine_flesh_off = class({})
function modifier_sai_divine_flesh_off:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE
	}
end
function modifier_sai_divine_flesh_off:GetModifierHealthRegenPercentage()
	local ability = self:GetAbility()
	return ability:GetSpecialValueFor("heal_pct")
end

function modifier_sai_divine_flesh_on:IsHidden()
	return false
end
function modifier_sai_divine_flesh_off:IsHidden()
	return false
end

function DealDamage(keys)
	caster:ModifyHealth(keys.caster:GetHealthPercent() - keys.damage, keys.ability, false, 0)
end