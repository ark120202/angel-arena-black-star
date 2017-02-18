"use strict";
var PlayerTables = GameUI.CustomUIConfig().PlayerTables

var g_ScoreboardHandle = null;

function UpdateScoreboard() {
	ScoreboardUpdater_SetScoreboardActive(g_ScoreboardHandle, true);

	//Arena: Update game time
	var current_Time = Math.abs(Game.GetDOTATime(false, true))
	_ScoreboardUpdater_SetTextSafe(g_ScoreboardHandle.scoreboardPanel, "timerLabel", secondsToMS(current_Time, true))
	var timerImageDeg = ((current_Time - (Math.floor(current_Time / 480) * 480)) / 480) * 360
	g_ScoreboardHandle.scoreboardPanel.FindChildInLayoutFile("timerImage").style.transform = "rotateZ(" + timerImageDeg + "deg)"
	if (timerImageDeg >= 0 && timerImageDeg < 180) {
		g_ScoreboardHandle.scoreboardPanel.FindChildInLayoutFile("timerImageMask3").SetImage("file://{images}/custom_game/scoreboard/scoreboard_ifd.png")
	} else {
		g_ScoreboardHandle.scoreboardPanel.FindChildInLayoutFile("timerImageMask3").SetImage("file://{images}/custom_game/scoreboard/scoreboard_if4.png")
	}
	if (($("#timerImageMask1").darknessEndTime != null && $("#timerImageMask1").darknessEndTime >= Game.GetDOTATime(false, false)) && !$("#timerImageMask1").visible) {
		$("#timerImageMask1").visible = true
	} else if ($("#timerImageMask1").darknessEndTime == null || ($("#timerImageMask1").darknessEndTime < Game.GetDOTATime(false, false) && $("#timerImageMask1").visible)) {
		$("#timerImageMask1").visible = false
	}
	//g_ScoreboardHandle.scoreboardPanel.FindChildInLayoutFile("duelTimerLabel");

	$.Schedule(0.2, UpdateScoreboard);
}

function ShowScoreboard() {
	var shouldSort = false;
	var scoreboardConfig = {
		"teamXmlName": "file://{resources}/layout/custom_game/arena_top_scoreboard_team.xml",
		"playerXmlName": "file://{resources}/layout/custom_game/arena_top_scoreboard_player.xml",
		"shouldSort": shouldSort
	};
	g_ScoreboardHandle = ScoreboardUpdater_InitializeScoreboard(scoreboardConfig, $("#MultiteamScoreboard"));
	UpdateScoreboard();

	GameEvents.Subscribe("time_nightstalker_darkness", (function(data) {
		$("#timerImageMask1").darknessEndTime = Game.GetDOTATime(false, false) + data.duration
	}))
}

function HideScoreboardVisible() {
	$("#TopBarScoreboard").visible = false
}

function ShowScoreboardVisible() {
	$("#TopBarScoreboard").visible = true
}

(function() {
	ShowScoreboard();
	HideScoreboardVisible();
	DynamicSubscribePTListener("hero_selection_available_heroes", function(tableName, changesObject, deletionsObject) {
		if (changesObject.HeroSelectionState != null && changesObject.HeroSelectionState >= HERO_SELECTION_STATE_END) {
			ShowScoreboardVisible()
		}
	});
	GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_TIMEOFDAY, false);
	GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_HEROES, false);
	GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_BAR_BACKGROUND, false);


	DynamicSubscribePTListener("arena", function(tableName, changesObject, deletionsObject) {
		var current_goal = changesObject["kill_goal"];
		if (current_goal != null) {
			$("#KillGoalLabel").text = current_goal;
		}
		if (changesObject["duel_timer"] != null)
			_ScoreboardUpdater_SetTextSafe(g_ScoreboardHandle.scoreboardPanel, "duelTimerLabel", secondsToMS(Number(changesObject["duel_timer"])));
	})
})();