if not Kills then
	_G.Kills = class({})
	Kills.BountyStorage = {}
	Kills.GoldForStreaks = {
		[0] = 0,
		[1] = 300,
		[2] = 450,
		[3] = 900,
		[4] = 1350,
		[5] = 3000,
		[6] = 4500,
		[7] = 7500,
		[8] = 12000,
		[9] = 18000,
		[10] = 22500,
		[11] = 30000,
		[12] = 33000,
		[13] = 39000,
		[14] = 48000,
		[15] = 60000,
	}
end

function Kills:GetGoldForKill(killedUnit)
	if not Kills.BountyStorage[killedUnit:GetPlayerID()] then Kills.BountyStorage[killedUnit:GetPlayerID()] = 0 end
	local streak = Kills.BountyStorage[killedUnit:GetPlayerID()]
	local streakGold = Kills.GoldForStreaks[streak]
	local gold = 400 + streakGold + (killedUnit:GetLevel() * 30) --100 + streakGold + (killedUnit:GetLevel() * 9.9)
	return gold
end

function Kills:OnEntityKilled(killedPlayer, killerPlayer)
	if not killedPlayer then
		return
	end
	local killedUnit = killedPlayer:GetAssignedHero()
	local killedPlayerID = killedPlayer:GetPlayerID()

	local killerEntity
	local killerPlayerID
	if killerPlayer then 
		killerEntity = killerPlayer:GetAssignedHero()
		if killerEntity.GetPlayerID then
			killerPlayerID = killerEntity:GetPlayerID()
		elseif killerEntity.GetPlayerOwnerID then
			killerPlayerID = killerEntity:GetPlayerOwnerID()
		end
	end
	if not Kills.BountyStorage[killedUnit:GetPlayerID()] then Kills.BountyStorage[killedUnit:GetPlayerID()] = 0 end
	local goldChange = Kills:GetGoldForKill(killedUnit)
	Gold:ModifyGold(killedUnit, -goldChange)
	if killerEntity and killerEntity:IsControllableByAnyPlayer() then
		local isDeny = false
		if killerEntity.GetPlayerID or killerEntity.GetPlayerOwnerID then
			if not Kills.BountyStorage[killerPlayerID] then Kills.BountyStorage[killerPlayerID] = 0 end
			if killerEntity == killedUnit then
				Kills:CreateKillTooltip(killedPlayerID, killedPlayerID)
				isDeny = true
			elseif killerEntity:GetTeamNumber() == killedUnit:GetTeamNumber() then
				Kills:CreateKillTooltip(killerPlayerID, killedPlayerID)
				isDeny = true
			else
				Kills.BountyStorage[killerPlayerID] = Kills.BountyStorage[killerPlayerID] + 1
				if Kills.BountyStorage[killerPlayerID] > 15 then Kills.BountyStorage[killerPlayerID] = 15 end
				Kills:CreateKillTooltip(killerPlayerID, killedPlayerID, goldChange)
				Kills:_GiveKillGold(killerEntity, killedUnit, goldChange)
			end
		else
			Kills:CreateKillTooltip(nil, killedPlayerID, goldChange)
		end
		if not isDeny then
			local assists = FindUnitsInRadius(killerEntity:GetTeamNumber(), killedUnit:GetAbsOrigin(), nil, HERO_ASSIST_RANGE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
			local assistGold = goldChange * 0.5
			local hadGold = {killerPlayerID}
			for _,v in ipairs(assists) do
				if v ~= killerEntity and v and v:IsRealHero() then
					if not table.contains(hadGold) then
						Kills:_GiveKillGold(v, killedUnit, assistGold)
						table.insert(hadGold, v:GetPlayerID())
					end
				end
			end
		end
	else
		local assistGold = goldChange * 0.6
		for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1  do
			if PlayerResource:IsValidPlayerID(playerID) and PlayerResource:GetTeam(playerID) ~= killedUnit:GetTeamNumber() then
				local player = PlayerResource:GetPlayer(playerID)
				if player and player:GetAssignedHero() then
					SendOverheadEventMessage(player, OVERHEAD_ALERT_GOLD, player:GetAssignedHero(), assistGold, player)
				end
				Gold:ModifyGold(playerID, assistGold)
			end
		end
		Kills:CreateKillTooltip(nil, killedPlayerID, goldChange)
	end
	Kills:ClearStreak(killedPlayerID)
end

function Kills:_GiveKillGold(killerEntity, killedUnit, goldChange)
	local plId = -1
	if killerEntity.GetPlayerID then
		plId = killerEntity:GetPlayerID()
	end
	if plId == -1 and killerEntity.GetPlayerOwnerID then
		plId = killerEntity:GetPlayerOwnerID()
	end
	if plId ~= -1 then
		Gold:ModifyGold(plId, goldChange)
		SendOverheadEventMessage(killerEntity:GetPlayerOwner(), OVERHEAD_ALERT_GOLD, killedUnit, goldChange, killerEntity:GetPlayerOwner())
	end
end

function Kills:CreateKillTooltip(killer, killed, gold)
	CustomGameEventManager:Send_ServerToAllClients("create_custom_toast", {
		type = "kill",
		killerPlayer = killer,
		victimPlayer = killed,
		gold = gold,
	})
	if (Kills.BountyStorage[killed] > 1) then
		CustomGameEventManager:Send_ServerToAllClients("create_custom_toast", {
			type = "kill_streak_ended",
			victimPlayer = killed,
			kill_streak = Kills.BountyStorage[killed]
		})
	end
end

function Kills:ClearStreak(playerID)
	Kills.BountyStorage[playerID] = 0
end