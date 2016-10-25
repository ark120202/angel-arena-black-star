if Bosses == nil then
	Bosses = class({})
	Bosses._KilledBosses = {}
	Bosses.BossKeeperEntity = nil
	Bosses.KeyDroppableFromCreeps = true
	Bosses.Portals = {
		AllOpened = function()
			for _,v in pairs(Bosses.Portals.Separately) do
				if not v.Teleport_Enabled then
					return false
				end
			end
			return true
		end,
		AnyOpened = function()
			for _,v in pairs(Bosses.Portals.Separately) do
				if v.Teleport_Enabled then
					return true
				end
			end
			return false
		end,
		InKilling = false,
		Separately = {}
	}
	Bosses.Portals.Separately[DOTA_TEAM_GOODGUYS] = {}
	Bosses.Portals.Separately[DOTA_TEAM_BADGUYS] = {}
end

local InvokerDebug = IsInToolsMode()

function Bosses:EnableBossKeeper()
	local abs = Bosses.BossKeeperEntity:GetAbsOrigin()
	Timers:CreateTimer(1, function()
		Bosses.BossKeeperEntity:SetAbsOrigin(Bosses.BossKeeperEntity:GetAbsOrigin() + Vector(0, 0, 1))
		local length = (abs - Bosses.BossKeeperEntity:GetAbsOrigin()):Length()
		if length >= 256 then
			Bosses.BossKeeperEntity:RemoveModifierByName("modifier_boss_keeper_opened")
			Bosses.KeyDroppableFromCreeps = true
			Notifications:TopToAll({text="#bosses_keeper_reactivated_p1", duration=9})
			Notifications:TopToAll(CreateItemNotificationSettings("item_boss_keeper_key"))
			Notifications:TopToAll({text="#bosses_keeper_reactivated_p2", continue=true})
		else
			return 0.0125
		end
	end)
end

function Bosses:InitAllBosses()
	for i = 2,3 do
		Bosses:CreateBossPortal("fire", i)
		Bosses:CreateBossPortal("water", i)
		Bosses:CreateBossPortal("earth", i)
		Bosses:CreateBossPortal("wind", i)
		Bosses:CreateBossPortal("primal", i)
	end
	Bosses:SpawnStaticBoss("heaven")
	Bosses:SpawnStaticBoss("hell")
	Bosses:SpawnStaticBoss("roshan")
end

function Bosses:CreateBossPortal(sName, team)
	Bosses.Portals.Separately[team][sName]= CreatePortal(Entities:FindByName(nil, "target_mark_bosses_teleport_" .. sName .. "_team" .. team):GetAbsOrigin(), Entities:FindByName(nil, "target_mark_boss_spawner_ttarget"):GetAbsOrigin(),
		80, BOSSES_SETTINGS[sName].ParticleEnabled, BOSSES_SETTINGS[sName].ParticleDisabled, false, function()
			if not Bosses.Portals.InKilling then
				Bosses:EnterPortal(sName)
				Notifications:TopToAll({text="#bossses_entered", duration=9})
				Bosses:SpawnBoss(sName, team)
			end
		end, sName)
end

function Bosses:OpenPortals(team)
	for i,v in pairs(Bosses.Portals.Separately[team]) do
		if i ~= "primal" or Bosses:AreAllKilled() or InvokerDebug then
			v:EnablePortal()
		end
	end
end

function Bosses:ClosePortals()
	for _,_v in pairs(Bosses.Portals.Separately) do
		for i,v in pairs(_v) do
			v:DisablePortal()
		end
	end
end

function Bosses:EnterPortal(sKey)
	for _,_v in pairs(Bosses.Portals.Separately) do
		for i,v in pairs(_v) do
			if i ~= sKey and (i ~= "primal" or Bosses:AreAllKilled() or InvokerDebug) then
				v:DisablePortal()
			end
		end
	end
	Bosses.Portals.InKilling = true
end

function Bosses:SpawnBoss(sName, portalTeam)
	local boss = CreateUnitByName("npc_dota_boss_" .. sName, Entities:FindByName(nil, "target_mark_boss_spawner"):GetAbsOrigin(), true, nil, nil, DOTA_TEAM_NEUTRALS)
	boss.portalTeam = portalTeam
	Bosses:MakeBossAI(boss, sName)
end

function IsBossEntity(unit)
	return string.find(unit:GetUnitName(), "npc_dota_boss_")
end

function Bosses:RegisterKilledBoss(unitname)
	local bossname = string.sub(unitname, 15) 
	if not table.contains(Bosses._KilledBosses, bossname) then table.insert(Bosses._KilledBosses, bossname) end 
end

function Bosses:AreAllKilled()
	if not table.contains(Bosses._KilledBosses, "primal") then
		for _,v in ipairs({"fire", "water", "earth", "wind"}) do
			if not table.contains(Bosses._KilledBosses, v) then return false end
		end
		return true
	else
		return true
	end
end

function Bosses:SpawnStaticBoss(name)
	Bosses:MakeBossAI(CreateUnitByName("npc_dota_boss_" .. name, Entities:FindByName(nil, "target_mark_bosses_" .. name):GetAbsOrigin(), true, nil, nil, DOTA_TEAM_NEUTRALS), name)
end

function Bosses:MakeBossAI(unit, name)
	unit:SetIdleAcquire(false) -- Отключаем ai доты
	local aiTable = {
		leashRange = 600,
	}
	if name == "roshan" then
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
	end
	if name == "water" then
		local boss_water_illusions_of_the_deep = unit:FindAbilityByName("boss_water_illusions_of_the_deep")

		aiTable["abilityCastCallback"] = function(self)
			if self.state == AI_STATE_AGGRESSIVE and self.aggroTarget then
				boss_water_illusions_of_the_deep.target = self.aggroTarget
				self:UseAbility(boss_water_illusions_of_the_deep, self.unit)
			end
		end
	end
	if name == "primal" then
		local boss_primal_sunstorm = unit:FindAbilityByName("boss_primal_sunstorm")

		aiTable["abilityCastCallback"] = function(self)
			local heroesInBossesArea = FindUnitsInBox(DOTA_TEAM_NEUTRALS, Entities:FindByName(nil, "target_mark_bosses_area_1"):GetAbsOrigin(), Entities:FindByName(nil, "target_mark_bosses_area_2"):GetAbsOrigin(),
				nil, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES)
			if #heroesInBossesArea >= 2 and self.unit:GetHealthPercent() < 80 then
				self:UseAbility(boss_primal_sunstorm, self.unit)
			end
		end
	end
	local ai = SimpleAI:new(unit, "boss", aiTable)
end