if Gold == nil then
	_G.Gold = class({})
end

function Gold:UpdatePlayerGold(unitvar)
	local playerID = UnitVarToPlayerID(unitvar)
	if playerID and playerID > -1 then
		local gold = PlayerResource:GetGold(playerID)
		local pd = PLAYER_DATA[playerID]
		local saved_gold
		if pd then
			saved_gold = pd.SavedGold
		end
		if not saved_gold then
			PLAYER_DATA[playerID].SavedGold = 0
			saved_gold = 0
		end
		if gold > 70000 then
			local gold_overflow = gold - 70000
			PLAYER_DATA[playerID].SavedGold = saved_gold + gold_overflow
			PlayerResource:SpendGold(playerID, gold_overflow, 0)
		elseif gold < 70000 then
			local gold_free = 70000 - gold
			if saved_gold < gold_free then
				PlayerResource:ModifyGold(playerID, saved_gold, true, 0)
				PLAYER_DATA[playerID].SavedGold = 0
			elseif saved_gold > gold_free then
				PlayerResource:ModifyGold(playerID, gold_free, true, 0)
				PLAYER_DATA[playerID].SavedGold = saved_gold - gold_free
			end
		end
		local allgold = PlayerTables:GetTableValue("arena", "gold")
		allgold[playerID] = gold + saved_gold
		PlayerTables:SetTableValue("arena", "gold", allgold)
	end
end

function Gold:ClearGold(unitvar)
	local playerID = UnitVarToPlayerID(unitvar)
	PlayerResource:SetGold(playerID, 0, true)
	PlayerResource:SetGold(playerID, 0, false)
	PLAYER_DATA[playerID].SavedGold = 0
end

function Gold:SetGold(unitvar, gold)
	local playerID = UnitVarToPlayerID(unitvar)
	Gold:ClearGold(playerID)
	Gold:AddGold(playerID, gold, false)
end

function Gold:ModifyGold(unitvar, gold, bReliable, iReason)
	if gold > 0 then
		Gold:AddGold(unitvar, gold, bReliable, iReason)
	elseif gold < 0 then
		Gold:RemoveGold(unitvar, -gold, iReason)
	end
end

function Gold:RemoveGold(unitvar, gold, iReason)
	local playerID = UnitVarToPlayerID(unitvar)
	PLAYER_DATA[playerID].SavedGold = (PLAYER_DATA[playerID].SavedGold or 0) - gold
	Gold:UpdatePlayerGold(playerID)
end

function Gold:AddGold(unitvar, gold, bReliable, iReason)
	local playerID = UnitVarToPlayerID(unitvar)
	PLAYER_DATA[playerID].SavedGold = (PLAYER_DATA[playerID].SavedGold or 0) + gold
	Gold:UpdatePlayerGold(playerID)
end

function Gold:GetGold(unitvar)
	local playerID = UnitVarToPlayerID(unitvar)
	return PlayerResource:GetGold(playerID) + (PLAYER_DATA[playerID].SavedGold or 0)
end