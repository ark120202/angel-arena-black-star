modifier_talent_spell_amplify = class({
	IsHidden        = function() return true end,
	IsPermanent     = function() return true end,
	IsPurgable      = function() return false end,
	DestroyOnExpire = function() return false end,
	GetAttributes   = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,
})

function modifier_talent_spell_amplify:DeclareFunctions()
	return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end

function modifier_talent_spell_amplify:GetModifierSpellAmplify_Percentage()
	return self:GetStackCount()
end
