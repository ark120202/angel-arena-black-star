ModuleRequire(..., "data")
if not Kills then
	_G.Kills = class({})
end

function Kills:GetGoldForKill(killedUnit)
	local gold = 180 + Kills:GetKillStreakGold(killedUnit:GetPlayerID()) + (killedUnit:GetLevel() * 30) --100 + streakGold + (killedUnit:GetLevel() * 9.9)
	return (Duel.IsFirstDuel and Duel:IsDuelOngoing()) and 0 or gold
end

function Kills:SetKillStreak(player, ks)
	PLAYER_DATA[player].KillStreak = ks
end

function Kills:GetKillStreak(player)
	return PLAYER_DATA[player].KillStreak or 0
end

function Kills:GetKillStreakGold(player)
	return KILL_STREAK_GOLD[Kills:GetKillStreak(player)] or KILL_STREAK_GOLD[#KILL_STREAK_GOLD]
end

function Kills:IncreaseKillStreak(player)
	Kills:SetKillStreak(player, Kills:GetKillStreak(player) + 1)
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
	local goldChange = Kills:GetGoldForKill(killedUnit)
	Gold:ModifyGold(killedUnit, -goldChange)
	local isDeny = false
	if killerEntity and killerEntity:IsControllableByAnyPlayer() then
		if killerEntity.GetPlayerID or killerEntity.GetPlayerOwnerID then
			if killerEntity == killedUnit then
				Kills:CreateKillTooltip(killedPlayerID, killedPlayerID)
				isDeny = true
			elseif killerEntity:GetTeamNumber() == killedUnit:GetTeamNumber() then
				Kills:CreateKillTooltip(killerPlayerID, killedPlayerID)
				isDeny = true
			else
				if not Duel.IsFirstDuel or not Duel:IsDuelOngoing() then
					Kills:IncreaseKillStreak(killerPlayerID)
				end
				Kills:CreateKillTooltip(killerPlayerID, killedPlayerID, goldChange)
				if not (killerEntity.HasModifier and killerEntity:HasModifier("modifier_item_golden_eagle_relic_enabled")) then
					Kills:_GiveKillGold(killerEntity, killedUnit, goldChange)
				end
			end
		else
			Kills:CreateKillTooltip(nil, killedPlayerID, goldChange)
		end
		if not isDeny then
			local assists = FindUnitsInRadius(killerEntity:GetTeamNumber(), killedUnit:GetAbsOrigin(), nil, HERO_ASSIST_RANGE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
			local assistGold = goldChange * 0.5
			local hadGold = {killerPlayerID}
			for _,v in ipairs(assists) do
				if v ~= killerEntity and v and v:IsMainHero() then
					if not table.includes(hadGold) then
						Kills:_GiveKillGold(v, killedUnit, assistGold)
						table.insert(hadGold, v:GetPlayerID())
					end
				end
			end
		end
	else
		local assistGold = goldChange * 0.6
		for playerId = 0, DOTA_MAX_TEAM_PLAYERS-1  do
			if PlayerResource:IsValidPlayerID(playerId) and PlayerResource:GetTeam(playerId) ~= killedUnit:GetTeamNumber() then
				local player = PlayerResource:GetPlayer(playerId)
				if player and player:GetAssignedHero() then
					SendOverheadEventMessage(player, OVERHEAD_ALERT_GOLD, player:GetAssignedHero(), assistGold, player)
				end
				Gold:ModifyGold(playerId, assistGold)
			end
		end
		Kills:CreateKillTooltip(nil, killedPlayerID, goldChange)
	end
	if not isDeny then
		local streak = Kills:GetKillStreak(killedPlayerID)
		if streak > 1 then
			CustomGameEventManager:Send_ServerToAllClients("create_custom_toast", {
				type = "generic",
				text = "#custom_toast_KillStreak_Ended",
				victimPlayer = killedPlayerID,
				teamPlayer = killedPlayerID,
				teamInverted = true,
				variables = {
					["{kill_streak}"] = streak
				}
			})
		end
		Kills:SetKillStreak(killedPlayerID, 0)
	end
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
end
