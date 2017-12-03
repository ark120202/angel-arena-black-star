modifier_talent_vision_day = class({
	IsHidden        = function() return true end,
	IsPermanent     = function() return true end,
	IsPurgable      = function() return false end,
	DestroyOnExpire = function() return false end,
	GetAttributes   = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,
})

function modifier_talent_vision_day:DeclareFunctions()
	return {MODIFIER_PROPERTY_BONUS_DAY_VISION}
end

function modifier_talent_vision_day:GetBonusDayVision()
	return self:GetStackCount()
end
