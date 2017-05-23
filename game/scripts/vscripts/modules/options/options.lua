Options = Options or class({})
Options.Values = Options.Values or {}
Options.PreGameVotings = Options.PreGameVotings or {}

function Options:SetValue(name, value)
	--if type(value) == "boolean" then value = value and 1 or 0 end
	Options.Values[name] = value
	PlayerTables:SetTableValue("options", name, value)
end

function Options:GetValue(name)
	return Options.Values[name]
end

function Options:IsEquals(name, value)
	--if type(value) == "boolean" then value = value and 1 or 0 end
	return Options:GetValue(name) == value
end

function Options:SetPreGameVoting(name, variants, default, calculation)
	Options.PreGameVotings[name] = {
		votes = {},
		variants = table.deepcopy(variants),
		default = default,
		calculation = calculation
	}
	PlayerTables:SetTableValue("option_votings", name, Options.PreGameVotings[name])
	return Options.PreGameVotings[name]
end

function Options:OnVote(data)
	local voteTable = Options.PreGameVotings[data.name]
	if table.contains(voteTable.variants, data.vote) then
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
	Options:SetValue("EnableAbilityShop", false)
	Options:SetValue("EnableRandomAbilities", false)
	Options:SetValue("EnableStatisticsCollection", true)
	Options:SetValue("EnableRatingAffection", false)
	--Options:SetValue("MapLayout", "5v5")

	Options:SetValue("BanningPhaseBannedPercentage", 0)
	Options:SetValue("MainHeroList", "Selection")

	--Can be not networkable
	Options:SetValue("PlayerCount", 10)

	Options:SetValue("PreGameTime", 60)

	Options:SetPreGameVoting("kill_limit", {75, 100, 125, 150}, 125, {
		calculationFunction = "/",
		callback = function(value)
			GameRules:SetKillGoal(math.round(value))
		end
	})
end

function Options:LoadMapValues()
	local mapName = GetMapName()
	local underscoreIndex = mapName:find("_")
	local landscape = underscoreIndex and mapName:sub(1, underscoreIndex - 1) or mapName
	local gamemode = underscoreIndex and mapName:sub(underscoreIndex - #mapName) or ""

	if gamemode == "custom_abilities" then
		for k,t in pairs(DROP_TABLE) do
			for i,info in ipairs(t) do
				if string.starts(info.Item, "item_god_transform_") then
					table.remove(DROP_TABLE[k], i)
				end
			end
		end
		Options:SetValue("MainHeroList", "NoAbilities")
		Options:SetPreGameVoting("custom_abilities", {"random_omg", "ability_shop"}, "ability_shop", {
			calculationFunction = ">",
			callback = function(value)
				Options:SetValue("EnableAbilityShop", value == "ability_shop")
				Options:SetValue("EnableRandomAbilities", value == "random_omg")
			end
		})
	elseif gamemode == "ranked" then
		Options:SetValue("EnableRatingAffection", true)
		Options:SetValue("BanningPhaseBannedPercentage", 50)
	end
	if landscape == "4v4v4v4" then
		MAP_LENGTH = 9216
		USE_AUTOMATIC_PLAYERS_PER_TEAM = false
		MAX_NUMBER_OF_TEAMS = 4
		CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_GOODGUYS] = 4
		CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_BADGUYS] = 4
		CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_1] = 4
		CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_2] = 4
		USE_CUSTOM_TEAM_COLORS = true
	end
end

function Options:LoadCheatValues()
	
end

function Options:LoadToolsValues()
	Options:SetValue("PreGameTime", 0)
end

function Options:Preload()
	if not PlayerTables:TableExists("options") then PlayerTables:CreateTable("options", {}, AllPlayersInterval) end
	if not PlayerTables:TableExists("option_votings") then PlayerTables:CreateTable("option_votings", {}, AllPlayersInterval) end

	Options:LoadDefaultValues()
	Options:LoadMapValues()
	if GameRules:IsCheatMode() then Options:LoadCheatValues() end
	if IsInToolsMode() then Options:LoadToolsValues() end
end