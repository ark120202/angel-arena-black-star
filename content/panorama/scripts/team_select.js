var selectedKillGoal = 3
var TeamPanels = []
var PlayerPanels = [];

function VoteMap(parentindex, gmtype) {
	GameEvents.SendCustomGameEventToServer("submit_gamemode_map", {
		GMType: gmtype
	});
	//$("#KillGoalVote").enabled = false;
}

function SubmitKillGoal() {
	GameEvents.SendCustomGameEventToServer("submit_gamemode_vote", {
		voteIndex: selectedKillGoal
	});
	$("#KillGoalVote").enabled = false;
	$("#KillGoalVoteSubmit").enabled = false;
}

function CheckStartable() {
	var player = Game.GetLocalPlayerInfo()
	if (player == null)
		$.Schedule(0.2, CheckStartable)
	else {
		//FindDotaHudElement("CustomLoadingScreenContainer").visible = true //temporary dark moon upadte fix
		//$("#GoalVotePanel").AddClass("GoalVotePanel_In")
		DynamicSubscribePTListener("arena", function(tableName, changesObject, deletionsObject) {
			var gamemode_settings = changesObject["gamemode_settings"]
			if (gamemode_settings != null) {
				if (gamemode_settings.kill_goals != null) {
					$.Each(gamemode_settings.kill_goals, function(killGoal, tIndex) {
						var button = $.CreatePanel("RadioButton", $("#KillGoalVoteVartiantList"), "");
						if (tIndex == selectedKillGoal) {
							button.AddClass("Activated")
						}
						//button.AddClass("ButtonBevel")
						//button.AddClass("VoteKillGoalButton")
						button.AddClass("KillGoalVariant")
						button.group = "kill_goal_variants"
						var label = $.CreatePanel("Label", button, ""); //<Label text="4 (20%)" style="horizontal-align: right;" />;
						label.text = killGoal;
						label.style.color = "white"
						label.style.fontSize = "20px"
						var votedataLabel = $.CreatePanel("Label", button, ""); //<Label text="4 (20%)" style="horizontal-align: right;" />;
						votedataLabel.text = "0 (0%)";
						votedataLabel.style.horizontalAlign = "right"
						votedataLabel.style.color = "white"
						votedataLabel.style.fontSize = "19px"
						button.SetPanelEvent("onactivate", function() {
							selectedKillGoal = tIndex
						})
					})
				}
				//$("#GoalVotePanelCustomSettingsRoot").visible = Number(gamemode_settings.gamemode_map) == ARENA_GAMEMODE_MAP_CUSTOM_ABILITIES
			}
		});
	}
}

function Snippet_PlayerSlot(playerId, root) {
	if (PlayerPanels[playerId] == null) {
		var panel = $.CreatePanel("Panel", root || $("#TeamList"), "")
		panel.BLoadLayoutSnippet("PlayerSlot")
		panel.SetHasClass("slot_empty", playerId == -1)
		PlayerPanels[playerId] = panel
	}
	return PlayerPanels[playerId];
}

function Snippet_Team(team) {
	if (TeamPanels[team] == null) {
		var panel = $.CreatePanel("Panel", $("#TeamList"), "")
		panel.BLoadLayoutSnippet("Team")
		panel.SetPanelEvent("onactivate", function() {
			Game.PlayerJoinTeam(team)
			$.Msg("JOINTEAM: " + team)
		})
		var teamDetails = Game.GetTeamDetails(team)
		var teamColor = GameUI.CustomUIConfig().team_colors[team].replace(";", "");
		panel.SetDialogVariable("team_name", $.Localize(teamDetails.team_name))
		panel.FindChildTraverse("TeamBackgroundGradient").style.backgroundColor = 'gradient( linear, -800% -1600%, 50% 100%, from( ' + teamColor + ' ), to( #00000088 ) );';
		panel.FindChildTraverse("TeamBackgroundGradientHighlight").style.backgroundColor = 'gradient( linear, -800% -1600%, 90% 100%, from( ' + teamColor + ' ), to( #00000088 ) );';
		var teamNameLabel = panel.FindChildTraverse("TeamNameLabel");
		teamNameLabel.style.color = teamColor + ';';
		panel.EmptySlots = []
		for (var i = 0; i < teamDetails.team_max_players; ++i) {
			var slot = $.CreatePanel("Panel", panel.FindChildTraverse("PlayerList"), "");
			slot.AddClass("player_slot");
			panel.EmptySlots[i] = slot;
		}
		TeamPanels[team] = panel
	}
	return TeamPanels[team];
}

