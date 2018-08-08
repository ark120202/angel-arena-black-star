LinkLuaModifier("modifier_maka_grigori", "heroes/hero_maka/grigori.lua", LUA_MODIFIER_MOTION_NONE)

maka_grigori = class({})

modifier_maka_grigori = class({
	IsHidden   = function() return false end,
	IsPurgable = function() return false end,
})

if IsServer() then
	function maka_grigori:OnSpellStart()
		local caster = self:GetCaster()
		local duration = self:GetSpecialValueFor("duration")
		caster:AddNewModifier(caster, self, "modifier_maka_grigori", {duration = duration})
	end
end

function modifier_maka_grigori:CheckState()
	return {
		[MODIFIER_STATE_FLYING] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}
end

function modifier_maka_grigori:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_MAX,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE
	}
end

function modifier_maka_grigori:GetModifierMoveSpeed_Limit()
	local parent = self:GetParent()
	if parent:HasModifier("modifier_maka_soul_resonance") then
		return self:GetAbility():GetSpecialValueFor("speed")
	end
end

function modifier_maka_grigori:GetModifierMoveSpeed_Max()
	local parent = self:GetParent()
	if parent:HasModifier("modifier_maka_soul_resonance") then
		return self:GetAbility():GetSpecialValueFor("speed")
	end
end

function modifier_maka_grigori:GetModifierMoveSpeed_Absolute()
	local parent = self:GetParent()
	if parent:HasModifier("modifier_maka_soul_resonance") then
		return self:GetAbility():GetSpecialValueFor("speed")
	end
end
