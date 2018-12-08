modifier_weather_blizzard_debuff = class({
	IsPurgable = function() return false end,
	IsDebuff = function() return true end,
	GetTexture = function() return "weather/blizzard" end,
	GetEffectName = function() return "particles/econ/items/crystal_maiden/ti7_immortal_shoulder/cm_ti7_immortal_frostbite.vpcf" end,

	DeclareFunctions = function() return { MODIFIER_PROPERTY_TOOLTIP } end,
	OnTooltip = function(self) self:GetDuration() end,
})

function modifier_weather_blizzard_debuff:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_INVISIBLE] = false,
	}
end
