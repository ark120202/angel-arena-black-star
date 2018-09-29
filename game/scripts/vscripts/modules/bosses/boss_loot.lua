function Bosses:CreateBossLoot(unit, team)
	local id = team .. "_" .. Bosses.NextVoteID
	Bosses.NextVoteID = Bosses.NextVoteID + 1
	local dropTables = PlayerTables:copy(DROP_TABLE[unit:GetUnitName()])

	local totalDamage = 0
	local damageByPlayers = {}
	for playerId, damage in pairs(unit.DamageReceived) do
		if PlayerResource:IsValidPlayerID(playerId) and not PlayerResource:IsPlayerAbandoned(playerId) and team == PlayerResource:GetTeam(playerId) then
			damageByPlayers[playerId] = (damageByPlayers[playerId] or 0) + damage
		end
		totalDamage = totalDamage + damage
	end
	local damagePcts = {}
	for playerId, damage in pairs(damageByPlayers) do
		damagePcts[playerId] = damage/totalDamage*100
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
	local itemcount = RandomInt(math.min(5, #dropTables), math.min(6, #dropTables))
	if dropTables.hero and not Options:IsEquals("MainHeroList", "NoAbilities") and not HeroSelection:IsHeroSelected(dropTables.hero) then
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
		-- Iterate over all entries
		for _, entry in pairs(t.rollableEntries) do
			local selectedPlayers = {}
			local bestPctLeft = -math.huge
			-- Iterate over all voted players and select player with biggest priority points
			for playerId, s in pairs(entry.votes) do
				damagePcts[playerId] = damagePcts[playerId] or 0
				local totalPointsAfterReduction = damagePcts[playerId] - entry.weight
				if s and totalPointsAfterReduction >= bestPctLeft and not PlayerResource:IsPlayerAbandoned(playerId) then
					if totalPointsAfterReduction > bestPctLeft then
						selectedPlayers = {}
					end
					table.insert(selectedPlayers, playerId)
					damagePcts[playerId] = totalPointsAfterReduction
					bestPctLeft = totalPointsAfterReduction
				end
			end
			if #selectedPlayers > 0 then
				local selectedPlayer = selectedPlayers[RandomInt(1, #selectedPlayers)]
				Bosses:GivePlayerSelectedDrop(selectedPlayer, entry)
			else
				local ntid = team .. "_" .. -1
				local tt = PlayerTables:GetTableValue("bosses_loot_drop_votes", ntid) or {}
				entry.votes = nil
				entry.weight = nil
				table.insert(tt, entry)
				PlayerTables:SetTableValue("bosses_loot_drop_votes", ntid, tt)
			end
		end
		PlayerTables:SetTableValue("bosses_loot_drop_votes", id, nil)
	end)
end

function Bosses:VoteForItem(data)
	local splittedId = data.voteid:split("_")
	local playerId = data.PlayerID
	local t = PlayerTables:GetTableValue("bosses_loot_drop_votes", data.voteid)
	if t and not PlayerResource:IsPlayerAbandoned(playerId) and PlayerResource:GetTeam(playerId) == tonumber(splittedId[1]) then
		if t.rollableEntries and t.rollableEntries[tonumber(data.entryid)] then
			t.rollableEntries[tonumber(data.entryid)].votes[playerId] = not t.rollableEntries[tonumber(data.entryid)].votes[playerId]
		else
			-- -1
			local entry = t[tonumber(data.entryid)]
			if entry then
				Bosses:GivePlayerSelectedDrop(playerId, entry)
				table.remove(t, tonumber(data.entryid))
			end
		end
		PlayerTables:SetTableValue("bosses_loot_drop_votes", data.voteid, t)
	end
end

function Bosses:GivePlayerSelectedDrop(playerId, entry)
	if entry.item then
		local hero = PlayerResource:GetSelectedHeroEntity(playerId)
		if hero then
			PanoramaShop:PushItem(playerId, hero, entry.item, true)
		end
	else
		local newHero = entry.hero
		function ActuallyReplaceHero()
			if PlayerResource:GetSelectedHeroEntity(playerId) and not HeroSelection:IsHeroSelected(newHero) then
				Timers:CreateTimer(function()
					if not HeroSelection:ChangeHero(playerId, newHero, true, 0) then
						return 0.1
					end
				end)
			else
				Notifications:Bottom(playerId, {text="hero_selection_change_hero_selected"})
			end
		end
		if Duel:IsDuelOngoing() then
			Notifications:Bottom(playerId, {text="boss_loot_vote_hero_duel_delayed"})
			Events:Once("Duel/end", ActuallyReplaceHero)
		else
			ActuallyReplaceHero()
		end
	end
end
