modifier_item_guardian_greaves_arena = class({})
function modifier_item_guardian_greaves_arena:IsHidden()
	return true
end
function modifier_item_guardian_greaves_arena:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
function modifier_item_guardian_greaves_arena:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE
	}
end
function modifier_item_guardian_greaves_arena:GetModifierManaBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_mana")
end
function modifier_item_guardian_greaves_arena:GetModifierMoveSpeedBonus_Special_Boots()
	return self:GetAbility():GetSpecialValueFor("bonus_movement")
end
function modifier_item_guardian_greaves_arena:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end
function modifier_item_guardian_greaves_arena:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end
function modifier_item_guardian_greaves_arena:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end
function modifier_item_guardian_greaves_arena:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_armor")
end
function modifier_item_guardian_greaves_arena:GetModifierAura()
	return "modifier_item_guardian_greaves_arena_effect"
end
function modifier_item_guardian_greaves_arena:IsAura()
	return true
end
function modifier_item_guardian_greaves_arena:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor("radius")
end
function modifier_item_guardian_greaves_arena:GetAuraSearchTeam()
	return self:GetAbility():GetAbilityTargetTeam()
end
function modifier_item_guardian_greaves_arena:GetAuraSearchType()
	return self:GetAbility():GetAbilityTargetType()
end
function modifier_item_guardian_greaves_arena:GetAuraSearchFlags()
	return self:GetAbility():GetAbilityTargetFlags()
end

modifier_item_guardian_greaves_arena_effect = class({})
function modifier_item_guardian_greaves_arena_effect:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
end
function modifier_item_guardian_greaves_arena_effect:GetModifierConstantHealthRegen()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	if ability then
		return ability:GetSpecialValueFor(parent:GetHealth() / parent:GetMaxHealth() > ability:GetSpecialValueFor("aura_bonus_threshold_pct") * 0.01 and "aura_health_regen" or "aura_health_regen_bonus")
	end
end
function modifier_item_guardian_greaves_arena_effect:GetModifierPhysicalArmorBonus()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	if ability then
		local s = parent:GetHealthPercent() >= ability:GetSpecialValueFor("aura_bonus_threshold_pct") and "aura_armor" or "aura_armor_bonus"
		return ability:GetSpecialValueFor(s)
	end
end
