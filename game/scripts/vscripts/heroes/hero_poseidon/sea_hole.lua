function DummyThink(keys)
	local caster = keys.caster
	local dummy = keys.target
	local ability = keys.ability
	local level = ability:GetLevel() - 1
	local think_interval = ability:GetLevelSpecialValueFor("think_interval", level)
	local pull_speed = ability:GetLevelSpecialValueFor("pull_per_second", level) * think_interval
	local slow_min_pct = ability:GetLevelSpecialValueFor("slow_min_pct", level)
	local slow_max_pct = ability:GetLevelSpecialValueFor("slow_max_pct", level)
	local dummyPosition = dummy:GetAbsOrigin()
	local radius = ability:GetLevelSpecialValueFor("aoe_radius", level)
	for _,v in ipairs(FindUnitsInRadius(caster:GetTeam(), dummyPosition, nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)) do
		if not v:IsMagicImmune() and not v:IsRooted() then
			local targetPosition = v:GetAbsOrigin()
			local len = (dummyPosition - targetPosition):Length2D()
			FindClearSpaceForUnit(v, len <= pull_speed and targetPosition or (targetPosition + (dummyPosition - targetPosition):Normalized() * pull_speed), false)
			local perMapUnit = (slow_max_pct - slow_min_pct) / radius
			local slow = slow_min_pct + perMapUnit * (radius - len)
			ability:ApplyDataDrivenModifier(caster, v, "modifier_poseidon_sea_hole_slow", nil)
			v:SetModifierStackCount("modifier_poseidon_sea_hole_slow", caster, math.abs(slow))
		end
	end
end