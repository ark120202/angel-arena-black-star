saitama_serious_punch = class({})

if IsServer() then
	function saitama_serious_punch:OnSpellStart()
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		if not target:TriggerSpellAbsorb(self) then
			target:TriggerSpellReflect(self)
			local damage = caster:GetAverageTrueAttackDamage(target) * (self:GetSpecialValueFor("base_damage_multiplier_pct") + self:GetSpecialValueFor("damage_multiplier_per_stack_pct") * caster:GetModifierStackCount("modifier_saitama_limiter", caster)) * 0.01

			target:EmitSound("Hero_Earthshaker.EchoSlam")
			ParticleManager:CreateParticle("particles/econ/items/earthshaker/egteam_set/hero_earthshaker_egset/earthshaker_echoslam_start_fallback_mid_egset.vpcf", PATTACH_ABSORIGIN, target)

			ApplyDamage({
				attacker = caster,
				victim = target,
				damage = damage,
				damage_type = self:GetAbilityDamageType(),
				damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
				ability = self
			})

			target:RemoveModifierByName("modifier_knockback")
			if damage > 0 then
				SendOverheadEventMessage(nil, OVERHEAD_ALERT_DAMAGE, target, damage, nil)
				local sourcePos = caster:GetAbsOrigin()
				local duration =  damage / self:GetSpecialValueFor("knockback_duration_step")
				target:AddNewModifier(caster, self, "modifier_knockback", {
					knockback_duration = duration,
					knockback_distance = damage / self:GetSpecialValueFor("knockback_distance_step"),
					knockback_height = damage / self:GetSpecialValueFor("knockback_height_step"),
					should_stun = 1,
					duration = duration,
					center_x = sourcePos.x,
					center_y = sourcePos.y,
					center_z = sourcePos.z
				})
			end
		end
	end
end
