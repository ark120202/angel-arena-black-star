modifier_item_casino_drug_pill1_addiction = class({})

function modifier_item_casino_drug_pill1_addiction:IsDebuff()
	return true
end

function modifier_item_casino_drug_pill1_addiction:OnCreated(keys)
	if IsServer() then
		self.amplitude = GetAbilitySpecial(self:GetAbility():GetName(), "strange_moving_addiction_amplitude")
		self:OnIntervalThink()
		self:StartIntervalThink(0.05)
	end
end

function modifier_item_casino_drug_pill1_addiction:OnIntervalThink()
	if IsServer() then
		if self:GetStackCount() >= 8 then
			if not self:GetParent():HasModifier("modifier_item_casino_drug_pill1_buff") or self:GetStackCount() >= 16 then
				DrugEffectStrangeMove(self:GetParent(), self.amplitude)
			end
		end
	end
end

function modifier_item_casino_drug_pill1_addiction:GetTexture()
	return "item_casino_drug_pill1"
end

function modifier_item_casino_drug_pill1_addiction:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_item_casino_drug_pill1_addiction:IsPurgable()
	return false
end

function modifier_item_casino_drug_pill1_addiction:RemoveOnDeath()
	return false
end