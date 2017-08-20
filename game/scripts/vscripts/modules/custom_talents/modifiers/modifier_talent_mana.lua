modifier_talent_mana = class({
	IsHidden        = function() return true end,
	IsPermanent     = function() return true end,
	IsPurgable      = function() return false end,
	DestroyOnExpire = function() return false end,
	GetAttributes   = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,
})

function modifier_talent_mana:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_BONUS}
end

function modifier_talent_mana:GetModifierManaBonus()
	return self:GetStackCount()
end
