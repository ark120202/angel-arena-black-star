item_battlefury_baseclass = {}
LinkLuaModifier("modifier_item_battlefury_arena", "items/modifier_item_battlefury_arena.lua", LUA_MODIFIER_MOTION_NONE)

function item_battlefury_baseclass:GetIntrinsicModifierName()
	return "modifier_item_battlefury_arena"
end

function item_battlefury_baseclass:CastFilterResultTarget(hTarget)
	return (hTarget:GetClassname() == "ent_dota_tree" or hTarget:IsCustomWard()) and UF_SUCCESS or UF_FAIL_CUSTOM
end

function item_battlefury_baseclass:GetCustomCastErrorTarget(hTarget)
	return (hTarget:GetClassname() == "ent_dota_tree" or hTarget:IsCustomWard()) and "" or "dota_hud_error_cant_cast_on_non_tree_ward"
end

if IsServer() then
	function item_battlefury_baseclass:OnSpellStart()
		self:GetCursorTarget():CutTreeOrWard(self:GetCaster(), self)
	end
end

item_quelling_fury = class(item_battlefury_baseclass)
item_quelling_fury.cleave_pfx = "particles/items_fx/battlefury_cleave.vpcf"
item_battlefury_arena = class(item_battlefury_baseclass)
item_battlefury_arena.cleave_pfx = "particles/items_fx/battlefury_cleave.vpcf"