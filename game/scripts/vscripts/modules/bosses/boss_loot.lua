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
		rollableEntries = {},
		team = team
	}
	local itemcount = RandomInt(math.min(5, #dropTables), math.min(7, #dropTables))
	if dropTables.hero then
		table.insert(t.rollableEntries, {
			hero = dropTables.hero,
			weight = 0,
			votes = {}
		})
	end
	while #t.rollableEntries < itemcount do
		table.shuffle(dropTables)
		for k,dropTable in ipairs(dropTables) do
			if RollPercentage(dropTable.DropChance) then
				table.insert(t.rollableEntries, {
					item = dropTable.Item,
					weight = dropTable.DamageWeightPct or 10,
					votes = {}
				})
				table.remove(dropTables, k)
				if #t.rollableEntries >= itemcount then
					break
				end
			end
		end
	end
	PlayerTables:SetTableValue("bosses_loot_drop_votes", id, t)
	Timers:CreateTimer(30, function()
		-- Take new data
		t = PlayerTables:GetTableValue("bosses_loot_drop_votes", id)
		-- Iterate over all vote entries
		for _, entry in pairs(t.rollableEntries) do
			local selectedPlayers = {}
			local bestPctLeft = -math.huge
			if table.count(entry.votes) > 0 then
				for pid, s in pairs(entry.votes) do
					damagePcts[pid] = damagePcts[pid] or 0
					local totalPointsAfterReduction = damagePcts[pid] - entry.weight
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
				print(selectedPlayer, "just rolled", entry.item)
				local hero = PlayerResource:GetSelectedHeroEntity(selectedPlayer)
				if hero then
					PanoramaShop:PushItem(selectedPlayer, hero, entry.item, true)
				end
			else
				local ntid = team .. "_" .. -1
				local tt = PlayerTables:GetTableValue("bosses_loot_drop_votes", ntid) or {}
				table.insert(tt, entry.item)
				PlayerTables:SetTableValue("bosses_loot_drop_votes", ntid, tt)
			end
		end
		PlayerTables:SetTableValue("bosses_loot_drop_votes", id, nil)
	end)
end

function Bosses:VoteForItem(data)
	local splittedId = data.voteid:split("_")
	local t = PlayerTables:GetTableValue("bosses_loot_drop_votes", data.voteid)
	if t and PlayerResource:GetTeam(data.PlayerID) == tonumber(splittedId[1]) then
		if t.rollableEntries and t.rollableEntries[tonumber(data.entryid)] then
			t.rollableEntries[tonumber(data.entryid)].votes[data.PlayerID] = not t.rollableEntries[tonumber(data.entryid)].votes[data.PlayerID]
		else
			local x = t[tonumber(data.entryid)]
			if x then
				local hero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
				if hero then
					PanoramaShop:PushItem(data.PlayerID, hero, x, true)
				end
				table.remove(t, tonumber(data.entryid))
			end
		end
		PlayerTables:SetTableValue("bosses_loot_drop_votes", data.voteid, t)
	end
end
