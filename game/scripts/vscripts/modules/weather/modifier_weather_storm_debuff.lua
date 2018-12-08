modifier_weather_storm_debuff = class({
	IsPurgable = function() return false end,
	IsDebuff = function() return true end,
	GetTexture = function() return "weather/storm" end,
	GetEffectName = function() return "particles/generic_gameplay/generic_stunned.vpcf" end,
	GetEffectAttachType = function() return PATTACH_OVERHEAD_FOLLOW end,
	CheckState = function() return { [MODIFIER_STATE_STUNNED] = true } end,
})

if IsServer() then
	function modifier_weather_storm_debuff:OnCreated()
		ParticleManager:CreateParticle(
			"particles/econ/items/antimage/antimage_weapon_basher_ti5_gold/am_basher_manaburn_impact_lightning_gold.vpcf",
			PATTACH_ABSORIGIN_FOLLOW,
			self:GetParent()
		)
	end
end
