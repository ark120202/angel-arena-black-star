LinkLuaModifier("modifier_saber_instinct", "heroes/hero_saber/instinct.lua", LUA_MODIFIER_MOTION_NONE)

saber_instinct = class({
	GetIntrinsicModifierName = function() return "modifier_saber_instinct" end,
})


modifier_saber_instinct = class({
	IsHidden   = function() return true end,
	IsPurgable = function() return false end,
})
