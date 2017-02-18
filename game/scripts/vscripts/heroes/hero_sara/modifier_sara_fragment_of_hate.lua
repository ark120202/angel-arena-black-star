modifier_sara_fragment_of_hate = class({})

function modifier_sara_fragment_of_hate:IsHidden()
	return true
end

function modifier_sara_fragment_of_hate:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE
	}
end

function modifier_sara_fragment_of_hate:GetModifierPreAttack_CriticalStrike(keys)
	local ability = self:GetAbility()
	if RollPercentage(ability:GetSpecialValueFor("crit_chance_pct")) then
		print("Crit!")
		if keys.attacker:HasScepter() then
			ApplyDamage({
				attacker = keys.attacker,
				victim = keys.target,
				damage_type = DAMAGE_TYPE_PURE,
				damage = damage,
				ability = ability
			})
		end
		return self:GetParent():GetMana() * ability:GetSpecialValueFor("energy_to_crit_pct")
	end
end

if IsServer() then
	function modifier_sara_fragment_of_hate:GetModifierPreAttack_BonusDamage()
		local parent = self:GetParent()
		if parent.GetEnergy then
			return parent:GetEnergy() * self:GetAbility():GetSpecialValueFor("energy_to_damage_pct") * 0.01
		end
	end
else
	function modifier_sara_fragment_of_hate:GetModifierPreAttack_BonusDamage()
		return self:GetParent():GetMana() * self:GetAbility():GetSpecialValueFor("energy_to_damage_pct") * 0.01
	end
end