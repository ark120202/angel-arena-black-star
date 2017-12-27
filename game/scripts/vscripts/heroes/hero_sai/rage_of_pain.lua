LinkLuaModifier("modifier_sai_rage_of_pain", "heroes/hero_sai/rage_of_pain.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sai_rage_of_pain_mass_debuff", "heroes/hero_sai/rage_of_pain.lua", LUA_MODIFIER_MOTION_NONE)

sai_rage_of_pain = class({
	GetIntrinsicModifierName = function() return "modifier_sai_rage_of_pain" end,
})


modifier_sai_rage_of_pain = class({})

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
	local health_per_stack_pct = ability:GetSpecialValueFor("health_per_stack_pct")
	self:SetStackCount(health_per_stack_pct - math.ceil(parent:GetHealth() / parent:GetMaxHealth() * health_per_stack_pct))
end

function modifier_sai_rage_of_pain:GetModifierPreAttack_CriticalStrike(keys)
	local ability = self:GetAbility()
	local stacks = self:GetStackCount()
	local chance = ability:GetSpecialValueFor("crit_chance_pct") +
		ability:GetSpecialValueFor("crit_chance_per_stack_pct") * stacks

	if RollPercentage(chance) then
		return 100 + self:GetAbility():GetSpecialValueFor("crit_mult_pre_stack_pct") * stacks
	end
end

function modifier_sai_rage_of_pain:GetModifierBaseDamageOutgoing_Percentage(keys)
	local ability = self:GetAbility()

	return (ability:GetSpecialValueFor("damage_per_stack_pct") + self:GetParent():GetMaxMana() / ability:GetSpecialValueFor("mana_for_bonus_damage")) * self:GetStackCount()
end
