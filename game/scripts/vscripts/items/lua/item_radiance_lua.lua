if IsClient() then require('internal/sharedutil') end
item_radiance_baseclass = {}
LinkLuaModifier("modifier_item_radiance_lua", "items/lua/modifiers/modifier_item_radiance_lua.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_radiance_lua_effect", "items/lua/modifiers/modifier_item_radiance_lua_effect.lua", LUA_MODIFIER_MOTION_NONE)
function item_radiance_baseclass:GetAbilityTextureName()
	local disabled = self:GetNetworkableEntityInfo("item_disabled") == 1
	return disabled and "item_arena/" .. string.gsub(self:GetName(), "item_", "") .. "_inactive" or "item_arena/" .. string.gsub(self:GetName(), "item_", "")
end

if IsServer() then
	function item_radiance_baseclass:GetIntrinsicModifierName()
		return "modifier_item_radiance_lua"
	end
	function item_radiance_baseclass:OnSpellStart()
		self.disabled = not self.disabled
		self:SetNetworkableEntityInfo("item_disabled", self.disabled)
		if not self.disabled then
			self.pfx = ParticleManager:CreateParticle(self.particle_owner, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
		elseif self.pfx then
			ParticleManager:DestroyParticle(self.pfx, false)
			self.pfx = nil
		end
	end
end

item_radiance_arena = class(item_radiance_baseclass)
item_radiance_arena.particle_owner = "particles/items2_fx/radiance_owner.vpcf"
item_radiance_2 = class(item_radiance_baseclass)
item_radiance_2.particle_owner = "particles/items2_fx/radiance_owner.vpcf"
item_radiance_3 = class(item_radiance_baseclass)
item_radiance_3.particle_owner = "particles/econ/events/ti6/radiance_owner_ti6.vpcf"
item_radiance_frozen = class(item_radiance_baseclass)
item_radiance_frozen.particle_owner = "particles/arena/items_fx/radiance_frozen_owner.vpcf"