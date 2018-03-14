LinkLuaModifier("modifier_healer_armor_aura", "vscripts/heroes/structures/healer_armor_aura.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_healer_armor_aura_effect", "vscripts/heroes/structures/healer_armor_aura_effect.lua", LUA_MODIFIER_MOTION_NONE)
healer_armor_aura = class({
    GetIntrinsicModifierName = function() return "modifier_healer_armor_aura" end,
})

modifier_healer_armor_aura = class({
    IsPurgable = function() return false end,
    IsHidden = function() return true end,
    GetModifierPhysicalArmorBonus = function() return 4 end,
    IsAura = function() return true end,
    GetAuraRadius = function() return 600 end,
})


function modifier_healer_armor_aura:DeclareFunctions()
    return { 
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }
end

function modifier_healer_armor_aura:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_healer_armor_aura:GetAuraSearchTeam()
    return self:GetAbility():GetAbilityTargetTeam()
end

function modifier_healer_armor_aura:GetAuraSearchType()
    return self:GetAbility():GetAbilityTargetType()
end

function modifier_healer_armor_aura:GetAuraSearchFlags()
    return self:GetAbility():GetAbilityTargetFlags()
end

healer_armor_aura_effect = class({})

function modifier_healer_armor_aura_effect:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("armor_bonus_aura")
end