function StartTimer(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if target:IsRealHero() and target.GetPlayerID then
		local playerID = target:GetPlayerID()
		Notifications:Bottom(playerID, {text="#notification_item_demon_king_bar_curse_p1", duration=9.0})
		Notifications:Bottom(playerID, {text=ability:GetAbilitySpecial("curse_duration"), continue = true})
		Notifications:Bottom(playerID, {text="#notification_item_demon_king_bar_curse_p2", continue = true})
	end
	local timerIndex = caster:GetEntityIndex() .. "_" .. target:GetEntityIndex()
	DemonKingBarTimers[timerIndex] = Timers:CreateTimer(ability:GetAbilitySpecial("curse_duration") - 0.1, function()
		if IsValidEntity(target) and target:IsAlive() then
			local a
			local c
			if IsValidEntity(ability) then a = ability end
			if IsValidEntity(caster) then c = caster end
			target:TrueKill(a, c)
			target:EmitSound("Hero_VengefulSpirit.MagicMissileImpact")
		end
		DemonKingBarTimers[timerIndex] = nil
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