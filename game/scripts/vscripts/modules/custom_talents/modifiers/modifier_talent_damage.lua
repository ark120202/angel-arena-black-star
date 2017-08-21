modifier_talent_damage = class({
	IsHidden        = function() return true end,
	IsPermanent     = function() return true end,
	IsPurgable      = function() return false end,
	DestroyOnExpire = function() return false end,
	GetAttributes   = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,
})

function modifier_talent_damage:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function modifier_talent_damage:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount()
end
