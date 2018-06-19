Console = Console or {}

Events:Register("activate", function ()
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

function Console:CanEvaluate(playerId)
	return IsInToolsMode() or DynamicWearables:HasWearable(playerId, "wearable_developer")
end

function Console:SetStack(playerId, stack)
	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerId), "console-stack", {
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

function Console:SendJSWithFilter(playerId, filter, code)
	local targets = {}
	for i = 0, 23 do
		if PlayerResource:IsValidPlayerID(i) then
			local includesI =
				(filter == "everyone" and i ~= playerId) or
				(filter == "enemies" and PlayerResource:GetTeam(i) ~= PlayerResource:GetTeam(playerId)) or
				(filter == "allies" and i ~= playerId and PlayerResource:GetTeam(i) == PlayerResource:GetTeam(playerId))
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
	local playerId = event.PlayerID
	local player = PlayerResource:GetPlayer(playerId)

	if not Console:CanEvaluate(playerId) then
		return Console:SetStack(playerId, "PermissionError: you should be a developer to be able to use debug console outside of tools")
	end

	local evalType = event.type
	local target = event.target
	local code = event.code

	if evalType == "lua" then
		Console:SetStack(playerId, Console:EvaluateLua(code))
	elseif evalType == "js" then
		if target == "everyone" or target == "enemies" or target == "allies" then
			Console:SetStack(playerId, Console:SendJSWithFilter(playerId, target, code))
		elseif tonumber(target) then
			Console:SetStack(playerId, Console:SendJSToPlayer(target, code))
		else
			Console:SetStack(playerId, "Error: illegal target - \"" .. target .. "\"")
		end
	else
		Console:SetStack(playerId, "Error: illegal event type - \"" .. evalType .. "\"")
	end
end
