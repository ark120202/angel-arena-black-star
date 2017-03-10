item_mekansm_baseclass = {}
LinkLuaModifier("modifier_item_mekansm_arena", "items/modifier_item_mekansm_arena.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_mekansm_arena_effect", "items/modifier_item_mekansm_arena.lua", LUA_MODIFIER_MOTION_NONE)
function item_mekansm_baseclass:GetIntrinsicModifierName()
	return "modifier_item_mekansm_arena"
end
if IsServer() then
	function item_mekansm_baseclass:OnSpellStart()
		local caster = self:GetCaster()
		caster:EmitSound("DOTA_Item.Mekansm.Activate")
		ParticleManager:CreateParticle(self.pfx, PATTACH_ABSORIGIN_FOLLOW, caster)
		for _,v in ipairs(FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, self:GetSpecialValueFor("radius"), self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)) do
			SafeHeal(v, self:GetSpecialValueFor("heal_amount"), self)
			ParticleManager:CreateParticle(self.recipient_pfx, PATTACH_ABSORIGIN_FOLLOW, v, caster)
			v:EmitSound("DOTA_Item.Mekansm.Target")
		end
	end
end

item_mekansm_arena = class(item_mekansm_baseclass)
item_mekansm_arena.pfx = "particles/items2_fx/mekanism.vpcf"
item_mekansm_arena.recipient_pfx = "particles/items2_fx/mekanism.vpcf"
item_mekansm_2 = class(item_mekansm_baseclass)
item_mekansm_2.pfx = "particles/econ/events/ti6/mekanism_ti6.vpcf"
item_mekansm_2.recipient_pfx = "particles/econ/events/ti6/mekanism_recipient_ti6.vpcf"