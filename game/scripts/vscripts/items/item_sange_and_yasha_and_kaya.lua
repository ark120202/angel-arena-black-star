local factory = require("items/factory_sange_yasha_kaya")

DeclarePassiveAbility("item_sange_and_yasha_and_kaya", "modifier_item_sange_and_yasha_and_kaya")

LinkLuaModifier("modifier_item_sange_and_yasha_and_kaya", "items/item_sange_and_yasha_and_kaya.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_sange_and_yasha_and_kaya_maim", "items/item_sange_and_yasha_and_kaya.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_sange_and_yasha_and_kaya, modifier_item_sange_and_yasha_and_kaya_maim = factory(
  { sange = "modifier_item_sange_and_yasha_and_kaya_maim", yasha = true, kaya = true }
)
