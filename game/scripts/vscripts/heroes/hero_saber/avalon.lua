saber_avalon = class({})
LinkLuaModifier("modifier_saber_avalon", "heroes/hero_saber/modifier_saber_avalon.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_saber_avalon_invulnerability", "heroes/hero_saber/modifier_saber_avalon.lua", LUA_MODIFIER_MOTION_NONE)
function saber_avalon:GetIntrinsicModifierName()
	return "modifier_saber_avalon"
end
if IsServer() then
	function saber_avalon:OnSpellStart()
		local caster = self:GetCaster()
		caster:AddNewModifier(caster, self, "modifier_saber_avalon_invulnerability", {duration = self:GetSpecialValueFor("duration")})
	end
	function saber_avalon:OnChannelFinish()
		self:GetCaster():RemoveModifierByName("modifier_saber_avalon_invulnerability")
	end
end