modifier_talent_damage = class({})
function modifier_talent_damage:IsHidden() return true end
function modifier_talent_damage:IsPermanent() return true end
function modifier_talent_damage:IsPurgable() return false end
function modifier_talent_damage:DestroyOnExpire() return false end
function modifier_talent_damage:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_talent_damage:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function modifier_talent_damage:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount()
end