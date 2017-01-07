function ManaBreak(keys)
	local caster = keys.caster
	if not caster:PassivesDisabled() then
		local ability = keys.ability
		local level = ability:GetLevel() - 1
		local baseManaBurn = ability:GetLevelSpecialValueFor("mana_per_hit", level)
		local baseManaBurnPct = ability:GetLevelSpecialValueFor(caster:HasScepter() and "mana_per_hit_pct_scepter" or "mana_per_hit_pct", level) * 0.01
		local mana_per_hit_illusions = ability:GetLevelSpecialValueFor("mana_per_hit_illusions_pct", level) * 0.01
		local damage_per_burn = ability:GetLevelSpecialValueFor("damage_per_burn_pct", level) * 0.01
		local nomana_bonus_pure_damage = ability:GetLevelSpecialValueFor("nomana_bonus_pure_damage_pct", level) * 0.01
		local mana_to_secondary_targets = ability:GetLevelSpecialValueFor("mana_to_secondary_targets_pct_scepter", level) * 0.01
		if caster:HasScepter() then
			ParticleManager:CreateParticle("particles/arena/units/heroes/hero_antimage/mana_break_cleave.vpcf", PATTACH_ABSORIGIN, keys.target)
		end
		for _,target in ipairs(caster:HasScepter() and FindUnitsInRadius(caster:GetTeamNumber(), keys.target:GetAbsOrigin(), nil, ability:GetLevelSpecialValueFor("aoe_radius_scepter", level), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MANA_ONLY, FIND_ANY_ORDER, false) or {keys.target}) do
			if not target:IsMagicImmune() then
				local manaBurn = baseManaBurn + (target:GetMaxMana() * baseManaBurnPct)
				manaBurn = target == keys.target and manaBurn or manaBurn * mana_to_secondary_targets
				manaBurn = caster:IsIllusion() and manaBurn * mana_per_hit_illusions or manaBurn
				SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_LOSS, target, manaBurn, nil)
				target:EmitSound("Hero_Antimage.ManaBreak")
				ParticleManager:CreateParticle("particles/generic_gameplay/generic_manaburn.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
				if target:GetMana() >= manaBurn then
					target:ReduceMana(manaBurn)
					ApplyDamage({
						damage = manaBurn * damage_per_burn,
						attacker = caster,
						victim = target,
						damage_type = ability:GetAbilityDamageType(),
						ability = ability,
					})
				else
					target:ReduceMana(manaBurn)
					ApplyDamage({
						damage = keys.Damage * nomana_bonus_pure_damage,
						attacker = caster,
						victim = target,
						damage_type = DAMAGE_TYPE_PURE,
						ability = ability,
					})
					if not target:HasModifier("modifier_antimage_mana_break_arena_stun_cooldown") then
						target:AddNewModifier(caster, ability, "modifier_stunned", {duration = ability:GetLevelSpecialValueFor("nomana_stun_duration", level)})
						ability:ApplyDataDrivenModifier(caster, target, "modifier_antimage_mana_break_arena_stun_cooldown", nil)
					end
				end
			end
		end
	end
end