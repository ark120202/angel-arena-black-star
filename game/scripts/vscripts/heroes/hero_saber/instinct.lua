saber_instinct = class({})
LinkLuaModifier("modifier_saber_instinct", "heroes/hero_saber/modifier_saber_instinct.lua", LUA_MODIFIER_MOTION_NONE)
function saber_instinct:GetIntrinsicModifierName()
	return "modifier_saber_instinct"
end