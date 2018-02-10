LinkLuaModifier("modifier_sai_divine_flesh_on", "heroes/hero_sai/divine_flesh.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sai_divine_flesh_off", "heroes/hero_sai/divine_flesh.lua", LUA_MODIFIER_MOTION_NONE)

sai_divine_flesh = class({
	GetIntrinsicModifierName = function() return "modifier_sai_divine_flesh_off" end,
})

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

modifier_sai_divine_flesh_on = class({
	GetEffectName = function() return "particles/arena/units/heroes/hero_sai/divine_flesh.vpcf" end,
})
function modifier_sai_divine_flesh_on:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_DISABLE_HEALING,
	}
end

function modifier_sai_divine_flesh_on:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("active_bonus_armor")
end

function modifier_sai_divine_flesh_on:GetModifierMagicalResistanceBonus()
	return self:GetAbility():GetSpecialValueFor("active_magic_resistance_pct")
end

function modifier_sai_divine_flesh_on:GetDisableHealing()
	return 1
end

if IsServer() then
	function modifier_sai_divine_flesh_on:OnCreated()
		self:GetAbility():AutoStartCooldown()
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("think_interval"))
		self:OnIntervalThink()
	end

	function modifier_sai_divine_flesh_on:OnIntervalThink()
		local ability = self:GetAbility()
		local parent = self:GetParent()
		local damage = parent:GetMaxHealth() * ability:GetSpecialValueFor("active_self_damage_pct") * 0.01 * ability:GetSpecialValueFor("think_interval")
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


modifier_sai_divine_flesh_off = class({
	IsHidden = function() return true end,
})

function modifier_sai_divine_flesh_off:DeclareFunctions()
	return { MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE }
end

function modifier_sai_divine_flesh_off:GetModifierHealthRegenPercentage()
	return self.health_regeneration_pct or self:GetSharedKey("health_regeneration_pct") or 0
end

if IsServer() then
	function modifier_sai_divine_flesh_off:OnCreated()
		self:StartIntervalThink(0.1)
		self:OnIntervalThink()
	end

	function modifier_sai_divine_flesh_off:OnIntervalThink()
		local ability = self:GetAbility()
		local parent = self:GetParent()
		local sai_invulnerability = parent:FindAbilityByName("sai_invulnerability")
		local isUnderInvulnerability = sai_invulnerability and sai_invulnerability:GetToggleState()

		self.health_regeneration_pct = ability:GetSpecialValueFor("health_regeneration_pct")
		if isUnderInvulnerability then
			self.health_regeneration_pct = self.health_regeneration_pct * sai_invulnerability:GetSpecialValueFor("divine_flesh_regen_mult")
		end
		self:SetSharedKey("health_regeneration_pct", self.health_regeneration_pct)
	end
end
