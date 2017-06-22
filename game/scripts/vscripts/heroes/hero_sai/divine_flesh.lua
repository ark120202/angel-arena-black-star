LinkLuaModifier("modifier_sai_divine_flesh_on", "heroes/hero_sai/divine_flesh.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sai_divine_flesh_off", "heroes/hero_sai/divine_flesh.lua", LUA_MODIFIER_MOTION_NONE)

sai_divine_flesh = class({
	GetIntrinsicModifierName = function() return "modifier_divine_flesh_off" end,
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
	IsHidden = function() return false end,
})

function modifier_sai_divine_flesh_on:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
	}
end

function modifier_sai_divine_flesh_on:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("active_bonus_armor")
end

function modifier_sai_divine_flesh_on:GetModifierMagicalResistanceBonus()
	return self:GetAbility():GetSpecialValueFor("active_magic_resistance_pct")
end
-- active_self_damage_pct

modifier_sai_divine_flesh_off = class({
	IsHidden = function() return false end,
})

function modifier_sai_divine_flesh_off:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE
	}
end

function modifier_sai_divine_flesh_off:GetModifierHealthRegenPercentage()
	return self:GetAbility():GetSpecialValueFor("health_regeneration_pct")
end
