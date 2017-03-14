var PlayerPanels = [];
var TeamPanels = [];
var SharedControlPanels = [];
var players_abandoned = [];
var teamColors = GameUI.CustomUIConfig().team_colors;

function Snippet_SharedControlPlayer() {
	var panel = $.CreatePanel("Panel", $("#PlayersContainer"), "");
	panel.BLoadLayoutSnippet("SharedControlPlayer");
	panel.playerId = -1;
	var DisableHelpButton = panel.FindChildTraverse("DisableHelpButton")
	DisableHelpButton.SetPanelEvent("onactivate", function() {
		GameEvents.SendCustomGameEventToServer("set_help_disabled", {
			player: panel.playerId,
			disabled: DisableHelpButton.checked
		});
	})
	SharedControlPanels.push(panel);
	return panel;
}

function Snippet_SharedControlPlayer_Update(panel, index, teamPlayers) {
	var playerId = -1;
	for (var i in teamPlayers) {
		if (teamPlayers[i].visible) {
			index--;
			if (index == -1) {
				playerId = Number(i);
				break;
			}
		}
	}
	panel.playerId = playerId
	panel.visible = playerId != -1
	panel.FindChildTraverse("DisableHelpButton").SetDialogVariable("player_name", Players.GetPlayerName(playerId))
	panel.SetHasClass("LocalPlayer", playerId == Game.GetLocalPlayerID())
}

function Snippet_Player(pid) {
	if (PlayerPanels[pid] == null) {
		var team = Players.GetTeam(pid)
		if (team != DOTA_TEAM_SPECTATOR) {
			var teamPanel = Snippet_Team(team).FindChildTraverse("TeamPlayersContainer")
			var panel = $.CreatePanel("Panel", teamPanel, "")
			panel.BLoadLayoutSnippet("Player")
			var VoiceMute = panel.FindChildTraverse("VoiceMute")
			panel.playerId = pid
			panel.SetHasClass("EmptyPlayerRow", false)
			panel.SetHasClass("LocalPlayer", pid == Game.GetLocalPlayerID())
			panel.FindChildTraverse("ScoreboardXP").FindChildTraverse("LevelLabel").style.width = "100%";
			panel.FindChildTraverse("HeroImage").SetPanelEvent("onactivate", function() {
				Players.PlayerPortraitClicked(pid, GameUI.IsControlDown(), GameUI.IsAltDown());
			});
			VoiceMute.SetPanelEvent("onactivate", function() {
				//$.Msg(VoiceMute.checked)
				Game.SetPlayerMuted(pid, VoiceMute.checked)
					//$.Msg(Game.IsPlayerMuted(pid))
			});
			panel.Resort = function() {
				SortPanelChildren(teamPanel, dynamicSort("playerId"), function(child, child2) {
					return child.playerId < child2.playerId
				});
			}
			panel.Resort();
			/*panel.FindChildTraverse("HeroImage").SetPanelEvent("onactivate", function() {
				Players.PlayerPortraitClicked(pid, GameUI.IsControlDown(), GameUI.IsAltDown());
			});
			var TopBarUltIndicator = panel.FindChildTraverse("TopBarUltIndicator")
			TopBarUltIndicator.SetPanelEvent("onmouseover", function() {
				//??????????
				if (panel.ultimateCooldown != null && panel.ultimateCooldown > 0) {
					$.DispatchEvent("UIShowTextTooltip", TopBarUltIndicator, panel.ultimateCooldown);
				}
				//$.DispatchEvent("UIShowTopBarUltimateTooltip ", panel, pid);
			});
			panel.FindChildTraverse("TopBarUltIndicator").SetPanelEvent("onmouseout", function() {
				$.DispatchEvent("UIHideTextTooltip", panel);
				//$.DispatchEvent("DOTAHideTopBarUltimateTooltip", panel);
			});
			// ="DOTAShowTopBarUltimateTooltip()" onmouseout="DOTAHideTopBarUltimateTooltip()"*/
			PlayerPanels[pid] = panel;
		}
	}
	return PlayerPanels[pid]
}

