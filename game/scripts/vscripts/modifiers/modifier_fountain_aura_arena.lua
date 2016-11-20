modifier_fountain_aura_arena = class({})
local FOUNTAIN_PERCENTAGE_MANA_REGEN = 20
local FOUNTAIN_PERCENTAGE_HEALTH_REGEN = 20

function modifier_fountain_aura_arena:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
		MODIFIER_PROPERTY_MIN_HEALTH,
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
		MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE,
	}
end

function modifier_fountain_aura_arena:GetAbsoluteNoDamageMagical()
	return 1
end

function modifier_fountain_aura_arena:GetAbsoluteNoDamagePhysical()
	return 1
end

function modifier_fountain_aura_arena:GetAbsoluteNoDamagePure()
	return 1
end

function modifier_fountain_aura_arena:GetMinHealth()
	return 1
end

function modifier_fountain_aura_arena:GetModifierHealthRegenPercentage()
	return FOUNTAIN_PERCENTAGE_MANA_REGEN
end

function modifier_fountain_aura_arena:GetModifierTotalPercentageManaRegen()
	return FOUNTAIN_PERCENTAGE_HEALTH_REGEN
end

function modifier_fountain_aura_arena:IsPurgable()
	return false
end

function modifier_fountain_aura_arena:IsHidden()
	return true
end

if IsServer() then
	function modifier_fountain_aura_arena:OnCreated()
		self:GetParent():AddNewModifier(self:GetCaster(), nil, "modifier_fountain_aura_buff", nil)
	end

	function modifier_fountain_aura_arena:OnDestroy()
		self:GetParent():RemoveModifierByName("modifier_fountain_aura_buff")
	end
end