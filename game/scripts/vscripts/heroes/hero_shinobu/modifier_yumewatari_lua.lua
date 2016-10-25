modifier_shinobu_yumewatari_lua = class({})

function modifier_shinobu_yumewatari_lua:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
end

function modifier_shinobu_yumewatari_lua:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_shinobu_yumewatari_lua:IsHidden()
    return true
end