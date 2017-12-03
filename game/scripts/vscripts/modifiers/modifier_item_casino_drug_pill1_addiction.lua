modifier_item_casino_drug_pill1_addiction = class({
	IsDebuff =      function() return true end,
	IsPurgable =    function() return false end,
	RemoveOnDeath = function() return false end,
	GetAttributes = function() return MODIFIER_ATTRIBUTE_PERMANENT end,
	GetTexture =    function() return "arena/casino_drug_pill1" end,
})

function modifier_item_casino_drug_pill1_addiction:OnCreated()
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
