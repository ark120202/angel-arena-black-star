modifier_talent_movespeed_pct = class({
	IsHidden        = function() return true end,
	IsPermanent     = function() return true end,
	IsPurgable      = function() return false end,
	DestroyOnExpire = function() return false end,
})

function modifier_talent_movespeed_pct:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_talent_movespeed_pct:GetModifierMoveSpeedBonus_Percentage()
	return self:GetStackCount()
end
