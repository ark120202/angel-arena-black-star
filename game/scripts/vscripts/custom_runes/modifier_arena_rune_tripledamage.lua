modifier_arena_rune_tripledamage = class({})

function modifier_arena_rune_tripledamage:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE
	}
end

function modifier_arena_rune_tripledamage:GetModifierBaseDamageOutgoing_Percentage()
	return 1 * self:GetStackCount()
end

function modifier_arena_rune_tripledamage:GetEffectName()
	return "particles/arena/generic_gameplay/rune_tripledamage_owner.vpcf"
end

function modifier_arena_rune_tripledamage:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_arena_rune_tripledamage:IsPurgable()
	return false
end

function modifier_arena_rune_tripledamage:GetTexture()
	return "arena/arena_rune_tripledamage"
end