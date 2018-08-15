LinkLuaModifier("modifier_guldan_curse_stun", "heroes/hero_guldan/guldan_curse.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_guldan_curse_silence", "heroes/hero_guldan/guldan_curse.lua", LUA_MODIFIER_MOTION_NONE)

guldan_curse = class({})

modifier_guldan_curse_stun = class({
	IsPurgable = function() return false end,
})

function modifier_guldan_curse_stun:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = true,
	}
end

modifier_guldan_curse_silence = class({
	IsPurgable = function() return false end,
})

function modifier_guldan_curse_silence:CheckState()
	return {
		[MODIFIER_STATE_SILENCED] = true,
	}
end

if IsServer() then
	function guldan_curse:OnSpellStart()
		local target = self:GetCursorTarget()
		local caster = self:GetCaster()
		caster:EmitSound("Arena.Hero_Guldan.Curse.Cast")
		local damage = self:GetAbilityDamage() + target:GetLevel()
		ApplyDamage({
			victim = target,
			attacker = self:GetCaster(),
			damage = damage,
			damage_type = self:GetAbilityDamageType(),
			ability = self,
		})
		target:AddNewModifier(self:GetCaster(), self, "modifier_guldan_curse_stun", {duration = self:GetSpecialValueFor('stun_duration')})
		local particle = ParticleManager:CreateParticle("particles/arena/units/heroes/hero_guldan/guldan_curse.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControlEnt(particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), false)
	end
	function modifier_guldan_curse_stun:OnDestroy()
		local parent = self:GetParent()
		parent:AddNewModifier(self:GetCaster(),self, "modifier_guldan_curse_silence",{duration = self:GetAbility():GetSpecialValueFor('silence_duration')})
	end
end
