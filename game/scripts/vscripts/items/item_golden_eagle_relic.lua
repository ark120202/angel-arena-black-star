function DealBonusDamage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local dmg = Gold:GetGold(caster) * ability:GetAbilitySpecial("gold_as_damage_pct") * 0.01
	ApplyDamage({
		victim = target,
		attacker = caster,
		damage = dmg,
		damage_type = ability:GetAbilityDamageType(),
		ability = ability
	})
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, target, dmg, nil)
end

function WasteGoldInterval(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local gold = Gold:GetGold(caster) * ability:GetAbilitySpecial("active_gold_lost_per_sec_pct") * 0.01 * keys.interval
	Gold:RemoveGold(caster, gold)
end