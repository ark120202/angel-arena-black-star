modifier_sai_rage_of_pain = class({})

function modifier_sai_rage_of_pain:IsHidden()
	return false
end
function modifier_sai_rage_of_pain:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE
	}
end

if IsServer() then
	function modifier_sai_rage_of_pain:OnCreated()
		self:StartIntervalThink(0.1)
		self:OnIntervalThink()
	end
end

function modifier_sai_rage_of_pain:OnIntervalThink()
	local ability = self:GetAbility()
	local parent = self:GetParent()
	self:SetStackCount(ability:GetSpecialValueFor("health_per_stack_pct")+1 - math.ceil(parent:GetHealth() / parent:GetMaxHealth() * ability:GetSpecialValueFor("health_per_stack_pct")+1))
end

function modifier_sai_rage_of_pain:GetModifierPreAttack_CriticalStrike(keys)
	local ability = self:GetAbility()
	local stacks = self:GetStackCount()
	if RollPercentage(ability:GetSpecialValueFor("crit_chance_pct") * stacks) then
		return 100 + ability:GetSpecialValueFor("crit_chance_per_stack_pct") * stacks
	end
end

function modifier_sai_rage_of_pain:GetModifierBaseDamageOutgoing_Percentage(keys)
	return self:GetAbility():GetSpecialValueFor("damage_per_stack_pct") * self:GetStackCount()
end