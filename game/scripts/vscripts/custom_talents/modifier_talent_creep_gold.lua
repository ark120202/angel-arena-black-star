modifier_talent_creep_gold = class({})
function modifier_talent_creep_gold:IsHidden() return true end
function modifier_talent_creep_gold:IsPermanent() return true end
function modifier_talent_creep_gold:IsPurgable() return false end
function modifier_talent_creep_gold:DestroyOnExpire() return false end
function modifier_talent_creep_gold:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end