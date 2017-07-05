LinkLuaModifier("modifier_item_runic_mekansm", "items/item_runic_mekansm.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_runic_mekansm_effect", "items/item_runic_mekansm.lua", LUA_MODIFIER_MOTION_NONE)

item_runic_mekansm = class({
	GetIntrinsicModifierName = function() return "modifier_item_runic_mekansm" end,
})

if IsServer() then
	function item_runic_mekansm:OnSpellStart()
		local caster = self:GetCaster()
		caster:EmitSound("DOTA_Item.Mekansm.Activate")
		ParticleManager:CreateParticle("particles/econ/events/ti6/mekanism_ti6.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		for _,v in ipairs(FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, self:GetSpecialValueFor("radius"), self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)) do
			SafeHeal(v, self:GetSpecialValueFor("heal_amount"), self)
			ParticleManager:CreateParticle("particles/econ/events/ti6/mekanism_recipient_ti6.vpcf", PATTACH_ABSORIGIN_FOLLOW, v, caster)
			v:EmitSound("DOTA_Item.Mekansm.Target")
		end
	end
end


modifier_item_runic_mekansm = class({
	IsHidden      = function() return true end,
	GetAttributes = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,
	IsPurgable    = function() return false end,
})

function modifier_item_runic_mekansm:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
end
function modifier_item_runic_mekansm:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end
function modifier_item_runic_mekansm:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end
function modifier_item_runic_mekansm:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end
function modifier_item_runic_mekansm:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_armor")
end
function modifier_item_runic_mekansm:GetModifierAura()
	return "modifier_item_runic_mekansm_effect"
end
function modifier_item_runic_mekansm:IsAura()
	return true
end
function modifier_item_runic_mekansm:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor("radius")
end
function modifier_item_runic_mekansm:GetAuraSearchTeam()
	return self:GetAbility():GetAbilityTargetTeam()
end
function modifier_item_runic_mekansm:GetAuraSearchType()
	return self:GetAbility():GetAbilityTargetType()
end
function modifier_item_runic_mekansm:GetAuraSearchFlags()
	return self:GetAbility():GetAbilityTargetFlags()
end

modifier_item_runic_mekansm_effect = class({})
function modifier_item_runic_mekansm_effect:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
end
function modifier_item_runic_mekansm_effect:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("aura_health_regen")
end
function modifier_item_runic_mekansm_effect:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("aura_bonus_armor")
end
