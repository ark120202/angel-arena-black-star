modifier_omniknight_repel_inverse_lua = class({})

function modifier_omniknight_repel_inverse_lua:GetEffectName()
	return "particles/arena/units/heroes/hero_omniknight/omniknight_repel_debuff.vpcf"
end

function modifier_omniknight_repel_inverse_lua:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_omniknight_repel_inverse_lua:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
	}
end

function modifier_omniknight_repel_inverse_lua:GetModifierMagicalResistanceBonus()
	return self:GetAbility():GetSpecialValueFor("magic_resistance_reduction_scepter")
end