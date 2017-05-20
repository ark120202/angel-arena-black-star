modifier_arena_rune_arcane = class({})

function modifier_arena_rune_arcane:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		--MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE
	}
end

function modifier_arena_rune_arcane:GetModifierPercentageCooldown()
	return 30
end

function modifier_arena_rune_arcane:IsPurgable()
	return false
end

function modifier_arena_rune_arcane:GetTexture()
	return "rune_arcane"
end

function modifier_arena_rune_arcane:GetEffectName()
	return "particles/generic_gameplay/rune_arcane_owner.vpcf"
end

function modifier_arena_rune_arcane:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end