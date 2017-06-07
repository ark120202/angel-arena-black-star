if StatsClient == nil then
	_G.StatsClient = class({})

	StatsClient.RetryDelay = 5
end
StatsClient.ServerAddress = false and "https://stats.dota-aabs.com/" or "http://127.0.0.1:6502/"

function StatsClient:Init()
	PlayerTables:CreateTable("stats_client", {}, AllPlayersInterval)
	PlayerTables:CreateTable("stats_team_rating", {}, AllPlayersInterval)
	CustomGameEventManager:RegisterListener("stats_client_add_guide", Dynamic_Wrap(StatsClient, "AddGuide"))
	CustomGameEventManager:RegisterListener("stats_client_vote_guide", Dynamic_Wrap(StatsClient, "VoteGuide"))
end

function StatsClient:FetchPreGameData()
	local data = {
		matchid = tostring(GameRules:GetMatchID()),
		players = {},
	}
	for i = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:IsValidPlayerID(i) and not IsPlayerAbandoned(i) then
			data.players[i] = tostring(PlayerResource:GetSteamID(i))
		end
	end
	--Should return rating table
	StatsClient:Send("fetchPreGameMatchData", data, function(response)
		local teamRatings = {}
		for pid, data in pairs(response) do
			pid = tonumber(pid)
			local team = PlayerResource:GetTeam(pid)

			teamRatings[team] = teamRatings[team] or {}
			local rating = data.Rating or (3000 + data.TBDRating)
			if rating then table.insert(teamRatings[team], rating) end

			PLAYER_DATA[pid].serverData = data
			PLAYER_DATA[pid].Inventory = data.inventory or {}

			local clientData = table.deepcopy(data)
			clientData.TBDRating = nil
			PlayerTables:SetTableValue("stats_client", pid, clientData)
		end

		for team, values in pairs(teamRatings) do
			debugp("StatsClient:FetchPreGameData", "Set team #" .. tostring(team) .. "'s average rating to " .. table.average(values))
			PlayerTables:SetTableValue("stats_team_rating", team, table.average(values))
		end

	end, math.huge)
end

function StatsClient:OnGameEnd(winner)
	local status, nextCall = xpcall(fun, function (msg)
		local time = GameRules:GetDOTATime(false, true)
		local matchID = tostring(GameRules:GetMatchID())
		local debug = true
		if (GameRules:IsCheatMode() and not debug) or time < 0 then
			return
		end
		local data = {
			version = ARENA_VERSION,
			matchID = matchID,
			players = {},
			killGoal = KILLS_TO_END_GAME_FOR_TEAM,
			teamsInfo = {},
			version = ARENA_VERSION,
			duration = math.floor(time),
			flags = {
				isRanked = Options:IsEquals("EnableRatingAffection")
			}
		}

		for i = DOTA_TEAM_FIRST, DOTA_TEAM_CUSTOM_MAX do
			if GetTeamAllPlayerCount(i) > 0 then
				data.teamsInfo[tostring(i)] = {
					duelsWon = (Duel.TimesTeamWins[i] or 0),
					isGameWinner = i == winner,
					kills = GetTeamHeroKills(i),
				}
			end
		end

		for i = 0, DOTA_MAX_TEAM_PLAYERS-1 do
			if PlayerResource:IsValidPlayerID(i) then
				local hero = PlayerResource:GetSelectedHeroEntity(i)
				local playerInfo = {
					abandoned = IsPlayerAbandoned(i),
					steamid = tostring(PlayerResource:GetSteamID(i)),

					heroDamage = PlayerResource:GetPlayerStat(i, "DamageToEnemyHeroes"),
					duelsPlayed = PlayerResource:GetPlayerStat(i, "Duels_Played"),
					duelsWon = PlayerResource:GetPlayerStat(i, "Duels_Won"),
					kills = PlayerResource:GetKills(i),
					deaths = PlayerResource:GetDeaths(i),
					assists = PlayerResource:GetAssists(i),
					lasthits = PlayerResource:GetLastHits(i),
					heroName = HeroSelection:GetSelectedHeroName(i),
					bonus_str = 0,
					bonus_agi = 0,
					bonus_int = 0,

					team = tonumber(PlayerResource:GetTeam(i)),
					level = 0,
					items = {}
				}
				if IsValidEntity(hero) then
					playerInfo.level = hero:GetLevel()
					if hero.Additional_str then playerInfo.bonus_str = hero.Additional_str end
					if hero.Additional_agi then playerInfo.bonus_agi = hero.Additional_agi end
					if hero.Additional_int then playerInfo.bonus_int = hero.Additional_int end
					for item_slot = DOTA_ITEM_SLOT_1, DOTA_STASH_SLOT_6 do
						local item = hero:GetItemInSlot(item_slot)
						if item then
							playerInfo.items[item_slot] = {
								name = item:GetAbilityName(),
								charges = item:GetCurrentCharges()
							}
						end
					end
				end
				playerInfo.networth = Gold:GetGold(i)
				for slot, item in pairs(playerInfo.items) do
					playerInfo.networth = playerInfo.networth + GetTrueItemCost(item.name)
				end
				data.players[i] = playerInfo
			end
		end
		PrintTable(data)

		local clientData = {players = {}}

		StatsClient:Send("endMatch", data, function(response)
			PrintTable(response)
			if not response.players then
				PlayerTables:CreateTable("stats_game_result", response, AllPlayersInterval)
			else
				for pid, receivedData in pairs(response.players) do
					pid = tonumber(pid)
					print(pid)
					local sentData = data.players[pid]
					clientData.players[pid] = {
						hero = sentData.heroName,
						hero_damage = sentData.heroDamage,
						netWorth = sentData.networth,
						bonus_str = sentData.bonus_str,
						bonus_agi = sentData.bonus_agi,
						bonus_int = sentData.bonus_int,
						ratingNew = receivedData.ratingNew,
						ratingOld = receivedData.ratingOld,
						experienceNew = receivedData.experienceNew,
						experienceOld = receivedData.experienceOld,
					}
				end
				PlayerTables:CreateTable("stats_game_result", clientData, AllPlayersInterval)
			end
		end, math.huge, nil, true)
	end)
	if not status then
		PlayerTables:CreateTable("stats_game_result", {error = status}, AllPlayersInterval)
	end
