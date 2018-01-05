modifier_talent_vision_night = class({
	IsHidden        = function() return true end,
	IsPermanent     = function() return true end,
	IsPurgable      = function() return false end,
	DestroyOnExpire = function() return false end,
	GetAttributes   = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,
})

function modifier_talent_vision_night:DeclareFunctions()
	return {MODIFIER_PROPERTY_BONUS_NIGHT_VISION}
end

function modifier_talent_vision_night:GetBonusNightVision()
	return self:GetStackCount()
end
