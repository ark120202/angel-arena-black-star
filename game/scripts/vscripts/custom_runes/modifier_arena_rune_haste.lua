modifier_arena_rune_haste = class({})

function modifier_arena_rune_haste:DeclareFunctions() 
	return {
		MODIFIER_PROPERTY_MOVESPEED_MAX,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
	}
end

function modifier_arena_rune_haste:GetModifierMoveSpeed_Max()
	return 1 * self:GetStackCount()
end
function modifier_arena_rune_haste:GetModifierMoveSpeed_Limit()
	return 1 * self:GetStackCount()
end
function modifier_arena_rune_haste:GetModifierMoveSpeed_Absolute()
	return 1 * self:GetStackCount()
end

function modifier_arena_rune_haste:GetEffectName()
	return "particles/generic_gameplay/rune_haste_owner.vpcf"
end

function modifier_arena_rune_haste:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_arena_rune_haste:IsPurgable()
	return false
end

function modifier_arena_rune_haste:GetTexture()
	return "rune_haste"
end