sara_fragment_of_logic = class({})
LinkLuaModifier("modifier_sara_fragment_of_logic", "heroes/hero_sara/modifier_sara_fragment_of_logic.lua", LUA_MODIFIER_MOTION_NONE)

function sara_fragment_of_logic:GetIntrinsicModifierName()
	return "modifier_sara_fragment_of_logic"
end

if IsClient() then
	function sara_fragment_of_logic:GetManaCost()
		return self:GetSpecialValueFor("energy_const") + self:GetCaster():GetMana() * self:GetSpecialValueFor("energy_pct") * 0.01
	end
end