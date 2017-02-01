modifier_saber_mana_burst = class({})

function modifier_saber_mana_burst:IsHidden()
	return true
end
function modifier_saber_mana_burst:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
end
function modifier_saber_mana_burst:CheckState()
	return self:GetStackCount() == 1 and {
		[MODIFIER_STATE_DISARMED] = true
	}
end
function modifier_saber_mana_burst:GetModifierPhysicalArmorBonus()
	return self:GetStackCount() == 1 and self:GetAbility():GetSpecialValueFor("weakness_disarmor")
end
if IsServer() then
	function modifier_saber_mana_burst:OnCreated()
		self:StartIntervalThink(0.1)
	end
	function modifier_saber_mana_burst:OnIntervalThink()
		self:SetStackCount(self:GetParent():GetManaPercent() < 10 and 1 or 0)
		local ability = self:GetAbility()
		if ability:GetAutoCastState() then
			if ability:IsOwnersManaEnough() then
				if ability:PreformPrecastActions(self:GetParent()) then
					ability:OnSpellStart()
				end
			--else
			--	ability:ToggleAutoCast()
			end
		end
	end
end

modifier_saber_mana_burst_active = class({})
function modifier_saber_mana_burst_active:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
end
function modifier_saber_mana_burst_active:IsPurgable()
	return false
end
function modifier_saber_mana_burst_active:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
function modifier_saber_mana_burst_active:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("damage_per_mana")
end
function modifier_saber_mana_burst_active:GetModifierPhysicalArmorBonus()
	return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("armor_per_mana")
end