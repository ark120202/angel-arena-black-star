modifier_set_attack_range = class({})

function modifier_set_attack_range:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS}
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

function modifier_set_attack_range:GetModifierAttackRangeBonus()
	return self:GetStackCount()
end

if IsServer() then
	function modifier_set_attack_range:OnCreated(kv)
		if kv and kv.AttackRange then
			local stacks = -(self:GetParent():GetKeyValue("AttackRange", nil, true) - kv.AttackRange)
			self:SetStackCount(stacks)
			--self:GetParent():SetNetworkableEntityInfo("BaseAttackRange", self:GetParent():GetKeyValue("AttackRange", nil, true))
			--self:GetParent():SetNetworkableEntityInfo("AttackRangeModify", stacks)
		end
	end
	function modifier_set_attack_range:OnDestroy()
		local parent = self:GetParent()
		if IsValidEntity(parent) then
			parent:SetNetworkableEntityInfo("AttackRangeModify", nil)
		end
	end
end
