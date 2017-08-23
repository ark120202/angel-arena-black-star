LinkLuaModifier("modifier_item_lightning_rod_ward", "items/item_lightning_rod", LUA_MODIFIER_MOTION_NONE)

item_lightning_rod = class({})

if IsServer() then
	function item_lightning_rod:OnSpellStart()
		local caster = self:GetCaster()
		local position = self:GetCursorPosition()
		local lifetime = self:GetSpecialValueFor("duration_minutes") * 60

		local ward = CreateUnitByName("npc_arena_lightning_rod", position, true, caster, caster, caster:GetTeamNumber())
		ward:SetHealth(self:GetSpecialValueFor("health"))
		ward:SetRenderColor(30, 50, 127)

		ward:EmitSound("DOTA_Item.ObserverWard.Activate")

		ward:AddNewModifier(caster, self, "modifier_kill", {
			duration = lifetime
		})
		ward:AddNewModifier(caster, self, "modifier_item_lightning_rod_ward", {
			duration = lifetime,
		})

		self:SpendCharge()
	end
end


modifier_item_lightning_rod_ward = class({
	IsPurgable = function() return false end,
	GetTexture = function() return "item_arena/lightning_rod" end,
})

function modifier_item_lightning_rod_ward:CheckState()
	return {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
	}
end
