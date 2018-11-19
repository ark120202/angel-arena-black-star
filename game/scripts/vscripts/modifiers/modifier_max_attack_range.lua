modifier_max_attack_range = class({})
modifier_max_attack_range.ParentAttackRange = 0
modifier_max_attack_range.AttackRangeChange = 0

function modifier_max_attack_range:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS}
end

function modifier_max_attack_range:RemoveOnDeath()
	return false
end

function modifier_max_attack_range:IsPurgable()
	return false
end

function modifier_max_attack_range:IsHidden()
	return true
end
function modifier_max_attack_range:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

if IsServer() then
	function modifier_max_attack_range:OnCreated(kv)
		if kv and kv.AttackRange then
			self:SetStackCount(kv.AttackRange)
		end
		local mods = self:GetParent():FindAllModifiersByName("modifier_max_attack_range")
		for _,v in ipairs(mods) do
			if v ~= self then
				if v:GetStackCount() < self:GetStackCount() then
					self:SetStackCount(v:GetStackCount())
				end
				if v:GetRemainingTime() > self:GetRemainingTime() then
					v:SetDuration(v:GetRemainingTime(), true)
				end
				v:Destroy()
			end
		end
		self:OnIntervalThink()
		self:StartIntervalThink(1/30)
	end

	function modifier_max_attack_range:GetModifierAttackRangeBonus()
		if self.ParentAttackRange > self:GetStackCount() then
			self.AttackRangeChange = self.ParentAttackRange - self:GetStackCount()
			return -self.AttackRangeChange
		end
	end

	function modifier_max_attack_range:OnIntervalThink()
		self.ParentAttackRange = self:GetParent():Script_GetAttackRange() + self.AttackRangeChange
	end
end
