LinkLuaModifier("modifier_maka_soul_resonance", "heroes/hero_maka/soul_resonance.lua", LUA_MODIFIER_MOTION_NONE)

maka_soul_resonance = class({})


if IsServer() then
	function maka_soul_resonance:CastFilterResult()
		local soul = self:GetCaster():GetLinkedHeroEntities()[1]
		return soul and soul:HasModifier("modifier_soul_eater_transform_to_scythe") and UF_SUCCESS or UF_FAIL_CUSTOM
	end

	function maka_soul_resonance:GetCustomCastError()
		local soul = self:GetCaster():GetLinkedHeroEntities()[1]
		return soul and soul:HasModifier("modifier_soul_eater_transform_to_scythe") or "arena_hud_error_todo"
	end

	function maka_soul_resonance:OnSpellStart()
		local maka = self:GetCaster()
		local soul = maka:GetLinkedHeroEntities()[1]
		if soul and maka:HasModifier("modifier_soul_eater_transform_to_scythe_buff") and soul:FindModifierByName("modifier_soul_eater_soul_resonance_channel") then
			local duration = self:GetSpecialValueFor("duration")
			maka:AddNewModifier(maka, self, "modifier_maka_soul_resonance", {duration = duration})
			soul:AddNewModifier(maka, self, "modifier_maka_soul_resonance", {duration = duration})
		end
	end

	function maka_soul_resonance:Spawn()
		self:SetLevel(1)
	end
end


modifier_maka_soul_resonance = class({
	IsPurgable       = function() return false end,
	GetEffectName    = function() return "particles/arena/units/heroes/hero_maka/soul_resonance.vpcf" end,
	IsHidden 	   	 = function() return false end,
})

function modifier_maka_soul_resonance:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
	}
end

function modifier_maka_soul_resonance:GetModifierBonusStats_Strength()
	local bonus = self:GetParent():GetBaseStrength() * self:GetAbility():GetSpecialValueFor("bonus_attributes_pct") * 0.01
	return bonus
end

function modifier_maka_soul_resonance:GetModifierBonusStats_Agility()
	local bonus = self:GetParent():GetBaseAgility() * self:GetAbility():GetSpecialValueFor("bonus_attributes_pct") * 0.01
	return bonus
end

function modifier_maka_soul_resonance:GetModifierBonusStats_Intellect()
	local bonus = self:GetParent():GetBaseIntellect() * self:GetAbility():GetSpecialValueFor("bonus_attributes_pct") * 0.01
	return bonus
end

