item_mekansm_arena = class({active_pfx = "particles/items2_fx/mekanism.vpcf"})
LinkLuaModifier("modifier_item_mekansm_arena", "items/modifier_item_mekansm_arena.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_mekansm_arena_effect", "items/modifier_item_mekansm_arena.lua", LUA_MODIFIER_MOTION_NONE)
function item_mekansm_arena:GetIntrinsicModifierName()
	return "modifier_item_mekansm_arena"
end
if IsServer() then
	function item_mekansm_arena:OnSpellStart()
		local caster = self:GetCaster()
		for _,v in ipairs(FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, self:GetSpecialValueFor("radius"), self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)) do
			SafeHeal(v, self:GetSpecialValueFor("heal_amount"), self)
			ParticleManager:CreateParticle(self.active_pfx, v, PATTACH_ABSORIGIN_FOLLOW)
		end
	end
end