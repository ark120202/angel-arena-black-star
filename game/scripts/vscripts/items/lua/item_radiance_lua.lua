item_radiance_baseclass = {}
LinkLuaModifier("modifier_item_radiance_lua", "items/lua/modifiers/modifier_item_radiance_lua.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_radiance_lua_effect", "items/lua/modifiers/modifier_item_radiance_lua_effect.lua", LUA_MODIFIER_MOTION_NONE)
if IsServer() then
	function item_radiance_baseclass:GetIntrinsicModifierName()
		return "modifier_item_radiance_lua"
	end
	function item_radiance_baseclass:OnSpellStart()
		self.disabled = not self.disabled
		self:SetNetworkableEntityInfo("ability_texture", self.disabled and "arena/" .. self:GetAbilityName() .. "_inactive" or "arena/" .. self:GetAbilityName())
		self:GetCaster():CalculateStatBonus()
	end
end

item_radiance_arena = class(item_radiance_baseclass)
item_radiance_2 = class(item_radiance_baseclass)
item_radiance_3 = class(item_radiance_baseclass)
item_radiance_frozen = class(item_radiance_baseclass)