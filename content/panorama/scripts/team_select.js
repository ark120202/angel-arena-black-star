$("#UnassignedPlayersContainer").RemoveAndDeleteChildren()
var TeamPanels = []
var PlayerPanels = [];

function Snippet_PlayerSlot(playerId, root) {
	var panel = PlayerPanels[playerId]
	if (panel == null) {
		panel = $.CreatePanel("Panel", root, "")
		panel.BLoadLayoutSnippet("PlayerSlot")
		panel.SetHasClass("slot_empty", playerId == -1)
		panel.AddClass("player_" + playerId)
		if (playerId != -1) {
			PlayerPanels[playerId] = panel
			var playerInfo = Game.GetPlayerInfo(playerId);
			panel.FindChildTraverse("PlayerName").text = playerInfo.player_name;
			panel.FindChildTraverse("PlayerAvatar").steamid = playerInfo.player_steamid;
			panel.SetHasClass("player_is_local", playerInfo.player_is_local);
			panel.SetHasClass("player_has_host_privileges", playerInfo.player_has_host_privileges);
		}
	}
	return panel;
}

function Snippet_Team(team) {
	if (TeamPanels[team] == null) {
		var panel = $.CreatePanel("Panel", $("#TeamList"), "")
		panel.BLoadLayoutSnippet("Team")
		panel.SetPanelEvent("onactivate", function() {
			Game.PlayerJoinTeam(team)
		})
		var teamDetails = Game.GetTeamDetails(team)
		var teamColor = GameUI.CustomUIConfig().team_colors[team].replace(";", "");
		panel.SetDialogVariable("team_name", $.Localize(teamDetails.team_name))
		panel.FindChildTraverse("TeamBackgroundGradient").style.backgroundColor = 'gradient(linear, 0% 0%, 100% 100%, from(#000000AA), to(' + teamColor + '80));';
		panel.FindChildTraverse("TeamBackgroundGradientHighlight").style.backgroundColor = 'gradient(linear, 0% 0%, 100% 100%, from(#000000AA), to(' + teamColor + 'A0));';
		var rgb = hexToRgb(teamColor)

		panel.FindChildTraverse("TeamNameLabel").style.color = shadeColor2(teamColor, 0.75);
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
	var teamPlayers = Game.GetPlayerIDsOnTeam(team);
	for (var i = 0; i < teamPlayers.length; ++i) {
		var playerSlot = panel.EmptySlots[i]
		playerSlot.RemoveAndDeleteChildren();
		Snippet_PlayerSlot(teamPlayers[i], playerSlot).SetParent(playerSlot)
	}

	var teamDetails = Game.GetTeamDetails(team);
	for (var i = teamPlayers.length; i < teamDetails.team_max_players; i++) {
		var playerSlot = panel.EmptySlots[i];
		if (playerSlot.GetChildCount() == 0) {
			Snippet_PlayerSlot(-1, playerSlot)
		}
	}
	panel.SetHasClass("team_is_full", teamPlayers.length == teamDetails.team_max_players);
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

	// Move all existing player panels back to the unassigned player list
	for (var i = 0; i < PlayerPanels.length; ++i) {
		PlayerPanels[i].SetParent(unassignedPlayersContainerNode);
	}

	// Make sure all of the unassigned player have a player panel and that panel is a child of the unassigned player panel.
	var unassignedPlayers = Game.GetUnassignedPlayerIDs();
	for (var i = 0; i < unassignedPlayers.length; ++i) {
		Snippet_PlayerSlot(unassignedPlayers[i], unassignedPlayersContainerNode)
	}
	Game.SetRemainingSetupTime(unassignedPlayers.length == 0 ? 15 : -1);
	// Update all of the team panels moving the player panels for the players assigned to each team to the corresponding team panel.
	for (var k in TeamPanels) {
		Snippet_Team_Update(Number(k))
	}

	$.GetContextPanel().SetHasClass("unassigned_players", unassignedPlayers.length != 0);
	$.GetContextPanel().SetHasClass("no_unassigned_players", unassignedPlayers.length == 0);
}

function OnLockAndStartPressed() {
	if (Game.GetUnassignedPlayerIDs().length > 0)
		return;
	Game.SetTeamSelectionLocked(true);
	Game.SetAutoLaunchEnabled(false);
	Game.SetRemainingSetupTime(4);
}

function OnCancelAndUnlockPressed() {
	Game.SetTeamSelectionLocked(false);
	Game.SetRemainingSetupTime(-1);
}

function OnShufflePlayersPressed() {
	Game.ShufflePlayerTeamAssignments();
	Game.SetRemainingSetupTime(Game.GetUnassignedPlayerIDs().length == 0 ? 15 : -1);
}

function OnAutoAssignPressed() {
	Game.AutoAssignPlayersToTeams();
}

(function() {
	$("#TeamList").RemoveAndDeleteChildren()
	for (var teamId of Game.GetAllTeamIDs()) {
		Snippet_Team(Number(teamId))
	}
	Game.AutoAssignPlayersToTeams();
	OnTeamPlayerListChanged();
	$.RegisterForUnhandledEvent("DOTAGame_TeamPlayerListChanged", OnTeamPlayerListChanged);
	$.RegisterForUnhandledEvent("DOTAGame_PlayerSelectedCustomTeam", OnPlayerSelectedTeam);
	UpdateTimer()
})()