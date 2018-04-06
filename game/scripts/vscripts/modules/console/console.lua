Console = Console or {}

Events:Register("activate", "console", function ()
	CustomGameEventManager:RegisterListener("console-evaluate", Dynamic_Wrap(Console, "ConsoleEvaluate"))

	Convars:RegisterCommand("arena_console", function()
		local player = Convars:GetCommandClient()
		Console:SetVisible(player)
	end, "Toggle Angel Arena Black Star debug console", FCVAR_NOTIFY)
end)

function Console:SetVisible(player, value)
	CustomGameEventManager:Send_ServerToPlayer(player, "console-set-visible", {
		value = value
	})
end

function Console:CanEvaluate(playerID)
	return IsInToolsMode() or DynamicWearables:HasWearable(playerID, "wearable_developer")
end

function Console:SetStack(playerID, stack)
	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "console-stack", {
		stack = stack,
	})
end

function Console:EvaluateLua(code)
	local _, nextCall = xpcall(loadstring(code), function (msg)
		return msg .. '\n' .. debug.traceback() .. '\n'
	end)
	return nextCall or "<no return value>"
end

function Console:SendJSToPlayer(target, code)
	local targetPlayer = PlayerResource:GetPlayer(tonumber(target))
	if targetPlayer then
		CustomGameEventManager:Send_ServerToPlayer(targetPlayer, "console-evaluate", {
			code = code
		})
		return "Sent"
	else
		return "Error: player " .. target .. " wasn't found"
	end
end

function Console:SendJSWithFilter(playerID, filter, code)
	local targets = {}
	for i = 0, 23 do
		if PlayerResource:IsValidPlayerID(i) then
			local includesI =
				(filter == "everyone" and i ~= playerID) or
				(filter == "enemies" and PlayerResource:GetTeam(i) ~= PlayerResource:GetTeam(playerID)) or
				(filter == "allies" and i ~= playerID and PlayerResource:GetTeam(i) == PlayerResource:GetTeam(playerID))
			if includesI then
				local status = false
				local targetPlayer = PlayerResource:GetPlayer(i)
				if targetPlayer then
					CustomGameEventManager:Send_ServerToPlayer(targetPlayer, "console-evaluate", {
						code = code
					})
					status = true
				end
				targets[i] = status
			end
		end
	end
	if table.count(targets) == 0 then
		return "No matching players found"
	else
		local sent = table.iterateKeys(table.filterValues(targets, function(status) return status end))
		local notFound = table.iterateKeys(table.filterValues(targets, function(status) return not status end))
		return "Matched players: [" .. table.concat(table.iterateKeys(targets), ", ") .. "]\n" ..
			"Sent: [" .. table.concat(sent, ", ") .. "]\n" ..
			"Not found: [" .. table.concat(notFound, ", ") .. "]"
	end
end

function Console:ConsoleEvaluate(event)
	local playerID = event.PlayerID
	local player = PlayerResource:GetPlayer(playerID)

	if not Console:CanEvaluate(playerID) then
		return Console:SetStack(playerID, "PermissionError: you should be a developer to be able to use debug console outside of tools")
	end

	local evalType = event.type
	local target = event.target
	local code = event.code

	if evalType == "lua" then
		Console:SetStack(playerID, Console:EvaluateLua(code))
	elseif evalType == "js" then
		if target == "everyone" or target == "enemies" or target == "allies" then
			Console:SetStack(playerID, Console:SendJSWithFilter(playerID, target, code))
		elseif tonumber(target) then
			Console:SetStack(playerID, Console:SendJSToPlayer(target, code))
		else
			Console:SetStack(playerID, "Error: illegal target - \"" .. target .. "\"")
		end
	else
		Console:SetStack(playerID, "Error: illegal event type - \"" .. evalType .. "\"")
	end
end
