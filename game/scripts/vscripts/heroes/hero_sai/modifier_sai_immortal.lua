modifier_sai_immortal = class({})

function modifier_sai_immortal:IsHidden()
	return true
end

function modifier_sai_immortal:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}
end

function modifier_sai_immortal:GetModifierAttackSpeedBonus_Constant()
	if self:GetParent():GetMana() >= self:GetAbility():GetSpecialValueFor("mana_per_second") then
		return self:GetAbility():GetSpecialValueFor("attack_speed_debuff")
	end
end

function modifier_sai_immortal:GetModifierMoveSpeedBonus_Percentage()
	local ability = self:GetAbility()
	local debuff = ability:GetSpecialValueFor("decreasement_ms_pct")
	if self:GetParent():GetMana() >= self:GetAbility():GetSpecialValueFor("mana_per_second") then
		return debuff
	end
end

function modifier_sai_immortal:GetModifierTotalDamageOutgoing_Percentage()
	local ability = self:GetAbility()
	local debuff = ability:GetSpecialValueFor("decreasement_pct")
	if self:GetParent():GetMana() >= self:GetAbility():GetSpecialValueFor("mana_per_second") then
		return debuff
	end
end

function modifier_sai_immortal:GetModifierIncomingDamage_Percentage()
	if self:GetParent():GetMana() >= self:GetAbility():GetSpecialValueFor("mana_per_second") then
		return -self:GetAbility():GetSpecialValueFor("damage_reduction_pct")
	end
end

if IsServer() then
	function modifier_sai_immortal:OnCreated()
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("think_interval"))
		self:OnIntervalThink()
	end
end

function modifier_sai_immortal:OnIntervalThink()
	self:GetParent():SpendMana(self:GetAbility():GetSpecialValueFor("mana_per_second") *
		self:GetAbility():GetSpecialValueFor("think_interval"), self:GetAbility())
end


