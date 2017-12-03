modifier_arena_rune_haste = class({
	GetEffectAttachType = function() return PATTACH_ABSORIGIN_FOLLOW end,
	IsPurgable          = function() return false end,
	GetTexture          = function() return "rune_haste" end,
	GetEffectName       = function() return "particles/generic_gameplay/rune_haste_owner.vpcf" end,
})

function modifier_arena_rune_haste:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_MAX,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
	}
end

function modifier_arena_rune_haste:GetModifierMoveSpeed_Max()
	return self.max_speed or self:GetSharedKey("max_speed") or 0
end

function modifier_arena_rune_haste:GetModifierMoveSpeed_Limit()
	return self.max_speed or self:GetSharedKey("max_speed") or 0
end

function modifier_arena_rune_haste:GetModifierMoveSpeed_Absolute()
	return self:GetStackCount()
end

if IsServer() then
	function modifier_arena_rune_haste:OnCreated()
		self:StartIntervalThink(0.2)
		self:OnIntervalThink()
	end

	function modifier_arena_rune_haste:OnIntervalThink()
		self.max_speed = self:GetParent():GetMaxMovementSpeed()
		self:SetSharedKey("max_speed", self.max_speed)
	end
end
