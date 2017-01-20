if Bosses == nil then
	Bosses = class({})
	Bosses.MinimapPoints = {}
	Bosses.NextVoteID = 0
end

function CDOTA_BaseNPC:IsBoss()
	return self.GetUnitName ~= nil and string.find(self:GetUnitName(), "npc_arena_boss_") ~= nil
end

function Bosses:InitAllBosses()
	CustomGameEventManager:RegisterListener("bosses_vote_for_item", Dynamic_Wrap(Bosses, "VoteForItem"))
	PlayerTables:CreateTable("bosses_loot_drop_votes", {}, GetPlayersInTeam(team))
	Bosses:SpawnStaticBoss("l1_v1")
	Bosses:SpawnStaticBoss("l1_v2")
	Bosses:SpawnStaticBoss("l2_v1")
	Bosses:SpawnStaticBoss("l2_v2")
	Bosses:SpawnStaticBoss("central")
	Bosses:SpawnStaticBoss("freya")
	Bosses:SpawnStaticBoss("zaken")
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
	Bosses:CreateBossLoot(unit, team)
	local amount = unit:GetKeyValue("Bosses_GoldToAll")
	DynamicMinimap:SetVisibleGlobal(Bosses.MinimapPoints[unit.SpawnerEntity], false)
	CustomGameEventManager:Send_ServerToAllClients("create_custom_toast", {
		type = "generic",
		text = "#custom_toast_BossKilled",
		victimUnitName = unitname,
		teamColor = team,
		team = team,
		gold = amount
	})
	for _,v in ipairs(GetPlayersInTeam(team)) do
		Gold:ModifyGold(v, amount)
	end
	Timers:CreateTimer(unit:GetKeyValue("Bosses_RespawnDuration"), function()
		Bosses:SpawnBossUnit(bossname, unit.SpawnerEntity)
	end)
end

function Bosses:CreateBossLoot(unit, team)
	local id = team .. "_" .. Bosses.NextVoteID
	Bosses.NextVoteID = Bosses.NextVoteID + 1
	local dropTables = PlayerTables:copy(DROP_TABLE[unit:GetUnitName()])

	local totalDamage = 0
	local damageByPlayers = {}
	for pid, damage in pairs(unit.DamageReceived) do
		if PlayerResource:IsValidPlayerID(pid) and not IsPlayerAbandoned(pid) and team == PlayerResource:GetTeam(pid) then
			damageByPlayers[pid] = (damageByPlayers[pid] or 0) + damage
		end
		totalDamage = totalDamage + damage
	end
	local damagePcts = {}
	for pid, damage in pairs(damageByPlayers) do
		damagePcts[pid] = damage/totalDamage*100
	end

	local t = {
		boss = unit:GetUnitName(),
		killtime = GameRules:GetGameTime(),
		time = 30,
		damageByPlayers = damageByPlayers,
		totalDamage = totalDamage,
		damagePcts = damagePcts,
		votes = {},
		team = team
	}
	local itemcount = RandomInt(math.min(5, #dropTables), math.min(7, #dropTables))
	while #t.votes < itemcount do
		table.shuffle(dropTables)
		for k,dropTable in ipairs(dropTables) do
			if RollPercentage(dropTable.DropChance) then
				table.insert(t.votes, {
					item = dropTable.Item,
					weight = dropTable.DamageWeightPct or 10,
					votes = {}
				})
				table.remove(dropTables, k)
				if #t.votes >= itemcount then
					break
				end
			end
		end
	end
	PlayerTables:SetTableValue("bosses_loot_drop_votes", id, t)
	Timers:CreateTimer(30, function()
		t = PlayerTables:GetTableValue("bosses_loot_drop_votes", id)
		for _, group in pairs(t.votes) do
			local selectedPlayers = {}
			local bestPctLeft = -math.huge
			if table.count(group.votes) > 0 then
				for pid, s in pairs(group.votes) do
					damagePcts[pid] = damagePcts[pid] or 0
					local totalPointsAfterReduction = damagePcts[pid] - group.weight
					if s and totalPointsAfterReduction >= bestPctLeft then
						if totalPointsAfterReduction > bestPctLeft then
							selectedPlayers = {}
						end
						table.insert(selectedPlayers, pid)
						damagePcts[pid] = totalPointsAfterReduction
						bestPctLeft = totalPointsAfterReduction
					end
				end
			end
			if #selectedPlayers > 0 then
				local selectedPlayer = selectedPlayers[RandomInt(1, #selectedPlayers)]
				print(selectedPlayer, "just rolled", group.item)
				local hero = PlayerResource:GetSelectedHeroEntity(selectedPlayer)
				if hero then
					PanoramaShop:PushItem(selectedPlayer, hero, group.item, true)
				end
			end
		end
		PlayerTables:SetTableValue("bosses_loot_drop_votes", id, nil)
	end)
--	ContainersHelper:CreateLootBox(unit:GetAbsOrigin() + RandomVector(100), items)
end

function Bosses:VoteForItem(data)
	local t = PlayerTables:GetTableValue("bosses_loot_drop_votes", data.voteid)
	if t and t.votes and t.votes[tonumber(data.itemid)] and PlayerResource:GetTeam(data.PlayerID) == t.team then
		t.votes[tonumber(data.itemid)].votes[data.PlayerID] = not t.votes[tonumber(data.itemid)].votes[data.PlayerID]
		PlayerTables:SetTableValue("bosses_loot_drop_votes", data.voteid, t)
	end
end

function Bosses:MakeBossAI(unit, name)
	unit:SetIdleAcquire(false)
	local aiTable = {
		leashRange = 1000,
	}
	local profile = "boss"
	if name == "freya" then
		local boss_freya_sharp_ice_shards = unit:FindAbilityByName("boss_freya_sharp_ice_shards")
		aiTable["abilityCastCallback"] = function(self)
			local unitsInRange = self:FindUnitsNearby(boss_freya_sharp_ice_shards:GetCastRange(unit:GetAbsOrigin(), nil) - 100, false, true, DOTA_UNIT_TARGET_HERO)
			if #unitsInRange > 0 then
				self:UseAbility(boss_freya_sharp_ice_shards)
			end
		end
		--[[aiTable["abilityCastCallback"] = function(self)
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
		end]]
	end
	if name == "central" then
		profile = "tower"
	end

	local ai = SimpleAI:new(unit, profile, aiTable)
end

--[[local boss = CreateUnitByName("npc_arena_boss_" .. "freya", Vector(0), true, nil, nil, DOTA_TEAM_NEUTRALS)
Bosses:MakeBossAI(boss, "freya")]]