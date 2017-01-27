function Attacks(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	for _,v in ipairs(FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, ability:GetCastRange(caster:GetAbsOrigin(), nil), ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)) do
		PerformGlobalAttack(caster, v, true, true, true, true, true, false, false)
	end
end