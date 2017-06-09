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
	Options:SetInitialValue("EnableAbilityShop", false)
	Options:SetInitialValue("EnableRandomAbilities", false)
	Options:SetInitialValue("EnableStatisticsCollection", true)
	Options:SetInitialValue("EnableRatingAffection", false)
	Options:SetInitialValue("FailedRankedGame", false)
	--Options:SetInitialValue("MapLayout", "5v5")

	Options:SetInitialValue("BanningPhaseBannedPercentage", 0)
	Options:SetInitialValue("MainHeroList", "Selection")

	--Can be not networkable
	Options:SetInitialValue("PreGameTime", 60)

	Options:SetPreGameVoting("kill_limit", {100, 125, 150, 175}, 150, {
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
		Options:SetValue("MainHeroList", "NoAbilities")
		Options:SetPreGameVoting("custom_abilities", {"random_omg", "ability_shop"}, "ability_shop", {
			calculationFunction = ">",
			callback = function(value)
				Options:SetValue("EnableAbilityShop", value == "ability_shop")
				Options:SetValue("EnableRandomAbilities", value == "random_omg")
				if value == "ability_shop" then
					CustomAbilities:PostAbilityShopData()
				end
			end
		})
	elseif gamemode == "ranked" then
		SKIP_TEAM_SETUP = true
		Events:On("AllPlayersLoaded", function()
			local failed = (GetInGamePlayerCount() < 10 or matchID == 0) and not StatsClient.Debug
			if not failed then
				Options:SetValue("EnableRatingAffection", true)
				Options:SetValue("BanningPhaseBannedPercentage", 50)
			else
				debugp("Options:LoadMapValues", "Ranked disabled because of low amount of players of match id == 0")
				Options:SetValue("FailedRankedGame", true)
			end
		end, true)
	end
	if landscape == "4v4v4v4" then
		MAP_LENGTH = 9216
		USE_CUSTOM_TEAM_COLORS = true
	end
end

function Options:LoadCheatValues()

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
