LinkLuaModifier("modifier_weather_rain_aura", "modules/weather/modifiers/modifier_weather_rain", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_weather_rain_aura_normal", "modules/weather/modifiers/modifier_weather_rain", LUA_MODIFIER_MOTION_NONE)

modifier_weather_rain = class({
	IsHidden           = function() return true end,
	IsPurgable         = function() return false end,

	IsAura             = function() return true end,
	GetModifierAura    = function() return "modifier_weather_rain_aura" end,
	GetAuraRadius      = function() return 99999 end,
	GetAuraDuration    = function() return 0.1 end,
	GetAuraSearchTeam  = function() return DOTA_UNIT_TARGET_TEAM_BOTH end,
	GetAuraSearchType  = function() return DOTA_UNIT_TARGET_ALL end,
	GetAuraSearchFlags = function() return DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end,
})


modifier_weather_rain_aura = class({
	IsPurgable = function() return false end,
	IsHidden   = function() return true end,
})

if IsServer() then
	function modifier_weather_rain_aura:OnCreated()
		local modifierName = "modifier_weather_rain_aura_normal"
		self.modifier = self:GetParent():AddNewModifier(self:GetCaster(), nil, modifierName, nil)
	end

	function modifier_weather_rain_aura:OnDestroy()
		if not self.modifier:IsNull() then self.modifier:Destroy() end
	end
end


modifier_weather_rain_aura_normal = class({
	IsPurgable = function() return false end,
	IsDebuff   = function() return true end,
	GetTexture = function() return "weather/rain" end,
})

function modifier_weather_rain_aura_normal:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_BONUS_VISION_PERCENTAGE
	}
end

function modifier_weather_rain_aura_normal:GetBonusVisionPercentage()
	return -25
end

if IsServer() then
	function modifier_weather_rain_aura_normal:OnCreated()
		local parent = self:GetParent()
		local pfx = ParticleManager:CreateParticle(parent:IsConsideredHero() and "particles/generic_gameplay/rain_effects_hero.vpcf" or "particles/generic_gameplay/rain_effects_creep.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
		self:AddParticle(pfx, false, false, 10, false, false)
	end
end
