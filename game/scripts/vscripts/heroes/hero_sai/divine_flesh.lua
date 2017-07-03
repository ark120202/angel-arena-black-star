sai_divine_flesh = class({})
LinkLuaModifier("modifier_sai_divine_flesh_on", "heroes/hero_sai/divine_flesh.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sai_divine_flesh_off", "heroes/hero_sai/divine_flesh.lua", LUA_MODIFIER_MOTION_NONE)

function sai_divine_flesh:GetIntrinsicModifierName()
	return "modifier_divine_flesh_off"
end

if IsServer() then
	function sai_divine_flesh:OnToggle()
		local caster = self:GetCaster()
		if self:GetToggleState() then
			caster:RemoveModifierByName("modifier_sai_divine_flesh_off")
			caster:AddNewModifier(caster, self, "modifier_sai_divine_flesh_on", nil)
		else
			caster:RemoveModifierByName("modifier_sai_divine_flesh_on")
			caster:AddNewModifier(caster, self, "modifier_sai_divine_flesh_off", nil)
		end
	end
end

modifier_sai_divine_flesh_on = class({})
function modifier_sai_divine_flesh_on:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
	}
end
function modifier_sai_divine_flesh_on:GetModifierPhysicalArmorBonus()
	local ability = self:GetAbility()
	return ability:GetSpecialValueFor("active_bonus_armor")
end
function modifier_sai_divine_flesh_on:GetModifierMagicalResistanceBonus()
	local ability = self:GetAbility()
	return ability:GetSpecialValueFor("active_magic_resistance_pct")
end

modifier_sai_divine_flesh_off = class({})
function modifier_sai_divine_flesh_off:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE
	}
end
function modifier_sai_divine_flesh_off:GetModifierHealthRegenPercentage()
	local ability = self:GetAbility()
	local unit = self:GetParent()
	if unit:FindAbilityByName("sai_immortal"):GetToggleState()==true and
		self:GetParent():GetMana() >= unit:FindAbilityByName("sai_immortal"):GetSpecialValueFor("mana_per_second") then
		return ability:GetSpecialValueFor("health_regeneration_pct") * 
		unit:FindAbilityByName("sai_immortal"):GetSpecialValueFor("bonus_regen")
	else
		return ability:GetSpecialValueFor("health_regeneration_pct")
	end
end

function modifier_sai_divine_flesh_on:IsHidden()
	return true
end
function modifier_sai_divine_flesh_off:IsHidden()
	return true
end

if IsServer() then
	function modifier_sai_divine_flesh_on:OnCreated()
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("think_interval"))
		self:OnIntervalThink()
	end
end

function modifier_sai_divine_flesh_on:OnIntervalThink()
	local ability = self:GetAbility()
	local parent = self:GetParent()
	local unit = parent
	local damage = parent:GetMaxHealth()/100*ability:GetSpecialValueFor("active_self_damage_pct") *
			ability:GetSpecialValueFor("think_interval")

	if unit:FindAbilityByName("sai_immortal"):GetToggleState()==true and
	self:GetParent():GetMana() >= unit:FindAbilityByName("sai_immortal"):GetSpecialValueFor("mana_second") then
		damage = damage/100*unit:FindAbilityByName("sai_immortal"):GetSpecialValueFor("damage_reduction_pct")

		ApplyDamage({
		victim = parent,
		attacker = parent,
		damage = damage,
		damage_type = DAMAGE_TYPE_PURE,
		damage_flags = DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS + DOTA_DAMAGE_FLAG_HPLOSS,
		ability = ability
	})
	else

		ApplyDamage({
		victim = parent,
		attacker = parent,
		damage = damage,
		damage_type = DAMAGE_TYPE_PURE,
		damage_flags = DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS + DOTA_DAMAGE_FLAG_HPLOSS,
		ability = ability
	})
	end
end