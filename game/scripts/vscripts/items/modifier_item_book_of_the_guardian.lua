modifier_item_book_of_the_guardian = class({})

function modifier_item_book_of_the_guardian:IsHidden()
	return true
end
function modifier_item_book_of_the_guardian:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_book_of_the_guardian:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
		MODIFIER_PROPERTY_MANA_REGEN_PERCENTAGE
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE
	}
end

function modifier_item_book_of_the_guardian:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end

function modifier_item_book_of_the_guardian:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_health_regen")
end

function modifier_item_book_of_the_guardian:GetModifierPercentageManaRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end

function modifier_item_book_of_the_guardian:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_item_book_of_the_guardian:GetModifierSpellAmplify_Percentage()
	return self:GetAbility():GetSpecialValueFor("spell_amp_pct")
end

function modifier_item_book_of_the_guardian:GetModifierAura()
	return "modifier_item_book_of_the_guardian_effect"
end
function modifier_item_book_of_the_guardian:IsAura()
	return true
end
function modifier_item_book_of_the_guardian:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor("aura_radius")
end
function modifier_item_book_of_the_guardian:GetAuraDuration()
	return 0.5
end
function modifier_item_book_of_the_guardian:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end
function modifier_item_book_of_the_guardian:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

modifier_item_book_of_the_guardian_effect = class({})
function modifier_item_book_of_the_guardian_effect:IsPurgable()
	return false
end
function modifier_item_book_of_the_guardian_effect:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
end
function modifier_item_book_of_the_guardian_effect:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("aura_attack_speed")
end`

modifier_item_book_of_the_guardian_blast = class({})
function modifier_item_book_of_the_guardian_blast:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end
function modifier_item_book_of_the_guardian_blast:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("blast_movement_speed_pct")
end`