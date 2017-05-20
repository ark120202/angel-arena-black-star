modifier_talent_health = class({})
function modifier_talent_health:IsHidden() return true end
function modifier_talent_health:IsPermanent() return true end
function modifier_talent_health:IsPurgable() return false end
function modifier_talent_health:DestroyOnExpire() return false end
function modifier_talent_health:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_talent_health:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS}
end

function modifier_talent_health:GetModifierHealthBonus()
	return self:GetStackCount()
end