item_skadi_baseclass = {}
LinkLuaModifier("modifier_item_skadi_arena", "items/modifier_item_skadi_arena.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_skadi_arena_cold_attack", "items/modifier_item_skadi_arena.lua", LUA_MODIFIER_MOTION_NONE)


function item_skadi_baseclass:GetIntrinsicModifierName()
	return "modifier_item_skadi_arena"
end

item_skadi_arena = class(item_skadi_baseclass)
item_skadi_2 = class(item_skadi_baseclass)
item_skadi_4 = class(item_skadi_baseclass)
item_skadi_8 = class(item_skadi_baseclass)
