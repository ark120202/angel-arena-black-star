item_blade_mail_baseclass = {
	GetIntrinsicModifierName = function() return "modifier_item_blade_mail_arena" end,
}
LinkLuaModifier("modifier_item_blade_mail_arena", "items/item_blade_mail.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_blade_mail_arena_active", "items/item_blade_mail.lua", LUA_MODIFIER_MOTION_NONE)
if IsServer() then
	function item_blade_mail_baseclass:OnSpellStart()
		local caster = self:GetCaster()
		caster:AddNewModifier(caster, self, "modifier_item_blade_mail_arena_active", {duration = self:GetLevelSpecialValueFor("duration", self:GetLevel() - 1)})
		caster:EmitSound("DOTA_Item.BladeMail.Activate")
	end
end
item_blade_mail_arena = class(item_blade_mail_baseclass)
item_blade_mail_2 = class(item_blade_mail_baseclass)
item_blade_mail_3 = class(item_blade_mail_baseclass)


modifier_item_blade_mail_arena = class({
	IsHidden   = function() return true end,
	IsPurgable = function() return false end,
})

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


modifier_item_blade_mail_arena_active = class({
	GetEffectName = function() return "particles/items_fx/blademail.vpcf" end,
	GetEffectAttachType = function() return PATTACH_ABSORIGIN end,
	GetStatusEffectName = function() return "particles/status_fx/status_effect_blademail.vpcf" end,
	StatusEffectPriority = function() return 10 end,
})
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
