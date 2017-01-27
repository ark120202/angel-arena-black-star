item_sacred_blade_mail = class({})
LinkLuaModifier("modifier_item_sacred_blade_mail", "items/lua/modifiers/modifier_item_sacred_blade_mail.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_sacred_blade_mail_active", "items/lua/modifiers/modifier_item_sacred_blade_mail.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_sacred_blade_mail_buff", "items/lua/modifiers/modifier_item_sacred_blade_mail.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_sacred_blade_mail_buff_cooldown", "items/lua/modifiers/modifier_item_sacred_blade_mail.lua", LUA_MODIFIER_MOTION_NONE)
function item_sacred_blade_mail:GetIntrinsicModifierName()
	return "modifier_item_sacred_blade_mail"
end
if IsServer() then
	function item_sacred_blade_mail:OnSpellStart()
		local caster = self:GetCaster()
		caster:AddNewModifier(caster, self, "modifier_item_sacred_blade_mail_active", {duration = self:GetSpecialValueFor("duration")})
		caster:EmitSound("DOTA_Item.BladeMail.Activate")
	end
end