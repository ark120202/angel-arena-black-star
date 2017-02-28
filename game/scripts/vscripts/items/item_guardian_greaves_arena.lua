item_guardian_greaves_arena = class({})
LinkLuaModifier("modifier_item_guardian_greaves_arena", "items/modifier_item_guardian_greaves_arena.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_guardian_greaves_arena_effect", "items/modifier_item_guardian_greaves_arena.lua", LUA_MODIFIER_MOTION_NONE)
function item_guardian_greaves_arena:GetIntrinsicModifierName()
	return "modifier_item_guardian_greaves_arena"
end
if IsServer() then
	function item_guardian_greaves_arena:OnSpellStart()
		local caster = self:GetCaster()
		caster:EmitSound("Item.GuardianGreaves.Activate")
		ParticleManager:CreateParticle("particles/items3_fx/warmage.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		for _,v in ipairs(FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, self:GetSpecialValueFor("radius"), self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)) do
			SafeHeal(v, self:GetSpecialValueFor("replenish_health"), self)
			v:GiveMana(self:GetSpecialValueFor("replenish_mana"))
			ParticleManager:CreateParticle("particles/items3_fx/warmage_recipient.vpcf", PATTACH_ABSORIGIN_FOLLOW, v, caster)
			v:EmitSound("Item.GuardianGreaves.Target")
		end
	end
end