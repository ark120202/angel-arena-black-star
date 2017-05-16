item_golden_eagle_relic = class({})
LinkLuaModifier("modifier_item_golden_eagle_relic", "items/lua/modifiers/modifier_item_golden_eagle_relic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_golden_eagle_relic_enabled", "items/lua/modifiers/modifier_item_golden_eagle_relic.lua", LUA_MODIFIER_MOTION_NONE)
function item_golden_eagle_relic:GetIntrinsicModifierName()
	return "modifier_item_golden_eagle_relic"
end
if IsServer() then
	function item_golden_eagle_relic:OnSpellStart()
		local caster = self:GetCaster()
		if caster:HasModifier("modifier_item_golden_eagle_relic_enabled") then
			caster:RemoveModifierByName("modifier_item_golden_eagle_relic_enabled")
			caster:EmitSound("DOTA_Item.Armlet.DeActivate")
		else
			caster:AddNewModifier(caster, self, "modifier_item_golden_eagle_relic_enabled", nil)
			caster:EmitSound("DOTA_Item.MaskOfMadness.Activate")
		end
	end
end