"use strict";

function VoteMap(parentindex, gmtype) {
	GameEvents.SendCustomGameEventToServer("submit_gamemode_map", {
		GMType: gmtype
	});
	$.Each($("#GoalVotePanelCustomSettings_GM" + parentindex).Children(), function(temppanel) {
		temppanel.enabled = false;
	});
}

function CheckStartable() {
	var player = Game.GetLocalPlayerInfo()
	if (player == null)
		$.Schedule(0.2, CheckStartable)
	else {
		$("#GoalVotePanel").AddClass("GoalVotePanel_In")
		PlayerTables = GameUI.CustomUIConfig().PlayerTables;
		DynamicSubscribePTListener("arena", function(tableName, changesObject, deletionsObject) {
			var gamemode_settings = changesObject["gamemode_settings"]
			if (gamemode_settings != null) {
				if (gamemode_settings.kill_goals != null) {
					$.Each(gamemode_settings.kill_goals, function(killGoal, tIndex) {
						var button = $.CreatePanel("Button", $("#GoalVotePanelKLValues"), "");
						button.AddClass("ButtonBevel")
						button.AddClass("VoteKillGoalButton")
						var label = $.CreatePanel("Label", button, "");
						label.hittest = false;
						label.text = killGoal;
						button.SetPanelEvent("onactivate", function() {
							GameEvents.SendCustomGameEventToServer("submit_gamemode_vote", {
								voteIndex: tIndex
							});
							$.Each($("#GoalVotePanelKLValues").Children(), function(temppanel) {
								temppanel.enabled = false;
							});
						})
					})
				}
				$("#GoalVotePanelCustomSettingsRoot").visible = Number(gamemode_settings.gamemode_map) == ARENA_GAMEMODE_MAP_CUSTOM_ABILITIES
			}
		});
	}
}

(function() {
	$.Schedule(0.2, CheckStartable)
})()