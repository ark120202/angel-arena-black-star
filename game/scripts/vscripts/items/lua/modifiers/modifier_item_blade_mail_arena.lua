modifier_item_blade_mail_arena = class({})

function modifier_item_blade_mail_arena:IsHidden()
	return true
end

function modifier_item_blade_mail_arena:DeclareFunctions()
	return { 
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
	}
end

function modifier_item_blade_mail_arena:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_item_blade_mail_arena:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_item_blade_mail_arena:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end


modifier_item_blade_mail_arena_active = class({})
function modifier_item_blade_mail_arena_active:GetEffectName()
	return "particles/items_fx/blademail.vpcf"
end
function modifier_item_blade_mail_arena_active:GetEffectAttachType()
	return PATTACH_ABSORIGIN
end
function modifier_item_blade_mail_arena_active:GetStatusEffectName()
	return "particles/status_fx/status_effect_blademail.vpcf"
end
function modifier_item_blade_mail_arena_active:StatusEffectPriority()
	return 10
end
if IsServer() then
	function modifier_item_blade_mail_arena_active:DeclareFunctions()
		return { MODIFIER_EVENT_ON_TAKEDAMAGE }
	end

	function modifier_item_blade_mail_arena_active:OnTakeDamage(keys)
		local unit = self:GetParent()
		local ability = self:GetAbility()
		if unit == keys.unit and SimpleDamageReflect(unit, keys.attacker, keys.original_damage * ability:GetSpecialValueFor("reflected_damage_pct") * 0.01, keys.damage_flags, ability, keys.damage_type) then
			keys.attacker:EmitSound("DOTA_Item.BladeMail.Damage")
		end
	end
end