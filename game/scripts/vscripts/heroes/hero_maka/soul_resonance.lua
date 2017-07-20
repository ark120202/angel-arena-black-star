LinkLuaModifier("modifier_maka_soul_resonance", "heroes/hero_maka/soul_resonance.lua", LUA_MODIFIER_MOTION_NONE)

maka_soul_resonance = class({})

if IsServer() then
	function maka_soul_resonance:CastFilterResult()
		local soul = self:GetCaster():GetLinkedHeroEntities()[1]
		return soul:HasModifier("modifier_soul_eater_demon_weapon_from") and UF_SUCCESS or UF_FAIL_CUSTOM
	end

	function maka_soul_resonance:GetCustomCastError()
		local soul = self:GetCaster():GetLinkedHeroEntities()[1]
		return soul:HasModifier("modifier_soul_eater_demon_weapon_from") and "" or "arena_hud_error_todo"
	end

	function maka_soul_resonance:OnSpellStart()
		local maka = self:GetCaster()
		local soul = maka:GetLinkedHeroEntities()[1]
		if soul:HasModifier("modifier_soul_eater_soul_resonance_channel") then
			local duration = self:GetSpecialValueFor("duration")
			maka:AddNewModifier(maka, self, "modifier_maka_soul_resonance", {duration = duration})
			soul:AddNewModifier(maka, self, "modifier_maka_soul_resonance", {duration = duration})
		end
	end
end


modifier_maka_soul_resonance = class({
	IsPurgable     = function() return false end,
	GetEffectName  = function() return "particles/arena/units/heroes/hero_maka/soul_resonance.vpcf" end,
})
