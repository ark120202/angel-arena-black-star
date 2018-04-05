function Transform(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local conversion_rate =
		ability:GetSpecialValueFor("base_conversion_rate") *
		ability:GetSpecialValueFor("think_interval")

	if GameRules:IsDaytime() then
		if caster:GetMana() >= conversion_rate then
			caster:SpendMana(conversion_rate, ability)
			local mana_to_hp_pct = ability:GetSpecialValueFor("mana_to_hp_pct")
			SafeHeal(caster, conversion_rate * mana_to_hp_pct * 0.01, caster)
		end
	elseif not caster:IsInvulnerable() then
		local hp = caster:GetHealth()
		ApplyDamage({
			victim = caster,
			attacker = caster,
			damage = conversion_rate,
			damage_type = DAMAGE_TYPE_PURE,
			damage_flags = DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS + DOTA_DAMAGE_FLAG_HPLOSS,
			ability = ability
		})

		if caster:IsAlive() then
			local diff = hp - caster:GetHealth()
			local hp_to_mana_pct = ability:GetSpecialValueFor("hp_to_mana_pct")
			caster:GiveMana(diff * hp_to_mana_pct * 0.01)
		end
	end
end
