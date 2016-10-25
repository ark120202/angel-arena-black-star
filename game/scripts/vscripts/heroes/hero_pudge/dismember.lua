function DamageThink(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetAbilitySpecial("dismember_damage")
	damage = damage + caster:GetStrength() * ability:GetAbilitySpecial("strength_damage") * 0.01
	ApplyDamage({
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = ability:GetAbilityDamageType(),
		ability = ability
	})
	SafeHeal(caster, damage, caster)
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, caster, damage, nil)
	if caster:HasScepter() then
		local targets = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, ability:GetAbilitySpecial("damage_aoe_scepter"), ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
		for _,v in ipairs(targets) do
			if v ~= target then
				ApplyDamage({
					victim = v,
					attacker = caster,
					damage = damage,
					damage_type = ability:GetAbilityDamageType(),
					ability = ability
				})
				SafeHeal(caster, damage, caster)
				SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, caster, damage, nil)
			end
		end
	end
end