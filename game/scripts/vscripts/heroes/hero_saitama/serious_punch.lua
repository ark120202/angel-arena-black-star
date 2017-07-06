saitama_serios_punch = class({})

if IsServer() then
	function saitama_serios_punch:OnSpellStart()
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local damage = caster:GetAverageTrueAttackDamage(target) * (self:GetSpecialValueFor("base_damage_multiplier_pct") + self:GetSpecialValueFor("damage_multiplier_per_stack_pct") * caster:GetModifierStackCount("modifier_saitama_limiter", caster)) * 0.01
		local radius = damage * 0.1

		target:EmitSound("Hero_Earthshaker.EchoSlam")
		ParticleManager:CreateParticle("particles/arena/units/heroes/hero_saitama/serios_punch.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)

		ApplyDamage({
			attacker = caster,
			victim = target,
			damage = damage,
			damage_type = self:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
			ability = self
		})

		local duration = self:GetSpecialValueFor("knockback_duration")
		local sourcePos = caster:GetAbsOrigin()
		target:RemoveModifierByName("modifier_knockback")
		target:AddNewModifier(caster, self, "modifier_knockback", {
			knockback_duration = duration,
			knockback_distance = self:GetSpecialValueFor("knockback_distance"),
			knockback_height = 1600,
			should_stun = 1,
			duration = duration,
			center_x = sourcePos.x,
			center_y = sourcePos.y,
			center_z = sourcePos.z
		})
	end
end
