LinkLuaModifier("modifier_item_radiance_lua", "items/item_radiance.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_radiance_lua_effect", "items/item_radiance.lua", LUA_MODIFIER_MOTION_NONE)

item_radiance_baseclass = {
	GetIntrinsicModifierName = function() return "modifier_item_radiance_lua" end,
}

function item_radiance_baseclass:GetAbilityTextureName()
	local disabled = self:GetNetworkableEntityInfo("item_disabled") == 1
	return disabled and "item_arena/" .. string.gsub(self:GetName(), "item_", "") .. "_inactive" or "item_arena/" .. string.gsub(self:GetName(), "item_", "")
end

if IsServer() then
	function item_radiance_baseclass:OnSpellStart()
		self.disabled = not self.disabled
		self:SetNetworkableEntityInfo("item_disabled", self.disabled)
		if not self.disabled then
			self.pfx = ParticleManager:CreateParticle(self.particle_owner, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
		elseif self.pfx then
			ParticleManager:DestroyParticle(self.pfx, false)
			self.pfx = nil
		end
	end
end

item_radiance_arena = class(item_radiance_baseclass)
item_radiance_arena.particle_owner = "particles/items2_fx/radiance_owner.vpcf"
item_radiance_2 = class(item_radiance_baseclass)
item_radiance_2.particle_owner = "particles/items2_fx/radiance_owner.vpcf"
item_radiance_3 = class(item_radiance_baseclass)
item_radiance_3.particle_owner = "particles/econ/events/ti6/radiance_owner_ti6.vpcf"
item_radiance_frozen = class(item_radiance_baseclass)
item_radiance_frozen.particle_owner = "particles/arena/items_fx/radiance_frozen_owner.vpcf"


modifier_item_radiance_lua = class({
	GetAttributes = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,
	IsPurgable    = function() return false end,
	IsHidden      = function() return true end,
})

function modifier_item_radiance_lua:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS
	}
end

function modifier_item_radiance_lua:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_item_radiance_lua:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end

function modifier_item_radiance_lua:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end

function modifier_item_radiance_lua:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end

function modifier_item_radiance_lua:GetModifierHealthBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_health")
end

function modifier_item_radiance_lua:GetModifierManaBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_mana")
end

if IsServer() then
	function modifier_item_radiance_lua:OnDestroy()
		local ability = self:GetAbility()
		if IsValidEntity(ability) and ability.pfx then
			ParticleManager:DestroyParticle(ability.pfx, false)
			ability.pfx = nil
		end
	end
	function modifier_item_radiance_lua:OnCreated()
		local ability = self:GetAbility()
		ability.pfx = ParticleManager:CreateParticle(ability.particle_owner, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		self:StartIntervalThink(0.1)
	end

	function modifier_item_radiance_lua:OnIntervalThink()
		local target = self:GetParent()
		local ability = self:GetAbility()
		if target:IsIllusion() then return end

		if not ability.disabled then
			for _,v in ipairs(FindUnitsInRadius(target:GetTeamNumber(), target:GetAbsOrigin(), nil, ability:GetSpecialValueFor("aura_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)) do
				if not v:IsBoss() then
					local modifier = v:FindModifierByNameAndCaster("modifier_item_radiance_lua_effect", target)
					if not modifier then
						v:AddNewModifier(target, ability, "modifier_item_radiance_lua_effect", {duration = 0.11})
					else
						modifier:SetDuration(0.11, false)
					end
				end
			end
		end
	end
end

modifier_item_radiance_lua_effect = class({
	IsPurgable = function() return false end,
	IsDebuff = function() return true end,
})
function modifier_item_radiance_lua_effect:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_MISS_PERCENTAGE
	}
end
function modifier_item_radiance_lua_effect:GetModifierAttackSpeedBonus_Constant()
	local ability = self:GetAbility()
	return ability:GetSpecialValueFor(ability:GetName() == "item_radiance_frozen" and "cold_attack_speed" or "attack_speed_slow")
end
function modifier_item_radiance_lua_effect:GetModifierMoveSpeedBonus_Percentage()
	local ability = self:GetAbility()
	return ability:GetSpecialValueFor(ability:GetName() == "item_radiance_frozen" and "cold_movement_speed_pct" or "move_speed_slow_pct")
end
function modifier_item_radiance_lua_effect:GetModifierMiss_Percentage()
	local ability = self:GetAbility()
	return ability:GetSpecialValueFor("blind_pct")
end

if IsServer() then
	modifier_item_radiance_lua_effect.interval_think = 0.5
	function modifier_item_radiance_lua_effect:OnCreated()
		self:StartIntervalThink(self.interval_think)
	end

	function modifier_item_radiance_lua_effect:OnIntervalThink()
		ApplyDamage({victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = self:GetAbility():GetSpecialValueFor("aura_damage_per_second") * self.interval_think,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self:GetAbility()
		})
	end
else
	function modifier_item_radiance_lua_effect:GetDuration()
		return -1
	end
end
