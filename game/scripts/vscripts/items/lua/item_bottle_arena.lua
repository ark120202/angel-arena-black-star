item_bottle_arena = class({})
LinkLuaModifier("modifier_item_bottle_arena_heal", "items/lua/modifiers/modifier_item_bottle_arena_heal.lua", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function item_bottle_arena:OnCreated()
		self:SetCurrentCharges(3)
	end

	function item_bottle_arena:SetCurrentCharges(charges)
		local texture
		if self.RuneStorage then
			texture = "arena/bottle_rune_" .. self.RuneStorage
		else
			texture = "arena/bottle_" .. charges
		end
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