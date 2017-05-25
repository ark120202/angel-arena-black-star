modifier_fountain_aura_arena = class({})
function modifier_fountain_aura_arena:IsPurgable() return false end
function modifier_fountain_aura_arena:IsHidden() return true end

local FOUNTAIN_PERCENTAGE_MANA_REGEN = 20
local FOUNTAIN_PERCENTAGE_HEALTH_REGEN = 20

function modifier_fountain_aura_arena:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MIN_HEALTH,
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
		MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE,
	}
end

function modifier_fountain_aura_arena:GetModifierHealthRegenPercentage()
	return FOUNTAIN_PERCENTAGE_MANA_REGEN
end

function modifier_fountain_aura_arena:GetModifierTotalPercentageManaRegen()
	return FOUNTAIN_PERCENTAGE_HEALTH_REGEN
end


if IsServer() then
	function modifier_fountain_aura_arena:OnCreated()
		self:GetParent():AddNewModifier(self:GetCaster(), nil, "modifier_fountain_aura_buff", nil)
		self:StartIntervalThink(0.25)
	end

	function modifier_fountain_aura_arena:OnDestroy()
		self:GetParent():RemoveModifierByName("modifier_fountain_aura_buff")
	end

	function modifier_fountain_aura_arena:OnIntervalThink()
		local parent = self:GetParent()
		while parent:HasModifier("modifier_saber_mana_burst_active") do
			parent:RemoveModifierByName("modifier_saber_mana_burst_active")
		end
		for i = 0, 11 do
			local item = parent:GetItemInSlot(i)
			if item and item:GetAbilityName() == "item_bottle_arena" then
				item:SetCurrentCharges(3)
			end
		end
	end
end
