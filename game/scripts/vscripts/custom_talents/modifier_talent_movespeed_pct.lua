modifier_talent_movespeed_pct = class({})
function modifier_talent_movespeed_pct:IsHidden() return true end
function modifier_talent_movespeed_pct:IsPermanent() return true end
function modifier_talent_movespeed_pct:IsPurgable() return false end
function modifier_talent_movespeed_pct:DestroyOnExpire() return false end
function modifier_talent_damage:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_talent_movespeed_pct:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_talent_movespeed_pct:GetModifierMoveSpeedBonus_Percentage()
	return self:GetStackCount()
end