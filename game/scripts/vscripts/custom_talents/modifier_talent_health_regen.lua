modifier_talent_health_regen = class({})
function modifier_talent_health_regen:IsHidden() return true end
function modifier_talent_health_regen:IsPermanent() return true end
function modifier_talent_health_regen:IsPurgable() return false end
function modifier_talent_health_regen:DestroyOnExpire() return false end
function modifier_talent_health_regen:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_talent_health_regen:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
end

function modifier_talent_health_regen:GetModifierConstantHealthRegen()
	return self:GetStackCount()
end