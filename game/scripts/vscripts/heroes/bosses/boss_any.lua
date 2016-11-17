function OnBossDeath(keys)
	local caster = keys.caster
	local attacker = keys.attacker

	if attacker and not caster.IsDominatedBoss then
		Bosses:RegisterKilledBoss(caster, attacker:GetTeam())
	end
end