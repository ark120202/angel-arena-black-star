Teams = Teams or class({})
Teams.Data = Teams.Data or {
	[DOTA_TEAM_GOODGUYS] = {
		color = {0, 128, 0},
		name = "#DOTA_GoodGuys",
		name2 = "#DOTA_GoodGuys_2",
		playerColors = {
			{51, 117, 255},
			{102, 255, 191},
			{191, 0, 191},
			{243, 240, 11},
			{255, 107, 0}
		}
	},
	[DOTA_TEAM_BADGUYS] = {
		color = {255, 0, 0},
		name = "#DOTA_BadGuys",
		name2 = "#DOTA_BadGuys_2",
		playerColors = {
			{254, 134, 194},
			{161, 180, 71},
			{101, 217, 247},
			{0, 131, 33},
			{164, 105, 0}
		}
	},
	[DOTA_TEAM_CUSTOM_1] = {
		color = {197, 77, 168},
		name = "#DOTA_Custom1",
		name2 = "#DOTA_Custom1_2",
		playerColors = {
			{178, 121, 90},
			{147, 255, 120},
			{255, 91, 0},
			{26, 20, 204},
			{130, 129, 178}
		}
	},
	[DOTA_TEAM_CUSTOM_2] = {
		color = {255, 108, 0},
		name = "#DOTA_Custom2",
		name2 = "#DOTA_Custom2_2",
		playerColors = {
			{71, 204, 131},
			{255, 255, 255},
			{255, 241, 96},
			{195, 86, 255},
			{204, 139, 85}
		}
	},
	[DOTA_TEAM_CUSTOM_3] = {
		color = {52, 85, 255},
		name = "#DOTA_Custom3",
		name2 = "#DOTA_Custom3_2",
	},
	[DOTA_TEAM_CUSTOM_4] = {
		color = {101, 212, 19},
		name = "#DOTA_Custom4",
		name2 = "#DOTA_Custom4_2",
	},
	[DOTA_TEAM_CUSTOM_5] = {
		color = {129, 83, 54},
		name = "#DOTA_Custom5",
		name2 = "#DOTA_Custom5_2",
	},
	[DOTA_TEAM_CUSTOM_6] = {
		color = {27, 192, 216},
		name = "#DOTA_Custom6",
		name2 = "#DOTA_Custom6_2",
	},
	[DOTA_TEAM_CUSTOM_7] = {
		color = {199, 228, 13},
		name = "#DOTA_Custom7",
		name2 = "#DOTA_Custom7_2",
	},
	[DOTA_TEAM_CUSTOM_8] = {
		color = {140, 42, 244},
		name = "#DOTA_Custom8",
		name2 = "#DOTA_Custom8_2",
	},
}

function Teams:Initialize()
	PlayerTables:CreateTable("teams", {}, AllPlayersInterval)

	local mapinfo = LoadKeyValues("addoninfo.txt")[GetMapName()]
	local num = math.floor(mapinfo.MaxPlayers / mapinfo.TeamCount)
	local count = 0
	for team, data in pairsByKeys(Teams.Data) do
		local playerCount = count < mapinfo.TeamCount and num or 0
		GameRules:SetCustomGameTeamMaxPlayers(team, playerCount)
		count = count + 1
		Teams.Data[team].count = playerCount
		Teams.Data[team].enabled = playerCount > 0

		if USE_CUSTOM_TEAM_COLORS then
			SetTeamCustomHealthbarColor(team, data.color[1], data.color[2], data.color[3])
		end
	end
end

function Teams:PostInitialize()
	for team, data in pairsByKeys(Teams.Data) do
		if data.enabled then
			Teams:RecalculateKillWeight(team)
		end

		local playerCounter = 0
		for _,playerID in ipairs(Teams:GetPlayerIDs(team, true, true)) do
			if false then
				PlayerResource:SetCustomPlayerColor(playerID, data.color[1], data.color[2], data.color[3])
			else
				playerCounter = playerCounter + 1
				local color = data.playerColors[playerCounter]
				PLAYER_DATA[playerID].Color = color
				PlayerResource:SetCustomPlayerColor(playerID, color[1], color[2], color[3])
			end
		end
	end
end

function Teams:GetScore(team)
	return Teams.Data[team].score or 0
end

function Teams:GetColor(team)
	return Teams.Data[team].color
end

function Teams:IsEnabled(team)
	return Teams.Data[team] and Teams.Data[team].enabled
end

function Teams:GetTeamKillWeight(team)
	return Teams.Data[team].kill_weight or 1
end

function Teams:GetDesiredPlayerCount(team)
	return Teams.Data[team].count or 0
end

function Teams:GetName(team, bSecond)
	return bSecond and Teams.Data[team].name2 or Teams.Data[team].name
end

function Teams:ModifyScore(team, value)
	local new = Teams:GetScore(team) + value
	new = math.min(new, KILLS_TO_END_GAME_FOR_TEAM)
	Teams.Data[team].score = new
	PlayerTables:SetTableValue("teams", team, table.deepcopy(Teams.Data[team]))
end

function Teams:SetTeamKillWeight(team, value)
	Teams.Data[team].kill_weight = value
	PlayerTables:SetTableValue("teams", team, table.deepcopy(Teams.Data[team]))
end

function Teams:GetPlayerIDs(team, bNotAbandoned, bAbandoned)
	local ids = {}
	for i = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
		local isAbandoned = PlayerResource:IsPlayerAbandoned(i)
		if PlayerResource:IsValidPlayerID(i) and PlayerResource:GetTeam(i) == team and ((bNotAbandoned and not isAbandoned) or (bAbandoned and isAbandoned)) then
			table.insert(ids, i)
		end
	end
	return ids
end

function Teams:RecalculateKillWeight(team)
	local remaining = GetTeamPlayerCount(team)
	local value
	if remaining == 0 then
		value = 0
	else
		--local abandoned = GetTeamAbandonedPlayerCount(team)
		local desired = Teams:GetDesiredPlayerCount(team)
		local missing = desired - remaining
		value = missing <= 1 and 1 or missing
	end
	Teams:SetTeamKillWeight(team, value)
end
