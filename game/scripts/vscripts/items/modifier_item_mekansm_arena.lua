modifier_item_mekansm_arena = class({})
function modifier_item_mekansm_arena:IsHidden()
	return true
end
function modifier_item_mekansm_arena:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
function modifier_item_mekansm_arena:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
end
function modifier_item_mekansm_arena:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end
function modifier_item_mekansm_arena:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end
function modifier_item_mekansm_arena:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end
function modifier_item_mekansm_arena:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_armor")
end
function modifier_item_mekansm_arena:GetModifierAura()
	return "modifier_item_mekansm_arena_effect"
end
function modifier_item_mekansm_arena:IsAura()
	return true
end
function modifier_item_mekansm_arena:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor("radius")
end
function modifier_item_mekansm_arena:GetAuraSearchTeam()
	return self:GetAbility():GetAbilityTargetTeam()
end
function modifier_item_mekansm_arena:GetAuraSearchType()
	return self:GetAbility():GetAbilityTargetType()
end
function modifier_item_mekansm_arena:GetAuraSearchFlags()
	return self:GetAbility():GetAbilityTargetFlags()
end

modifier_item_mekansm_arena_effect = class({})
function modifier_item_mekansm_arena_effect:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
end
function modifier_item_mekansm_arena_effect:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("aura_health_regen")
end
function modifier_item_mekansm_arena_effect:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("aura_bonus_armor")
end