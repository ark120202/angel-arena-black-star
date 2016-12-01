function GameMode:RegisterCustomListeners()
	CustomGameEventManager:RegisterListener("custom_chat_send_message", Dynamic_Wrap(GameMode, "CustomChatSendMessage"))
	CustomGameEventManager:RegisterListener("metamorphosis_elixir_cast", Dynamic_Wrap(GameMode, "MetamorphosisElixirCast"))
	CustomGameEventManager:RegisterListener("hell_hero_change_cast", Dynamic_Wrap(GameMode, "HellHeroChangeCast"))
	CustomGameEventManager:RegisterListener("heaven_hero_change_cast", Dynamic_Wrap(GameMode, "HeavenHeroChangeCast"))
	CustomGameEventManager:RegisterListener("hud_courier_burst", Dynamic_Wrap(GameMode, "BurstCourier"))
	CustomGameEventManager:RegisterListener("modifier_clicked_purge", Dynamic_Wrap(GameMode, "ModifierClickedPurge"))

	if DOTA_ACTIVE_GAMEMODE ~= DOTA_GAMEMODE_HOLDOUT_5 then
		--CustomGameEventManager:RegisterListener("duel1x1call_send_call", Dynamic_Wrap(GameMode, "SendDuel1x1Call"))
		CustomGameEventManager:RegisterListener("submit_gamemode_vote", Dynamic_Wrap(GameMode, "SubmitGamemodeVote"))
	end
end

function GameMode:MetamorphosisElixirCast(data)
	local hero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
	local elixirItem = FindItemInInventoryByName(hero, "item_metamorphosis_elixir", false)
	if hero and GetFullHeroName(hero) ~= data.hero and not HeroSelection:IsHeroSelected(data.hero) and elixirItem and not Duel:IsDuelOngoing() and not hero:HasModifier("modifier_shredder_chakram_disarm") and HeroSelection:VerifyHeroGroup(data.hero, "Selection") then
		HeroSelection:ChangeHero(data.PlayerID, data.hero, true, true, elixirItem:GetSpecialValueFor("transformation_time"), elixirItem)
	end
end

function GameMode:HellHeroChangeCast(data)
	local hero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
	local elixirItem = FindItemInInventoryByName(hero, "item_hell_hero_change", false)
	if hero and GetFullHeroName(hero) ~= data.hero and not HeroSelection:IsHeroSelected(data.hero) and elixirItem and not Duel:IsDuelOngoing() and not hero:HasModifier("modifier_shredder_chakram_disarm") and HeroSelection:VerifyHeroGroup(data.hero, "Hell") then
		HeroSelection:ChangeHero(data.PlayerID, data.hero, true, true, elixirItem:GetSpecialValueFor("transformation_time"), elixirItem)
	end
end

function GameMode:HeavenHeroChangeCast(data)
	local hero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
	local elixirItem = FindItemInInventoryByName(hero, "item_heaven_hero_change", false)
	if hero and GetFullHeroName(hero) ~= data.hero and not HeroSelection:IsHeroSelected(data.hero) and elixirItem and not Duel:IsDuelOngoing() and not hero:HasModifier("modifier_shredder_chakram_disarm") and HeroSelection:VerifyHeroGroup(data.hero, "Heaven") then
		HeroSelection:ChangeHero(data.PlayerID, data.hero, true, true, elixirItem:GetSpecialValueFor("transformation_time"), elixirItem)
	end
end

