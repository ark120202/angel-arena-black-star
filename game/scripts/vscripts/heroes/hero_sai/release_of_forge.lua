sai_release_of_forge = class({})
LinkLuaModifier("modifier_sai_release_of_forge", "heroes/hero_sai/modifier_sai_release_of_forge.lua", LUA_MODIFIER_MOTION_NONE)

function sai_release_of_forge:GetIntrinsicModifierName()
	return "modifier_sai_release_of_forge"
end
