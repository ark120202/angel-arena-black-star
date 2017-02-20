item_aether_lens_baseclass = {}

LinkLuaModifier("modifier_item_aether_lens_arena", "items/modifier_item_aether_lens_arena.lua", LUA_MODIFIER_MOTION_NONE)

function item_aether_lens_baseclass:GetIntrinsicModifierName()
	return "modifier_item_aether_lens_arena"
end

item_aether_lens_arena = class(item_aether_lens_baseclass)
item_aether_lens_2 = class(item_aether_lens_baseclass)
item_aether_lens_3 = class(item_aether_lens_baseclass)
item_aether_lens_4 = class(item_aether_lens_baseclass)
item_aether_lens_5 = class(item_aether_lens_baseclass)