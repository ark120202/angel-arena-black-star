LinkLuaModifier("modifier_weather_snow_aura_effect", "modules/weather/modifiers/modifier_weather_snow", LUA_MODIFIER_MOTION_NONE)

modifier_weather_snow = class({
	IsHidden           = function() return true end,
	IsPurgable         = function() return false end,

	IsAura             = function() return true end,
	GetModifierAura    = function() return "modifier_weather_snow_aura_effect" end,
	GetAuraRadius      = function() return 99999 end,
	GetAuraDuration    = function() return 0.1 end,
	GetAuraSearchTeam  = function() return DOTA_UNIT_TARGET_TEAM_BOTH end,
	GetAuraSearchType  = function() return DOTA_UNIT_TARGET_ALL end,
	GetAuraSearchFlags = function() return DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end,
})

modifier_weather_snow_aura_effect = class({
	IsPurgable          = function() return false end,
	GetStatusEffectName = function() return "particles/status_fx/status_effect_frost_lich.vpcf" end,
})
--particles/econ/items/crystal_maiden/ti7_immortal_shoulder/cm_ti7_immortal_frostbite.vpcf
