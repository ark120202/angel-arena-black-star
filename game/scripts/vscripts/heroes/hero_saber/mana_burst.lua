saber_mana_burst = class({})
LinkLuaModifier("modifier_saber_mana_burst", "heroes/hero_saber/modifier_saber_mana_burst.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_saber_mana_burst_active", "heroes/hero_saber/modifier_saber_mana_burst.lua", LUA_MODIFIER_MOTION_NONE)
function saber_mana_burst:GetManaCost(iLevel)
	return self:GetCaster():GetMaxMana() * self:GetSpecialValueFor("mana_wasted_pct") * 0.01
end
function saber_mana_burst:GetIntrinsicModifierName()
	return "modifier_saber_mana_burst"
end
if IsServer() then
	function saber_mana_burst:OnSpellStart()
		local caster = self:GetCaster()
		caster:AddNewModifier(caster, self, "modifier_saber_mana_burst_active", {duration = self:GetSpecialValueFor("duration")}):SetStackCount(self:GetManaCost())
	end
end