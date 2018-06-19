var PlayerPanels = [];
var TeamPanels = [];
var SharedControlPanels = [];
var players_abandoned = [];
var teamColors = GameUI.CustomUIConfig().team_colors;

function Snippet_SharedControlPlayer(pid) {
	if (SharedControlPanels[pid] == null) {
		var panel = $.CreatePanel('Panel', $('#PlayersContainer'), '');
		panel.BLoadLayoutSnippet('SharedControlPlayer');
		panel.playerId = pid;
		var DisableHelpButton = panel.FindChildTraverse('DisableHelpButton');
		DisableHelpButton.SetDialogVariable('player_name', Players.GetPlayerName(pid));
		DisableHelpButton.SetPanelEvent('onactivate', function() {
			GameEvents.SendCustomGameEventToServer('set_help_disabled', {
				player: pid,
				disabled: DisableHelpButton.checked
			});
		});
		SharedControlPanels[pid] = panel;
	}
	return SharedControlPanels[pid];
}

function Snippet_SharedControlPlayer_Update(panel) {
	panel.visible = Players.GetTeam(panel.playerId) === Players.GetTeam(Game.GetLocalPlayerID()) && Snippet_Player(panel.playerId).visible;
	panel.SetHasClass('LocalPlayer', panel.playerId === Game.GetLocalPlayerID());
}

function Snippet_Player(playerId) {
	if (PlayerPanels[playerId] == null) {
		var team = Players.GetTeam(playerId);
		if (team !== DOTA_TEAM_SPECTATOR) {
			var playerInfo = Game.GetPlayerInfo(playerId);
			var teamPanel = Snippet_Team(team).FindChildTraverse('TeamPlayersContainer');
			var panel = $.CreatePanel('Panel', teamPanel, '');
			panel.BLoadLayoutSnippet('Player');
			panel.FindChildTraverse('PlayerNameLabel').text = Players.GetPlayerName(playerId);
			panel.FindChildTraverse('AvatarImage').steamid = playerInfo.player_steamid;
			panel.FindChildTraverse('AvatarImage').SetPanelEvent('onactivate', function() {
				GameEvents.SendEventClientSide('player_profiles_show_info', { playerId: playerId });
			});
			var VoiceMute = panel.FindChildTraverse('VoiceMute');
			panel.playerId = playerId;
			panel.SetHasClass('EmptyPlayerRow', false);
			panel.SetHasClass('LocalPlayer', playerId === Game.GetLocalPlayerID());
			var xpRoot = FindDotaHudElement('ScoreboardXP');
			_.each([xpRoot.FindChildTraverse('LevelBackground'), xpRoot.FindChildTraverse('CircularXPProgress')/*, xpRoot.FindChildTraverse("XPProgress")*/], function(p) {
				p.SetPanelEvent('onactivate', function() {
					if (GameUI.IsAltDown()) {
						var clientEnt = Players.GetPlayerHeroEntityIndex(playerId);
						GameEvents.SendCustomGameEventToServer('custom_chat_send_message', {
							xpunit: clientEnt === -1 ? playerInfo.player_selected_hero_entity_index : clientEnt
						});
					}
				});
			});
			panel.FindChildTraverse('HeroImage').SetPanelEvent('onactivate', function() {
				Players.PlayerPortraitClicked(playerId, GameUI.IsControlDown(), GameUI.IsAltDown());
			});
			VoiceMute.checked = Game.IsPlayerMuted(playerId);
			VoiceMute.SetPanelEvent('onactivate', function() {
				Game.SetPlayerMuted(playerId, VoiceMute.checked);
			});
			panel.Resort = function() {
				SortPanelChildren(teamPanel, dynamicSort('playerId'), function(child, child2) {
					return child.playerId < child2.playerId;
				});
			};
			panel.Resort();
			/*panel.FindChildTraverse("HeroImage").SetPanelEvent("onactivate", function() {
				Players.PlayerPortraitClicked(playerId, GameUI.IsControlDown(), GameUI.IsAltDown());
			});
			var TopBarUltIndicator = panel.FindChildTraverse("TopBarUltIndicator")
			TopBarUltIndicator.SetPanelEvent("onmouseover", function() {
				//??????????
				if (panel.ultimateCooldown != null && panel.ultimateCooldown > 0) {
					$.DispatchEvent("UIShowTextTooltip", TopBarUltIndicator, panel.ultimateCooldown);
				}
				//$.DispatchEvent("UIShowTopBarUltimateTooltip ", panel, playerId);
			});
			panel.FindChildTraverse("TopBarUltIndicator").SetPanelEvent("onmouseout", function() {
				$.DispatchEvent("UIHideTextTooltip", panel);
				//$.DispatchEvent("DOTAHideTopBarUltimateTooltip", panel);
			});
			// ="DOTAShowTopBarUltimateTooltip()" onmouseout="DOTAHideTopBarUltimateTooltip()"*/
			PlayerPanels[playerId] = panel;
		}
	}
	return PlayerPanels[playerId];
}

