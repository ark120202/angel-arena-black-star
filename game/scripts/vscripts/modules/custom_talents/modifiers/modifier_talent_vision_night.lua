modifier_talent_vision_night = class({})
function modifier_talent_vision_night:IsHidden() return true end
function modifier_talent_vision_night:IsPermanent() return true end
function modifier_talent_vision_night:IsPurgable() return false end
function modifier_talent_vision_night:DestroyOnExpire() return false end
function modifier_talent_vision_night:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_talent_vision_night:DeclareFunctions()
	return {MODIFIER_PROPERTY_BONUS_NIGHT_VISION}
end

function modifier_talent_vision_night:GetBonusNightVision()
	return self:GetStackCount()
end