item_wand_of_midas = class({})
LinkLuaModifier("modifier_item_wand_of_midas", "items/modifier_item_wand_of_midas.lua", LUA_MODIFIER_MOTION_NONE)

function item_wand_of_midas:GetIntrinsicModifierName()
	return "modifier_item_wand_of_midas"
end