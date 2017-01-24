if StatsClient == nil then
	_G.StatsClient = class({})
end

StatsClient.ServerAddress = "https://angelarenablackstar-ark120202.rhcloud.com/AABSServer/"
--StatsClient:OnGameBegin()
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

	--[[StatsClient:Send("startMatch", data, function(response)
		PrintTable(response)
	end)]]
end

function StatsClient:OnGameEnd()
	local data = {
		matchid = tostring(GameRules:GetMatchID()),
		players = {},
	}
	for i = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:IsValidPlayerID(i) then
			local hero = PlayerResource:GetSelectedHeroEntity(i)
			players[i] = {
				abandoned = IsPlayerAbandoned(i),
				hero_stats = PLAYER_DATA[i].HeroStats or {},
				items = {}
			}
			if IsValidEntity(hero) then
				for item_slot = DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_9 do
					local item = hero:GetItemInSlot(item_slot)
					if item then
						items[item_slot] = {
							name = item:GetAbilityName(),
							stacks = item:GetStackCount()
						}
					end
				end
			end
		end
	end

	StatsClient:Send("endMatch", data, function(response)
		PrintTable(response)
	end)
end

function StatsClient:HandleError(err)
	if err and type(err) == "string" then
		StatsClient:Send("HandleError", { text = err })
	end
end

function StatsClient:Send(path, data, callback, retryCount, _currentRetry)
	local request = CreateHTTPRequest('POST', self.ServerAddress .. path)
	request:SetHTTPRequestGetOrPostParameter("data", JSON:encode(data))
	request:Send(function(response)
		if response.StatusCode ~= 200 or not response.Body then
			print("error, status == " .. response.StatusCode)
			local currentRetry = (_currentRetry or 0) + 1
			if currentRetry < (retryCount or 0) then
				print("Retry...")
				StatsClient:Send(path, data, callback, retryCount, currentRetry)
			end
		else
			local obj, pos, err = JSON:decode(response.Body, 1, nil)
			if callback then
				callback(obj)
			end
		end
	end)
end