LinkLuaModifier("modifier_sai_immortal", "heroes/hero_sai/immortal.lua", LUA_MODIFIER_MOTION_NONE)

sai_immortal = class({})

if IsServer() then
	function sai_immortal:OnToggle()
		local caster = self:GetCaster()
		if self:GetToggleState() then
			caster:AddNewModifier(caster, self, "modifier_sai_immortal", nil)
		else
			caster:RemoveModifierByName("modifier_sai_immortal")
		end
	end
end


modifier_sai_immortal = class({
	IsHidden      = function() return true end,
	GetEffectName = function() return "particles/units/heroes/hero_omniknight/omniknight_guardian_angel_wings.vpcf" end,
})

function modifier_sai_immortal:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}
end

function modifier_sai_immortal:GetModifierAttackSpeedBonus_Constant()
		return self:GetAbility():GetSpecialValueFor("attack_speed_reduction_pct")
end

function modifier_sai_immortal:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("movement_speed_reduction_pct")
end

function modifier_sai_immortal:GetModifierTotalDamageOutgoing_Percentage()
	return self:GetAbility():GetSpecialValueFor("outgoing_damage_reduction_pct")
end

function modifier_sai_immortal:GetModifierIncomingDamage_Percentage()
		return self:GetAbility():GetSpecialValueFor("incoming_damage_reduction_pct")
end

if IsServer() then
	function modifier_sai_immortal:OnCreated()
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("think_interval"))
		self:OnIntervalThink()
	end

	function modifier_sai_immortal:OnIntervalThink()
		local ability = self:GetAbility()
		local parent = self:GetParent()
		local caster = self:GetCaster()
		local manaPerTick = ability:GetSpecialValueFor("mana_per_second") * ability:GetSpecialValueFor("think_interval")
		if parent:GetMana() >= manaPerTick and ability:GetToggleState() then
			parent:SpendMana(manaPerTick, ability)
		else
			ability:ToggleAbility()
		end
	end
end
