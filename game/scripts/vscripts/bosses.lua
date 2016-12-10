if Bosses == nil then
	Bosses = class({})
	Bosses.MinimapPoints = {}
end

function Bosses:InitAllBosses()
	Bosses:SpawnStaticBoss("l1_v1")
	Bosses:SpawnStaticBoss("l1_v2")
	Bosses:SpawnStaticBoss("l2_v1")
	Bosses:SpawnStaticBoss("l2_v2")
	Bosses:SpawnStaticBoss("central")
	Bosses:SpawnStaticBoss("heaven")
	Bosses:SpawnStaticBoss("hell")
end

function IsBossEntity(unit)
	return string.find(unit:GetUnitName(), "npc_arena_boss_")
end

function Bosses:SpawnStaticBoss(name)
	for _,v in ipairs(Entities:FindAllByName("target_mark_bosses_" .. name)) do
		Bosses.MinimapPoints[v] = DynamicMinimap:CreateMinimapPoint(v:GetAbsOrigin(), "icon_boss_" .. name)
		Bosses:SpawnBossUnit(name, v)
	end
end

function Bosses:SpawnBossUnit(name, spawner)
	DynamicMinimap:SetVisibleGlobal(Bosses.MinimapPoints[spawner], true)
	local boss = CreateUnitByName("npc_arena_boss_" .. name, spawner:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_NEUTRALS)
	boss.SpawnerEntity = spawner
	Bosses:MakeBossAI(boss, name)
	return boss
end

function Bosses:RegisterKilledBoss(unit, team)
	local unitname = unit:GetUnitName()
	local bossname = string.gsub(unitname, "npc_arena_boss_", "")
	local amount = unit:GetKeyValue("Bosses_GoldToAll")
	local p1, p2 = CreateGoldNotificationSettings(amount)
	DynamicMinimap:SetVisibleGlobal(Bosses.MinimapPoints[unit.SpawnerEntity], false)
	
	Notifications:TopToAll({text="#" .. unitname})
	Notifications:TopToAll({text="#bosses_killed_p1", continue=true})
	Notifications:TopToAll(CreateTeamNotificationSettings(team, true))
	Notifications:TopToAll({text="#bosses_killed_p2", continue=true})
	Notifications:TopToAll(p1)
	Notifications:TopToAll(p2)
	for _,v in ipairs(GetPlayersInTeam(team)) do
		Gold:ModifyGold(v, amount)
	end
	Timers:CreateTimer(unit:GetKeyValue("Bosses_RespawnDuration"), function()
		Bosses:SpawnBossUnit(bossname, unit.SpawnerEntity)
	end)
end

function Bosses:MakeBossAI(unit, name)
	unit:SetIdleAcquire(false)
	local aiTable = {
		leashRange = 1000,
	}
	local profile = "boss"
	--[[if name == "roshan" then
		local boss_roshan_spikes = unit:FindAbilityByName("boss_roshan_spikes")
		aiTable["abilityCastCallback"] = function(self)
			local unitsInRange = self:FindUnitsNearby(boss_roshan_spikes:GetAbilitySpecial("length") - 200, false, true, DOTA_UNIT_TARGET_HERO)
			if #unitsInRange > 0 then
				local spikesTarget
				for _,v in ipairs(unitsInRange) do
					if v:GetHealth() <= boss_roshan_spikes:GetAbilityDamage() then
						spikesTarget = v
					end
				end
				if not spikesTarget then
					spikesTarget = unitsInRange[RandomInt(1, #unitsInRange)]
				end
				if spikesTarget then
					self:UseAbility(boss_roshan_spikes, spikesTarget:GetAbsOrigin())
				end
			end
		end
	end]]
	if name == "central" then
		profile = "tower"
	end

	local ai = SimpleAI:new(unit, profile, aiTable)
end

