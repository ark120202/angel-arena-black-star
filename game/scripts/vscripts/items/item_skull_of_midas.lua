LinkLuaModifier("modifier_item_skull_of_midas", "items/item_skull_of_midas.lua", LUA_MODIFIER_MOTION_NONE)

item_skull_of_midas = class({
	GetIntrinsicModifierName = function() return "modifier_item_skull_of_midas" end,
})

modifier_item_skull_of_midas = class({
	IsHidden      = function() return true end,
	GetAttributes = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,
	IsPurgable    = function() return false end,
})

function modifier_item_skull_of_midas:DeclareFunctions()
	return { MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE }
end

function modifier_item_skull_of_midas:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end
