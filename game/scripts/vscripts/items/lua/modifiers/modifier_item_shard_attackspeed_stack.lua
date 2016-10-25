modifier_item_shard_attackspeed_stack = class({})

function modifier_item_shard_attackspeed_stack:GetTexture()
	return "item_shard_attackspeed"
end

function modifier_item_shard_attackspeed_stack:IsHidden()
	return true
end

function modifier_item_shard_attackspeed_stack:IsPurgable()
	return false
end

function modifier_item_shard_attackspeed_stack:IsBuff()
	return true
end

function modifier_item_shard_attackspeed_stack:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_item_shard_attackspeed_stack:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
    return funcs
end

function modifier_item_shard_attackspeed_stack:GetModifierAttackSpeedBonus_Constant()
    return 50 * self:GetStackCount()
end

function modifier_item_shard_attackspeed_stack:RemoveOnDeath()
	return false
end