function GameMode:SendDuel1x1Call(data)
	local sender = tonumber(data.PlayerID)
	local targetPlayer = tonumber(data.selectedEnemyID)
	if data and sender and targetPlayer and PlayerResource:IsValidPlayerID(sender) and PlayerResource:IsValidPlayerID(targetPlayer) then
		if not Duel:IsDuelOngoing() then
			--targetPlayer = sender
			local messageTable = {messageFields = {
					{field = "Text", class = "FieldTextTitle", fieldData = {text = "#duel1x1_message_title"}},
					{field = "PanelCollection", fieldData = {
						{field = "Text", fieldData = {text = "#duel1x1_message_sender_p1"}},
						{field = "HeroImage", fieldData = {heroname = PlayerResource:GetSelectedHeroName(sender), heroimagestyle="icon"}},
						{field = "Text", class = "FieldTextBlank", fieldData = {text = PlayerResource:GetPlayerName(sender)}},
					}},

					{field = "PanelCollection", fieldData = {
						{field = "Text", fieldData = {text = "#duel1x1_message_cost_p1"}},
						{field = "Text", class = "FieldTextBlank", fieldData = {text = data.gold}},
					}},
					--data.message
					{field = "PanelCollection", fieldData = {
						{field = "Button", class = "FieldButtonDecline", fieldData = {
							{field = "Text", class = "FieldTextButtonDecline", fieldData = {text = "#duel1x1_message_answer_decline"}},
						}, onactivate = function()
							Notifications:Bottom(sender, {text="#duel1x1_message_error_duel_declined", duration=10, style={color="red"}})
							return true
						end},
						{field = "Button", class = "FieldButtonAccept", fieldData = {
							{field = "Text", class = "FieldTextButtonAccept", fieldData = {text = "#duel1x1_message_answer_accept"}},
						}, onactivate = function()
							if not Duel:IsDuelOngoing() then
								if Gold:GetGold(targetPlayer) >= tonumber(data.gold) then
									if PlayerResource:GetSelectedHeroEntity(targetPlayer):IsAlive() and PlayerResource:GetSelectedHeroEntity(sender):IsAlive() then
										Duel:Start1X1(sender, targetPlayer, tonumber(data.gold))
									else
										Notifications:Bottom(sender, {text="#duel1x1_message_error_duel_not_alive", duration=10, style={color="red"}})
										Notifications:Bottom(targetPlayer, {text="#duel1x1_message_error_duel_not_alive", duration=10, style={color="red"}})
									end
								else
									Notifications:Bottom(sender, {text="#duel1x1_message_error_duel_declined", duration=10, style={color="red"}})
									Notifications:Bottom(targetPlayer, {text="#duel1x1_message_error_not_enough_gold", duration=10, style={color="red"}})
								end
							else
								Notifications:Bottom(sender, {text="#duel1x1_message_error_duel_is_running", duration=10, style={color="red"}})
								Notifications:Bottom(targetPlayer, {text="#duel1x1_message_error_duel_is_running", duration=10, style={color="red"}})
							end
							return true
						end}
					}}
				}
			}
			if data.message and data.message ~= "" then
				table.insert(messageTable.messageFields, 4, {field = "PanelCollection", fieldData = {
					{field = "Text", fieldData = {text = "#duel1x1_message_usermessage_p1"}},
					{field = "Text", class = "FieldTextBlank", fieldData = {text = data.message}}
				}})
			end
			PlayerMessages:SendMessage(targetPlayer, messageTable)
		else
			Notifications:Bottom(sender, {text="#duel1x1_message_error_duel_is_running", duration=10, style={color="red"}})
		end
	end
end

function GameMode:CustomChatSendMessage(data)
	if data and data.text and type(data.text) == "string" then
		local teamonly = data.teamOnly == 1
		CustomChatSay(tonumber(data.PlayerID), tostring(data.text), teamonly)
	end
end

function GameMode:SubmitGamemodeVote(data)
	if data and data.vote and type(data.vote) == "string" then
		local vote = tonumber(data.vote)
		if not vote then vote = DOTA_KILL_GOAL_VOTE_STANDART end
		vote = math.min(vote, DOTA_KILL_GOAL_VOTE_MAX)
		vote = math.max(vote, DOTA_KILL_GOAL_VOTE_MIN)

		PLAYER_DATA[tonumber(data.PlayerID)].GameModeVote = vote
	end
end

function GameMode:BurstCourier(data)
	local courier = FindCourier(PlayerResource:GetTeam(tonumber(data.PlayerID)))
	if courier then
		courier:CastAbilityNoTarget(courier:FindAbilityByName("courier_burst"), tonumber(data.PlayerID))
	end
end

function GameMode:ModifierClickedPurge(data)
	if data.PlayerID and data.unit and data.modifier then
		local ent = EntIndexToHScript(data.unit)
		if ent and ent.entindex and ent:GetOwner() == PlayerResource:GetPlayer(data.PlayerID) and table.contains(ONCLICK_PURGABLE_MODIFIERS, data.modifier) then
			ent:RemoveModifierByName(data.modifier)
		end
	end
end