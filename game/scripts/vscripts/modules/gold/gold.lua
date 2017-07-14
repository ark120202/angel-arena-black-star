CUSTOM_GOLD_PER_TICK = 2
CUSTOM_GOLD_TICK_TIME = 0.5

Gold = Gold or class({})

function Gold:UpdatePlayerGold(unitvar)
	local playerID = UnitVarToPlayerID(unitvar)
	if playerID and playerID > -1 then
		PlayerResource:SetGold(playerID, 0, false)
		PlayerTables:SetTableValue("gold", playerID, PLAYER_DATA[playerID].SavedGold)
	end
end

function Gold:ClearGold(unitvar)
	Gold:SetGold(unitvar, 0)
end

function Gold:SetGold(unitvar, gold)
	local playerID = UnitVarToPlayerID(unitvar)
	PLAYER_DATA[playerID].SavedGold = math.floor(gold)
	Gold:UpdatePlayerGold(playerID)
end

function Gold:ModifyGold(unitvar, gold, bReliable, iReason)
	if gold > 0 then
		Gold:AddGold(unitvar, gold)
	elseif gold < 0 then
		Gold:RemoveGold(unitvar, -gold)
	end
end

function Gold:RemoveGold(unitvar, gold)
	local playerID = UnitVarToPlayerID(unitvar)
	PLAYER_DATA[playerID].SavedGold = math.max((PLAYER_DATA[playerID].SavedGold or 0) - math.ceil(gold), 0)
	Gold:UpdatePlayerGold(playerID)
end

function Gold:AddGold(unitvar, gold)
	local playerID = UnitVarToPlayerID(unitvar)
	PLAYER_DATA[playerID].SavedGold = (PLAYER_DATA[playerID].SavedGold or 0) + math.floor(gold)
	Gold:UpdatePlayerGold(playerID)
end

function Gold:AddGoldWithMessage(unit, gold, optPlayerID)
	local player = optPlayerID and PlayerResource:GetPlayer(optPlayerID) or PlayerResource:GetPlayer(UnitVarToPlayerID(unit))
	SendOverheadEventMessage(player, OVERHEAD_ALERT_GOLD, unit, math.floor(gold), player)
	Gold:AddGold(optPlayerID or unit, gold)
end

function Gold:GetGold(unitvar)
	return math.floor(PLAYER_DATA[UnitVarToPlayerID(unitvar)].SavedGold or 0)
end
