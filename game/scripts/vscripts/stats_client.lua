if StatsClient == nil then
	_G.StatsClient = class({})
end

StatsClient.ServerAddress = (IsInToolsMode() and "http://127.0.0.1:3228" or "https://angelarenablackstar-ark120202.rhcloud.com") .. "/AABSServer/"
function StatsClient:Init()
	CustomGameEventManager:RegisterListener("stats_client_add_guide", Dynamic_Wrap(StatsClient, "AddGuide"))
end
function StatsClient:OnGameBegin()
	local data = {
		matchid = tostring(GameRules:GetMatchID()),
		players = {},
	}
	for i = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:IsValidPlayerID(i) and not IsPlayerAbandoned(i) then
			data.players[i] = {
				steam_id = tostring(PlayerResource:GetSteamID(i)),
			}
		end
	end
	--Should return rating table
	--[[StatsClient:Send("startMatch", data, function(response)
		PrintTable(response)
	end)]]
end
--StatsClient:OnGameBegin()
function StatsClient:OnGameEnd(winner)
	local time = GameRules:GetDOTATime(false, true)
	if not IsInToolsMode() and (GameRules:IsCheatMode() or GetInGamePlayerCount() < 8 or time < 0) then
		return
	end
	local data = {
		version = ARENA_VERSION,
		matchid = tostring(GameRules:GetMatchID()),
		WinnerTeam = winner,
		players = {},
		KillGoal = KILLS_TO_END_GAME_FOR_TEAM,
		TeamsInfo = {},
		version = ARENA_VERSION,
		duration = math.floor(time),
	}
	for i = DOTA_TEAM_FIRST, DOTA_TEAM_CUSTOM_MAX do
		if GetTeamAllPlayerCount(i) > 0 then
			data.TeamsInfo[i] = {
				Duels_Won = (Duel.TimesTeamWins[i] or 0),
				IsGameWinner = i == winner,
				Kills = GetTeamHeroKills(i),
			}
		end
	end
	for i = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:IsValidPlayerID(i) then
			local hero = PlayerResource:GetSelectedHeroEntity(i)
			local playerInfo = {
				abandoned = IsPlayerAbandoned(i),
				steamid = tostring(PlayerResource:GetSteamID(i)),
				stats = PLAYER_DATA[i].HeroStats or {},
				hero_name = HeroSelection:GetSelectedHeroName(i),
				team = tonumber(PlayerResource:GetTeam(i)),
				level = PLAYER_DATA[i].BeforeAbandon_Level or 0,
				items = PLAYER_DATA[i].BeforeAbandon_HeroInventorySnapshot or {}
			}
			table.merge(playerInfo.stats, {
				Kills = PlayerResource:GetKills(i),
				Deaths = PlayerResource:GetDeaths(i),
				Assists = PlayerResource:GetAssists(i),
				Lasthits = PlayerResource:GetLastHits(i)
			})
			if IsValidEntity(hero) then
				playerInfo.level = hero:GetLevel()
				for item_slot = DOTA_ITEM_SLOT_1, DOTA_STASH_SLOT_6 do
					local item = hero:GetItemInSlot(item_slot)
					if item then
						local charges = item:GetCurrentCharges()
						local toWriteCharges
						if item:GetInitialCharges() ~= charges then
							toWriteCharges = charges
						end
						playerInfo.items[item_slot] = {
							name = item:GetAbilityName(),
							stacks = toWriteCharges
						}
					end
				end
			end
			data.players[i] = playerInfo
		end
	end
	PrintTable(data)
	StatsClient:Send("endMatch", data, function(response)
		PrintTable(response)
	end, 4)
end
--StatsClient:OnGameEnd(2)
function StatsClient:HandleError(err)
	if err and type(err) == "string" then
		StatsClient:Send("HandleError", {
			version = ARENA_VERSION,
			text = err
		})
	end
end

function StatsClient:GetMatchPlayerInfo()
	local postData = {players = {}}
	for i = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:IsValidPlayerID(i) and PlayerResource:IsValidTeamPlayer(i) then
			postData.players[i] = PlayerResource:GetSteamID(i)
		end
	end
	StatsClient:Send("GetPublicInfoForPlayer", postData, function()
		PlayerTables:SetTableValue("arena", "player_server_stats", stats)
	end, 5)
end

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
		if response.success then
			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "stats_client_add_guide_success", {insertedId = response.insertedId})
		else
			Containers:DisplayError(playerID, response.error)
		end
	end)
end

function StatsClient:Send(path, data, callback, retryCount, protocol, _currentRetry)
	local request = CreateHTTPRequestScriptVM(protocol or "POST", self.ServerAddress .. path)
	request:SetHTTPRequestGetOrPostParameter("data", JSON:encode(data))
	request:Send(function(response)
		if response.StatusCode ~= 200 or not response.Body then
			print("error, status == " .. response.StatusCode)
			local currentRetry = (_currentRetry or 0) + 1
			if currentRetry < (retryCount or 0) then
				Timers:CreateTimer(1, function()
					print("Retry (" .. currentRetry .. ")")
					StatsClient:Send(path, data, callback, retryCount, protocol, currentRetry)
				end)
			end
		else
			local obj, pos, err = JSON:decode(response.Body, 1, nil)
			if callback then
				callback(obj)
			end
		end
	end)
end
--[[StatsClient:AddGuide({
	PlayerID = 0,
	items = {
		{
			title = "#DOTA_Item_Build_Starting_Items",
			content = {
				"item_tango_arena",
				"item_flask",
				"item_clarity",
				"item_clarity",
				"item_clarity",
				"item_circlet",
				"item_branches",
			}
		},
		{
			title = "#DOTA_Item_Build_Early_Game",
			content = {
				"item_bottle_arena",
				"item_boots",
				"item_null_talisman",
			}
		},
		{
			title = "#DOTA_Item_Build_Core_Items",
			content = {
				"item_arcane_boots",
				"item_veil_of_discord",
				"item_tpscroll",
			}
		},
		{
			title = "#DOTA_Item_Build_Luxury",
			content = {
				"item_ultimate_scepter_arena",
				"item_refresher_arena",
				"item_cyclone",
				"item_blink_arena",
				"item_sheepstick",
				"item_bloodstone_arena",
				"item_sunray_dagon_5_arena",
				"item_octarine_core_arena",
			}
		},
	},
	title = "Valve's build",
	description = "Valve's build",

	--youtube = "",
})]]
--[[
function GameMode:CustomSaveFunc(pid)
	print("HANDLED!")
	return {Rating = 5000}
end
GameRules:SetCustomGameAccountRecordSaveFunction(Dynamic_Wrap(GameMode, "CustomSaveFunc"), GameMode)
PrintTable(GameRules:GetPlayerCustomGameAccountRecord(0))
]]