modifier_item_aether_lens_arena = class({})

function modifier_item_aether_lens_arena:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_aether_lens_arena:IsHidden()
	return true
end

function modifier_item_aether_lens_arena:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_CAST_RANGE_BONUS,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE
	}
end

function modifier_item_aether_lens_arena:GetModifierSpellAmplify_Percentage()
	return self:GetAbility():GetSpecialValueFor("spell_amp_pct")
end

function modifier_item_aether_lens_arena:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_health_regen")
end

function modifier_item_aether_lens_arena:GetModifierManaBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_mana")
end

function modifier_item_aether_lens_arena:GetModifierCastRangeBonus()
	return self:GetAbility():GetSpecialValueFor("cast_range_bonus")
end