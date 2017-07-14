LinkLuaModifier("modifier_item_guardian_greaves_arena", "items/item_guardian_greaves_arena.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_guardian_greaves_arena_effect", "items/item_guardian_greaves_arena.lua", LUA_MODIFIER_MOTION_NONE)

item_guardian_greaves_arena = class({
	GetIntrinsicModifierName = function() return "modifier_item_guardian_greaves_arena" end,
})

if IsServer() then
	function item_guardian_greaves_arena:OnSpellStart()
		local caster = self:GetCaster()
		caster:EmitSound("Item.GuardianGreaves.Activate")
		ParticleManager:CreateParticle("particles/items3_fx/warmage.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		for _,v in ipairs(FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, self:GetSpecialValueFor("radius"), self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)) do
			SafeHeal(v, self:GetSpecialValueFor("replenish_health"), self)
			v:GiveMana(self:GetSpecialValueFor("replenish_mana"))
			ParticleManager:CreateParticle("particles/items3_fx/warmage_recipient.vpcf", PATTACH_ABSORIGIN_FOLLOW, v, caster)
			v:EmitSound("Item.GuardianGreaves.Target")
			v:Purge(false, true, false, true, false)
		end
	end
end

modifier_item_guardian_greaves_arena = class({
	IsHidden      = function() return true end,
	GetAttributes = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,
	IsPurgable    = function() return false end,
})

function modifier_item_guardian_greaves_arena:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE
	}
end
function modifier_item_guardian_greaves_arena:GetModifierHealthBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_health")
end
function modifier_item_guardian_greaves_arena:GetModifierManaBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_mana")
end
function modifier_item_guardian_greaves_arena:GetModifierMoveSpeedBonus_Special_Boots()
	return self:GetAbility():GetSpecialValueFor("bonus_movement")
end
function modifier_item_guardian_greaves_arena:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end
function modifier_item_guardian_greaves_arena:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end
function modifier_item_guardian_greaves_arena:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end
function modifier_item_guardian_greaves_arena:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_armor")
end
function modifier_item_guardian_greaves_arena:GetModifierAura()
	return "modifier_item_guardian_greaves_arena_effect"
end
function modifier_item_guardian_greaves_arena:IsAura()
	return true
end
function modifier_item_guardian_greaves_arena:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor("radius")
end
function modifier_item_guardian_greaves_arena:GetAuraSearchTeam()
	return self:GetAbility():GetAbilityTargetTeam()
end
function modifier_item_guardian_greaves_arena:GetAuraSearchType()
	return self:GetAbility():GetAbilityTargetType()
end
function modifier_item_guardian_greaves_arena:GetAuraSearchFlags()
	return self:GetAbility():GetAbilityTargetFlags()
end

modifier_item_guardian_greaves_arena_effect = class({})
function modifier_item_guardian_greaves_arena_effect:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
end
function modifier_item_guardian_greaves_arena_effect:GetModifierConstantHealthRegen()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	if ability then
		return ability:GetSpecialValueFor(parent:GetHealth() / parent:GetMaxHealth() > ability:GetSpecialValueFor("aura_bonus_threshold_pct") * 0.01 and "aura_health_regen" or "aura_health_regen_bonus")
	end
end
function modifier_item_guardian_greaves_arena_effect:GetModifierPhysicalArmorBonus()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	if ability then
		local s = parent:GetHealthPercent() >= ability:GetSpecialValueFor("aura_bonus_threshold_pct") and "aura_armor" or "aura_armor_bonus"
		return ability:GetSpecialValueFor(s)
	end
end
