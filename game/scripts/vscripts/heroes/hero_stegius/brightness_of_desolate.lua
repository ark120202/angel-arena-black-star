function OnBuffDestroy(keys)
	if keys.target:IsHero() then
		keys.target:CalculateStatBonus()
	end
end

function ThinkPenalty(keys)
	local target = keys.target
	if target:IsHero() then
		target:CalculateHealthReduction()
	end
end

function IncreaseDamage(keys)
	local caster = keys.caster
	local target = keys.unit
	local ability = keys.ability
	local damage
	if target:IsRealHero() then
		ModifyStacks(ability, caster, caster, "modifier_stegius_brightness_of_desolate_steal_buff", 1, false)
		damage = ability:GetAbilitySpecial("bonus_damage_from_hero")
	else
		damage = ability:GetAbilitySpecial("bonus_damage_from_creep")
	end
	ModifyStacks(ability, caster, caster, "modifier_stegius_brightness_of_desolate_damage", damage, true)
	Timers:CreateTimer(ability:GetAbilitySpecial("bonus_damage_duration"), function()
		if IsValidEntity(caster) then
			ModifyStacks(ability, caster, caster, "modifier_stegius_brightness_of_desolate_damage", -damage)
		end
	end)
end