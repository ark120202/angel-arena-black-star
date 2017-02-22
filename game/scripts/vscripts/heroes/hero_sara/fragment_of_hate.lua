sara_fragment_of_hate = class({})
LinkLuaModifier("modifier_sara_fragment_of_hate", "heroes/hero_sara/modifier_sara_fragment_of_hate.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sara_fragment_of_hate_buff_scepter", "heroes/hero_sara/modifier_sara_fragment_of_hate.lua", LUA_MODIFIER_MOTION_NONE)

function sara_fragment_of_hate:GetIntrinsicModifierName()
	return "modifier_sara_fragment_of_hate"
end

function sara_fragment_of_hate:GetBehavior()
	return self:GetCaster():HasScepter() and DOTA_ABILITY_BEHAVIOR_NO_TARGET or DOTA_ABILITY_BEHAVIOR_PASSIVE
end

if IsServer() then
	function sara_fragment_of_hate:OnSpellStart()
		local caster = self:GetCaster()
		caster:AddNewModifier(caster, self, "modifier_sara_fragment_of_hate_buff_scepter", {duration = self:GetSpecialValueFor("buff_duration_scepter")})
		
	end
end