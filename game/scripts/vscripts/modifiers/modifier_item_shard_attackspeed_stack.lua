modifier_item_shard_attackspeed_stack = class({
	IsHidden =      function() return true end,
	IsPurgable =    function() return false end,
	IsBuff =        function() return true end,
	RemoveOnDeath = function() return false end,
	GetAttributes = function() return MODIFIER_ATTRIBUTE_PERMANENT end,
	GetTexture =    function() return "arena/shard_attackspeed" end,
})

function modifier_item_shard_attackspeed_stack:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
end

function modifier_item_shard_attackspeed_stack:GetModifierAttackSpeedBonus_Constant()
	return 55 * self:GetStackCount()
end