function Snippet_Player_Update(panel) {
	var playerId = panel.playerId;
	if (players_abandoned.indexOf(playerId) != -1) {
		panel.visible = false;
	} else {
		var playerInfo = Game.GetPlayerInfo(playerId);
		var heroName = GetPlayerHeroName(playerId);
		var respawnSeconds = playerInfo.player_respawn_seconds;
		var connectionState = playerInfo.player_connection_state;
		var heroEnt = playerInfo.player_selected_hero_entity_index;
		var ScoreboardUltIndicator = panel.FindChildTraverse("ScoreboardUltIndicator")
		var ultStateOrTime = playerInfo.player_team_id == Players.GetTeam(Game.GetLocalPlayerID()) ? Game.GetPlayerUltimateStateOrTime(playerId) : PlayerUltimateStateOrTime_t.PLAYER_ULTIMATE_STATE_HIDDEN;
		panel.SetHasClass("UltLearned", ultStateOrTime != PlayerUltimateStateOrTime_t.PLAYER_ULTIMATE_STATE_NOT_LEVELED);
		panel.SetHasClass("UltReady", ultStateOrTime == PlayerUltimateStateOrTime_t.PLAYER_ULTIMATE_STATE_READY);
		panel.SetHasClass("UltReadyNoMana", ultStateOrTime == PlayerUltimateStateOrTime_t.PLAYER_ULTIMATE_STATE_NO_MANA);
		panel.SetHasClass("UltOnCooldown", ultStateOrTime > 0);
		panel.SetDialogVariableInt("ult_cooldown", ultStateOrTime);
		panel.SetDialogVariableInt("kills", Players.GetKills(playerId));
		panel.SetDialogVariableInt("deaths", Players.GetDeaths(playerId));
		panel.SetDialogVariableInt("assists", Players.GetAssists(playerId));
		panel.SetDialogVariableInt("gold", GetPlayerGold(playerId));
		panel.SetDialogVariableInt("level", Players.GetLevel(playerId))
		panel.FindChildTraverse("HeroImage").SetImage(TransformTextureToPath(heroName));
		panel.FindChildTraverse("HeroNameLabel").text = $.Localize(heroName).toUpperCase();
		panel.FindChildTraverse("PlayerNameLabel").text = Players.GetPlayerName(playerId)
		panel.FindChildTraverse("AvatarImage").steamid = playerInfo.player_steamid
		panel.FindChildTraverse("PlayerColor").style.backgroundColor = GetHEXPlayerColor(playerId);

		/*panel.SetDialogVariableInt("respawn_seconds", respawnSeconds + 1);
		panel.SetHasClass("Dead", respawnSeconds >= 0);
		panel.SetHasClass("Disconnected", connectionState == DOTAConnectionState_t.DOTA_CONNECTION_STATE_DISCONNECTED);*/
		if (playerInfo.player_team_id != panel.GetParent().team && teamColors[playerInfo.player_team_id] != null) {
			panel.SetParent(Snippet_Team(playerInfo.player_team_id).FindChildTraverse("TeamPlayersContainer"))
			panel.Resort();
		}
		//panel.FindChildTraverse("TopBarUltIndicatorTimer").text = 99;
		//Abilities.GetAbilityType(ab) == ABILITY_TYPES.ABILITY_TYPE_ULTIMATE
		//panel.SetHasClass("player_ultimate_hidden", (ultStateOrTime == PlayerUltimateStateOrTime_t.PLAYER_ULTIMATE_STATE_HIDDEN));
		//_ScoreboardUpdater_SetTextSafe(TopBarUltIndicator, "PlayerUltimateCooldown", ultStateOrTime);
		//panel.FindChildTraverse("PlayerColorShadow").style.washColor = playerColor;
		/*
			BuybackReady
			IsAbilityDraft
		*/
	}
}

