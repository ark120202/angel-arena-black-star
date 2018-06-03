$('#UnassignedPlayersContainer').RemoveAndDeleteChildren();
var TeamPanels = [];
var PlayerPanels = [];
var LockTime = 4;
var NormalTime = 15;

function Snippet_PlayerSlot(playerId, root) {
	var panel = PlayerPanels[playerId];
	if (panel == null) {
		panel = $.CreatePanel('Panel', root, '');
		panel.BLoadLayoutSnippet('PlayerSlot');
		panel.SetHasClass('slot_empty', playerId == -1);
		panel.AddClass('player_' + playerId);
		if (playerId != -1) {
			$.RegisterEventHandler('DragStart', panel, function(panelId, dragCallbacks) {
				if ($.GetContextPanel().BHasClass('player_has_host_privileges')) {
					var displayPanel = $.CreatePanel('Panel', panel, '');
					displayPanel.hittest = false;
					displayPanel.hittestchildren = false;
					displayPanel.BLoadLayoutSnippet('PlayerSlot');
					displayPanel.AddClass('player_' + playerId);
					displayPanel.playerId = playerId;
					var playerInfo = Game.GetPlayerInfo(playerId);
					displayPanel.team = playerInfo.player_team_id;
					displayPanel.FindChildTraverse('PlayerName').text = playerInfo.player_name;
					displayPanel.FindChildTraverse('PlayerAvatar').steamid = playerInfo.player_steamid;
					displayPanel.SetHasClass('player_is_local', playerInfo.player_is_local);
					displayPanel.SetHasClass('player_has_host_privileges', playerInfo.player_has_host_privileges);
					$.DispatchEvent('DOTAHideProfileCardTooltip', panel.FindChildTraverse('PlayerAvatar'));

					dragCallbacks.displayPanel = displayPanel;
					dragCallbacks.offsetX = 15;
					dragCallbacks.offsetY = 15;
					panel.AddClass('player_dragged');
					return true;
				}
				return false;
			});
			$.RegisterEventHandler('DragEnd', panel, function(panelId, draggedPanel) {
				draggedPanel.DeleteAsync(0);
				panel.RemoveClass('player_dragged');
				return true;
			});
			$.RegisterEventHandler('DragEnter', panel, function(a, draggedPanel) {
				if (draggedPanel.playerId == null || draggedPanel.playerId == playerId)
					return true;
				panel.AddClass('potential_drop_target');
				return true;
			});
			$.RegisterEventHandler('DragDrop', panel, function(panelId, draggedPanel) {
				panel.RemoveClass('potential_drop_target');
				if (draggedPanel.playerId != playerId) {
					HostSwapPlayers(draggedPanel.playerId, playerId);
				}
				return true;
			});
			$.RegisterEventHandler('DragLeave', panel, function(panelId, draggedPanel) {
				if (draggedPanel.playerId == null || draggedPanel.playerId == playerId) return false;
				panel.RemoveClass('potential_drop_target');
				return true;
			});
			PlayerPanels[playerId] = panel;
			var playerInfo = Game.GetPlayerInfo(playerId);
			panel.FindChildTraverse('PlayerName').text = playerInfo.player_name;
			panel.FindChildTraverse('PlayerAvatar').steamid = playerInfo.player_steamid;
			panel.SetHasClass('player_is_local', playerInfo.player_is_local);
			panel.SetHasClass('player_has_host_privileges', playerInfo.player_has_host_privileges);
		}
	}
	return panel;
}

