modifier_sai_rage_of_pain = class({})

<<<<<<< HEAD
function modifier_sai_rage_of_pain:IsHidden()
	return false
end

=======
>>>>>>> e1e3c6383e4cda78d195dc155e58b985ac3c378a
function modifier_sai_rage_of_pain:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE
	}
end

<<<<<<< HEAD
function modifier_sai_rage_of_pain:GetModifierPreAttack_CriticalStrike()
	local ability = self:GetAbility()
	local parent = self:GetParent()
	local pctHealth = math.round(parent:GetHealth() / parent:GetMaxHealth() * 10)
	if RollPercentage(ability:GetSpecialValueFor("crit_chance_pct") * (10 - pctHealth)) then
		return 100 + ability:GetSpecialValueFor("crit_pct") * (10 - pctHealth) * 0.01
=======
if IsServer() then
	function modifier_sai_rage_of_pain:OnCreated()
		self:StartIntervalThink(0.1)
		self:OnIntervalThink()
>>>>>>> e1e3c6383e4cda78d195dc155e58b985ac3c378a
	end

<<<<<<< HEAD
function modifier_sai_rage_of_pain:GetModifierPreAttack_BonusDamage()
	local ability = self:GetAbility()
	local parent = self:GetParent()
	local pctHealth = math.round(parent:GetHealth() / parent:GetMaxHealth() * 10)
	return parent:GetBaseDamageMax()*(ability:GetSpecialValueFor("damage_pct") * (10 - pctHealth)*0.01)
=======
	function modifier_sai_rage_of_pain:OnIntervalThink()
		local ability = self:GetAbility()
		local parent = self:GetParent()
		self:SetStackCount(10 - math.ceil(parent:GetHealth() / parent:GetMaxHealth() * 10))
	end
end

function modifier_sai_rage_of_pain:GetModifierPreAttack_CriticalStrike(keys)
	local ability = self:GetAbility()
	local stacks = self:GetStackCount()
	if RollPercentage(ability:GetSpecialValueFor("crit_chance_pct") * stacks) then
		return 100 + ability:GetSpecialValueFor("crit_pct") * stacks
	end
end

function modifier_sai_rage_of_pain:GetModifierBaseDamageOutgoing_Percentage(keys)
	return self:GetAbility():GetSpecialValueFor("damage_pct") * self:GetStackCount()
>>>>>>> e1e3c6383e4cda78d195dc155e58b985ac3c378a
end