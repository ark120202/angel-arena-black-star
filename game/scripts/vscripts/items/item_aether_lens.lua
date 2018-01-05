LinkLuaModifier("modifier_item_aether_lens_arena", "items/item_aether_lens.lua", LUA_MODIFIER_MOTION_NONE)

item_aether_lens_arena = class({
	GetIntrinsicModifierName = function() return "modifier_item_aether_lens_arena" end
})


modifier_item_aether_lens_arena = class({
	GetAttributes = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,
	IsHidden      = function() return true end,
	IsPurgable    = function() return false end,
})

function modifier_item_aether_lens_arena:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_CAST_RANGE_BONUS,
	}
end

function modifier_item_aether_lens_arena:GetModifierManaBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_mana")
end

function modifier_item_aether_lens_arena:GetModifierConstantManaRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end

function modifier_item_aether_lens_arena:GetModifierCastRangeBonus()
	return self:GetAbility():GetSpecialValueFor("cast_range_bonus")
end
