modifier_sara_fragment_of_armor = class({})

function modifier_sara_fragment_of_armor:IsHidden()
	return true
end

function modifier_sara_fragment_of_armor:GetEffectName()
	return "particles/arena/units/heroes/hero_sara/fragment_of_armor.vpcf"
end

function modifier_sara_fragment_of_armor:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end