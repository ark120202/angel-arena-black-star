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

modifier_sai_immortal = class({
	IsHidden = function() return true end,
	GetEffectAttachType = function() return PATTACH_ABSORIGIN_FOLLOW end,
	GetEffectName = function() return "particles/arena/units/heroes/hero_sai/immortal.vpcf" end,
})