modifier_item_bottle_arena_heal = class({})

function modifier_item_bottle_arena_heal:GetTexture()
	return "item_bottle_3"
end

function modifier_item_bottle_arena_heal:IsPurgable()
	return false
end

function modifier_item_bottle_arena_heal:GetEffectName()
	return "particles/items_fx/bottle.vpcf"
end

function modifier_item_bottle_arena_heal:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_item_bottle_arena_heal:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT
	}
end

function modifier_item_bottle_arena_heal:GetModifierConstantHealthRegen()
	return self:GetAbility():GetAbilitySpecial("health_restore") / self:GetDuration()
end

function modifier_item_bottle_arena_heal:GetModifierConstantManaRegen()
	return self:GetAbility():GetAbilitySpecial("mana_restore") / self:GetDuration()
end