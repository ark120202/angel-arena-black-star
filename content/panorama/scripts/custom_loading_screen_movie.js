"use strict";
var minVote = 0
var maxVote = 0

function SendKillGoalVote() {
	var input = $("#GoalVoteTextEntry").text
	if (isNaN(input) || Number(input) > maxVote || Number(input) < minVote) {
		$("#GoalVoteTextEntry").AddClass("RedOutlineForNaN")
	} else {
		$("#GoalVoteTextEntry").RemoveClass("RedOutlineForNaN")
		GameEvents.SendCustomGameEventToServer("submit_gamemode_vote", {
			vote: input
		});
		$("#GoalVotePanel").RemoveClass("GoalVotePanel_In")
			//HideCallMenu()
	}
}

function RandomizeStar() {
	var pnlid = Math.floor((Math.random() * 5) + 1)
	var pnl = $("#star" + pnlid)
	if (pnl) {
		var scale = Math.random() * (1.1 - 0.85) + 0.85;
		var offsetX = Math.random() * (12 - -12) + -12;
		var offsetY = Math.random() * (12 - -12) + -12;
		pnl.style.transform = "scaleX(" + scale + ") scaleY(" + scale + ") translateX(" + offsetX + "px) translateY(" + offsetY + "px)"
		$.Schedule(0.5, RandomizeStar)
	}
}

function ShowStar(id) {
	var panel = $("#star" + id)
	if (panel != null) {
		panel.visible = true
		$.Schedule(1, function() {
			panel.AddClass("star_floating")
			ShowStar(id + 1)
		})
	}
}

(function() {
	$("#GoalVotePanel").AddClass("GoalVotePanel_In")
	DynamicSubscribePTListener("arena", function(tableName, changesObject, deletionsObject) {
		var gamemode_settings = changesObject["gamemode_settings"]
		if (gamemode_settings != null && gamemode_settings.kill_goal_vote_min != null && gamemode_settings.kill_goal_vote_max != null) {
			minVote = gamemode_settings.kill_goal_vote_min
			maxVote = gamemode_settings.kill_goal_vote_max
			$("#GoalVoteMinValue").text = minVote + ".."
			$("#GoalVoteMaxValue").text = ".." + maxVote
		}
	})

	//GameEvents.Subscribe("game_rules_state_change", CheckGoalVote);
	$("#StarsBox").visible = false
	$("#star1").visible = false
	$("#star2").visible = false
	$("#star3").visible = false
	$("#star4").visible = false
	$("#star5").visible = false
	$("#Arthas").AddClass("Arthas_Animation")
	$.Schedule(8.0, function() { //Hooked to class Arthas_Animation
		$("#Arthas").RemoveClass("Arthas_Animation")
		$("#Arthas").AddClass("Arthas_Animation_end")
		$("#Enigma").AddClass("Enigma_In")
		$.Schedule(3.0, function() { //Hooked to class Enigma
			$("#EnigmasBlackhole").style.visibility = "visible"
			$("#EnigmasBlackhole").AddClass("EnigmasBlackhole_In")
			var bhid = Game.EmitSound("Hero_Enigma.Black_Hole")
			$.Schedule(5.0, function() { //Hooked to class EnigmasBlackhole_In
				Game.StopSound(bhid)
				Game.EmitSound("Hero_Enigma.Black_Hole.Stop")
				$("#Enigma").RemoveClass("Enigma_In")
				$("#Arthas").AddClass("Fade_Out")
				$("#EnigmasBlackhole").RemoveClass("EnigmasBlackhole_In")
				$("#EnigmasBlackhole").visible = false
				$.Schedule(1, function() { //Hooked to class Fade_Out
					$("#Arthas").visible = false
					$.Schedule(2, function() { //Not hooked
						$("#Logo_aa").AddClass("Logo_aa_In")
						$.Schedule(2, function() { //Hooked to class Logo_aa
							$("#Logo_aa").AddClass("Logo_aa_locked_moving")
							$("#Logo_jesus").AddClass("Logo_jesus_In")
							$("#Logo_satan").AddClass("Logo_satan_In")
							$.Schedule(4, function() { //Hooked to classes Logo_jesus && Logo_satan
								$("#Logo_jesus").AddClass("Logo_jesus_locked_moving")
								$("#Logo_satan").AddClass("Logo_satan_locked_moving")
								$("#Label_black_panel").AddClass("Label_black_panel_In")
								$.Schedule(3, function() { //Hooked to class Label_black_panel
									$("#Label_black_panel").AddClass("Label_black_panel_locked_moving")
									$("#Label_black").AddClass("Label_black_locked_blinking")
									$("#StarsBox").visible = true
									$("#StarsBox").AddClass("StarsBox_Showing")
									$.Schedule(5, function() { //Hooked to classes Label_black_locked_blinking && StarsBox_Showing
										$("#Label_black").RemoveClass("Label_black_locked_blinking")
										$("#StarsBox").RemoveClass("StarsBox_Showing")
										$("#StarsBox").AddClass("StarsBox_Shown")
										$.Schedule(1, function() {
											ShowStar(1)
											RandomizeStar()
										})
										$.Schedule(5, function() {
											//TODO Afterload actions
										})
									})
								})
							})
						})
					})
				})
			})
		})
	})
})()