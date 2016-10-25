modifier_remove_movespeed_cap = class({})

function modifier_remove_movespeed_cap:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_MAX
	}
	return funcs
end

function modifier_remove_movespeed_cap:GetModifierMoveSpeed_Max()
	return 18446744073709551615
end


function modifier_remove_movespeed_cap:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_remove_movespeed_cap:IsHidden()
	return true
end