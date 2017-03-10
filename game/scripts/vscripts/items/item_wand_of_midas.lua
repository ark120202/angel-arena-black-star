item_wand_of_midas = class({})
LinkLuaModifier("modifier_item_wand_of_midas", "items/modifier_item_wand_of_midas.lua", LUA_MODIFIER_MOTION_NONE)

function item_wand_of_midas:GetIntrinsicModifierName()
	return "modifier_item_wand_of_midas"
end

if IsServer() then
	function item_wand_of_midas:CastFilterResult()
		return self:GetCurrentCharges() == 0 and UF_FAIL_CUSTOM or UF_SUCCESS
	end

	function item_wand_of_midas:GetCustomCastError()
		return self:GetCurrentCharges() == 0 and "#dota_hud_error_no_charges" or ""
	end

	function item_wand_of_midas:OnSpellStart()
		local charges = self:GetCurrentCharges()
		local restore = charges * self:GetSpecialValueFor("restore_per_charge")
		local caster = self:GetCaster()
		SafeHeal(caster, restore, self, true)
		caster:GiveMana(restore)
		ParticleManager:SetParticleControl(ParticleManager:CreateParticle("particles/arena/items_fx/wand_of_midas.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster), 1, Vector(charges))
		caster:EmitSound("DOTA_Item.MagicWand.Activate")
		self:SetCurrentCharges(0)
	end
end