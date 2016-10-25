if StatsClient == nil then
	_G.StatsClient = class({
		ServerAddress = "http://127.0.0.1:3228/"
	})
end

StatsClient.ServerAddress = "http://127.0.0.1:3228/"

function StatsClient:OnGameBegin()

end

function StatsClient:SendData(path, data, callback, trynum)
	local request = CreateHTTPRequest('POST', self.ServerAddress .. path)
	local s = JSON:encode(data)
	request:SetHTTPRequestGetOrPostParameter('body', s)
	request:Send(function(response)
		if response.StatusCode ~= 200 or not response.Body then
			print("error, status != 200")
		else
			local obj, pos, err = JSON:decode(response.Body, 1, nil)
			callback(err, obj)
		end
	end)
end