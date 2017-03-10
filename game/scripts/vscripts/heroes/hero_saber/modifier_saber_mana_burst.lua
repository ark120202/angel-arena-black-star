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
		local parent = self:GetParent()
		if parent:IsAlive() then
			local ability = self:GetAbility()
			local manacost = ability:GetManaCost()
			local isWeak = (parent:GetMana() / parent:GetMaxMana()) * 100 < ability:GetSpecialValueFor("weakness_mana_pct")
			self:SetStackCount(isWeak and 1 or 0)
			if isWeak and not self.pfx then
				self.pfx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_disarm.vpcf", PATTACH_OVERHEAD_FOLLOW, parent)
			elseif not isWeak and self.pfx then
				ParticleManager:DestroyParticle(self.pfx, false)
				self.pfx = nil
			end
			if ability:GetAutoCastState() and manacost * 2 < parent:GetMana() then
				parent:CastAbilityNoTarget(ability, parent:GetPlayerID())
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
if IsServer() then
	function modifier_saber_mana_burst_active:OnCreated()
		local parent = self:GetParent()
		self.pfx = ParticleManager:CreateParticle("particles/arena/units/heroes/hero_saber/mana_burst_stack.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
		ParticleManager:SetParticleControlEnt(self.pfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
	end
	function modifier_saber_mana_burst_active:OnDestroy()
		ParticleManager:DestroyParticle(self.pfx, false)
	end
end