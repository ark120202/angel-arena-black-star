sara_fragment_of_logic = class({})
LinkLuaModifier("modifier_sara_fragment_of_logic", "heroes/hero_sara/modifier_sara_fragment_of_logic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sara_fragment_of_logic_debuff", "heroes/hero_sara/modifier_sara_fragment_of_logic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sara_fragment_of_logic_buff_scepter", "heroes/hero_sara/modifier_sara_fragment_of_logic.lua", LUA_MODIFIER_MOTION_NONE)
function sara_fragment_of_logic:GetIntrinsicModifierName()
	return "modifier_sara_fragment_of_logic"
end

function sara_fragment_of_logic:GetBehavior()
	return self:GetCaster():HasScepter() and DOTA_ABILITY_BEHAVIOR_NO_TARGET or DOTA_ABILITY_BEHAVIOR_PASSIVE
end

if IsServer() then
	function sara_fragment_of_logic:OnSpellStart()
		local caster = self:GetCaster()
		local energy = caster:GetIntellect() * self:GetSpecialValueFor("int_to_energy_mult_scepter")
		local duration = self:GetSpecialValueFor("duration_scepter")
		caster:AddNewModifier(caster, self, "modifier_sara_fragment_of_logic_buff_scepter", {duration = duration}):SetStackCount(energy)
		caster:ModifyMaxEnergy(energy)
		Timers:CreateTimer(duration, function()
			if IsValidEntity(caster) then
				caster:ModifyMaxEnergy(-energy)
			end
		end)
	end
else
	function sara_fragment_of_logic:GetManaCost()
		return self:GetSpecialValueFor("energy_const") + self:GetCaster():GetMaxMana() * self:GetSpecialValueFor("energy_pct") * 0.01
	end
end