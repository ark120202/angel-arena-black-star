modifier_talent_true_strike = class({})
function modifier_talent_true_strike:IsHidden() return true end
function modifier_talent_true_strike:IsPermanent() return true end
function modifier_talent_true_strike:IsPurgable() return false end
function modifier_talent_true_strike:DestroyOnExpire() return false end

function modifier_talent_true_strike:CheckState() 
	return {
		[MODIFIER_STATE_CANNOT_MISS] = true
	}
end