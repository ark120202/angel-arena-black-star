modifier_item_casino_drug_pill2_addiction = class({})

function modifier_item_casino_drug_pill2_addiction:IsDebuff()
	return true
end

function modifier_item_casino_drug_pill2_addiction:OnCreated(keys)
	if IsServer() then

		self.amplitude = GetAbilitySpecial(self:GetAbility():GetName(), "strange_moving_addiction_amplitude")
		self.duration = GetAbilitySpecial(self:GetAbility():GetName(), "random_particles_addiction_duration")
		self:OnIntervalThink()
		self:StartIntervalThink(0.05)
	end
end

function modifier_item_casino_drug_pill2_addiction:OnIntervalThink()
	if IsServer() then
		if self:GetStackCount() >= 8 then
			if not self:GetParent():HasModifier("modifier_item_casino_drug_pill2_buff") or self:GetStackCount() >= 16 then
				DrugEffectStrangeMove(self:GetParent(), self.amplitude)
				if RandomInt(1, 50) <= 1 then
					DrugEffectRandomParticles(self:GetParent(), self.duration)
				end
			end
		end
	end
end

function modifier_item_casino_drug_pill2_addiction:GetTexture()
	return "arena/casino_drug_pill2"
end

function modifier_item_casino_drug_pill2_addiction:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_item_casino_drug_pill2_addiction:IsPurgable()
	return false
end

function modifier_item_casino_drug_pill2_addiction:RemoveOnDeath()
	return false
end