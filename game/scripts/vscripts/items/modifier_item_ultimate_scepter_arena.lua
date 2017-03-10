modifier_item_ultimate_scepter_arena = class({})

function modifier_item_ultimate_scepter_arena:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_ultimate_scepter_arena:RemoveOnDeath()
	return false
end

function modifier_item_ultimate_scepter_arena:IsHidden()
	return true
end

function modifier_item_ultimate_scepter_arena:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_IS_SCEPTER,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_CAST_RANGE_BONUS,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE
	}
end

function modifier_item_ultimate_scepter_arena:GetModifierScepter()
	return 1
end

function modifier_item_ultimate_scepter_arena:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_all")
end

function modifier_item_ultimate_scepter_arena:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_all")
end

function modifier_item_ultimate_scepter_arena:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_all")
end

function modifier_item_ultimate_scepter_arena:GetModifierSpellAmplify_Percentage()
	return self:GetAbility():GetSpecialValueFor("spell_amp_pct")
end

function modifier_item_ultimate_scepter_arena:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_health_regen")
end

function modifier_item_ultimate_scepter_arena:GetModifierManaBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_mana")
end

function modifier_item_ultimate_scepter_arena:GetModifierCastRangeBonus()
	return self:GetAbility():GetSpecialValueFor("cast_range_bonus")
end