modifier_sai_rage_of_pain = class({})

function modifier_sai_rage_of_pain:IsHidden()
	return true
end

function modifier_sai_rage_of_pain:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE
	}
end

function modifier_sai_rage_of_pain:GetModifierPreAttack_CriticalStrike(keys)
	local ability = self:GetAbility()
	local parent = keys.unit
	local pctHealth = math.round(parent.GetHealth()/parent.GetMaxHealth()*10)
	if parent == self:GetParent() then
		if RollPercentage(ability:GetSpecialValueFor("crit_chance_pct")*(10-pctHealth)) then
			return 100 + ability:GetSpecialValueFor("crit_pct")*(10-pctHealth) * 0.01
		end
	end
end

function modifier_sai_rage_of_pain:GetModifierBaseDamageOutgoing_Percentage(keys)
	local ability = self:GetAbility()
	local parent = keys.unit
	local pctHealth = math.round(parent.GetHealth()/parent.GetMaxHealth()*10)
	if parent == self:GetParent() then
		return parent:GetSpecialValueFor("damage_pct")*(10-pctHealth)
	end
end


