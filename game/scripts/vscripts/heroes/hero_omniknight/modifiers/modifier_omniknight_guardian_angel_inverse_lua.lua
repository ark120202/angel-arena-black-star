modifier_omniknight_guardian_angel_inverse_lua = class({})

function modifier_omniknight_guardian_angel_inverse_lua:GetEffectName()
	return "particles/arena/units/heroes/hero_omniknight/omniknight_guardian_angel_inverse_ally.vpcf"
end

function modifier_omniknight_guardian_angel_inverse_lua:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_omniknight_guardian_angel_inverse_lua:GetStatusEffectName()
	return "particles/status_fx/status_effect_guardian_angel.vpcf"
end

function modifier_omniknight_guardian_angel_inverse_lua:StatusEffectPriority()
	return 10
end


function modifier_omniknight_guardian_angel_inverse_lua:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
end

function modifier_omniknight_guardian_angel_inverse_lua:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("armor_debuff_scepter")
end