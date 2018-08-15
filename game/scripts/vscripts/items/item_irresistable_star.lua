LinkLuaModifier("modifier_item_irresistable_star", "items/item_irresistable_star.lua", LUA_MODIFIER_MOTION_NONE)

item_irresistable_star = class ({
	GetIntrinsicModifierName = function() return "modifier_item_irresistable_star" end
})

modifier_item_irresistable_star = class({
	GetAttributes = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,
	IsHidden = function() return true end,
	IsPurgable = function() return false end,
})

function modifier_item_irresistable_star:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_CAST_RANGE_BONUS,
	}
end

function modifier_item_irresistable_star:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end

function modifier_item_irresistable_star:GetModifierSpellAmplify_Percentage()
	return self:GetAbility():GetSpecialValueFor("spell_amp_pct")
end

function modifier_item_irresistable_star:GetModifierManaBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_mana")
end

function modifier_item_irresistable_star:GetModifierCastRangeBonus()
	return self:GetAbility():GetSpecialValueFor("cast_range_bonus")
end

function modifier_item_irresistable_star:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_health_regen")
end

function modifier_item_irresistable_star:GetModifierConstantManaRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end

if IsServer() then
	function modifier_item_irresistable_star:OnTakeDamage(keys)
		local parent = self:GetParent()
		local damage = keys.original_damage
		local ability = self:GetAbility()
		if keys.attacker == parent and not keys.unit:IsMagicImmune() and keys.damage_type == 2 then
			ApplyDamage({
				attacker = parent,
				victim = keys.unit,
				damage = keys.original_damage * ability:GetSpecialValueFor("magic_damage_to_pure_pct") * 0.01,
				damage_type = DAMAGE_TYPE_PURE,
				damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
				ability = ability
			})
		end
	end
end
