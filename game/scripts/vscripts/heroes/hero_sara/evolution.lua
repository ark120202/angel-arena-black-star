sara_evolution = class({})
LinkLuaModifier("modifier_sara_evolution", "heroes/hero_sara/modifier_sara_evolution.lua", LUA_MODIFIER_MOTION_NONE)

function sara_evolution:GetIntrinsicModifierName()
	return "modifier_sara_evolution"
end