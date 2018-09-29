LinkLuaModifier("modifier_anakim_wisps", "heroes/hero_anakim/wisps.lua", LUA_MODIFIER_MOTION_NONE)

anakim_wisps = class({GetIntrinsicModifierName = function() return "modifier_anakim_wisps" end})

modifier_anakim_wisps = class({
	IsHidden = function() return true end,
	IsPurgable = function() return false end,
	DeclareFunctions = function() return {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
	} end
})

if IsServer() then
	function modifier_anakim_wisps:OnCreated()
		local ability = self:GetAbility()
		ability:SetLevel(ability:GetMaxLevel())
	end

	function modifier_anakim_wisps:GetModifierPreAttack_CriticalStrike()
		if RandomInt(0, 100) <= self:GetAbility():GetSpecialValueFor("critical_chance_pct") then
			return self:GetAbility():GetSpecialValueFor("critical_damage_pct")
		end
	end
end
