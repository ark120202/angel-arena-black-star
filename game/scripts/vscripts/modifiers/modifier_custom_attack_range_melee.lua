modifier_custom_attack_range_melee = class({})

function modifier_custom_attack_range_melee:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS}
end

function modifier_custom_attack_range_melee:GetModifierAttackRangeBonus()
	if IsServer() then
		return (self:GetParent():GetKeyValue("AttackRange", nil, true) - 150)*-1
	end
end

function modifier_custom_attack_range_melee:RemoveOnDeath()
	return false
end

function modifier_custom_attack_range_melee:IsPurgable()
	return false
end

function modifier_custom_attack_range_melee:IsHidden()
	return true
end