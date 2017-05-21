--https://moddota.com/forums/discussion/1205/making-any-ability-use-charges
modifier_charges = class({})

if IsServer() then
	function modifier_charges:Update()
		if self:GetDuration() == -1 then
			self:SetDuration(self.kv.replenish_time, true)
			self:StartIntervalThink(self.kv.replenish_time)
		end

		if self:GetStackCount() == 0 then
			self:GetAbility():StartCooldown(self:GetRemainingTime())
		end
	end

	function modifier_charges:OnCreated(kv)
		self:SetStackCount(kv.start_count or kv.max_count)
		self.kv = kv

		if kv.start_count and kv.start_count ~= kv.max_count then
			self:Update()
		end
	end

	function modifier_charges:DeclareFunctions()
		return {
			MODIFIER_EVENT_ON_ABILITY_EXECUTED
		}
	end

	function modifier_charges:OnAbilityExecuted(params)
		if params.unit == self:GetParent() then
			local ability = params.ability

			if params.ability == self:GetAbility() then
				self:DecrementStackCount()
				self:Update()
			end
		end
	end

	function modifier_charges:OnIntervalThink()
		local stacks = self:GetStackCount()

		if stacks < self.kv.max_count then
			self:SetDuration(self.kv.replenish_time, true)
			self:IncrementStackCount()

			if stacks == self.kv.max_count - 1 then
				self:SetDuration(-1, true)
				self:StartIntervalThink(-1)
			end
		end
	end

	function modifier_charges:SetMaxStackCount(count)
		if self.kv.max_count == count then
			return
		end
		if self.kv.max_count < count then
			self.kv.max_count = count
			self:Update()
		else
			self.kv.max_count = count
			self:SetStackCount(math.min(self:GetStackCount(), count))
			if self:GetStackCount() == count then
				self:SetDuration(-1, true)
				self:StartIntervalThink(-1)
			end
		end
	end
end

function modifier_charges:DestroyOnExpire()
	return false
end

function modifier_charges:IsPurgable()
	return false
end

function modifier_charges:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end