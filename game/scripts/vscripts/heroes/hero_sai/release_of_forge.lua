LinkLuaModifier("modifier_sai_release_of_forge", "heroes/hero_sai/release_of_forge.lua", LUA_MODIFIER_MOTION_NONE)

sai_release_of_forge = class({})

if IsServer() then
	function sai_release_of_forge:OnSpellStart()
		local caster = self:GetCaster()
		caster:AddNewModifier(caster, self, "modifier_sai_release_of_forge", {duration = self:GetSpecialValueFor("duration")})
	end
end


modifier_sai_release_of_forge = class({
	IsPurgable = function() return false end,
})
-- TODO
