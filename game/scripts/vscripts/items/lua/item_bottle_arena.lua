item_bottle_arena = class({})
LinkLuaModifier("modifier_item_bottle_arena_heal", "items/lua/modifiers/modifier_item_bottle_arena_heal.lua", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function item_bottle_arena:OnCreated()
		self:SetCurrentCharges(3)
	end

	function item_bottle_arena:SetCurrentCharges(charges)
		local texture
		if self.RuneStorage then
			texture = "item_bottle_rune_" .. self.RuneStorage
		else
			texture = "item_bottle_" .. charges
		end
		CustomNetTables:SetTableValue("custom_ability_icons", tostring(self:GetEntityIndex()), {texture})
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
			GameRules:SendCustomMessageToTeam("custom_runes_rune_" .. type .. "_bottle", self:GetCaster():GetTeam(), self:GetCaster():GetPlayerID(), -1)
		end
		self.RuneStorage = type
		self:SetCurrentCharges(3)
	end
end