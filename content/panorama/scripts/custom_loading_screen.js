"use strict";
var selectedKillGoal;

var TipList = [];
var ShuffledTipList = [];

function VoteMap(parentindex, gmtype) {
	GameEvents.SendCustomGameEventToServer("submit_gamemode_map", {
		GMType: gmtype
	});
	$("#GoalVotePanelCustomSettings_GM201").enabled = false;
	$.Each($("#GoalVotePanelCustomSettings_GM201").Children(), function(child) {
		child.enabled = false;
	})
}

function SubmitKillGoal() {
	if (selectedKillGoal != null) {
		GameEvents.SendCustomGameEventToServer("submit_gamemode_vote", {
			voteIndex: selectedKillGoal
		});
		$("#KillGoalVote").enabled = false;
		$("#KillGoalVoteSubmit").enabled = false;
	}
}

function FillTips() {
	var i = 1
	while (true) {
		var unlocalized = "arena_tip_" + i
		var localized = $.Localize(unlocalized)
		if (localized != unlocalized) {
			TipList.push({
				num: i,
				text: localized
			});
		} else {
			break;
		}
		i++;
	}
}

function NextTip() {
	if (ShuffledTipList.length == 0) {
		ShuffledTipList = JSON.parse(JSON.stringify(TipList))
		shuffle(ShuffledTipList)
	}
	var shifted = ShuffledTipList.shift()

	$("#TipLabel").text = shifted.text;
}

function CheckStartable() {
	var player = Game.GetLocalPlayerInfo()
	if (player == null)
		$.Schedule(0.2, CheckStartable)
	else {
		$("#afterload_panel").visible = true;
		/*$.AsyncWebRequest('http://127.0.0.1:3228/AABSServer/GetPublicInfoForPlayer?steam_id=' + player.player_steamid, {
			type: 'GET',
			success: function(data) {
				$.Msg('Server Reply: ', data)
				if (data) {
					var LocalPlayerDataPanel = $("#LocalPlayerDataPanel");
					LocalPlayerDataPanel.RemoveClass("Loading");
					LocalPlayerDataPanel.SetDialogVariable("rating", data.Rating || "TBD")
					LocalPlayerDataPanel.SetDialogVariable("win_rate", data.Games_Won + "/" + data.Games_Played + " (" + Math.round(data.Games_Won / data.Games_Played * 100) + ")");
				}
			}
		});*/
		PlayerTables = GameUI.CustomUIConfig().PlayerTables;
		DynamicSubscribePTListener("arena", function(tableName, changesObject, deletionsObject) {
			var gamemode_settings = changesObject["gamemode_settings"]
			if (gamemode_settings != null) {
				if (gamemode_settings.kill_goals != null) {
					$.Each(gamemode_settings.kill_goals, function(killGoal, tIndex) {
						var button = $.CreatePanel("RadioButton", $("#KillGoalVoteVartiantList"), "");
						//button.AddClass("ButtonBevel")
						//button.AddClass("VoteKillGoalButton")
						button.AddClass("KillGoalVariant")
						button.group = "kill_goal_variants"
						button.SetPanelEvent("onactivate", function() {
							selectedKillGoal = tIndex
						})
						var label = $.CreatePanel("Label", button, ""); //<Label text="4 (20%)" style="horizontal-align: right;" />;
						label.text = killGoal;
						label.style.color = "white"
						label.style.fontSize = "20px"
							/*var votedataLabel = $.CreatePanel("Label", button, "vote_data_variant_" + tIndex); //<Label text="4 (20%)" style="horizontal-align: right;" />;
							//votedataLabel.text = "0 (0%)";
							votedataLabel.style.horizontalAlign = "right"
							votedataLabel.style.color = "white"
							votedataLabel.style.fontSize = "19px"*/
					})
				}
				if (gamemode_settings.kill_goal_votes != null) {
					var votes = []
					$.Each(gamemode_settings.kill_goal_votes, function(selectedVariant, playerID) {
						votes[selectedVariant] = (votes[selectedVariant] || 0) + 1
					})
				}
				$("#CustomSettingsRoot").visible = Number(gamemode_settings.gamemode_map) == ARENA_GAMEMODE_MAP_CUSTOM_ABILITIES
			}
		});
	}
}

(function() {
	$("#LocalPlayerDataPanel").AddClass("Loading")
	$.Schedule(0.2, CheckStartable);
	FillTips();
	$("#TipsPanel").visible = TipList.length > 0;
	if (TipList.length > 0) {
		NextTip()
	}
})()