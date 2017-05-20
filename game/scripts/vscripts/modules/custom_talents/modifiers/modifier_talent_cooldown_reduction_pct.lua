modifier_talent_cooldown_reduction_pct = class({})
function modifier_talent_cooldown_reduction_pct:IsHidden() return true end
function modifier_talent_cooldown_reduction_pct:IsPermanent() return true end
function modifier_talent_cooldown_reduction_pct:IsPurgable() return false end
function modifier_talent_cooldown_reduction_pct:DestroyOnExpire() return false end
function modifier_talent_cooldown_reduction_pct:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_talent_cooldown_reduction_pct:DeclareFunctions()
	return {MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE}
end

function modifier_talent_cooldown_reduction_pct:GetModifierPercentageCooldown()
	return self:GetStackCount()
end