LinkLuaModifier("modifier_sara_evolution", "heroes/hero_sara/evolution.lua", LUA_MODIFIER_MOTION_NONE)

sara_evolution = class({
	GetIntrinsicModifierName = function() return "modifier_sara_evolution" end,
})

modifier_sara_evolution = class({
	IsPurgable      = function() return false end,
	DestroyOnExpire = function() return false end,
})

function modifier_sara_evolution:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_TOOLTIP
	}
end

function modifier_sara_evolution:GetModifierManaBonus()
	return self.ManaModifier or self:GetSharedKey("ManaModifier") or 0
end

function modifier_sara_evolution:OnTooltip()
	local ability = self:GetAbility()
	return ability:GetSpecialValueFor("max_per_minute") + ability:GetSpecialValueFor("max_per_minute_pct") * self:GetParent():GetMaxMana() * 0.01
end

function modifier_sara_evolution:GetModifierExtraHealthBonus()
	local ability = self:GetAbility()
	return ability:GetSpecialValueFor("bonus_health") / (1 - ability:GetSpecialValueFor("health_reduction_pct") * 0.01)
end

function modifier_sara_evolution:GetModifierPhysicalArmorBonus()
	return self.armorReduction
end
if IsServer() then
	modifier_sara_evolution.think_interval = 1/30
	function modifier_sara_evolution:OnCreated()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		if ability:GetLevel() == 0 then
			ability:SetLevel(1)
		end
		self:StartIntervalThink(self.think_interval)
		self:SetDuration(60, true)
		self.MaxEnergy = 100
		self.Energy = self.MaxEnergy
		local illusionParent = parent:GetIllusionParent()
		if parent.SavedEnergyStates then
			self.Energy = parent.SavedEnergyStates.Energy or self.Energy
			self.MaxEnergy = parent.SavedEnergyStates.MaxEnergy or self.MaxEnergy
			parent.SavedEnergyStates = nil
		elseif IsValidEntity(illusionParent) and illusionParent.GetEnergy and illusionParent.GetMaxEnergy then
			self.Energy = illusionParent:GetEnergy()
			self.MaxEnergy = illusionParent:GetMaxEnergy()
		end
		parent:SetNetworkableEntityInfo("Energy", self.Energy)
		parent:SetNetworkableEntityInfo("MaxEnergy", self.MaxEnergy)
		parent.ModifyEnergy = function(_, value, bShowMessage)
			if value > 0 and parent:HasModifier("modifier_sara_fragment_of_logic_debuff") then
				return self.Energy
			end
			if bShowMessage then
				--print("Call: modify mana by " .. value  .. ", result: old mana: " .. self.Energy .. " new mana: " .. math.min(math.max(self.Energy + value, 0), self.MaxEnergy))
				SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_ADD, parent, value, nil)
			end
			self.Energy = math.min(math.max(self.Energy + value, 0), self.MaxEnergy)
			parent:SetNetworkableEntityInfo("Energy", self.Energy)
			return self.Energy
		end
		parent.GetEnergy = function()
			return self.Energy
		end
		parent.GetMaxEnergy = function()
			return self.MaxEnergy
		end
		parent.ModifyMaxEnergy = function(_, value)
			self.MaxEnergy = self.MaxEnergy + value
			parent:SetNetworkableEntityInfo("MaxEnergy", self.MaxEnergy)
			return self.MaxEnergy
		end
	end
	function modifier_sara_evolution:OnDestroy()
		local parent = self:GetParent()
		if IsValidEntity(parent) then
			--For illusions and RecreateAbility function
			parent.SavedEnergyStates = {
				Energy = self.Energy,
				MaxEnergy = self.MaxEnergy
			}
		end
	end
	function modifier_sara_evolution:OnAttackLanded(keys)
		if keys.attacker == self:GetParent() then
			--keys.attacker:ModifyEnergy(keys.attacker:GetMaxEnergy() * self:GetAbility():GetSpecialValueFor("per_hit_pct") * 0.01)
		end
	end
	function modifier_sara_evolution:OnDeath(keys)
		if keys.attacker == self:GetParent() and keys.unit:IsRealCreep() then
			local ability = self:GetAbility()
			local energy = ability:GetSpecialValueFor("max_per_creep") + ability:GetSpecialValueFor("max_per_creep_pct") * keys.attacker:GetMaxEnergy() * 0.01
			if keys.unit.SpaceDissectionMultiplier then
				energy = energy * keys.unit.SpaceDissectionMultiplier
			end
			keys.attacker:ModifyMaxEnergy(energy)
		end
	end
	function modifier_sara_evolution:OnIntervalThink()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		if self:GetRemainingTime() <= 0 then
			self:GetParent():ModifyMaxEnergy(ability:GetSpecialValueFor("max_per_minute") + ability:GetSpecialValueFor("max_per_minute_pct") * parent:GetMaxEnergy() * 0.01)
			self:SetDuration(60, true)
		end
		local energyPS = (ability:GetSpecialValueFor("per_sec_pct") * parent:GetMaxEnergy() * 0.01 + ability:GetSpecialValueFor("per_sec"))
		if parent:HasScepter() then
			energyPS = energyPS * ability:GetSpecialValueFor("per_sec_multiplier_scepter")
		end
		parent:ModifyEnergy(energyPS * self.think_interval)
		parent:SetMana(self.Energy)
		local maxMana = parent:GetMaxMana() - (self.ManaModifier or 0)
		local previous = self.ManaModifier
		self.ManaModifier = self.MaxEnergy - maxMana
		self:SetSharedKey("ManaModifier", self.ManaModifier)
		if parent:IsAlive() then
			parent:CalculateHealthReduction()
		end
		self.armorReduction = ability:GetSpecialValueFor("armor_reduction_pct") * (parent:GetPhysicalArmorValue() - (self.armorReduction or 0)) * 0.01
	end
else
	function modifier_sara_evolution:OnCreated()
		self:StartIntervalThink(0.1)
	end
	function modifier_sara_evolution:OnIntervalThink()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		self.armorReduction = ability:GetSpecialValueFor("armor_reduction_pct") * (parent:GetPhysicalArmorValue() - (self.armorReduction or 0)) * 0.01
	end
end
