function UpdateHealth(keys)
	local caster = keys.caster
	local ability = keys.ability
	local max_health = ability:GetLevelSpecialValueFor("max_health_pct", ability:GetLevel() - 1) * 0.01
	if caster:GetHealth() / caster:GetMaxHealth() > max_health then
		caster:SetHealth(caster:GetMaxHealth() * max_health)
	end
end