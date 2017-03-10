modifier_talent_spell_amplify = class({})
function modifier_talent_spell_amplify:IsHidden() return true end
function modifier_talent_spell_amplify:IsPermanent() return true end
function modifier_talent_spell_amplify:IsPurgable() return false end
function modifier_talent_spell_amplify:DestroyOnExpire() return false end
function modifier_talent_spell_amplify:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_talent_spell_amplify:DeclareFunctions()
	return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end

function modifier_talent_spell_amplify:GetModifierSpellAmplify_Percentage()
	return self:GetStackCount()
end