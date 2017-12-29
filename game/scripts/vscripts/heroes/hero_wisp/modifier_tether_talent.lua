modifier_wisp_tether_aghanim_buff = class ({
	IsHidden   = function() return false end,
	IsPurgable = function() return false end,
	GetTexture = function () return "talents/heroes/wisp_aghanim" end,
})

function modifier_wisp_tether_aghanim_buff:DeclareFunctions()
	return { 
		MODIFIER_PROPERTY_IS_SCEPTER
	}
end

function modifier_wisp_tether_aghanim_buff:GetModifierScepter()
	return 1
end