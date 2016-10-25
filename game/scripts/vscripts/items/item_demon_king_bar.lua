function StartTimer(keys)
	local target = keys.target
	local ability = keys.ability

	ability.EntTimers = ability.EntTimers or {}

	ability.EntTimers[target:GetEntityIndex()] = Timers:CreateTimer(ability:GetAbilitySpecial("curse_duration") - 0.1, function()
		if target:IsAlive() then
			TrueKill(keys.caster, ability, target)
			target:EmitSound("Hero_VengefulSpirit.MagicMissileImpact")
		end
		ability.EntTimers[target:GetEntityIndex()] = nil
	end)
end

function StopTimer(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if ability.EntTimers and ability.EntTimers[target:GetEntityIndex()] then
		Timers:RemoveTimer(ability.EntTimers[target:GetEntityIndex()])
		ability.EntTimers[target:GetEntityIndex()] = nil
	end
end