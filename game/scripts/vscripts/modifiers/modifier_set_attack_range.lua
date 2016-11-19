modifier_set_attack_range = class({})

function modifier_set_attack_range:OnCreated(kv)
	if IsServer() and kv and kv.AttackRange then
		self:SetStackCount(kv.AttackRange)
	end
end

function modifier_set_attack_range:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS}
end

function modifier_set_attack_range:GetModifierAttackRangeBonus()
	if IsServer() then
		return (self:GetParent():GetKeyValue("AttackRange", nil, true) - self:GetStackCount())*-1
	end
end

function modifier_set_attack_range:RemoveOnDeath()
	return false
end

function modifier_set_attack_range:IsPurgable()
	return false
end

function modifier_set_attack_range:IsHidden()
	return true
end