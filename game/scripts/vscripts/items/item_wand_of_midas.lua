LinkLuaModifier("modifier_item_wand_of_midas", "items/item_wand_of_midas.lua", LUA_MODIFIER_MOTION_NONE)

item_wand_of_midas = class({
	GetIntrinsicModifierName = function() return "modifier_item_wand_of_midas" end,
})

if IsServer() then
	function item_wand_of_midas:CastFilterResult()
		return self:GetCurrentCharges() == 0 and UF_FAIL_CUSTOM or UF_SUCCESS
	end

	function item_wand_of_midas:GetCustomCastError()
		return self:GetCurrentCharges() == 0 and "#dota_hud_error_no_charges" or ""
	end

	function item_wand_of_midas:OnSpellStart()
		local caster = self:GetCaster()
		local charges = self:GetCurrentCharges()
		local restore = charges * self:GetSpecialValueFor("restore_per_charge")

		Gold:AddGoldWithMessage(caster, charges * self:GetSpecialValueFor("gold"))
		SafeHeal(caster, restore, self, true)
		caster:GiveMana(restore)

		ParticleManager:SetParticleControl(ParticleManager:CreateParticle("particles/arena/items_fx/wand_of_midas.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster), 1, Vector(charges))
		caster:EmitSound("DOTA_Item.MagicWand.Activate")
		self:SetCurrentCharges(0)
	end
end


modifier_item_wand_of_midas = class({
	GetAttributes = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,
	IsHidden      = function() return true end,
	IsPurgable    = function() return false end,
})

function modifier_item_wand_of_midas:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
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
		if parent:IsAlive() and
			parent:GetRangeToUnit(unit) <= ability:GetSpecialValueFor("radius") and
			unit:GetTeamNumber() ~= parent:GetTeamNumber() and
			keys.ability:ProcsMagicStick() then

			local maxCharges = ability:GetSpecialValueFor("max_charges")
			for i = DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
				local itemInSlot = parent:GetItemInSlot(i)
				if itemInSlot and itemInSlot:GetAbilityName() == "item_wand_of_midas" then
					local charges = itemInSlot:GetCurrentCharges()
					if charges < maxCharges then
						if itemInSlot == ability then
							ability:SetCurrentCharges(charges + 1)
						end
						break
					end
				end
			end
		end
	end
end
