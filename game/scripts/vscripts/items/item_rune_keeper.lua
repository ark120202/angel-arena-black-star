function TrackStacks(keys)
	local caster = keys.caster
	local ability = keys.ability
	if not ability.RuneContainer then ability.RuneContainer = {} end

	for i,v in ipairs(ability.RuneContainer) do
		if GameRules:GetGameTime() > v.expireGameTime then
			PreformRuneUsage(caster, ability, ability:GetLevelSpecialValueFor("rune_multiplier", ability:GetLevel() - 1), i)
		end
	end
	ability:SetCurrentCharges(#ability.RuneContainer)
end

function UseRune(keys)
	local caster = keys.caster
	local ability = keys.ability

	if ability.RuneContainer and #ability.RuneContainer > 0 then
		PreformRuneUsage(caster, ability, ability:GetLevelSpecialValueFor("rune_multiplier", ability:GetLevel() - 1), 1)
	else
		ability:RefundManaCost()
		ability:EndCooldown()
	end
end

function PreformRuneUsage(unit, ability, rune_multiplier, index)
	CustomRunes:ActivateRune(unit, ability.RuneContainer[index].rune, rune_multiplier)
	table.remove(ability.RuneContainer, index)
	if #ability.RuneContainer > 0 then
		Notifications:Bottom(unit:GetPlayerID(), {text="#item_rune_keeper_contains", duration = 8})
		for i,v in ipairs(ability.RuneContainer) do
			Notifications:Bottom(unit:GetPlayerID(), {text="#custom_runes_rune_" .. v.rune .. "_title", continue=true})
			Notifications:Bottom(unit:GetPlayerID(), {text=" ,", continue=true})
		end
	else
		Notifications:Bottom(unit:GetPlayerID(), {text="#item_rune_keeper_no_runes_left", duration = 8})
	end
end