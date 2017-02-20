sara_fragment_of_armor = class({})
LinkLuaModifier("modifier_sara_fragment_of_armor", "heroes/hero_sara/modifier_sara_fragment_of_armor.lua", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function sara_fragment_of_armor:OnToggle()
		local caster = self:GetCaster()
		if self:GetToggleState() then
			caster:AddNewModifier(caster, self, "modifier_sara_fragment_of_armor", nil)
		else
			caster:RemoveModifierByName("modifier_sara_fragment_of_armor")
		end
	end
end