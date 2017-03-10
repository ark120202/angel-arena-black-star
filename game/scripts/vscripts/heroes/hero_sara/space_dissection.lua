sara_space_dissection = class({})
LinkLuaModifier("modifier_sara_space_dissection", "heroes/hero_sara/modifier_sara_space_dissection.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sara_space_dissection_armor_reduction", "heroes/hero_sara/modifier_sara_space_dissection.lua", LUA_MODIFIER_MOTION_NONE)

function sara_space_dissection:GetIntrinsicModifierName()
	return "modifier_sara_space_dissection"
end

if IsClient() then
	function sara_space_dissection:GetManaCost()
		return self:GetCaster():GetMaxMana() * self:GetSpecialValueFor("energy_pct") * 0.01
	end
end