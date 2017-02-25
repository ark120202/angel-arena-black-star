var PlayerPanels = [];
var TeamPanels = [];
var darknessEndTime = -1;
var players_abandoned = [];

function Snippet_TopBarPlayerSlot(panel, pid) {
	panel.BLoadLayoutSnippet("TopBarPlayerSlot")
	panel.playerId = pid
	PlayerPanels.push(panel);
}

function Snippet_TopBarPlayerSlot_Update(panel) {
	var playerId = panel.playerId;
	if (players_abandoned.indexOf(playerId) == -1) {
		panel.visible = false;
	} else {
		var playerInfo = Game.GetPlayerInfo(playerId);
		var heroName = GetPlayerHeroName(playerId)
		var respawnSeconds = playerInfo.player_respawn_seconds
		var connectionState = playerInfo.player_connection_state
		var heroEnt = playerInfo.player_selected_hero_entity_index
		var playerColor = GetHEXPlayerColor(playerId);
		panel.SetDialogVariableInt("respawn_seconds", respawnSeconds)
		panel.SetHasClass("Dead", respawnSeconds > 0)
		panel.SetHasClass("Disconnected", connectionState == DOTAConnectionState_t.DOTA_CONNECTION_STATE_DISCONNECTED);
		panel.FindChildTraverse("HeroImage").SetImage(TransformTextureToPath(heroName));
		panel.FindChildTraverse("PlayerColor").style.backgroundColor = playerColor;
		//panel.FindChildTraverse("PlayerColorShadow").style.washColor = playerColor;

		/*
			BuybackReady

			IsAbilityDraft
			UltLearned
			UltReady
			UltReadyNoMana
			UltOnCooldown


			.TopBarHeroImage
			.PlayerContainer
		*/
	}
}

function Snippet_DotaTeamBar(team) {
	var isRight = team % 2 != 0;
	var rootPanel = $(isRight ? "#TopBarRightPlayers" : "#TopBarLeftPlayers")
	var panel = $.CreatePanel("Panel", rootPanel, "")
	panel.BLoadLayoutSnippet("DotaTeamBar")
	panel.team = team
	panel.SetHasClass("LeftAlignedTeam", !isRight)
	panel.SetHasClass("RightAlignedTeam", isRight)

	TeamPanels.push(panel);
	return panel;
}

function Snippet_DotaTeamBar_Update(panel) {
	var team = panel.team
	panel.SetHasClass("EnemyTeam", team == Players.GetTeam(Game.GetLocalPlayerID()));
	panel.SetDialogVariableInt("team_score", 12)
}

function Update() {
	$.Schedule(0.1, Update);
	var rawTime = Game.GetDOTATime(false, true);
	var time = Math.abs(rawTime);
	var isNSNight = rawTime < darknessEndTime;
	var IsDayTime = !isNSNight && (time - (Math.floor(time / 480) * 480)) <= 240;
	var context = $.GetContextPanel();

	context.SetHasClass("DayTime", IsDayTime)
	context.SetHasClass("NightTime", !IsDayTime)
	context.SetDialogVariable("time_of_day", secondsToMS(time, true));
	$("#DayTime").visible = IsDayTime;
	$("#NightTime").visible = !isNSNight && !IsDayTime;
	$("#NightstalkerNight").visible = isNSNight;

	for (var i = 0; i < PlayerPanels.length; i++) {
		Snippet_TopBarPlayerSlot_Update(PlayerPanels[i]);
	}
	//context.SetHasClass("Spectating", Players.IsSpectator(Game.GetLocalPlayerID()))
}

(function() {
	GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_TIMEOFDAY, false);
	GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_HEROES, false);
	GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_BAR_BACKGROUND, false);
	GameEvents.Subscribe("time_nightstalker_darkness", (function(data) {
		darknessEndTime = Game.GetDOTATime(false, false) + data.duration
	}))
	DynamicSubscribePTListener("hero_selection_available_heroes", function(tableName, changesObject, deletionsObject) {
		if (changesObject.HeroSelectionState != null && changesObject.HeroSelectionState >= HERO_SELECTION_STATE_END) {
			$.GetContextPanel().SetHasClass("TopBarVisible", true)
		}
	});
	DynamicSubscribePTListener("arena", function(tableName, changesObject, deletionsObject) {
		if (changesObject.kill_goal != null) {
			//$("#KillGoalLabel").text = changesObject.kill_goal;
		}
		if (changesObject.duel_timer != null) {
			//_ScoreboardUpdater_SetTextSafe(g_ScoreboardHandle.scoreboardPanel, "duelTimerLabel", secondsToMS(Number(changesObject.duel_timer)));
		}
		if (changesObject.players_abandoned != null) {
			players_abandoned = changesObject.players_abandoned
		}
	})

	$("#TopBarLeftPlayers").RemoveAndDeleteChildren()
	$("#TopBarRightPlayers").RemoveAndDeleteChildren()
		//var PlayerPanel = $.CreatePanel("Panel", $("#TopBarRadiantPlayersContainer"), "")
		//Snippet_TopBarPlayerSlot(PlayerPanel, Game.GetLocalPlayerID())
	Snippet_DotaTeamBar(2)
	Snippet_DotaTeamBar(3)
	Snippet_DotaTeamBar(6)


	Update();
})()