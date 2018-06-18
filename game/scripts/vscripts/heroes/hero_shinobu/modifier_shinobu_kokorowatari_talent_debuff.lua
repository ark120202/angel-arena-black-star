modifier_shinobu_kokorowatari_talent_debuff = class ({
	IsHidden   = function() return false end,
	IsPurgable = function() return false end,
})

function modifier_shinobu_kokorowatari_talent_debuff:DeclareFunctions()
	return { 
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_HEALTH_BONUS,
	}
end

function modifier_shinobu_kokorowatari_talent_debuff:GetModifierTotalDamageOutgoing_Percentage()
	return -self:GetCaster():GetTalentSpecial("talent_hero_shinobu_kokorowatari", "decrease_pct")
end

function modifier_shinobu_kokorowatari_talent_debuff:GetModifierHealthBonus()
	return -self:GetParent():GetMaxHealth() * self:GetCaster():GetTalentSpecial("talent_hero_shinobu_kokorowatari", "decrease_pct") * 0.01
end
