LinkLuaModifier("modifier_item_bottle_arena_heal", "items/item_bottle.lua", LUA_MODIFIER_MOTION_NONE)

item_bottle_arena = class({})
function item_bottle_arena:GetAbilityTextureName()
	return self:GetNetworkableEntityInfo("ability_texture") or "item_arena/bottle_3"
end

if IsServer() then
	function item_bottle_arena:OnCreated()
		self:SetCurrentCharges(3)
	end

	function item_bottle_arena:SetCurrentCharges(charges)
		local texture = self.RuneStorage ~= nil and "item_arena/bottle_rune_" .. self.RuneStorage or "item_arena/bottle_" .. charges
		self:SetNetworkableEntityInfo("ability_texture", texture)
		return self.BaseClass.SetCurrentCharges(self, charges)
	end

	function item_bottle_arena:OnSpellStart()
		self:GetCaster():EmitSound("Bottle.Drink")
		if self.RuneStorage then
			CustomRunes:ActivateRune(self:GetCaster(), self.RuneStorage, self:GetSpecialValueFor("rune_multiplier"))
			self.RuneStorage = nil
			self:SetCurrentCharges(3)
		else
			local charges = self:GetCurrentCharges()
			if charges > 0 then
				self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_bottle_arena_heal", {duration = self:GetSpecialValueFor("restore_time")})
				self:SetCurrentCharges(charges - 1)
			end
		end
	end

	function item_bottle_arena:SetStorageRune(type)
		self:GetCaster():EmitSound("Bottle.Cork")
		if self:GetCaster().GetPlayerID then
			CustomGameEventManager:Send_ServerToTeam(self:GetCaster():GetTeam(), "create_custom_toast", {
				type = "generic",
				text = "#custom_toast_BottledRune",
				player = self:GetCaster():GetPlayerID(),
				runeType = type
			})
		end
		self.RuneStorage = type
		self:SetCurrentCharges(3)
	end
end


modifier_item_bottle_arena_heal = class({
	GetTexture =          function() return "item_arena/bottle_3" end,
	IsPurgable =          function() return false end,
	GetEffectName =       function() return "particles/items_fx/bottle.vpcf" end,
	GetEffectAttachType = function() return PATTACH_ABSORIGIN_FOLLOW end,
})

function modifier_item_bottle_arena_heal:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT
	}
end

function modifier_item_bottle_arena_heal:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("health_restore") / self:GetDuration()
end

function modifier_item_bottle_arena_heal:GetModifierConstantManaRegen()
	return self:GetAbility():GetSpecialValueFor("mana_restore") / self:GetDuration()
end
