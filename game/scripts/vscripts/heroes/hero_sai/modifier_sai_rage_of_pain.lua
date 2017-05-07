modifier_sai_rage_of_pain = class({})

function modifier_sai_rage_of_pain:IsHidden()
	return true
end

function modifier_sai_rage_of_pain:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
end

function modifier_sai_rage_of_pain:GetModifierPreAttack_CriticalStrike(keys)
	local ability = self:GetAbility()
	local parent = self:GetParent()
	local pctHealth = math.round(parent:GetHealth() / parent:GetMaxHealth() * 10)
	if RollPercentage(ability:GetSpecialValueFor("crit_chance_pct") * (10 - pctHealth)) then
		return 100 + ability:GetSpecialValueFor("crit_pct") * (10 - pctHealth) * 0.01
	end
end

if IsServer() then
	function modifier_sai_rage_of_pain:GetModifierPreAttack_BonusDamage(keys)
		local ability = self:GetAbility()
		local parent = self:GetParent()
		local pctHealth = math.round(parent:GetHealth() / parent:GetMaxHealth() * 10)
		return parent:GetBaseDamageMax()*(ability:GetSpecialValueFor("damage_pct") * (10 - pctHealth)*0.01)
	end
end