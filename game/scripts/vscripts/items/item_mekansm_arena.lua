LinkLuaModifier("modifier_item_mekansm_arena", "items/item_mekansm_arena.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_mekansm_arena_effect", "items/item_mekansm_arena.lua", LUA_MODIFIER_MOTION_NONE)

item_mekansm_baseclass = {
	GetIntrinsicModifierName = function() return "modifier_item_mekansm_arena" end,
}

if IsServer() then
	function item_mekansm_baseclass:OnSpellStart()
		local caster = self:GetCaster()
		caster:EmitSound("DOTA_Item.Mekansm.Activate")
		ParticleManager:CreateParticle(self.pfx, PATTACH_ABSORIGIN_FOLLOW, caster)
		for _,v in ipairs(FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, self:GetSpecialValueFor("radius"), self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)) do
			SafeHeal(v, self:GetSpecialValueFor("heal_amount"), self)
			ParticleManager:CreateParticle(self.recipient_pfx, PATTACH_ABSORIGIN_FOLLOW, v, caster)
			v:EmitSound("DOTA_Item.Mekansm.Target")
		end
	end
end

item_mekansm_arena = class(item_mekansm_baseclass)
item_mekansm_arena.pfx = "particles/items2_fx/mekanism.vpcf"
item_mekansm_arena.recipient_pfx = "particles/items2_fx/mekanism.vpcf"
item_mekansm_2 = class(item_mekansm_baseclass)
item_mekansm_2.pfx = "particles/econ/events/ti6/mekanism_ti6.vpcf"
item_mekansm_2.recipient_pfx = "particles/econ/events/ti6/mekanism_recipient_ti6.vpcf"


modifier_item_mekansm_arena = class({
	IsHidden      = function() return true end,
	GetAttributes = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,
	IsPurgable    = function() return false end,
})

function modifier_item_mekansm_arena:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
	}
end
function modifier_item_mekansm_arena:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end
function modifier_item_mekansm_arena:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end
function modifier_item_mekansm_arena:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end
function modifier_item_mekansm_arena:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_armor")
end
function modifier_item_mekansm_arena:GetModifierHealthBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_health")
end
function modifier_item_mekansm_arena:GetModifierManaBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_mana")
end
function modifier_item_mekansm_arena:GetModifierAura()
	return "modifier_item_mekansm_arena_effect"
end
function modifier_item_mekansm_arena:IsAura()
	return true
end
function modifier_item_mekansm_arena:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor("radius")
end
function modifier_item_mekansm_arena:GetAuraSearchTeam()
	return self:GetAbility():GetAbilityTargetTeam()
end
function modifier_item_mekansm_arena:GetAuraSearchType()
	return self:GetAbility():GetAbilityTargetType()
end
function modifier_item_mekansm_arena:GetAuraSearchFlags()
	return self:GetAbility():GetAbilityTargetFlags()
end

modifier_item_mekansm_arena_effect = class({})
function modifier_item_mekansm_arena_effect:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
end
function modifier_item_mekansm_arena_effect:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("aura_health_regen")
end
function modifier_item_mekansm_arena_effect:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("aura_bonus_armor")
end
