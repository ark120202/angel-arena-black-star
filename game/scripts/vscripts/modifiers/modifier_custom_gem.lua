modifier_custom_gem = class({
	IsHidden   = function() return true end,
	IsPurgable = function() return false end,
	RemoveOnDeath = function() return false end,
	GetAttributes = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,
})

function modifier_custom_gem:OnCreated(keys)
	self.radius = keys.radius
	self.teams = keys.teams
	self.types = keys.types
	self.flags = keys.flags
end

function modifier_custom_gem:GetModifierAura()
	return "modifier_truesight"
end

function modifier_custom_gem:IsAura()
	return true
end

function modifier_custom_gem:GetAuraRadius()
	return self.radius or self:GetAbility():GetSpecialValueFor("aura_radius")
end

function modifier_custom_gem:GetAuraSearchTeam()
	return _G[self.teams] or self:GetAbility():GetAbilityTargetTeam()
end

function modifier_custom_gem:GetAuraSearchType()
	return _G[self.types] or self:GetAbility():GetAbilityTargetType()
end

function modifier_custom_gem:GetAuraSearchFlags()
	return _G[self.flags] or self:GetAbility():GetAbilityTargetFlags()
end
