LinkLuaModifier("modifier_weather_sunny_aura", "modules/weather/modifiers/modifier_weather_sunny", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_weather_sunny_aura_normal", "modules/weather/modifiers/modifier_weather_sunny", LUA_MODIFIER_MOTION_NONE)

modifier_weather_sunny = class({
	IsHidden           = function() return true end,
	IsPurgable         = function() return false end,

	IsAura             = function() return true end,
	GetModifierAura    = function() return "modifier_weather_sunny_aura" end,
	GetAuraRadius      = function() return 99999 end,
	GetAuraDuration    = function() return 0.1 end,
	GetAuraSearchTeam  = function() return DOTA_UNIT_TARGET_TEAM_BOTH end,
	GetAuraSearchType  = function() return DOTA_UNIT_TARGET_ALL end,
	GetAuraSearchFlags = function() return DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end,
})


modifier_weather_sunny_aura = class({
	IsPurgable = function() return false end,
	IsHidden   = function() return true end,
})

function modifier_weather_sunny_aura:IsHidden() return true end
if IsServer() then
	function modifier_weather_sunny_aura:OnCreated()
		local modifierName = "modifier_weather_sunny_aura_normal"
		self.modifier = self:GetParent():AddNewModifier(self:GetCaster(), nil, modifierName, nil)
	end

	function modifier_weather_sunny_aura:OnDestroy()
		self.modifier:Destroy()
	end
end


modifier_weather_sunny_aura_normal = class({
	IsPurgable = function() return false end,
	IsDebuff = function() return false end,
	GetTexture = function() return "weather/sunny" end,
})

function modifier_weather_sunny_aura_normal:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_BONUS_VISION_PERCENTAGE
	}
end

function modifier_weather_sunny_aura_normal:GetBonusVisionPercentage()
	return 30
end
