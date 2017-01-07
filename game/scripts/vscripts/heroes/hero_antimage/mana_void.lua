--[[Author: Pizzalol
	Date: 17.12.2014.
	Gets the targets mana and deals damage based on missing mana in an area around the target]]
function ManaVoid(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local silence_duration = ability:GetLevelSpecialValueFor("silence_duration", ability:GetLevel() - 1)
	local cooldown_increase = ability:GetLevelSpecialValueFor("cooldown_increase", ability:GetLevel() - 1)
	local mana_void_damage_per_mana = ability:GetLevelSpecialValueFor("mana_void_damage_per_mana", ability:GetLevel() - 1)
	local damageTable = {
		attacker = caster,
		ability = ability,
		damage_type = ability:GetAbilityDamageType(),
		damage = (target:GetMaxMana() - target:GetMana()) * mana_void_damage_per_mana,
	}

	local targetLocation = target:GetAbsOrigin()
	local targets = FindUnitsInRadius(caster:GetTeam(), targetLocation, nil, ability:GetCastRange(targetLocation, nil), ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	if caster:HasScepter() then
		damageTable.damage = 0
		for _,v in ipairs(targets) do
			damageTable.damage = damageTable.damage + (v:GetMaxMana() - v:GetMana()) * mana_void_damage_per_mana
		end
	end
	for _,v in ipairs(targets) do
		v:AddNewModifier(caster, ability, "modifier_silence", {duration = silence_duration})
		damageTable.victim = v
		ApplyDamage(damageTable)
		for i = 0, v:GetAbilityCount() - 1 do
			local skill = v:GetAbilityByIndex(i)
			if skill then
				skill:StartCooldown(skill:GetCooldownTimeRemaining() + cooldown_increase)
			end
		end
	end
end