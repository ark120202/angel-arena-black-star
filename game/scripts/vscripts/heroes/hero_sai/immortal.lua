sai_immortal = class({})
LinkLuaModifier("modifier_sai_immortal", "heroes/hero_sai/immortal.lua", LUA_MODIFIER_MOTION_NONE)

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


modifier_sai_immortal = class({
	IsPurgable = function() return false end,
	IsHidden   = function() return true end,
})

function modifier_sai_immortal:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE
	}
end
