function StealArmor(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if target:IsConsideredHero() and not target:IsIllusion() and not target:IsBoss() then
		ModifyStacks(ability, caster, caster, "modifier_apocalypse_agnis_touch_armor", ability:GetAbilitySpecial("armor_per_attack"), false)
		ModifyStacks(ability, caster, target, "modifier_apocalypse_agnis_touch_disarmor", ability:GetAbilitySpecial("armor_per_attack"), false)
		if not ability.damaged_units then
			ability.damaged_units = {}
		end
		ability.damaged_units[target] = true
	end
end

function ReturnArmor(keys)
	if keys.ability.damaged_units then
		for k,_ in pairs(keys.ability.damaged_units) do
			k:RemoveModifierByNameAndCaster("modifier_apocalypse_agnis_touch_disarmor", keys.caster)
		end
	end
	keys.caster:RemoveModifierByNameAndCaster("modifier_apocalypse_agnis_touch_armor", keys.caster)
end

function AuraDamage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	for _,v in ipairs(FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, ability:GetAbilitySpecial("ablaze_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
		ApplyDamage({
			victim = v,
			attacker = caster,
			damage = ability:GetAbilitySpecial("ablaze_max_damage_per_second") * (1-(caster:GetHealthPercent() / ability:GetAbilitySpecial("ablaze_threshold_pct"))),
			damage_type = ability:GetAbilityDamageType(),
			ability = ability
		})
	end
end

function CheckAblaze(keys)
	local caster = keys.caster
	local ability = keys.ability
	if not caster:HasModifier("modifier_apocalypse_agnis_touch_ablaze") and caster:GetHealthPercent() <= ability:GetAbilitySpecial("ablaze_threshold_pct") then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_apocalypse_agnis_touch_ablaze", nil)
	elseif caster:HasModifier("modifier_apocalypse_agnis_touch_ablaze") and caster:GetHealthPercent() > ability:GetAbilitySpecial("ablaze_threshold_pct") then
		caster:RemoveModifierByName("modifier_apocalypse_agnis_touch_ablaze")
	end
end