function Snippet_Team(team) {
	if (TeamPanels[team] == null) {
		var panel = $.CreatePanel('Panel', $('#TeamList'), '');
		panel.BLoadLayoutSnippet('Team');
		panel.AddClass('Team_' + team)
		panel.SetPanelEvent('onactivate', function() {
			Game.PlayerJoinTeam(team);
		});

		var teamColor = GameUI.CustomUIConfig().team_colors[team];
		panel.FindChildTraverse('TeamNameLabel').style.color = shadeColor2(teamColor, 0.75);

		var teamDetails = Game.GetTeamDetails(team);
		panel.SetDialogVariable('team_name', $.Localize(teamDetails.team_name));

		panel.EmptySlots = [];
		for (var i = 0; i < teamDetails.team_max_players; ++i) {
			var slot = $.CreatePanel('Panel', panel.FindChildTraverse('PlayerList'), '');
			slot.AddClass('player_slot');
			panel.EmptySlots[i] = slot;
		}
		$.RegisterEventHandler('DragEnter', panel, function(a, draggedPanel) {
			if (draggedPanel.team == null || draggedPanel.team == team)
				return true;
			panel.AddClass('potential_drop_target');
			return true;
		});
		$.RegisterEventHandler('DragDrop', panel, function(panelId, draggedPanel) {
			panel.RemoveClass('potential_drop_target');
			if (draggedPanel.team == team)
				return true;
			HostSwapPlayerWithTeam(draggedPanel.playerId, team);
			return true;
		});
		$.RegisterEventHandler('DragLeave', panel, function(panelId, draggedPanel) {
			if (draggedPanel.team == null || draggedPanel.team == team)
				return false;
			panel.RemoveClass('potential_drop_target');
			return true;
		});
		TeamPanels[team] = panel;
	}
	return TeamPanels[team];
}

function Snippet_Team_Update(team) {
	var panel = Snippet_Team(team);
	var teamPlayers = Game.GetPlayerIDsOnTeam(team);
	for (var i = 0; i < teamPlayers.length; ++i) {
		var playerSlot = panel.EmptySlots[i];
		playerSlot.RemoveAndDeleteChildren();
		Snippet_PlayerSlot(teamPlayers[i], playerSlot).SetParent(playerSlot);
	}

	var teamDetails = Game.GetTeamDetails(team);
	for (var i = teamPlayers.length; i < teamDetails.team_max_players; i++) {
		var playerSlot = panel.EmptySlots[i];
		if (playerSlot.GetChildCount() == 0) {
			Snippet_PlayerSlot(-1, playerSlot);
		}
	}
	panel.SetHasClass('team_is_full', teamPlayers.length == teamDetails.team_max_players);
	panel.SetHasClass('local_player_on_this_team', Players.GetTeam(Game.GetLocalPlayerID()) == team);
}

function UpdateTimer() {
	$.Schedule(0.1, UpdateTimer);

	var gameTime = Game.GetGameTime();
	var transitionTime = Game.GetStateTransitionTime();

	var playerInfo = Game.GetLocalPlayerInfo();
	if (playerInfo != null) {
		$.GetContextPanel().SetHasClass('player_has_host_privileges', playerInfo.player_has_host_privileges && Options.GetMapInfo().gamemode !== 'ranked');
	}
	if (transitionTime >= 0) {
		$('#StartGameCountdownTimer').SetDialogVariableInt('countdown_timer_seconds', Math.max(0, Math.floor(transitionTime - gameTime)));
	}

	$('#StartGameCountdownTimer').SetHasClass('countdown_active', transitionTime >= 0);
	$('#StartGameCountdownTimer').SetHasClass('countdown_inactive', transitionTime < 0);

	var autoLaunch = Game.GetAutoLaunchEnabled();
	$('#StartGameCountdownTimer').SetHasClass('auto_start', autoLaunch);
	$('#StartGameCountdownTimer').SetHasClass('forced_start', !autoLaunch);
	var teams_locked = Game.GetTeamSelectionLocked();
	$.GetContextPanel().SetHasClass('teams_locked', teams_locked);
	$.GetContextPanel().SetHasClass('teams_unlocked', !teams_locked);
}

function OnPlayerSelectedTeam(nPlayerId, nTeamId, bSuccess) {
	if (Game.GetLocalPlayerID() === nPlayerId) {
		Game.EmitSound(bSuccess ? 'ui_team_select_pick_team' : 'ui_team_select_pick_team_failed');
	}
}

