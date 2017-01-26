saber_avalon = class({})

function saber_avalon:GetIntrinsicModifierName()
	return "modifier_saber_avalon"
end
if IsServer() then
	function saber_avalon:OnSpellStart()
		local caster = self:GetCaster()
		caster:AddNewModifier(caster, self, "modifier_saber_avalon_invulnerability", {duration = self:GetSpecialValueFor("duration")})
	end
end