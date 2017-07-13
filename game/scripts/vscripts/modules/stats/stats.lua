StatsClient = StatsClient or class({})
ModuleRequire(..., "data")

function StatsClient:Init()
	PlayerTables:CreateTable("stats_client", {}, AllPlayersInterval)
	PlayerTables:CreateTable("stats_team_rating", {}, AllPlayersInterval)
	CustomGameEventManager:RegisterListener("stats_client_add_guide", Dynamic_Wrap(StatsClient, "AddGuide"))
	CustomGameEventManager:RegisterListener("stats_client_vote_guide", Dynamic_Wrap(StatsClient, "VoteGuide"))
end

function StatsClient:FetchTopPlayers()
	StatsClient:Send("fetchTopPlayers", nil, function(response)
		PlayerTables:CreateTable("loading_top_players", response, AllPlayersInterval)
	end, nil, "GET")
end

function StatsClient:FetchPreGameData()
	local data = {
		matchid = tostring(GameRules:GetMatchID()),
		players = {},
	}
	for i = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:IsValidPlayerID(i) and not IsPlayerAbandoned(i) then
			data.players[i] = PlayerResource:GetRealSteamID(i)
		end
	end
	--Should return rating table
	StatsClient:Send("fetchPreGameMatchData", data, function(response)
		local teamRatings = {}
		for pid, data in pairs(response) do
			pid = tonumber(pid)
			local team = PlayerResource:GetTeam(pid)

			teamRatings[team] = teamRatings[team] or {}
			table.insert(teamRatings[team], data.Rating or (2500 + (data.TBDRating or 0)))

			PLAYER_DATA[pid].serverData = data
			PLAYER_DATA[pid].Inventory = data.inventory or {}

			local clientData = table.deepcopy(data)
			clientData.TBDRating = nil
			PlayerTables:SetTableValue("stats_client", pid, clientData)
		end

		for team, values in pairs(teamRatings) do
			debugp("StatsClient:FetchPreGameData", "Set team #" .. tostring(team) .. "'s average rating to " .. table.average(values))
			PlayerTables:SetTableValue("stats_team_rating", team, math.round(table.average(values)))
		end
	end, math.huge)
end

function StatsClient:OnGameEnd(winner)
	local status, nextCall = xpcall(function()
		if GameMode.Broken then
			PlayerTables:CreateTable("stats_game_result", {error = "arena_end_screen_error_broken"}, AllPlayersInterval)
			return
		end
		if not IsInToolsMode() and StatsClient.GameEndScheduled then return end
		StatsClient.GameEndScheduled = true
		local time = GameRules:GetDOTATime(false, true)
		local matchID = tostring(GameRules:GetMatchID())
		local debug = true
		if (GameRules:IsCheatMode() and not StatsClient.Debug) or time < 0 then
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
					score = Teams:GetScore(i),
				}
			end
		end

		for i = 0, DOTA_MAX_TEAM_PLAYERS-1 do
			if PlayerResource:IsValidPlayerID(i) then
				local hero = PlayerResource:GetSelectedHeroEntity(i)
				local playerInfo = {
					abandoned = IsPlayerAbandoned(i),
					steamid = PlayerResource:GetRealSteamID(i),

					heroDamage = PlayerResource:GetPlayerStat(i, "heroDamage"),
					bossDamage = PlayerResource:GetPlayerStat(i, "bossDamage"),
					heroHealing = PlayerResource:GetHealing(i),
					duelsPlayed = PlayerResource:GetPlayerStat(i, "Duels_Played"),
					duelsWon = PlayerResource:GetPlayerStat(i, "Duels_Won"),
					kills = PlayerResource:GetKills(i),
					deaths = PlayerResource:GetDeaths(i),
					assists = PlayerResource:GetAssists(i),
					lasthits = PlayerResource:GetLastHits(i),
					heroName = HeroSelection:GetSelectedHeroName(i) or "",
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
					if playerInfo.heroName == "" then playerInfo.heroName = hero:GetFullName() end
				end
				playerInfo.netWorth = Gold:GetGold(i)
				for slot, item in pairs(playerInfo.items) do
					playerInfo.netWorth = playerInfo.netWorth + GetTrueItemCost(item.name)
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
					local sentData = data.players[pid]
					clientData.players[pid] = {
						hero = sentData.heroName,
						heroDamage = sentData.heroDamage,
						bossDamage = sentData.bossDamage,
						heroHealing = sentData.heroHealing,

						netWorth = sentData.netWorth,
						bonus_str = sentData.bonus_str,
						bonus_agi = sentData.bonus_agi,
						bonus_int = sentData.bonus_int,
						items = sentData.items,

						ratingNew = receivedData.ratingNew,
						ratingOld = receivedData.ratingOld,
						ratingGamesRemaining = receivedData.ratingGamesRemaining or 10,
						experienceNew = receivedData.experienceNew or 0,
						experienceOld = receivedData.experienceOld or 0,
					}
				end
				PlayerTables:CreateTable("stats_game_result", clientData, AllPlayersInterval)
			end
		end, math.huge, nil, true)
	end, function(msg)
		return msg..'\n'..debug.traceback()..'\n'
	end)
	if not status then
		print(nextCall)
		CPrint(nextCall)
		PlayerTables:CreateTable("stats_game_result", {error = nextCall}, AllPlayersInterval)
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
	local steamID = PlayerResource:GetRealSteamID(playerID)
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
		steamID = PlayerResource:GetRealSteamID(data.PlayerID),
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
	local request = CreateHTTPRequestScriptVM(protocol or "POST", self.ServerAddress .. path .. (protocol == "GET" and StatsClient:EncodeParams(data) or ""))
	request:SetHTTPRequestGetOrPostParameter("data", JSON:encode(data))
	request:Send(function(response)
		if response.StatusCode ~= 200 or not response.Body then
			debugp("StatsClient:Send", "Server returned an error, status is " .. response.StatusCode)
			if response.Body then
				debugp("StatsClient:Send", response.StatusCode .. ": " .. response.Body)
			end
			local currentRetry = (_currentRetry or 0) + 1
			if not StatsClient.Debug and currentRetry < retryCount then
				Timers:CreateTimer(self.RetryDelay, function()
					debugp("StatsClient:Send", "Retry (" .. currentRetry .. ")")
					StatsClient:Send(path, data, callback, retryCount, protocol, onerror, currentRetry)
				end)
			elseif onerror then
				debugp("StatsClient:Send", "Retries for " .. path .." just stopped.")
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

function StatsClient:EncodeParams(params)
	if type(params) ~= "table" or next(params) == nil then return "" end
	local str = "/?"
	for k,v in pairs(params) do
		k = k:gsub("([^%w ])", function(c) return string.format("%%%02X", string.byte(c)) end):gsub(" ", "+")
		v = v:gsub("([^%w ])", function(c) return string.format("%%%02X", string.byte(c)) end):gsub(" ", "+")
		str = str + k + "=" + v
	end
	return str
end
