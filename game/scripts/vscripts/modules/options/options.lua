Options = Options or class({})
Options.Values = Options.Values or {}
Options.PreGameVotings = Options.PreGameVotings or {}

function Options:SetValue(name, value)
	--if type(value) == "boolean" then value = value and 1 or 0 end
	Options.Values[name] = value
	PlayerTables:SetTableValue("options", name, value)
end

function Options:SetInitialValue(name, value)
	--if type(value) == "boolean" then value = value and 1 or 0 end
	if not Options.Values[name] then
		Options.Values[name] = value
		PlayerTables:SetTableValue("options", name, value)
	end
end

function Options:GetValue(name)
	return Options.Values[name]
end

function Options:IsEquals(name, value)
	--if type(value) == "boolean" then value = value and 1 or 0 end
	if value == nil then value = true end
	return Options:GetValue(name) == value
end

function Options:SetPreGameVoting(name, variants, default, calculation)
	if not Options.PreGameVotings[name] then
		Options.PreGameVotings[name] = {votes = {}}
	end
	if variants then
		Options.PreGameVotings[name].variants = variants
	end
	if default then
		Options.PreGameVotings[name].default = default
	end
	if calculation then
		Options.PreGameVotings[name].calculation = calculation
	end

	PlayerTables:SetTableValue("option_votings", name, Options.PreGameVotings[name])
	return Options.PreGameVotings[name]
end

function Options:OnVote(data)
	local voteTable = Options.PreGameVotings[data.name]
	if table.includes(voteTable.variants, data.vote) then
		voteTable.votes[data.PlayerID] = data.vote
		CustomGameEventManager:Send_ServerToAllClients("option_votings_refresh", {name = data.name, data = voteTable})
		--PlayerTables:SetTableValue("option_votings", data.name, table.deepcopy(voteTable))
	end
end

function Options:CalculateVotes()
	for voteName, voteData in pairs(Options.PreGameVotings) do
		local counts = {}
		for player, voted in pairs(voteData.votes) do
			counts[voted] = (counts[voted] or 0) + 1
		end
		if table.count(counts) == 0 then
			counts[voteData.default] = 1
		end
		local calculation = voteData.calculation
		if type(calculation) == "function" then
			calculation(counts)
		elseif type(calculation) == "table" then
			local value = counts
			local calculationFunction = calculation.calculationFunction
			if calculationFunction then
				if type(calculationFunction) == "function" then
					value = calculationFunction(counts)
				elseif calculationFunction == "/" then
					local sum = 0
					local count = 0
					for v, num in pairs(counts) do
						sum = sum + v * num
						count = count + num
					end
					value = sum / count
				elseif calculationFunction == ">" then
					local key, max = next(counts)
					for k, v in pairs(counts) do
						if v > max then
							key, max = k, v
						elseif v == max and key ~= k and RollPercentage(50) then --TODO: better chance based roll
							key, max = k, v
						end
					end
					value = key
				else
					error("Unknown calculation function type")
				end
			end
			if calculation.callback then
				calculation.callback(value, counts)
			end
		else
			error("Unknown vote type")
		end
	end
	Options.PreGameVotings = {}
end

function Options:LoadDefaultValues()
	Options:SetInitialValue("EnableAbilityShop", false)
	Options:SetInitialValue("EnableRandomAbilities", false)
	Options:SetInitialValue("EnableStatisticsCollection", true)
	Options:SetInitialValue("EnableRatingAffection", false)
	Options:SetInitialValue("DynamicKillWeight", true)
	Options:SetInitialValue("TeamSetupMode", "open")
	Options:SetInitialValue("EnableBans", true)
	Options:SetInitialValue("CustomTeamColors", false)
	Options:SetInitialValue("KillLimit", 0)
	--Options:SetInitialValue("MapLayout", "5v5")

	Options:SetInitialValue("BanningPhaseBannedPercentage", 0)
	Options:SetInitialValue("MainHeroList", "Selection")

	--Can be not networkable
	Options:SetInitialValue("PreGameTime", 60)

	Options:SetPreGameVoting("kill_limit", {100, 125, 150, 175}, 150, {
		calculationFunction = "/",
		callback = function(value)
			Options:SetValue("KillLimit", math.round(value))
		end
	})
end

function Options:LoadMapValues()
	local mapName = GetMapName()
	local underscoreIndex = mapName:find("_")
	local landscape = underscoreIndex and mapName:sub(1, underscoreIndex - 1) or mapName
	local gamemode = underscoreIndex and mapName:sub(underscoreIndex - #mapName) or ""

	if gamemode == "custom_abilities" then
		Options:SetValue("MainHeroList", "NoAbilities")
		Options:SetValue("EnableAbilityShop", true)
		CustomAbilities:PostAbilityShopData()
	elseif gamemode == "ranked" then
		Options:SetValue("EnableRatingAffection", true)
		Options:SetValue("BanningPhaseBannedPercentage", 80)

		GameRules:SetCustomGameSetupAutoLaunchDelay(-1)
		GameRules:LockCustomGameSetupTeamAssignment(true)
		GameRules:EnableCustomGameSetupAutoLaunch(false)
		Options:SetValue("TeamSetupMode", "balanced")

		Events:Once("AllPlayersLoaded", function()
			local playerCount = GetInGamePlayerCount()
			local desiredPlayerCount = Teams:GetTotalDesiredPlayerCount()
			local failed = not StatsClient.Debug and (matchID == 0 or playerCount < desiredPlayerCount)

			if failed then
				GameMode:BreakSetup("Not enough players. Ranked games are meant to be full.")
				return
			end

			StatsClient:AssignTeams(function(response)
				for i = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
					local player = PlayerResource:GetPlayer(i)
					if player then player:SetTeam(DOTA_TEAM_NOTEAM) end
				end

				for team, players in ipairs(response) do
					for _, player in ipairs(players) do
						local player = PlayerResource:GetPlayer(player)
						if player then player:SetTeam(team + 1) end
					end
				end

				GameRules:FinishCustomGameSetup()
			end)
		end, true)
	elseif gamemode == "" then
		Options:SetValue("BanningPhaseBannedPercentage", 40)
	end
	if landscape == "4v4v4v4" then
		MAP_LENGTH = 9216
		Options:SetValue("CustomTeamColors", true)
	end
	if landscape == "1v1" then
		MAP_LENGTH = 3840
		Options:SetValue("DynamicKillWeight", false)
		Options:SetPreGameVoting("kill_limit", {10, 15, 20, 25, 30, 35}, 25)
		-- Would be pretty annoying for enemy
		Options:SetValue("EnableBans", false)
	end
end

function Options:LoadCheatValues()
	Options:SetValue("EnableBans", false)
end

function Options:LoadToolsValues()
	Options:SetInitialValue("PreGameTime", 0)
end

function Options:Preload()
	if not PlayerTables:TableExists("options") then PlayerTables:CreateTable("options", {}, AllPlayersInterval) end
	if not PlayerTables:TableExists("option_votings") then PlayerTables:CreateTable("option_votings", {}, AllPlayersInterval) end

	Options:LoadDefaultValues()
	Options:LoadMapValues()
	if GameRules:IsCheatMode() then Options:LoadCheatValues() end
	if IsInToolsMode() then Options:LoadToolsValues() end
end
