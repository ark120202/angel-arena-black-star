saber_mana_burst = class({})
function saber_mana_burst:GetManaCost(iLevel)
	return self:GetCaster():GetMaxMana() * self:GetSpecialValueFor("mana_wasted_pct") * 0.01
end
function saber_mana_burst:GetIntrinsicModifierName()
	return "modifier_saber_mana_burst"
end
if IsServer() then
	function saber_mana_burst:OnSpellStart()
		local caster = self:GetCaster()
		local mana = self:GetManaCost()
		caster:AddNewModifier(caster, self, "modifier_saber_mana_burst_active", {duration = self:GetSpecialValueFor("duration")}):SetStackCount(mana)
	end
end