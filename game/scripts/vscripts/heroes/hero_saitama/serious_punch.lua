saitama_serios_punch = class({})

if IsServer() then
	function saitama_serios_punch:OnSpellStart()
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local damage = (0.01 * self:GetSpecialValueFor("used_damage_pct") * caster:GetAverageTrueAttackDamage(target)) * (0.01 * (self:GetSpecialValueFor("default_critical_damage_pct") + self:GetSpecialValueFor("bonus_ctitical_damage_pct") * caster:GetModifierStackCount("modifier_saitama_limiter", caster)))
		caster:EmitSound("Hero_Earthshaker.EchoSlam")
		local radius = damage * 0.1
		local pfx = ParticleManager:CreateParticle("particles/arena/units/heroes/hero_saitama/serios_punch.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControlEnt(pfx, 0, target, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", caster:GetOrigin(), true)
		ApplyDamage({
			attacker = caster,
			victim = target,
			damage = damage,
			damage_type = self:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
			ability = self
		})
	end
end