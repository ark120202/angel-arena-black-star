modifier_freya_pain_reflection = class({})

function modifier_freya_pain_reflection:IsPurgable()
	return false
end

function modifier_freya_pain_reflection:GetEffectName()
	return "particles/arena/units/heroes/hero_freya/pain_reflection.vpcf"
end

function modifier_freya_pain_reflection:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

if IsServer() then
	function modifier_freya_pain_reflection:DeclareFunctions()
		return { MODIFIER_EVENT_ON_TAKEDAMAGE }
	end

	function modifier_freya_pain_reflection:OnTakeDamage(keys)
		local unit = self:GetParent()
		if unit == keys.unit then
			local ability = self:GetAbility()
			local returnedDmg = keys.damage * ability:GetAbilitySpecial("damage_return_pct") * 0.01
			if SimpleDamageReflect(unit, keys.attacker, returnedDmg, keys.damage_flags, ability, ability:GetAbilityDamageType()) then
				local heal = returnedDmg * ability:GetAbilitySpecial("returned_to_heal_pct") * 0.01
				SafeHeal(unit, heal, unit)
				if heal then
					SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, unit, heal, nil)
					ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)
				end
			end
		end
	end
end