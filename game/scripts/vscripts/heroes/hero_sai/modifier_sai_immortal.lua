modifier_sai_immortal = class({})

function modifier_sai_immortal:IsHidden()
	return true
end

function modifier_sai_immortal:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE
	}
end

function modifier_sai_immortal:GetModifierConstantHealthRegen()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	local max_regern = parent:GetHealthRegen()
	local bonus_regen = max_regen/100*ability:GetSpecialValueFor("bonus_regen_pct")
	return bonus_regen
end

--[[function modifier_sai_immortal:GetModifierMoveSpeedBonus_Percentage()
	local ability = self:GetAbility()
	local debuff = ability:GetSpecialValueFor("debuff_pct")
	return -debuff
end

function modifier_sai_immortal:GetModifierAttackSpeedBonus_Constant()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	local max_attack_speed = parent:GetAttackSpeed()
	local debuff = max_attack_speed/100*ability:GetSpecialValueFor("debuff_pct")
	return -debuff
end

function modifier_sai_immortal:GetModifierTotalDamageOutgoing_Percentage()
	local ability = self:GetAbility()
	local debuff = ability:GetSpecialValueFor("debuff_pct")
	return -debuff
end]]--
