LinkLuaModifier("modifier_soul_eater_soul_resonance_channel", "heroes/hero_soul_eater/soul_resonance.lua", LUA_MODIFIER_MOTION_NONE)

soul_eater_soul_resonance = class({})

if IsServer() then
	function soul_eater_soul_resonance:CastFilterResult()
		local soul = self:GetCaster()
		return soul:HasModifier("modifier_soul_eater_demon_weapon_from") and UF_SUCCESS or UF_FAIL_CUSTOM
	end

	function soul_eater_soul_resonance:GetCustomCastError()
		local soul = self:GetCaster()
		return soul:HasModifier("modifier_soul_eater_demon_weapon_from") and "" or "arena_hud_error_todo"
	end

	function soul_eater_soul_resonance:OnSpellStart()
		local soul = self:GetCaster()
		soul:AddNewModifier(soul, self, "modifier_soul_eater_soul_resonance_channel", {duration = self:GetSpecialValueFor("channel_time")})
	end

	function soul_eater_soul_resonance:OnChannelFinish(bInterrupted)
		self:GetCaster():RemoveModifierByName("modifier_soul_eater_soul_resonance_channel")
	end
end


modifier_soul_eater_soul_resonance_channel = class({
	IsPurgable = function() return false end,
})
