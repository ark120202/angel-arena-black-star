item_flask_arena = {}
if IsServer() then
	function item_flask_arena:OnSpellStart()
		local target = self:GetCursorTarget()
		local duration = self:GetSpecialValueFor("buff_duration")
		target:EmitSound("DOTA_Item.HealingSalve.Activate")
		target:AddNewModifier(self:GetCaster(), self, "modifier_item_flask_arena_healing", { duration = duration })
		self:SpendCharge()
	end
end


LinkLuaModifier("modifier_item_flask_arena_healing", "items/item_flask_arena.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_flask_arena_healing = {
	GetTexture = function() return "item_flask" end,
	GetEffectName = function() return "particles/items_fx/healing_flask.vpcf" end,
}

function modifier_item_flask_arena_healing:OnCreated()
	self.health_regen = self:GetAbility():GetSpecialValueFor("health_regen")
end

function modifier_item_flask_arena_healing:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end

function modifier_item_flask_arena_healing:GetModifierConstantHealthRegen()
	return self.health_regen
end

if IsServer() then
	function modifier_item_flask_arena_healing:OnTakeDamage(keys)
		local unit = self:GetParent()
		if unit ~= keys.unit then return end
		if unit:GetTeamNumber() == keys.attacker:GetTeamNumber() then return end
		if unit:IsHero() or unit:IsTower() or unit.SpawnerType == "jungle" then
			self:Destroy()
		end
	end
end