end

function StatsClient:HandleError(err)
	if err and type(err) == "string" then
		StatsClient:Send("HandleError", {
			version = ARENA_VERSION,
			text = err
		})
	end
end

--Guides
function StatsClient:AddGuide(data)
	local playerID = data.PlayerID
	local hero = HeroSelection:GetSelectedHeroName(playerID)
	local steamID = tostring(PlayerResource:GetSteamID(playerID))
	if #data.title < 4 or #data.description < 4 then
		return
	end
	if #data.title > 60 or #data.description > 250 or table.count(data.items) == 0 then
		return
	end
	if not NPC_HEROES_CUSTOM[hero] or NPC_HEROES_CUSTOM[hero].Enabled == 0 then
		return
	end
	for _,group in ipairs(data.items) do
		if type(group.title) ~= "string" or #group.title > 20 then
			return
		end
		for _,item in ipairs(group.content) do
			if not KeyValues.ItemKV[item] then
				error("Invalid item", item)
			end
		end
	end

	if data.youtube ~= nil and (type(data.youtube) ~= "string" or #data.youtube == 0) then
		data.youtube = nil
	end

	StatsClient:Send("AddGuide", {
		title = data.title,
		description = data.description,
		steamID = steamID,
		hero = hero,
		items = data.items,
		youtube = data.youtube,
		version = ARENA_VERSION,
	}, function(response)
		if response.insertedId then
			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "stats_client_add_guide_success", {insertedId = response.insertedId})
		else
			Containers:DisplayError(playerID, response.error)
		end
	end)
end

function StatsClient:VoteGuide(data)
	StatsClient:Send("VoteGuide", {
		steamID = tostring(PlayerResource:GetSteamID(data.PlayerID)),
		id = data.id or "",
		vote = type(data.vote) == "number" and data.vote or 0
	})
end

function StatsClient:Send(path, data, callback, retryCount, protocol, onerror, _currentRetry)
	if type(retryCount) == "boolean" then
		retryCount = retryCount and math.huge or 0
	elseif not retryCount then
		retryCount = 0
	end
	debugp("StatsClient:Send", "Sent data to " .. path .. "(with current retry of " .. (_currentRetry or 0) .. ")")
	local request = CreateHTTPRequestScriptVM(protocol or "POST", self.ServerAddress .. path)
	request:SetHTTPRequestGetOrPostParameter("data", JSON:encode(data))
	request:Send(function(response)
		if response.StatusCode ~= 200 or not response.Body then
			debugp("StatsClient:Send", "Server returned an error, status is " .. response.StatusCode)
			if response.Body then
				debugp("StatsClient:Send", response.StatusCode .. ": " .. response.Body)
			end
			local currentRetry = (_currentRetry or 0) + 1
			if currentRetry < retryCount then
				Timers:CreateTimer(self.RetryDelay, function()
					debugp("StatsClient:Send", "Retry (" .. currentRetry .. ")")
					StatsClient:Send(path, data, callback, retryCount, protocol, onerror, currentRetry)
				end)
			elseif onerror then
				if onerror == true then onerror = callback end
				onerror(response.Body)
			end
		else
			local obj, pos, err = JSON:decode(response.Body, 1, nil)
			if not obj then
				debugp("[StatsClient] Critical Error: request to " .. self.ServerAddress .. path .. " returned undefined. Check server configuration")
			elseif callback then
				callback(obj)
			end
		end
	end)
end
