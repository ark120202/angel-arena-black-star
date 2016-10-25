function OnUpgrade(keys)
	local caster = keys.caster
	local ability = keys.ability
	local stacks = ability:GetLevel() - 1
	ModifyStacks(ability, caster, caster, "modifier_attribute_bonus_arena", stacks - caster:GetModifierStackCount("modifier_attribute_bonus_arena", caster), false)
end

function AutoUpgrade(keys)
	local caster = keys.caster
	local ability = keys.ability
	if not ability or DOTA_ACTIVE_GAMEMODE_TYPE == DOTA_GAMEMODE_TYPE_ABILITY_SHOP then
		caster:RemoveModifierByName("modifier_attribute_bonus_thinker")
		return
	end
	if caster:GetAbilityPoints() > 0 then
		for i = 1, caster:GetAbilityPoints() do
			local canUpgrade = true
			for i = 0, caster:GetAbilityCount()-1 do
				local skill = caster:GetAbilityByIndex(i)
			 	if skill and skill:CanAbilityBeUpgraded() == 0 and skill:GetName() ~= ability:GetName() and not table.contains(ATTRIBUTE_IGNORED_ABILITIES, skill:GetName()) then
					canUpgrade = false
				end
			end
			if canUpgrade then
				ability:SetLevel(ability:GetLevel() + 1)
				caster:SetAbilityPoints(caster:GetAbilityPoints() - 1)
			end
		end
	end
end