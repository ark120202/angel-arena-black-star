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
	var duelTimer = PlayerTables.GetTableValue("arena", "duel_timer")
	_ScoreboardUpdater_SetTextSafe(g_ScoreboardHandle.scoreboardPanel, "duelTimerLabel", secondsToHms(duelTimer))

	$.Schedule(0.2, UpdateScoreboard);
}

function ShowScoreboard() {
	var shouldSort = false;
	if (GameUI.CustomUIConfig().multiteam_top_scoreboard) {
		var cfg = GameUI.CustomUIConfig().multiteam_top_scoreboard;
		if (cfg.LeftInjectXMLFile) {
			$("#LeftInjectXMLFile").BLoadLayout(cfg.LeftInjectXMLFile, false, false);
		}
		if (cfg.RightInjectXMLFile) {
			$("#RightInjectXMLFile").BLoadLayout(cfg.RightInjectXMLFile, false, false);
		}

		if (typeof(cfg.shouldSort) !== 'undefined') {
			shouldSort = cfg.shouldSort;
		}
	}
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

function UpdateKillGoal(tableName, changesObject, deletionsObject) {
	if (changesObject["kill_goal"]) {
		$("#KillGoalLabel").text = changesObject["kill_goal"]
	}
}

(function() {
	GameEvents.Subscribe("time_hide", HideScoreboardVisible)
	GameEvents.Subscribe("time_show", ShowScoreboardVisible)
	PlayerTables.SubscribeNetTableListener("arena", UpdateKillGoal)
	var current_goal = PlayerTables.GetTableValue("arena", "kill_goal")
	if (current_goal != null) {
		$("#KillGoalLabel").text = current_goal
	}
	ShowScoreboard()
	if (!Game.GameStateIsAfter(DOTA_GameState.DOTA_GAMERULES_STATE_PRE_GAME)) {
		HideScoreboardVisible()
	}
	GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_TIMEOFDAY, false)
	GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_HEROES, false)
	GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_BAR_BACKGROUND, false)

})();

function secondsToHms(seconds) {
	var sec_num = parseInt(seconds, 10); // don't forget the second param
	var hours = Math.floor(sec_num / 3600);
	var minutes = Math.floor((sec_num - (hours * 3600)) / 60);
	var seconds = sec_num - (hours * 3600) - (minutes * 60);

	if (hours < 10) {
		hours = "0" + hours;
	}
	if (minutes < 10) {
		minutes = "0" + minutes;
	}
	if (seconds < 10) {
		seconds = "0" + seconds;
	}
	var time = hours + ':' + minutes + ':' + seconds;
	return time;
}