function Snippet_Player_Update(panel) {
	var playerId = panel.playerId;
	if (players_abandoned.indexOf(playerId) !== -1) {
		panel.visible = false;
	} else {
		var playerInfo = Game.GetPlayerInfo(playerId);
		var heroName = GetPlayerHeroName(playerId);
		var respawnSeconds = playerInfo.player_respawn_seconds;
		var connectionState = playerInfo.player_connection_state;
		var heroEnt = playerInfo.player_selected_hero_entity_index;
		var ScoreboardUltIndicator = panel.FindChildTraverse('ScoreboardUltIndicator');
		var ultStateOrTime = playerInfo.player_team_id === Players.GetTeam(Game.GetLocalPlayerID()) ? Game.GetPlayerUltimateStateOrTime(playerId) : PlayerUltimateStateOrTime_t.PLAYER_ULTIMATE_STATE_HIDDEN;
		panel.SetHasClass('UltLearned', ultStateOrTime !== PlayerUltimateStateOrTime_t.PLAYER_ULTIMATE_STATE_NOT_LEVELED);
		panel.SetHasClass('UltReady', ultStateOrTime === PlayerUltimateStateOrTime_t.PLAYER_ULTIMATE_STATE_READY);
		panel.SetHasClass('UltReadyNoMana', ultStateOrTime === PlayerUltimateStateOrTime_t.PLAYER_ULTIMATE_STATE_NO_MANA);
		panel.SetHasClass('UltOnCooldown', ultStateOrTime > 0);
		panel.SetDialogVariableInt('ult_cooldown', ultStateOrTime);
		panel.SetDialogVariableInt('kills', Players.GetKills(playerId));
		panel.SetDialogVariableInt('deaths', Players.GetDeaths(playerId));
		panel.SetDialogVariableInt('assists', Players.GetAssists(playerId));
		panel.SetDialogVariable('gold', FormatGold(GetPlayerGold(playerId)));
		panel.SetDialogVariableInt('level', Players.GetLevel(playerId));
		panel.FindChildTraverse('HeroImage').SetImage(TransformTextureToPath(heroName));
		panel.FindChildTraverse('HeroNameLabel').text = $.Localize(heroName).toUpperCase();
		panel.FindChildTraverse('PlayerColor').style.backgroundColor = GetHEXPlayerColor(playerId);

		/*panel.SetDialogVariableInt("respawn_seconds", respawnSeconds + 1);
		panel.SetHasClass("Dead", respawnSeconds >= 0);
		panel.SetHasClass("Disconnected", connectionState == DOTAConnectionState_t.DOTA_CONNECTION_STATE_DISCONNECTED);*/
		if (playerInfo.player_team_id !== panel.GetParent().team && teamColors[playerInfo.player_team_id] != null) {
			panel.SetParent(Snippet_Team(playerInfo.player_team_id).FindChildTraverse('TeamPlayersContainer'));
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
		var TeamList = $('#TeamList');
		var panel = $.CreatePanel('Panel', TeamList, '');
		panel.BLoadLayoutSnippet('Team');
		panel.team = team;
		TeamPanels[team] = panel;
		panel.FindChildTraverse('TeamLabel').text = GameUI.CustomUIConfig().team_names[team];
		panel.FindChildTraverse('TeamLabel').style.textShadow = '0px 0px 6px 1.0 ' + teamColors[team];
		panel.FindChildTraverse('TeamScoreLabel').style.textShadow = '0px 0px 6px 1.0 ' + teamColors[team];
		panel.SetHasClass('FirstTeam', team === DOTATeam_t.DOTA_TEAM_GOODGUYS);

		SortPanelChildren(TeamList, dynamicSort('team'), function(child, child2) {
			return child.team < child2.team;
		});
	}
	return TeamPanels[team];
}

function Snippet_Team_Update(panel) {
	var team = panel.team;
	var isAlly = team === Players.GetTeam(Game.GetLocalPlayerID());
	panel.SetHasClass('EnemyTeam', !isAlly);
	panel.SetDialogVariableInt('score', GetTeamInfo(team).score);
	if (isAlly) {
		$('#SharedUnitControl').style.marginTop = Math.max(parseInt(panel.actualyoffset, 10), 0) + 'px';
		$('#SharedUnitControl').style.height = panel.actuallayoutheight + 'px';
	}
}

function Update() {
	$.Schedule(0.1, Update);
	var context = $.GetContextPanel();
	_.each(Game.GetAllPlayerIDs(), function(pid) {
		var team = Players.GetTeam(pid);
		if (team !== DOTA_TEAM_SPECTATOR) {
			Snippet_Player_Update(Snippet_Player(pid));
			Snippet_SharedControlPlayer_Update(Snippet_SharedControlPlayer(pid));
		}
	});
	var LocalTeam = Players.GetTeam(Game.GetLocalPlayerID());
	for (var i in TeamPanels) {
		Snippet_Team_Update(TeamPanels[i]);
	}
	context.SetHasClass('AltPressed', GameUI.IsAltDown());
}

function SetFlyoutScoreboardVisible(visible) {
	$.GetContextPanel().SetHasClass('ScoreboardClosed', !visible);
}

(function() {
	var LocalPlayerID = Game.GetLocalPlayerID();
	DynamicSubscribePTListener('players_abandoned', function(tableName, changesObject, deletionsObject) {
		for (var k in changesObject) {
			players_abandoned.push(Number(k));
		}
	});
	DynamicSubscribePTListener('disable_help_data', function(tableName, changesObject, deletionsObject) {
		if (changesObject[LocalPlayerID] != null) {
			_.each(changesObject[LocalPlayerID], function(state, playerId) {
				Snippet_SharedControlPlayer(playerId).FindChildTraverse('DisableHelpButton').checked = state === 1;
			});
		}
	});


	$('#TeamList').RemoveAndDeleteChildren();
	$('#PlayersContainer').RemoveAndDeleteChildren();
	Update();

	SetFlyoutScoreboardVisible(false);
	$.RegisterEventHandler('DOTACustomUI_SetFlyoutScoreboardVisible', $.GetContextPanel(), SetFlyoutScoreboardVisible);
	var debug = false;
	GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_FLYOUT_SCOREBOARD, debug);
	$.GetContextPanel().visible = !debug;
})();
