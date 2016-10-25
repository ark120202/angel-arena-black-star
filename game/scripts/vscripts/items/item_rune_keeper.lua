function TrackStacks(keys)
	local caster = keys.caster
	local ability = keys.ability
	local rune_multiplier = ability:GetLevelSpecialValueFor("rune_multiplier", ability:GetLevel() - 1)
	if not ability.RuneContainer then ability.RuneContainer = {} end

	for i,v in ipairs(ability.RuneContainer) do
		if Time() > v.expireGameTime then
			PreformRuneUsage(caster, ability, rune_multiplier, i)
		end
	end
	ability:SetCurrentCharges(#ability.RuneContainer)
end

function UseRune(keys)
	local caster = keys.caster
	local ability = keys.ability
	local rune_multiplier = ability:GetLevelSpecialValueFor("rune_multiplier", ability:GetLevel() - 1)

	if ability.RuneContainer and #ability.RuneContainer > 0 then
		PreformRuneUsage(caster, ability, rune_multiplier, 1)
	else
		ability:RefundManaCost()
		ability:EndCooldown()
	end
end

function PreformRuneUsage(unit, ability, rune_multiplier, index)
	Notifications:Bottom(unit:GetPlayerID(), {text="#item_rune_keeper_rune_used", duration = 8})
	Notifications:Bottom(unit:GetPlayerID(), {text="#item_rune_keeper_rune_" .. ability.RuneContainer[index].rune, continue=true})
	PreformRunePickup(unit, ability.RuneContainer[index].rune, {runeSettings = {
		[DOTA_RUNE_DOUBLEDAMAGE] = {multiplier_duration = rune_multiplier},
		[DOTA_RUNE_HASTE] = {multiplier_duration = rune_multiplier},
		[DOTA_RUNE_ILLUSION] = {multiplier_duration = rune_multiplier},
		[DOTA_RUNE_INVISIBILITY] = {multiplier_duration = rune_multiplier},
		[DOTA_RUNE_REGENERATION] = {multiplier_duration = rune_multiplier},
		[DOTA_RUNE_BOUNTY] = {bounty_special_multiplier = rune_multiplier},
		[DOTA_RUNE_ARCANE] = {multiplier_duration = rune_multiplier},
	}})
	table.remove(ability.RuneContainer, index)
	if #ability.RuneContainer > 0 then
		Notifications:Bottom(unit:GetPlayerID(), {text="#item_rune_keeper_contains", duration = 8})
		for i,v in ipairs(ability.RuneContainer) do
			Notifications:Bottom(unit:GetPlayerID(), {text="#item_rune_keeper_rune_" .. v.rune, continue=true})
		end

	else
		Notifications:Bottom(unit:GetPlayerID(), {text="#item_rune_keeper_no_runes_left", duration = 8})
	end
end