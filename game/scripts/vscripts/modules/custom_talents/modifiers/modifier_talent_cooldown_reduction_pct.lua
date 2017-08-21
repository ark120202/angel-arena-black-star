modifier_talent_cooldown_reduction_pct = class({
	IsHidden        = function() return true end,
	IsPermanent     = function() return true end,
	IsPurgable      = function() return false end,
	DestroyOnExpire = function() return false end,
	GetAttributes   = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,
})

function modifier_talent_cooldown_reduction_pct:DeclareFunctions()
	return {MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE}
end

function modifier_talent_cooldown_reduction_pct:GetModifierPercentageCooldown()
	return self:GetStackCount()
end
