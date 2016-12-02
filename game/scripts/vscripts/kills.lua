KILLS_TOOLTIP_GOLD = 0
KILLS_TOOLTIP_ACTION_KILL = 1
KILLS_TOOLTIP_ACTION_SUICIDE = 2
KILLS_TOOLTIP_ACTION_DENY = 3

if not Kills then
	_G.Kills = class({})
	Kills.BountyStorage = {}
	Kills.GoldForStreaks = {
		--[[[0] = 0,
		[1] = 400,
		[2] = 600,
		[3] = 1200,
		[4] = 1800,
		[5] = 1000,
		[6] = 1500,
		[7] = 2500,
		[8] = 4000,
		[9] = 6000,
		[10] = 7500,
		[11] = 10000,
		[12] = 11000,
		[13] = 13000,
		[14] = 16000,
		[15] = 20000,]]
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

	local killerEntity
	if killerPlayer then 
		killerEntity = killerPlayer:GetAssignedHero()
	end
	if not Kills.BountyStorage[killedUnit:GetPlayerID()] then Kills.BountyStorage[killedUnit:GetPlayerID()] = 0 end
	local goldChange = Kills:GetGoldForKill(killedUnit)
	Gold:ModifyGold(killedUnit, -goldChange, 0)
	Kills:ClearStreak(killedUnit:GetPlayerID())
	if killerEntity and killerEntity:IsControllableByAnyPlayer() then
		local isDeny = false
		if killerEntity.GetPlayerID or killerEntity.GetPlayerOwnerID then
			local plId
			if killerEntity.GetPlayerID then
				plId = killerEntity:GetPlayerID()
			elseif killerEntity.GetPlayerOwnerID then
				plId = killerEntity:GetPlayerOwnerID()
			end
			if not Kills.BountyStorage[plId] then Kills.BountyStorage[plId] = 0 end
			if killerEntity == killedUnit then
				Kills:_CreateKillTooltip(killedUnit, KILLS_TOOLTIP_ACTION_SUICIDE, killedUnit)
				isDeny = true
			elseif killerEntity:GetTeamNumber() == killedUnit:GetTeamNumber() then
				Kills:_CreateKillTooltip(killerEntity, KILLS_TOOLTIP_ACTION_DENY, killedUnit)
				isDeny = true
			else
				Kills.BountyStorage[plId] = Kills.BountyStorage[plId] + 1
				if Kills.BountyStorage[plId] > 15 then Kills.BountyStorage[plId] = 15 end
				Kills:_CreateKillTooltip(killerEntity, KILLS_TOOLTIP_ACTION_KILL, killedUnit, goldChange)
				Kills:_GiveKillGold(killerEntity, killedUnit, goldChange)
			end
		else
			Kills:_CreateKillTooltip(nil, KILLS_TOOLTIP_ACTION_KILL, killedUnit, goldChange)
		end
		if not isDeny then
			local assists = FindUnitsInRadius(killerEntity:GetTeamNumber(), killedUnit:GetAbsOrigin(), nil, HERO_ASSIST_RANGE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
			local assistGold = goldChange * 0.5
			local hadGold = {plId}
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
		Kills:_CreateKillTooltip(nil, KILLS_TOOLTIP_ACTION_KILL, killedUnit, goldChange)
	end
end

function Kills:_GiveKillGold(killerEntity, killedUnit, goldChange)
	local plId
	if killerEntity.GetPlayerID then
		plId = killerEntity:GetPlayerID()
	elseif killerEntity.GetPlayerOwnerID then
		plId = killerEntity:GetPlayerOwnerID()
	end
	if plId then
		Gold:ModifyGold(plId, goldChange)
		SendOverheadEventMessage(killerEntity:GetPlayerOwner(), OVERHEAD_ALERT_GOLD, killedUnit, goldChange, killerEntity:GetPlayerOwner())
	end
end

function Kills:_CreateKillTooltip(unit1, action, unit2, gold)
	local data = {}
	if unit1 then
		table.insert(data, {type = "heroIcon", heroName = GetFullHeroName(unit1), team = unit1:GetTeamNumber(), p_style={["background-color"]=""}})
	end

	if action then
		table.insert(data, {type = "picture",  pictureType = action})
	end

	if unit2 then
		table.insert(data, {type = "heroIcon", heroName = GetFullHeroName(unit2), team = unit2:GetTeamNumber(), p_style={["background-color"]=""}})
	end
	
	if gold then
		table.insert(data, {type = "picture", pictureType = KILLS_TOOLTIP_GOLD})
		table.insert(data, {type = "text", text = math.floor(gold), style={["font-size"] = "18px", ["color"] = "black"}})
	end

	for i = DOTA_TEAM_FIRST, DOTA_TEAM_CUSTOM_MAX do
		local newData = {}
		table.merge(newData, data)
		for k,v in ipairs(newData) do
			if v and v.p_style and v.p_style["background-color"] then
				if v.team == i then
					newData[k].p_style["background-color"] = "LightGreen"
				else
					newData[k].p_style["background-color"] = "#ff4d4d"
				end
			end
		end
		Kills:_CreateMessageTooltip(i, newData)
	end
end

function Kills:_CreateMessageTooltip(team, data)
	CustomGameEventManager:Send_ServerToTeam(team, "kills_create_kill_tooltip", data)
end

function Kills:ClearStreak(playerID)
	Kills.BountyStorage[playerID] = 0
end