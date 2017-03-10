modifier_talent_movespeed_limit = class({})
function modifier_talent_movespeed_limit:IsHidden() return true end
function modifier_talent_movespeed_limit:IsPermanent() return true end
function modifier_talent_movespeed_limit:IsPurgable() return false end
function modifier_talent_movespeed_limit:DestroyOnExpire() return false end
function modifier_talent_movespeed_limit:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_talent_movespeed_limit:DeclareFunctions() 
	return {
		MODIFIER_PROPERTY_MOVESPEED_MAX,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
	}
end

function modifier_talent_movespeed_limit:GetModifierMoveSpeed_Max()
	return self:GetStackCount()
end
function modifier_talent_movespeed_limit:GetModifierMoveSpeed_Limit()
	return self:GetStackCount()
end