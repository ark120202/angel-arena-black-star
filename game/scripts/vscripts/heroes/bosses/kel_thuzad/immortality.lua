boss_kel_thuzad_immortality = class({})
LinkLuaModifier("modifier_boss_kel_thuzad_immortality", "heroes/bosses/kel_thuzad/modifier_boss_kel_thuzad_immortality.lua", LUA_MODIFIER_MOTION_NONE)

function boss_kel_thuzad_immortality:GetIntrinsicModifierName()
	return "modifier_boss_kel_thuzad_immortality"
end