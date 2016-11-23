function StartTimer(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local playerID = target:GetPlayerID()
	if target:IsRealHero() then
		Notifications:Bottom(playerID, {text="#notification_item_demon_king_bar_curse_p1", duration=9.0})
		Notifications:Bottom(playerID, {text=ability:GetAbilitySpecial("curse_duration"), continue = true})
		Notifications:Bottom(playerID, {text="#notification_item_demon_king_bar_curse_p2", continue = true})
	end
	DemonKingBarTimers[caster:GetEntityIndex() .. "_" .. target:GetEntityIndex()] = Timers:CreateTimer(ability:GetAbilitySpecial("curse_duration") - 0.1, function()
		if target:IsAlive() then
			TrueKill(keys.caster, ability, target)
			target:EmitSound("Hero_VengefulSpirit.MagicMissileImpact")
		end
		DemonKingBarTimers[caster:GetEntityIndex() .. "_" .. target:GetEntityIndex()] = nil
	end)
end

function StopTimer(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if DemonKingBarTimers[caster:GetEntityIndex() .. "_" .. target:GetEntityIndex()] then
		Timers:RemoveTimer(DemonKingBarTimers[caster:GetEntityIndex() .. "_" .. target:GetEntityIndex()])
		DemonKingBarTimers[caster:GetEntityIndex() .. "_" .. target:GetEntityIndex()] = nil
	end
end