function OnTeamPlayerListChanged() {
	var unassignedPlayersContainerNode = $('#UnassignedPlayersContainer');

	// Move all existing player panels back to the unassigned player list
	for (var i = 0; i < PlayerPanels.length; ++i) {
		PlayerPanels[i].SetParent(unassignedPlayersContainerNode);
	}

	// Make sure all of the unassigned player have a player panel and that panel is a child of the unassigned player panel.
	var unassignedPlayers = Game.GetUnassignedPlayerIDs();
	for (var i = 0; i < unassignedPlayers.length; ++i) {
		Snippet_PlayerSlot(unassignedPlayers[i], unassignedPlayersContainerNode);
	}
	Game.SetRemainingSetupTime(Game.GetTeamSelectionLocked() ? LockTime : unassignedPlayers.length == 0 ? NormalTime : -1);
	// Update all of the team panels moving the player panels for the players assigned to each team to the corresponding team panel.
	for (var k in TeamPanels) {
		Snippet_Team_Update(Number(k));
	}

	$.GetContextPanel().SetHasClass('unassigned_players', unassignedPlayers.length != 0);
	$.GetContextPanel().SetHasClass('no_unassigned_players', unassignedPlayers.length == 0);
}

function OnLockAndStartPressed() {
	if (Game.GetUnassignedPlayerIDs().length > 0)
		return;
	Game.SetTeamSelectionLocked(true);
	Game.SetAutoLaunchEnabled(false);
	Game.SetRemainingSetupTime(LockTime);
}

function OnCancelAndUnlockPressed() {
	Game.SetTeamSelectionLocked(false);
	Game.SetRemainingSetupTime(-1);
}

function OnShufflePlayersPressed() {
	Game.ShufflePlayerTeamAssignments();
	Game.SetRemainingSetupTime(Game.GetTeamSelectionLocked() ? LockTime : Game.GetUnassignedPlayerIDs().length == 0 ? NormalTime : -1);
}

function OnAutoAssignPressed() {
	Game.AutoAssignPlayersToTeams();
}

function SetUnassignedTeamDraggable() {
	var panel = $('#UnassignedPlayersButton');
	var team = DOTATeam_t.DOTA_TEAM_NOTEAM;
	$.RegisterEventHandler('DragEnter', panel, function(a, draggedPanel) {
		if (draggedPanel.team == null || draggedPanel.team == team)
			return true;
		panel.AddClass('potential_drop_target');
		return true;
	});
	$.RegisterEventHandler('DragDrop', panel, function(panelId, draggedPanel) {
		panel.RemoveClass('potential_drop_target');
		if (draggedPanel.team == team)
			return true;
		HostSwapPlayerWithTeam(draggedPanel.playerId, team);
		return true;
	});
	$.RegisterEventHandler('DragLeave', panel, function(panelId, draggedPanel) {
		if (draggedPanel.team == null || draggedPanel.team == team)
			return false;
		panel.RemoveClass('potential_drop_target');
		return true;
	});
}

function HostSwapPlayerWithTeam(playerId, team) {
	if (!Game.GetTeamSelectionLocked() || team != DOTATeam_t.DOTA_TEAM_NOTEAM) {
		GameEvents.SendCustomGameEventToServer('team_select_host_set_player_team', {
			player: playerId,
			team: team
		});
	}
	//$.Msg("Swap player " + playerId + " to team " + team)
}

function HostSwapPlayers(playerId, playerId2) {
	GameEvents.SendCustomGameEventToServer('team_select_host_set_player_team', {
		player: playerId,
		player2: playerId2,
	});
	//$.Msg("Swap player " + playerId + " with player " + playerId)
}

(function() {
	$('#TeamList').RemoveAndDeleteChildren();
	$.GetContextPanel().Children().forEach(function(child) { child.visible = false; });

	Options.Subscribe('TeamSetupMode', function(mode) {
		$('#team-select__' + mode).visible = true;

		switch (mode) {
			case 'open':
				var teamIDs = Game.GetAllTeamIDs();
				teamIDs.forEach(Snippet_Team);
				Game.AutoAssignPlayersToTeams();
				OnTeamPlayerListChanged();
				$.RegisterForUnhandledEvent('DOTAGame_TeamPlayerListChanged', OnTeamPlayerListChanged);
				$.RegisterForUnhandledEvent('DOTAGame_PlayerSelectedCustomTeam', OnPlayerSelectedTeam);
				SetUnassignedTeamDraggable();
				UpdateTimer();
				break;
			case 'balanced':
				$('#LoadingPanel').visible = true;
				$('#ErrorPanel').visible = false;
				DynamicSubscribePTListener('stats_setup_error', function(tableName, error) {
					$('#LoadingPanel').visible = false;
					$('#ErrorPanel').visible = true;
					$('#ErrorMessage').text = $.Localize(error);
				});
				break;
		}
	});
})();
