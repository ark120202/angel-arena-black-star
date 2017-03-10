modifier_talent_vision_day = class({})
function modifier_talent_vision_day:IsHidden() return true end
function modifier_talent_vision_day:IsPermanent() return true end
function modifier_talent_vision_day:IsPurgable() return false end
function modifier_talent_vision_day:DestroyOnExpire() return false end
function modifier_talent_vision_day:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_talent_vision_day:DeclareFunctions()
	return {MODIFIER_PROPERTY_BONUS_DAY_VISION}
end

function modifier_talent_vision_day:GetBonusDayVision()
	return self:GetStackCount()
end