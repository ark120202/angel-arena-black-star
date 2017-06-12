local FOUNTAIN_EFFECTIVE_TIME_THRESHOLD = 2700

modifier_fountain_aura_enemy = class({
	IsDebuff =   function() return true end,
	IsPurgable = function() return false end,
	GetTexture = function() return "fountain_heal" end,
})

function modifier_fountain_aura_enemy:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE
	}
end

-- Each 5m = -5%
function modifier_fountain_aura_enemy:GetModifierDamageOutgoing_Percentage()
	local timeLast = GameRules:GetDOTATime(false, true) - FOUNTAIN_EFFECTIVE_TIME_THRESHOLD
	local b = math.floor(timeLast / 300) * 5
	return -math.max(50 - b)
end
