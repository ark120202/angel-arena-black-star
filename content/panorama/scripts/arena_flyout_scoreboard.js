"use strict";

var g_ScoreboardHandle = null;

function SetFlyoutScoreboardVisible(bVisible) {
	$.GetContextPanel().SetHasClass("flyout_scoreboard_visible", bVisible);
	ScoreboardUpdater_SetScoreboardActive(g_ScoreboardHandle, bVisible);
}

(function() {
	if (ScoreboardUpdater_InitializeScoreboard === null) {
		$.Msg("WARNING: This file requires shared_scoreboard_updater.js to be included.");
	}

	var scoreboardConfig = {
		"teamXmlName": "file://{resources}/layout/custom_game/arena_flyout_scoreboard_team.xml",
		"playerXmlName": "file://{resources}/layout/custom_game/arena_flyout_scoreboard_player.xml",
	};
	g_ScoreboardHandle = ScoreboardUpdater_InitializeScoreboard(scoreboardConfig, $("#TeamsContainer"));

	SetFlyoutScoreboardVisible(false);
	var scoreboard = GetDotaHud().FindChildTraverse("scoreboard");
	var UpdateScoreVisible = function() {
		SetFlyoutScoreboardVisible(!scoreboard.BHasClass("ScoreboardClosed"))
		$.Schedule(0.2, UpdateScoreVisible);
	}
	UpdateScoreVisible();
	//$.RegisterEventHandler("DOTACustomUI_SetFlyoutScoreboardVisible", $.GetContextPanel(), SetFlyoutScoreboardVisible);
	GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_FLYOUT_SCOREBOARD, false)
})();