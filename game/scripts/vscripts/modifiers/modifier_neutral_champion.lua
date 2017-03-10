modifier_neutral_champion = class({})

function modifier_neutral_champion:IsPurgable()
	return false
end

function modifier_neutral_champion:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP}
end

function modifier_neutral_champion:OnTooltip()
	return self:GetStackCount()
end

function modifier_neutral_champion:GetTexture()
	return "granite_golem_bash"
end