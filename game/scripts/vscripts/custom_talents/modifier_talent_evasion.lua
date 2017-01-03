modifier_talent_evasion = class({})
function modifier_talent_evasion:IsHidden() return true end
function modifier_talent_evasion:IsPermanent() return true end
function modifier_talent_evasion:IsPurgable() return false end
function modifier_talent_evasion:DestroyOnExpire() return false end
function modifier_talent_evasion:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_talent_evasion:DeclareFunctions()
	return {MODIFIER_PROPERTY_EVASION_CONSTANT}
end

function modifier_talent_evasion:GetModifierEvasion_Constant()
	return self:GetStackCount()
end