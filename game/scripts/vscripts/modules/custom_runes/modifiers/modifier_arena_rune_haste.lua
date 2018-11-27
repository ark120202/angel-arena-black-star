modifier_arena_rune_haste = class({
	GetEffectAttachType = function() return PATTACH_ABSORIGIN_FOLLOW end,
	IsPurgable          = function() return false end,
	GetTexture          = function() return "rune_haste" end,
	GetEffectName       = function() return "particles/generic_gameplay/rune_haste_owner.vpcf" end,

	DeclareFunctions    = function() return { MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE } end,
	GetModifierMoveSpeed_Absolute = function(self) return self:GetStackCount() end
})
