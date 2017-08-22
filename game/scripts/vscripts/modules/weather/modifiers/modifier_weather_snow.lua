LinkLuaModifier("modifier_weather_snow_aura", "modules/weather/modifiers/modifier_weather_snow", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_weather_snow_aura_normal", "modules/weather/modifiers/modifier_weather_snow", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_weather_blizzard_debuff", "modules/weather/modifiers/modifier_weather_snow", LUA_MODIFIER_MOTION_NONE)

modifier_weather_snow = class({
	IsHidden           = function() return true end,
	IsPurgable         = function() return false end,

	IsAura             = function() return true end,
	GetModifierAura    = function() return "modifier_weather_snow_aura" end,
	GetAuraRadius      = function() return 99999 end,
	GetAuraDuration    = function() return 0.1 end,
	GetAuraSearchTeam  = function() return DOTA_UNIT_TARGET_TEAM_BOTH end,
	GetAuraSearchType  = function() return DOTA_UNIT_TARGET_ALL end,
	GetAuraSearchFlags = function() return DOTA_UNIT_TARGET_FLAG_NONE end,
})

if IsServer() then
	function modifier_weather_snow:GetAuraEntityReject(hEntity)
		return hEntity:IsBoss()
	end
end


modifier_weather_snow_aura = class({
	IsPurgable = function() return false end,
	IsHidden   = function() return true end,
})

if IsServer() then
	function modifier_weather_snow_aura:OnCreated()
		local modifierName = "modifier_weather_snow_aura_normal"
		self.modifier = self:GetParent():AddNewModifier(self:GetCaster(), nil, modifierName, nil)
	end

	function modifier_weather_snow_aura:OnDestroy()
		if not self.modifier:IsNull() then self.modifier:Destroy() end
	end
end


modifier_weather_snow_aura_normal = class({
	IsPurgable          = function() return false end,
	IsDebuff            = function() return true end,
	GetTexture          = function() return "weather/snow" end,
	GetStatusEffectName = function() return "particles/status_fx/status_effect_frost_lich.vpcf" end,
})

function modifier_weather_snow_aura_normal:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
end

function modifier_weather_snow_aura_normal:GetModifierMoveSpeedBonus_Percentage()
	return -20
end

function modifier_weather_snow_aura_normal:GetModifierAttackSpeedBonus_Constant()
	return -30
end

modifier_weather_blizzard_debuff = class({
	IsPurgable    = function() return false end,
	IsDebuff      = function() return true end,
	GetTexture    = function() return "weather/blizzard" end,
	GetEffectName = function() return "particles/econ/items/crystal_maiden/ti7_immortal_shoulder/cm_ti7_immortal_frostbite.vpcf" end,
})

function modifier_weather_blizzard_debuff:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_INVISIBLE] = false,
	}
end

function modifier_weather_blizzard_debuff:DeclareFunctions()
	return { MODIFIER_PROPERTY_TOOLTIP }
end

function modifier_weather_blizzard_debuff:OnTooltip()
	return self:GetDuration()
end

