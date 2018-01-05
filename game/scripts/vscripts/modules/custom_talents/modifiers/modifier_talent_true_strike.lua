modifier_talent_true_strike = class({
	IsHidden        = function() return true end,
	IsPermanent     = function() return true end,
	IsPurgable      = function() return false end,
	DestroyOnExpire = function() return false end,
})

function modifier_talent_true_strike:CheckState()
	return {
		[MODIFIER_STATE_CANNOT_MISS] = true
	}
end
