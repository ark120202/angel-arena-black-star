modifier_item_battlefury_arena = class({})

function modifier_item_battlefury_arena:IsHidden() return true end
function modifier_item_battlefury_arena:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_battlefury_arena:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_item_battlefury_arena:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_item_battlefury_arena:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_health_regen")
end

function modifier_item_battlefury_arena:GetModifierPercentageManaRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_mana_regen_pct")
end

if IsServer() then
	function modifier_item_battlefury_arena:OnAttackLanded(keys)
		local attacker = keys.attacker
		if attacker == self:GetParent() --[[and not attacker:IsMuted()]] then
			local ability = self:GetAbility()
			local target = keys.target
			if target:IsRealCreep() then
				ApplyDamage({
					attacker = attacker,
					victim = target,
					damage = keys.damage * (ability:GetSpecialValueFor("quelling_bonus_damage_pct") * 0.01 - 1),
					damage_type = DAMAGE_TYPE_PURE,
					damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
					ability = ability
				})
			end
			if not attacker:IsRangedUnit() then
				DoCleaveAttack(attacker, target, ability, keys.damage * ability:GetSpecialValueFor("cleave_damage_percent") * 0.01, ability:GetSpecialValueFor("cleave_distance"), ability:GetSpecialValueFor("cleave_starting_width"), ability:GetSpecialValueFor("cleave_ending_width"), self:GetAbility().cleave_pfx)
			end
		end
	end
end