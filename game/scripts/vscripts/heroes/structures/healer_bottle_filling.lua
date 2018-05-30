LinkLuaModifier("modifier_healer_bottle_filling", "heroes/structures/healer_bottle_filling.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_healer_bottle_filling_delay", "heroes/structures/healer_bottle_filling.lua", LUA_MODIFIER_MOTION_NONE)

healer_bottle_filling = class({
	GetIntrinsicModifierName = function() return "modifier_healer_bottle_filling" end,
})

modifier_healer_bottle_filling = class({
	IsPurgable = function() return false end,
	IsHidden = function() return true end,
})

if IsServer() then
	function modifier_healer_bottle_filling:OnCreated()
		self:StartIntervalThink(1)
		self:OnIntervalThink()
	end

	function modifier_healer_bottle_filling:OnIntervalThink()
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local radius = ability:GetSpecialValueFor("aura_radius")
		local delay_duration = ability:GetSpecialValueFor('bottle_refill_cooldown')
			for _,v in ipairs(FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
				if not v:HasModifier("modifier_healer_bottle_filling_delay") then
				for i = 0, 11 do
						local item = v:GetItemInSlot(i)
						if item and item:GetAbilityName() == "item_bottle_arena" then
						item:SetCurrentCharges(3)
						v:EmitSound("DOTA_Item.MagicWand.Activate")
						v:AddNewModifier(ability:GetCaster(), ability, "modifier_healer_bottle_filling_delay", {duration = delay_duration})
					end
				end
			end
		end
	end
end

modifier_healer_bottle_filling_delay = class({
	IsDebuff = function() return true end,
	IsPurgable = function() return false end,
})

