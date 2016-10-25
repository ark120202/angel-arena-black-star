function OnBossDeath(keys)
	local ability = keys.ability
	local caster = keys.caster
	if not caster.IsDominatedBoss then
		local bossLoc = caster:GetAbsOrigin()
		local p1 = Entities:FindByName(nil, "target_mark_boss_spawner_ttarget"):GetAbsOrigin()
		local p2 = Entities:FindByName(nil, "target_mark_boss_spawner"):GetAbsOrigin()
		local l1 = (bossLoc - p1):Length2D()
		local l2 = (bossLoc - p2):Length2D()
		local portalPoint = Vector(0, 0, 0)
		if l1 > l2 then
			portalPoint = p1
		else
			portalPoint = p2
		end
		Bosses:ClosePortals()
		local targetPoint = Entities:FindByName(nil, "target_mark_bosses_thome_team" .. caster.portalTeam):GetAbsOrigin()
		local portal = CreatePortal(portalPoint, targetPoint, 80, "particles/customgames/capturepoints/cp_wood.vpcf", nil, true, nil, nil)
		Notifications:TopToAll({text="#bosses_essential_killed", duration=7})
		Bosses:RegisterKilledBoss(caster:GetUnitName())
		Timers:CreateTimer(60, function()
			Bosses.Portals.InKilling = false
			portal:RemoveSelf()
		end)
		Timers:CreateTimer(BOSSES_SETTINGS.BOSS_KEEPER_RESPAWN_TIME, function() Bosses:EnableBossKeeper() end)
	end
end