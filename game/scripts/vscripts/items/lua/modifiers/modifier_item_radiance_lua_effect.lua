modifier_item_radiance_lua_effect = class({})
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
function modifier_item_radiance_lua_effect:IsPurgable()
	return false
end
function modifier_item_radiance_lua_effect:IsDebuff()
	return true
end

if IsServer() then
	modifier_item_radiance_lua_effect.interval_think = 0.1
	function modifier_item_radiance_lua_effect:OnCreated()
		self:StartIntervalThink(self.interval_think)
	end

	function modifier_item_radiance_lua_effect:OnIntervalThink()
		ApplyDamage({victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = self:GetAbility():GetSpecialValueFor("aura_damage_per_second") * self.interval_think,
			damage_type = DAMAGE_TYPE_MAGICAL,
			damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
			ability = ability})
	end
else
	function modifier_item_radiance_lua_effect:GetDuration()
		return -1
	end
end