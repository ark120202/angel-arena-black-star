LinkLuaModifier("modifier_destroyer_frenzy", "heroes/hero_destroyer/modifier_destroyer_frenzy.lua", LUA_MODIFIER_MOTION_NONE)
destroyer_frenzy = class({})

function destroyer_frenzy:GetIntrinsicModifierName()
	return "modifier_destroyer_frenzy"
end