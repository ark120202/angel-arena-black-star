if StatsClient == nil then
	_G.StatsClient = class({
		ServerAddress = "http://127.0.0.1:3228/"
	})
end

StatsClient.ServerAddress = "http://127.0.0.1:3228/"

function StatsClient:OnGameBegin()
	print(GameRules:GetMatchID())
	StatsClient:SendData("/startmatch", {
		matchid = GameRules:GetMatchID()
	})
end

function StatsClient:SendData(path, data, callback, retryCount, _currentRetry)
	local request = CreateHTTPRequest('POST', self.ServerAddress .. path)
	local s = JSON:encode(data)
	request:SetHTTPRequestGetOrPostParameter('body', s)
	request:Send(function(response)
		if response.StatusCode ~= 200 or not response.Body then
			print("error, status != 200")
			local currentRetry = (_currentRetry or 0) + 1
			if currentRetry < retryCount
				StatsClient:SendData(path, data, callback, currentRetry)
			end
		else
			local obj, pos, err = JSON:decode(response.Body, 1, nil)
			if callback then
				callback(obj)
			end
		end
	end)
end