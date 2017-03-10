modifier_talent_magic_resistance_pct = class({})
function modifier_talent_magic_resistance_pct:IsHidden() return true end
function modifier_talent_magic_resistance_pct:IsPermanent() return true end
function modifier_talent_magic_resistance_pct:IsPurgable() return false end
function modifier_talent_magic_resistance_pct:DestroyOnExpire() return false end
function modifier_talent_magic_resistance_pct:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_talent_magic_resistance_pct:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function modifier_talent_magic_resistance_pct:GetModifierMagicalResistanceBonus()
	return self:GetStackCount()
end