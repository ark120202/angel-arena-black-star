freya_pain_reflection = class({})
LinkLuaModifier("modifier_freya_pain_reflection", "heroes/hero_freya/modifier_freya_pain_reflection.lua", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function freya_pain_reflection:OnSpellStart()
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_freya_pain_reflection", {duration = self:GetSpecialValueFor("duration")})
	end
end