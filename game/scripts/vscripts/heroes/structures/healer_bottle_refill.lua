LinkLuaModifier("modifier_healer_bottle_refill", "heroes/structures/healer_bottle_refill.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_healer_bottle_refill_cooldown", "heroes/structures/healer_bottle_refill.lua", LUA_MODIFIER_MOTION_NONE)

healer_bottle_refill = class({
	GetIntrinsicModifierName = function() return "modifier_healer_bottle_refill" end,
})

function healer_bottle_refill:GetCooldown()
	return self:GetSpecialValueFor("cooldown")
end

modifier_healer_bottle_refill = class({
	IsPurgable = function() return false end,
	IsHidden = function() return true end,
})

if IsServer() then
	function modifier_healer_bottle_refill:OnCreated()
		self:StartIntervalThink(1)
		self:OnIntervalThink()
	end

	function modifier_healer_bottle_refill:OnIntervalThink()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local radius = ability:GetSpecialValueFor("radius")
		local cooldown = ability:GetSpecialValueFor("cooldown")

		for _,v in ipairs(FindUnitsInRadius(parent:GetTeamNumber(), parent:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
			if not v:HasModifier("modifier_healer_bottle_refill_cooldown") then
				local refilled = false
				for i = 0, 11 do
					local item = v:GetItemInSlot(i)
					if item and item:GetAbilityName() == "item_bottle_arena" and item:GetCurrentCharges() ~= 3 then
						item:SetCurrentCharges(3)
						refilled = true
					end
				end

				if refilled then
					v:EmitSound("DOTA_Item.MagicWand.Activate")
					v:AddNewModifier(parent, ability, "modifier_healer_bottle_refill_cooldown", {duration = cooldown})
				end
			end
		end
	end
end

modifier_healer_bottle_refill_cooldown = class({
	IsDebuff = function() return true end,
	IsPurgable = function() return false end,
})
