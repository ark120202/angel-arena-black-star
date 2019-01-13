item_skadi_baseclass = {}
LinkLuaModifier("modifier_item_skadi_arena", "items/item_skadi.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_skadi_arena_cold_attack", "items/item_skadi.lua", LUA_MODIFIER_MOTION_NONE)


function item_skadi_baseclass:GetIntrinsicModifierName()
	return "modifier_item_skadi_arena"
end

item_skadi_arena = class(item_skadi_baseclass)
item_skadi_2 = class(item_skadi_baseclass)
item_skadi_4 = class(item_skadi_baseclass)
item_skadi_8 = class(item_skadi_baseclass)


modifier_item_skadi_arena = class({
	IsHidden      = function() return true end,
	GetAttributes = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,
	IsPurgable    = function() return false end,
})

function modifier_item_skadi_arena:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_item_skadi_arena:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end

function modifier_item_skadi_arena:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end

function modifier_item_skadi_arena:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end

function modifier_item_skadi_arena:GetModifierHealthBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_health")
end

function modifier_item_skadi_arena:GetModifierManaBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_mana")
end

if IsServer() then
	function modifier_item_skadi_arena:OnCreated()
		self:GetParent():UpdateAttackProjectile()
	end

	function modifier_item_skadi_arena:OnDestroy()
		self:GetParent():UpdateAttackProjectile()
	end

	function modifier_item_skadi_arena:OnAttackLanded(keys)
		local target = keys.target
		local attacker = keys.attacker
		if attacker == self:GetParent() and not attacker:IsIllusion() then
			local ability = self:GetAbility()
			if not (target.IsBoss and target:IsBoss()) then
				target:AddNewModifier(attacker, ability, "modifier_item_skadi_arena_cold_attack", {duration = ability:GetSpecialValueFor("cold_duration")})
			end
		end
	end
end

modifier_item_skadi_arena_cold_attack = class({
	IsDebuff =            function() return true end,
	GetStatusEffectName = function() return "particles/status_fx/status_effect_frost_lich.vpcf" end,
})

function modifier_item_skadi_arena_cold_attack:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_item_skadi_arena_cold_attack:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("cold_attack_speed")
end

function modifier_item_skadi_arena_cold_attack:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("cold_movement_speed_pct")
end
