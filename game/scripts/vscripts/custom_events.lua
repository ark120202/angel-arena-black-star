function GameMode:RegisterCustomListeners()
	CustomGameEventManager:RegisterListener("custom_chat_send_message", Dynamic_Wrap(GameMode, "CustomChatSendMessage"))
	CustomGameEventManager:RegisterListener("metamorphosis_elixir_cast", Dynamic_Wrap(GameMode, "MetamorphosisElixirCast"))
	CustomGameEventManager:RegisterListener("modifier_clicked_purge", Dynamic_Wrap(GameMode, "ModifierClickedPurge"))
	CustomGameEventManager:RegisterListener("submit_gamemode_vote", Dynamic_Wrap(GameMode, "SubmitGamemodeVote"))
	CustomGameEventManager:RegisterListener("submit_gamemode_map", Dynamic_Wrap(GameMode, "SubmitGamemodeMap"))
end

function GameMode:MetamorphosisElixirCast(data)
	local hero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
	local elixirItem = FindItemInInventoryByName(hero, "item_metamorphosis_elixir", false)
	if hero and GetFullHeroName(hero) ~= data.hero and not HeroSelection:IsHeroSelected(data.hero) and elixirItem and not Duel:IsDuelOngoing() and not hero:HasModifier("modifier_shredder_chakram_disarm") and HeroSelection:VerifyHeroGroup(data.hero, "Selection") then
		HeroSelection:ChangeHero(data.PlayerID, data.hero, true, elixirItem:GetSpecialValueFor("transformation_time"), elixirItem)
	end
end

function GameMode:CustomChatSendMessage(data)
	if data and data.text and type(data.text) == "string" then
		local teamonly = data.teamOnly == 1
		CustomChatSay(tonumber(data.PlayerID), tostring(data.text), teamonly)
	end
end

function GameMode:SubmitGamemodeVote(data)
	if data and data.voteIndex then
		local vote = POSSIBLE_KILL_GOALS[tonumber(data.voteIndex)]
		if not vote then
			vote = DOTA_KILL_GOAL_VOTE_STANDART
		end
		PLAYER_DATA[tonumber(data.PlayerID)].GameModeVote = vote
	end
end

function GameMode:SubmitGamemodeMap(data)
	if data and data.GMType then
		local GMType = tonumber(data.GMType)
		if ARENA_ACTIVE_GAMEMODE_MAP == ARENA_GAMEMODE_MAP_CUSTOM_ABILITIES then
			if GMType and GMType == DOTA_GAMEMODE_TYPE_RANDOM_OMG or GMType == DOTA_GAMEMODE_TYPE_ABILITY_SHOP then
				PLAYER_DATA[tonumber(data.PlayerID)].GameModeTypeVote = GMType
			end
		end
	end
end

function GameMode:ModifierClickedPurge(data)
	if data.PlayerID and data.unit and data.modifier then
		local ent = EntIndexToHScript(data.unit)
		if IsValidEntity(ent) and ent:GetPlayerOwner() == PlayerResource:GetPlayer(data.PlayerID) and table.contains(ONCLICK_PURGABLE_MODIFIERS, data.modifier) and not ent:IsStunned() and not ent:IsChanneling() then
			ent:RemoveModifierByName(data.modifier)
		end
	end
end