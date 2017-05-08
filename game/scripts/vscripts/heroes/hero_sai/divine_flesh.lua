sai_divine_flesh = class({})
LinkLuaModifier("modifier_sai_divine_flesh_on", "heroes/hero_sai/modifier_sai_divine_flesh.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sai_divine_flesh_off", "heroes/hero_sai/modifier_sai_divine_flesh.lua", LUA_MODIFIER_MOTION_NONE)

function sai_divine_flesh:GetIntrinsicModifierName()
	return "modifier_divine_flesh_off"
end

if IsServer() then
	function sai_divine_flesh:OnToggle()
		local caster = self:GetCaster()
		if self:GetToggleState() then
			caster:RemoveModifierByName("modifier_sai_divine_flesh_off")
			caster:AddNewModifier(caster, self, "modifier_sai_divine_flesh_on", nil)
		else
			caster:RemoveModifierByName("modifier_sai_divine_flesh_on")
			caster:AddNewModifier(caster, self, "modifier_sai_divine_flesh_off", nil)
		end
	end
end