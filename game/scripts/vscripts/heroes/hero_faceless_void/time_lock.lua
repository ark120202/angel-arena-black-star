function TimeLock(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local skills = {}
	local bonus_cooldown = ability:GetLevelSpecialValueFor("bonus_cooldown", ability:GetLevel() - 1)
	if not caster:IsIllusion() then
		if target:IsRealHero() or target:IsBoss() then
			for i = 0, target:GetAbilityCount() - 1 do
				local skill = target:GetAbilityByIndex(i)
				if skill and not skill:IsHidden() then
					table.insert(skills, skill)
				end
			end
			local delayed = skills[RandomInt(1, #skills)]
			if delayed then
				local cd = delayed:GetCooldownTimeRemaining()
				if cd > 0 then
					delayed:StartCooldown(cd + bonus_cooldown)
				else
					delayed:StartCooldown(bonus_cooldown)
				end
			end
			ability:ApplyDataDrivenModifier(caster, target, "modifier_time_lock_stun_arena", { duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() - 1) })
		else
			ability:ApplyDataDrivenModifier(caster, target, "modifier_time_lock_stun_arena", { duration = ability:GetLevelSpecialValueFor("duration_creep", ability:GetLevel() - 1) })
		end
	end
end