modifier_arena_courier = class({})

function modifier_arena_courier:IsHidden()
	return true
end

function modifier_arena_courier:IsPurgable()
	return false
end

function modifier_arena_courier:CheckState() 
	return {
		[MODIFIER_STATE_INVULNERABLE] = true
	}
end

function modifier_arena_courier:DeclareFunctions() 
	return {
		MODIFIER_PROPERTY_MOVESPEED_MAX,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
	}
end

function modifier_arena_courier:GetModifierMoveSpeed_Max()
	return 800
end
function modifier_arena_courier:GetModifierMoveSpeed_Limit()
	return 800
end
function modifier_arena_courier:GetModifierMoveSpeed_Absolute()
	return 800
end