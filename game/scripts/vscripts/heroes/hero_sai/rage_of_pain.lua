sai_rage_of_pain = class({})
LinkLuaModifier("modifier_sai_rage_of_pain", "heroes/hero_sai/modifier_sai_rage_of_pain.lua", LUA_MODIFIER_MOTION_NONE)

function sai_rage_of_pain:GetIntrinsicModifierName()
	return "modifier_sai_rage_of_pain"
end

function sai_rage_of_pain:GetBehavior()
	return self:GetCaster():HasScepter() and DOTA_ABILITY_BEHAVIOR_NO_TARGET or DOTA_ABILITY_BEHAVIOR_PASSIVE
end
