local commands = ModuleRequire(..., "commands")

Chat = Chat or {}

Events:Register("activate", function ()
	CustomGameEventManager:RegisterListener("custom_chat_send_message", function(_, data)
		Chat:Send(tonumber(data.PlayerID), data.teamOnly == 1, data)
	end)

	ListenToGameEvent("player_chat", function(keys)
		Chat:Send(keys.playerid, keys.teamonly == 1, {text = keys.text})
	end, nil)
end)

function Chat:SendSystemMessage(data, team)
	if team == nil then team = false end
	Chat:Send(-1, team, data)
end

function Chat:Send(playerId, teamonly, data)
	if PlayerResource:IsValidPlayerID(playerId) and PlayerResource:IsBanned(playerId) then return end

	if Chat:ApplyCommand(playerId, teamonly, data.text) then return end
	local heroName
	if HeroSelection:GetState() == HERO_SELECTION_PHASE_END then
		heroName = HeroSelection:GetSelectedHeroName(playerId)
	end
	local args = {playerId=playerId, hero=heroName}
	if data.text then
		args.text = data.text
	else
		if type(teamonly) ~= "boolean" and data.localizable then
			args.localizable = data.localizable
			args.variables = data.variables
			args.player = data.player
		else
			teamonly = true
			if data.GoldUnit then
				local unit = EntIndexToHScript(tonumber(data.GoldUnit))
				if IsValidEntity(unit) and unit:GetTeam() == PlayerResource:GetTeam(playerId) then
					args.gold = Gold:GetGold(unit)
					args.player = UnitVarToPlayerID(unit)
				else
					return
				end
			elseif data.ability then
				local ability = EntIndexToHScript(data.ability)
				if IsValidEntity(ability) then
					args.ability = data.ability
					args.unit = ability:GetCaster():GetEntityIndex()
					args.player = UnitVarToPlayerID(ability:GetCaster())
				else
					return
				end
			elseif data.shop_item_name then
				local item = data.shop_item_name
				if item then
					local team = PlayerResource:GetTeam(playerId)
					local stocks = PanoramaShop:GetItemStockCount(team, item)
					if GetKeyValue(item, "ItemPurchasableFilter") == 0 or GetKeyValue(item, "ItemPurchasable") == 0 then
						args.boss_drop = true
					elseif stocks and stocks < 1 then
						args.stock_time = math.round(PanoramaShop:GetItemStockCooldown(team, item))
					elseif data.gold then --relying on client for that
						local gold_required = data.gold - Gold:GetGold(playerId)
						if gold_required > 0 then
							args.gold = gold_required
						end
					end
					args.shop_item_name = item
					args.isQuickbuy = data.isQuickbuy == 1
				end
			elseif data.xpunit then
				local unit = EntIndexToHScript(data.xpunit)
				if IsValidEntity(unit) then
					args.unit = data.xpunit
					args.level = unit:GetLevel()
					args.player = UnitVarToPlayerID(unit)
					args.isNeutral = args.player == -1
					if unit.GetCurrentXP and XP_PER_LEVEL_TABLE[args.level + 1] then
						args.xpToNextLevel = (XP_PER_LEVEL_TABLE[args.level + 1] or 0) - unit:GetCurrentXP()
					end
				end
			end
		end
	end

	local team = type(teamonly) == "number" and teamonly or PlayerResource:GetTeam(playerId)
	args.teamonly = type(teamonly) == "boolean" and teamonly
	if args.teamonly then
		CustomGameEventManager:Send_ServerToTeam(team, "custom_chat_recieve_message", args)
		--CustomGameEventManager:Send_ServerToTeam(1, "custom_chat_recieve_message", args) --TODO: Spect, need test
	else
		CustomGameEventManager:Send_ServerToAllClients("custom_chat_recieve_message", args)
	end
end

function Chat:ApplyCommand(playerId, teamonly, text)
	if not text or not string.starts(text, "-") then
		return false
	end

	local hero = PlayerResource:GetSelectedHeroEntity(playerId)
	local args = {}
	for v in string.gmatch(string.sub(text, 2), "%S+") do table.insert(args, v) end

	local commandName = table.remove(args, 1)
	local data = commands[commandName]
	if data then
		local isDev = DynamicWearables:HasWearable(playerId, "wearable_developer") or IsInToolsMode()
		local isCheat = GameRules:IsCheatMode()
		if data.level == CUSTOMCHAT_COMMAND_LEVEL_PUBLIC
			or (data.level == CUSTOMCHAT_COMMAND_LEVEL_CHEAT and isCheat)
			or (data.level == CUSTOMCHAT_COMMAND_LEVEL_DEVELOPER and isDev)
			or (data.level == CUSTOMCHAT_COMMAND_LEVEL_CHEAT_DEVELOPER and (isCheat or isDev)) then
			data.f(args, hero, playerId)
		end
	end
	return true
end
