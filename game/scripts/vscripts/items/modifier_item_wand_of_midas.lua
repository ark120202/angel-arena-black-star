modifier_item_wand_of_midas = class({})

function modifier_item_wand_of_midas:IsHidden()
	return true
end

function modifier_item_wand_of_midas:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
	}
end

function modifier_item_wand_of_midas:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_all")
end

function modifier_item_wand_of_midas:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_all")
end

function modifier_item_wand_of_midas:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_all")
end

if IsServer() then
	function modifier_item_wand_of_midas:OnAbilityExecuted(keys)
		local unit = keys.unit
		local parent = self:GetParent()
		local ability = self:GetAbility()
		if parent:IsAlive() and parent:GetRangeToUnit(unit) <= ability:GetSpecialValueFor("radius") and unit:GetTeamNumber() ~= parent:GetTeamNumber() and keys.ability:ProcsMagicStick() then
			Gold:AddGoldWithMessage(parent, ability:GetSpecialValueFor("gold"))
		end
	end
end