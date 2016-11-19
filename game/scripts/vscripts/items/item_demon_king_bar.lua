function StartTimer(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

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