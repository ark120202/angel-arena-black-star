sai_immortal = class({})
LinkLuaModifier("modifier_sai_immortal", "heroes/hero_sai/modifier_sai_immortal.lua", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function sai_immortal:OnToggle()
		local caster = self:GetCaster()
		if self:GetToggleState() then
			caster:AddNewModifier(caster, self, "modifier_sai_immortal", nil)
		else
			caster:RemoveModifierByName("modifier_sai_immortal")
		end
	end
end