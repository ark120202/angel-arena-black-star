modifier_neutral_upgrade_attackspeed = class({})

function modifier_neutral_upgrade_attackspeed:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
	return funcs
end

function modifier_neutral_upgrade_attackspeed:GetModifierAttackSpeedBonus_Constant()
	return 1 * self:GetStackCount()
end

function modifier_neutral_upgrade_attackspeed:IsHidden()
	return true
end