function Snippet_Team(team) {
	if (TeamPanels[team] == null) {
		var TeamList = $("#TeamList")
		var panel = $.CreatePanel("Panel", TeamList, "")
		panel.BLoadLayoutSnippet("Team")
		panel.team = team
		TeamPanels[team] = panel;
		panel.FindChildTraverse("TeamLabel").text = GameUI.CustomUIConfig().team_names[team];
		panel.FindChildTraverse("TeamLabel").style.textShadow = "0px 0px 6px 1.0 " + teamColors[team]
		panel.FindChildTraverse("TeamScoreLabel").style.textShadow = "0px 0px 6px 1.0 " + teamColors[team]
		panel.SetHasClass("FirstTeam", team == DOTATeam_t.DOTA_TEAM_GOODGUYS)

		SortPanelChildren(TeamList, dynamicSort("team"), function(child, child2) {
			return child.team < child2.team
		});
	}
	return TeamPanels[team];
}

function Snippet_Team_Update(panel) {
	var team = panel.team
	var teamDetails = Game.GetTeamDetails(team);
	var isAlly = team == Players.GetTeam(Game.GetLocalPlayerID());
	panel.SetHasClass("EnemyTeam", !isAlly);
	panel.SetDialogVariableInt("score", teamDetails.team_score);
	if (isAlly) {
		$("#SharedUnitControl").style.marginTop = Math.min(panel.actualyoffset, 0) + "px"
		$("#SharedUnitControl").style.height = panel.actuallayoutheight + "px"
	}
}

function Update() {
	$.Schedule(0.1, Update);
	var context = $.GetContextPanel();
	$.Each(Game.GetAllPlayerIDs(), function(pid) {
		var team = Players.GetTeam(pid)
		if (team != DOTA_TEAM_SPECTATOR) {
			Snippet_Player_Update(Snippet_Player(pid));
		}
	})
	var LocalTeam = Players.GetTeam(Game.GetLocalPlayerID())
	for (var i in TeamPanels) {
		Snippet_Team_Update(TeamPanels[i]);
	}
	var teamPlayers = Snippet_Team(LocalTeam).FindChildTraverse("TeamPlayersContainer").Children()
	for (var i in SharedControlPanels) {
		Snippet_SharedControlPlayer_Update(SharedControlPanels[i], Number(i), teamPlayers);
	}
	var maxTeamPlayers = Game.GetTeamDetails(LocalTeam).team_max_players
	if (SharedControlPanels.length < maxTeamPlayers) {
		for (i = 0; i < maxTeamPlayers - SharedControlPanels.length; i++) {
			Snippet_SharedControlPlayer();
		}
	}


	context.SetHasClass("AltPressed", GameUI.IsAltDown())
}

function SetFlyoutScoreboardVisible(visible) {
	$.GetContextPanel().SetHasClass("ScoreboardClosed", !visible)
}

(function() {
	var LocalPlayerID = Game.GetLocalPlayerID()
	DynamicSubscribePTListener("arena", function(tableName, changesObject, deletionsObject) {
		if (changesObject.players_abandoned != null) {
			for (var k in changesObject.players_abandoned) {
				players_abandoned.push(Number(changesObject.players_abandoned[k]));
			}
		}
		if (changesObject.player_data != null && changesObject.player_data[LocalPlayerID] != null && changesObject.player_data[LocalPlayerID].DisableHelp != null) {
			$.Each(changesObject.player_data[LocalPlayerID].DisableHelp, function(state, playerID) {
				for (var i in SharedControlPanels) {
					if (SharedControlPanels[i].playerId == playerID) {
						SharedControlPanels[i].FindChildTraverse("DisableHelpButton").checked = state == 1
					}
				}
			})
		}
	});
	$("#TeamList").RemoveAndDeleteChildren()
	$("#PlayersContainer").RemoveAndDeleteChildren()
	Update();

	SetFlyoutScoreboardVisible(false);
	$.RegisterEventHandler("DOTACustomUI_SetFlyoutScoreboardVisible", $.GetContextPanel(), SetFlyoutScoreboardVisible);
	var debug = false;
	GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_FLYOUT_SCOREBOARD, debug)
	$.GetContextPanel().visible = !debug;
})();