function Snippet_Team_Update(team) {
	var panel = Snippet_Team(team);
	var teamPlayersLength = Game.GetPlayerIDsOnTeam(team).length;
	for (var i = 0; i < teamPlayersLength; ++i) {
		var playerSlot = panel.EmptySlots[i]
		playerSlot.RemoveAndDeleteChildren();
		var panel = Snippet_PlayerSlot(teamPlayersLength[i], playerSlot)
		panel.SetParent(playerSlot)
	}

	var teamDetails = Game.GetTeamDetails(team);
	$.Msg(team + panel.EmptySlots + "\n")
	for (var i = teamPlayersLength; i < teamDetails.team_max_players; i++) {
		var playerSlot = panel.EmptySlots[i];
		if (playerSlot.GetChildCount() == 0) {
			Snippet_PlayerSlot(-1, playerSlot)
		}
	}
	panel.SetHasClass("team_is_full", teamPlayersLength == teamDetails.team_max_players);
	panel.SetHasClass("local_player_on_this_team", Players.GetTeam(Game.GetLocalPlayerID()) == team);
}

function UpdateTimer() {
	$.Schedule(0.1, UpdateTimer)

	var gameTime = Game.GetGameTime();
	var transitionTime = Game.GetStateTransitionTime();

	var playerInfo = Game.GetLocalPlayerInfo();
	if (playerInfo != null) {
		$.GetContextPanel().SetHasClass("player_has_host_privileges", playerInfo.player_has_host_privileges);
	}

	if (transitionTime >= 0) {
		$("#StartGameCountdownTimer").SetDialogVariableInt("countdown_timer_seconds", Math.max(0, Math.floor(transitionTime - gameTime)));
		$("#StartGameCountdownTimer").SetHasClass("countdown_active", true);
		$("#StartGameCountdownTimer").SetHasClass("countdown_inactive", false);
	} else {
		$("#StartGameCountdownTimer").SetHasClass("countdown_active", false);
		$("#StartGameCountdownTimer").SetHasClass("countdown_inactive", true);
	}

	var autoLaunch = Game.GetAutoLaunchEnabled();
	$("#StartGameCountdownTimer").SetHasClass("auto_start", autoLaunch);
	$("#StartGameCountdownTimer").SetHasClass("forced_start", !autoLaunch);
	var teams_locked = Game.GetTeamSelectionLocked()
	$.GetContextPanel().SetHasClass("teams_locked", teams_locked);
	$.GetContextPanel().SetHasClass("teams_unlocked", !teams_locked);
}

function OnPlayerSelectedTeam(nPlayerId, nTeamId, bSuccess) {
	if (Game.GetLocalPlayerID() === nPlayerId) {
		Game.EmitSound(bSuccess ? "ui_team_select_pick_team" : "ui_team_select_pick_team_failed");
	}
}

function OnTeamPlayerListChanged() {
	var unassignedPlayersContainerNode = $("#UnassignedPlayersContainer");
	//unassignedPlayersContainerNode.RemoveAndDeleteChildren()
	$.Msg("List changed")
	for (var i = 0; i < PlayerPanels.length; ++i) {
		PlayerPanels[i].SetParent(unassignedPlayersContainerNode);
	}

	var unassignedPlayers = Game.GetUnassignedPlayerIDs();
	for (var i = 0; i < unassignedPlayers.length; ++i) {
		Snippet_PlayerSlot(unassignedPlayers[i], unassignedPlayersContainerNode)
	}
	for (var k in TeamPanels) {
		Snippet_Team_Update(Number(k))
	}

	$.GetContextPanel().SetHasClass("unassigned_players", unassignedPlayers.length != 0);
	$.GetContextPanel().SetHasClass("no_unassigned_players", unassignedPlayers.length == 0);
}

(function() {
	$.Schedule(0.2, CheckStartable)
	UpdateTimer()
	$("#TeamList").RemoveAndDeleteChildren()
	for (var teamId of Game.GetAllTeamIDs()) {
		Snippet_Team(Number(teamId))
	}

	$.RegisterForUnhandledEvent("DOTAGame_TeamPlayerListChanged", OnTeamPlayerListChanged);
	$.RegisterForUnhandledEvent("DOTAGame_PlayerSelectedCustomTeam", OnPlayerSelectedTeam);
	OnTeamPlayerListChanged();
})()