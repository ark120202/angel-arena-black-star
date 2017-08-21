modifier_talent_mana_regen = class({
	IsHidden        = function() return true end,
	IsPermanent     = function() return true end,
	IsPurgable      = function() return false end,
	DestroyOnExpire = function() return false end,
})

function modifier_talent_mana_regen:DeclareFunctions()
	return { MODIFIER_PROPERTY_MANA_REGEN_CONSTANT }
end

function modifier_talent_mana_regen:GetModifierConstantManaRegen()
	return self:GetStackCount()
end
