"use strict";
var PlayerTables = GameUI.CustomUIConfig().PlayerTables

var g_ScoreboardHandle = null;

function UpdateScoreboard() {
	ScoreboardUpdater_SetScoreboardActive(g_ScoreboardHandle, true);

	//////////////////////////////////////////////////////////////////////////////////////////////
	//Arena: Update game time
	//////////////////////////////////////////////////////////////////////////////////////////////
	var current_Time = Game.GetDOTATime(false, false)

	_ScoreboardUpdater_SetTextSafe(g_ScoreboardHandle.scoreboardPanel, "timerLabel", secondsToHms(current_Time))
	var timerImageDeg = ((current_Time - (Math.floor(current_Time / 480) * 480)) / 480) * 360
	g_ScoreboardHandle.scoreboardPanel.FindChildInLayoutFile("timerImage").style.transform = "rotateZ(" + timerImageDeg + "deg)"
	if (timerImageDeg >= 0 && timerImageDeg < 180) {
		g_ScoreboardHandle.scoreboardPanel.FindChildInLayoutFile("timerImageMask3").SetImage("file://{resources}/images/custom_game/scoreboard/scoreboard_ifd.png")
	} else {
		g_ScoreboardHandle.scoreboardPanel.FindChildInLayoutFile("timerImageMask3").SetImage("file://{resources}/images/custom_game/scoreboard/scoreboard_if4.png")
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

function secondsToHms(seconds) {
	var sec_num = parseInt(seconds, 10);
	var hours = Math.floor(sec_num / 3600);
	var minutes = Math.floor((sec_num - (hours * 3600)) / 60);
	var seconds = sec_num - (hours * 3600) - (minutes * 60);

	if (hours < 10)
		hours = "0" + hours;
	if (minutes < 10)
		minutes = "0" + minutes;
	if (seconds < 10)
		seconds = "0" + seconds;
	return hours + ':' + minutes + ':' + seconds;
}

function secondsToMS(seconds) {
	var sec_num = parseInt(seconds, 10);
	var minutes = Math.floor(sec_num / 60);
	var seconds = Math.floor(sec_num - minutes * 60);

	if (minutes < 10)
		minutes = "0" + minutes;
	if (seconds < 10)
		seconds = "0" + seconds;
	return minutes + ':' + seconds;
}

(function() {
	GameEvents.Subscribe("time_hide", HideScoreboardVisible);
	GameEvents.Subscribe("time_show", ShowScoreboardVisible);
	ShowScoreboard();
	GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_TIMEOFDAY, false);
	GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_HEROES, false);
	GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_BAR_BACKGROUND, false);
	if (!Game.GameStateIsAfter(DOTA_GameState.DOTA_GAMERULES_STATE_PRE_GAME)) {
		HideScoreboardVisible();
	}

	DynamicSubscribePTListener("arena", function(tableName, changesObject, deletionsObject) {
		var current_goal = changesObject["kill_goal"];
		if (current_goal != null) {
			$("#KillGoalLabel").text = current_goal;
		}
		if (changesObject["gamemode_settings"] != null && changesObject["gamemode_settings"]["gamemode_type"] != null) {
			if (changesObject["gamemode_settings"]["gamemode"] == DOTA_GAMEMODE_HOLDOUT_5) {
				$("#KillGoalPanel").visible = false;
				$("#duelTimerLabel_base").text = "1" + $.Localize("holdout_timer_label");
			}
		}
		if (changesObject["duel_timer"] != null)
			_ScoreboardUpdater_SetTextSafe(g_ScoreboardHandle.scoreboardPanel, "duelTimerLabel", secondsToMS(Number(changesObject["duel_timer"])));
		if (changesObject["holdout_wave_num"] != null)
			_ScoreboardUpdater_SetTextSafe(g_ScoreboardHandle.scoreboardPanel, "duelTimerLabel_base", changesObject["holdout_wave_num"] + $.Localize("holdout_timer_label"));
		if (changesObject["holdout_timer"] != null)
			_ScoreboardUpdater_SetTextSafe(g_ScoreboardHandle.scoreboardPanel, "duelTimerLabel", secondsToMS(changesObject["holdout_timer"]));
		if (changesObject["holdout_killed_units"] != null)
			_ScoreboardUpdater_SetTextSafe(g_ScoreboardHandle.scoreboardPanel, "duelTimerLabel", changesObject["holdout_killed_units"]);
	})
})();