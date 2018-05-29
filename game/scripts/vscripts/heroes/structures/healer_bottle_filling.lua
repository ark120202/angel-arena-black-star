LinkLuaModifier("modifier_healer_bottle_filling", "heroes/structures/healer_bottle_filling.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_healer_bottle_filling_effect", "heroes/structures/healer_bottle_filling.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_healer_bottle_filling_delay", "heroes/structures/healer_bottle_filling.lua", LUA_MODIFIER_MOTION_NONE)
healer_bottle_filling = class({
	GetIntrinsicModifierName = function() return "modifier_healer_bottle_filling" end,
})

modifier_healer_bottle_filling = class({
	IsPurgable = function() return false end,
	IsHidden = function() return true end,
})

function modifier_healer_bottle_filling:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor("aura_radius")
end
function modifier_healer_bottle_filling:GetAuraSearchTeam()
	return self:GetAbility():GetAbilityTargetTeam()
end
function modifier_healer_bottle_filling:GetAuraSearchType()
	return self:GetAbility():GetAbilityTargetType()
end
function modifier_healer_bottle_filling:GetAuraSearchFlags()
	return self:GetAbility():GetAbilityTargetFlags()
end
function modifier_healer_bottle_filling:IsAura()
	return true
end
function modifier_healer_bottle_filling:GetModifierAura()
	return "modifier_healer_bottle_filling_effect"
end

modifier_healer_bottle_filling_effect = class({
	IsHidden = function() return true end,
	IsPurgable = function() return false end,
})

if IsServer() then
	function modifier_healer_bottle_filling_effect:OnCreated()
		local parent = self:GetParent()
		for i = 0, 11 do
			local item = parent:GetItemInSlot(i)
			if item and item:GetAbilityName() == "item_bottle_arena" then
				if  parent:IsCourier() or parent:HasModifier("modifier_healer_bottle_filling_delay") then return end
				item:SetCurrentCharges(3)
				local duration = self:GetAbility():GetSpecialValueFor('bottle_refill_cooldown')
				local ability = self:GetAbility()
				parent:AddNewModifier(ability:GetCaster(), ability, "modifier_healer_bottle_filling_delay", {duration = duration})
			end
		end
	end
end

modifier_healer_bottle_filling_delay = class({
	IsDebuff = function() return true end,
	IsPurgable = function() return false end,
})

