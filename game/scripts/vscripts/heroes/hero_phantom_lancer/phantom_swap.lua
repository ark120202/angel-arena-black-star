function Swap(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]
	local target
	local range
	for _,v in ipairs(FindUnitsInRadius(caster:GetTeamNumber(), point, nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_CLOSEST, true)) do
		if v:IsIllusion() and v:IsAlive() and (not range or (v:GetAbsOrigin()-point):Length2D() < range) then
			target = v
			range = (v:GetAbsOrigin()-point):Length2D()
		end
	end
	if target then
		ParticleManager:SetParticleControl(ParticleManager:CreateParticle("particles/arena/units/heroes/hero_phantom_lancer/phantom_swap.vpcf", PATTACH_ABSORIGIN, caster), 1, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(ParticleManager:CreateParticle("particles/arena/units/heroes/hero_phantom_lancer/phantom_swap.vpcf", PATTACH_ABSORIGIN, target), 1, caster:GetAbsOrigin())
		local casterOrigin = caster:GetAbsOrigin()
		local casterForward = caster:GetForwardVector()
		local targetOrigin = target:GetAbsOrigin()
		local targetForward = target:GetForwardVector()
		caster:SetAbsOrigin(targetOrigin)
		caster:SetForwardVector(targetForward)
		caster:Stop()
		target:SetAbsOrigin(casterOrigin)
		target:SetForwardVector(casterForward)
		target:Stop()
	else
		Containers:DisplayError(caster:GetPlayerID(), "#dota_hud_error_phantom_swap_no_illusions")
		ability:EndCooldown()
		ability:RefundManaCost()
	end
end