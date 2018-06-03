LinkLuaModifier("modifier_healer_taste_of_armor", "heroes/structures/healer_taste_of_armor.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_healer_taste_of_armor_effect", "heroes/structures/healer_taste_of_armor.lua", LUA_MODIFIER_MOTION_NONE)

healer_taste_of_armor = class({
	GetIntrinsicModifierName = function() return "modifier_healer_taste_of_armor" end,
})

modifier_healer_taste_of_armor = class({
	IsPurgable = function() return false end,
	IsHidden = function() return true end,
})

function modifier_healer_taste_of_armor:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor("aura_radius")
end
function modifier_healer_taste_of_armor:GetAuraSearchTeam()
	return self:GetAbility():GetAbilityTargetTeam()
end
function modifier_healer_taste_of_armor:GetAuraSearchType()
	return self:GetAbility():GetAbilityTargetType()
end
function modifier_healer_taste_of_armor:GetAuraSearchFlags()
	return self:GetAbility():GetAbilityTargetFlags()
end
function modifier_healer_taste_of_armor:IsAura()
	return true
end
function modifier_healer_taste_of_armor:GetModifierAura()
	return "modifier_healer_taste_of_armor_effect"
end


modifier_healer_taste_of_armor_effect = class({})
function modifier_healer_taste_of_armor_effect:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
end
function modifier_healer_taste_of_armor_effect:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("aura_bonus_armor")
end
