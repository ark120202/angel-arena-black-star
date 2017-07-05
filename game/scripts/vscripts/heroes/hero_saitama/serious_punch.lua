saitama_serios_punch = class({})

if IsServer() then
	function saitama_serios_punch:OnSpellStart()
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local damage = (0.01 * self:GetSpecialValueFor("used_damage_pct") * caster:GetAverageTrueAttackDamage(target)) * (0.01 * (self:GetSpecialValueFor("default_critical_damage_pct") + self:GetSpecialValueFor("bonus_ctitical_damage_pct") * caster:GetModifierStackCount("modifier_saitama_limiter", caster)))
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