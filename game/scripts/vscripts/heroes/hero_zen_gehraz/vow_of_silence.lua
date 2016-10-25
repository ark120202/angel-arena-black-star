function OnAbilityExecuted(keys)
	local caster = keys.caster
	local unit = keys.unit
	local ability = keys.ability
	local event_ability = keys.event_ability
	if not event_ability:IsItem() then
		unit:AddNewModifier(caster, ability, "modifier_silence", {duration = ability:GetAbilitySpecial("debuff_duration")})
		local enemies = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, ability:GetAbilitySpecial("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _,v in ipairs(enemies) do
			if v ~= unit then
				v:AddNewModifier(caster, ability, "modifier_stunned", {duration = ability:GetAbilitySpecial("debuff_duration")})
			end
		end
	end
end