LinkLuaModifier("modifier_guldan_hatred", "heroes/hero_guldan/guldan_hatred.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_guldan_hatred_effect", "heroes/hero_guldan/guldan_hatred.lua", LUA_MODIFIER_MOTION_NONE)

guldan_hatred = class({
	GetIntrinsicModifierName = function() return "modifier_guldan_hatred" end,
})
function guldan_hatred:GetCastRange()
	return self:GetSpecialValueFor('aura_radius')
end

modifier_guldan_hatred = class({
	IsPurgable = function() return false end,
	IsHidden = function() return true end,
})

function modifier_guldan_hatred:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor("aura_radius")
end
function modifier_guldan_hatred:GetAuraSearchTeam()
	return self:GetAbility():GetAbilityTargetTeam()
end
function modifier_guldan_hatred:GetAuraSearchType()
	return self:GetAbility():GetAbilityTargetType()
end
function modifier_guldan_hatred:GetAuraSearchFlags()
	return self:GetAbility():GetAbilityTargetFlags()
end
function modifier_guldan_hatred:IsAura()
	return true
end
function modifier_guldan_hatred:GetModifierAura()
	return "modifier_guldan_hatred_effect"
end


modifier_guldan_hatred_effect = class({})
function modifier_guldan_hatred_effect:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
	}
end
function modifier_guldan_hatred_effect:GetModifierHealthRegenPercentage()
	return self:GetAbility():GetSpecialValueFor('aura_percentage_health_regen')
end
