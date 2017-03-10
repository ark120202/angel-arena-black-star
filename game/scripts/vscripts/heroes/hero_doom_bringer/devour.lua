function Devour( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local modifier = keys.modifier

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_doom_bringer_devour_arena", nil)
	caster:SetModifierStackCount("modifier_doom_bringer_devour_arena", caster, target:GetMaxHealth() * ability:GetLevelSpecialValueFor("stolen_health_pct", ability:GetLevel() - 1) * 0.01)
	caster:CalculateStatBonus()
	
	local gold = math.max(ability:GetLevelSpecialValueFor("min_bonus_gold", ability:GetLevel() - 1), ((target:GetMinimumGoldBounty() + target:GetMaximumGoldBounty()) / 2) * ability:GetLevelSpecialValueFor("bonus_gold_pct", ability:GetLevel() - 1) * 0.01)
	Gold:AddGoldWithMessage(caster, gold)

	target:SetMinimumGoldBounty(0)
	target:SetMaximumGoldBounty(0)
	target:Kill(ability, caster)
	--[[
	local devour_table = {} --TODO
	if devour_table[target:GetUnitName()] then
		local ability1 = "doom_bringer_empty1"
		local ability2 = "doom_bringer_empty2"
		if ability.DevourAbilities then
			ability1 = ability.DevourAbilities[1]
			ability2 = ability.DevourAbilities[2]
		end
		local creep1 = target:GetAbilityByIndex(0)
		local creep2 = target:GetAbilityByIndex(1)

		if creep1 then
			ability.DevourAbilities[1] = creep1:GetAbilityName()
			local caster1 = ReplaceAbilities(caster, ability1, ability.DevourAbilities[1], false, false)
			caster1:SetLevel(creep1:GetLevel())
		else
			ReplaceAbilities(caster, ability.DevourAbilities[1], "doom_bringer_empty1", false, false)
			ability.DevourAbilities[1] = nil
		end
		if creep2 then
			ability.DevourAbilities[2] = creep2:GetAbilityName()
			local caster2 = ReplaceAbilities(caster, ability1, ability.DevourAbilities[2], false, false)
			caster2:SetLevel(creep2:GetLevel())
		else
			ReplaceAbilities(caster, ability.DevourAbilities[2], "doom_bringer_empty2", false, false)
			ability.DevourAbilities[2] = nil
		end
	end]]
end