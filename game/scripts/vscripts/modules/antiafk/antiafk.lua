PLAYER_AUTOABANDON_TIME = 60*8
PLAYER_ANTI_AFK_TIME = 60*10
PLAYER_ANTI_AFK_NOTIFY_TIME = 60*4

AntiAFK = AntiAFK or class({})

function AntiAFK:Think(playerId)
	if not PlayerResource:IsPlayerAbandoned(playerId) then
		AntiAFK:ThinkPlayerInGame(playerId)
	else
		local gold = Gold:GetGold(playerId)
		local allyCount = GetTeamPlayerCount(PlayerResource:GetTeam(playerId))
		local goldPerAlly = math.floor(gold/allyCount)
		Gold:RemoveGold(playerId, goldPerAlly * allyCount)
		for ally = 0, 23 do
			if PlayerResource:IsValidPlayerID(ally) and not PlayerResource:IsPlayerAbandoned(ally) then
				if PlayerResource:GetTeam(ally) == PlayerResource:GetTeam(playerId) then
					Gold:ModifyGold(ally, goldPerAlly)
				end
			end
		end
	end
end

function AntiAFK:ThinkPlayerInGame(playerId)
	local playerData = PLAYER_DATA[playerId]
	if GetConnectionState(playerId) == DOTA_CONNECTION_STATE_CONNECTED then
		playerData.AutoAbandonGameTime = nil
		--Anti-AFK
		if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS and not GameRules:IsCheatMode() then
			local timeLeft = (playerData.AntiAFKLastXP or (GameRules:GetGameTime() + PLAYER_ANTI_AFK_TIME)) - GameRules:GetGameTime()
			if timeLeft <= PLAYER_ANTI_AFK_NOTIFY_TIME and (not playerData.AntiAFKLastLeftNotify or timeLeft < playerData.AntiAFKLastLeftNotify - 60) then
				playerData.AntiAFKLastLeftNotify = timeLeft
				CustomGameEventManager:Send_ServerToAllClients("create_custom_toast", {
					type = "generic",
					text = "#custom_toast_AntiAFKTime",
					player = playerId,
					variables = {
						["{minutes}"] = math.ceil(timeLeft/60)
					}
				})
			end
			if timeLeft <= 0 then
				CustomGameEventManager:Send_ServerToAllClients("create_custom_toast", {
					type = "generic",
					text = "#custom_toast_AntiAFKNoTime",
					player = playerId
				})
				PlayerResource:KickPlayer(playerId)
			end
		end
	elseif GetConnectionState(playerId) == DOTA_CONNECTION_STATE_DISCONNECTED then
		playerData.AntiAFKLastLeftNotify = nil
		playerData.AntiAFKLastXP = nil
		--Auto Abandon
		if not playerData.AutoAbandonGameTime then
			playerData.AutoAbandonGameTime = GameRules:GetGameTime() + PLAYER_AUTOABANDON_TIME
			--GameRules:SendCustomMessage("#DOTA_Chat_DisconnectWaitForReconnect", playerId, -1)
		end
		local timeLeft = playerData.AutoAbandonGameTime - GameRules:GetGameTime()
		if not playerData.LastLeftNotify or timeLeft < playerData.LastLeftNotify - 60 then
			playerData.LastLeftNotify = timeLeft
			CustomGameEventManager:Send_ServerToAllClients("create_custom_toast", {
				type = "generic",
				text = "#custom_toast_AutoAbandonTime",
				player = playerId,
				variables = {
					["{minutes}"] = math.ceil(timeLeft/60)
				}
			})
		end
		if timeLeft <= 0 then
			CustomGameEventManager:Send_ServerToAllClients("create_custom_toast", {
				type = "generic",
				text = "#custom_toast_AutoAbandonNoTime",
				player = playerId
			})
			PlayerResource:MakePlayerAbandoned(playerId)
		end
	elseif GetConnectionState(playerId) == DOTA_CONNECTION_STATE_ABANDONED then
		PlayerResource:MakePlayerAbandoned(playerId)
	end
end
