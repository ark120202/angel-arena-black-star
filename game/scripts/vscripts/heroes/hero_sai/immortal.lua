sai_immortal = class({})
LinkLuaModifier("modifier_sai_immortal", "heroes/hero_sai/immortal.lua", LUA_MODIFIER_MOTION_NONE)

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
	GetEffectName = function() return "particles/units/heroes/hero_omniknight/omniknight_guardian_angel_wings.vpcf" end,
	})

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
		return self:GetAbility():GetSpecialValueFor("attack_speed_debuff")
end

function modifier_sai_immortal:GetModifierMoveSpeedBonus_Percentage()
	local ability = self:GetAbility()
	local debuff = ability:GetSpecialValueFor("decreasement_ms_pct")
	return debuff
end

function modifier_sai_immortal:GetModifierTotalDamageOutgoing_Percentage()
	local ability = self:GetAbility()
	local debuff = ability:GetSpecialValueFor("decreasement_pct")
	return debuff
end

function modifier_sai_immortal:GetModifierIncomingDamage_Percentage()
		return -self:GetAbility():GetSpecialValueFor("damage_reduction_pct")
end

if IsServer() then
	function modifier_sai_immortal:OnCreated()
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("think_interval"))
		self:OnIntervalThink()
	end
end

function modifier_sai_immortal:OnIntervalThink()
	local ability = self:GetAbility()
	local parent = self:GetParent()
	local caster = self:GetCaster()
	if parent:GetMana() > ability:GetSpecialValueFor("mana_per_second") and ability:GetToggleState() then
		parent:SpendMana(self:GetAbility():GetSpecialValueFor("mana_per_second") *
		ability:GetSpecialValueFor("think_interval"), ability)
	else 
		ability:ToggleAbility()
		caster:RemoveModifierByName("modifier_sai_immortal")
	end
end