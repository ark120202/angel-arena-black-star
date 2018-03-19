LinkLuaModifier("modifier_healer_bonus_armor", "heroes/structures/healer_bonus_armor.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_healer_bonus_armor_effect", "heroes/structures/healer_bonus_armor",LUA_MODIFIER_MOTION_NONE)

healer_bonus_armor = class({
    GetIntrinsicModifierName = function() return "modifier_healer_bonus_armor" end,
})

modifier_healer_bonus_armor = class({
    IsPurgable = function() return false end,
    IsHidden = function() return false end,
})

function modifier_healer_bonus_armor:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_armor_aura")
end
function modifier_healer_bonus_armor:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("aura_radius")
end
function modifier_healer_bonus_armor:GetAuraSearchTeam()
    return self:GetAbility():GetAbilityTargetTeam()
end
function modifier_healer_bonus_armor:GetAuraSearchType()
    return self:GetAbility():GetAbilityTargetType()
end
function modifier_healer_bonus_armor:GetAuraSearchFlags()
    return self:GetAbility():GetAbilityTargetFlags()
end
function modifier_healer_bonus_armor:IsAura()
	return true
end
function modifier_healer_bonus_armor:GetModifierAura()
    return "modifier_healer_bonus_armor_effect"
end


modifier_healer_bonus_armor_effect = class({})
function modifier_healer_bonus_armor_effect:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }
end
function modifier_healer_bonus_armor_effect:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_armor_aura")
end