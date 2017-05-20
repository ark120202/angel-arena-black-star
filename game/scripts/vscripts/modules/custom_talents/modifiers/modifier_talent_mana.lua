modifier_talent_mana = class({})
function modifier_talent_mana:IsHidden() return true end
function modifier_talent_mana:IsPermanent() return true end
function modifier_talent_mana:IsPurgable() return false end
function modifier_talent_mana:DestroyOnExpire() return false end
function modifier_talent_mana:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_talent_mana:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_BONUS}
end

function modifier_talent_mana:GetModifierManaBonus()
	return self:GetStackCount()
end