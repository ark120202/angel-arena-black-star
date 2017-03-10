"use strict";

function ChatSendMessage() {
	if ($("#SelectionChatEntry").text.length > 0) {
		GameEvents.SendCustomGameEventToServer("custom_chat_send_message", {
			text: $("#SelectionChatEntry").text,
			teamOnly: true
		})
		$("#SelectionChatEntry").text = ""
	}
}

function RecieveMessage(data) {
	var playerID = data.playerId
	if (data != null && data.text != null && playerID != null && !Game.IsPlayerMuted(playerID)) {
		var rootPanel = CustomChatLinesPanel || $("#SelectionChatMessages")
		var playerColor = Players.GetPlayerColor(playerID).toString(16)
		if (playerColor != null)
			playerColor = "#" + playerColor.substring(6, 8) + playerColor.substring(4, 6) + playerColor.substring(2, 4) + playerColor.substring(0, 2)
		else
			playerColor = "#000000";
		var text = ""
		if (GetPlayerHeroName(playerID) != "npc_dota_hero_target_dummy")
			text = "<img src='" + TransformTextureToPath(GetPlayerHeroName(playerID)) + "' class='HeroIcon' style='vertical-align: top;'/> "
		text += (data.teamonly == 1 ? "<font color='lime'>[T]</font>" : "<font color='darkred'>[A]</font>") + " <font color='" + playerColor + "'>" + Players.GetPlayerName(playerID).encodeHTML() + "</font>: " + AddSmiles(String(data.text).encodeHTML())
		var lastLine = rootPanel.GetChild(0);
		var msgBox = $.CreatePanel("Label", rootPanel, "")
		msgBox.AddClass("ChatLine")
		msgBox.style.transform = "scaleY(-1)"
		$.Schedule(7.5, function() {
			msgBox.AddClass("Expired")
		})
		msgBox.html = true;
		msgBox.text = text
		if (lastLine != null) {
			rootPanel.MoveChildBefore(msgBox, lastLine);
		}
	}
}

function AddSmiles(string) {
	string = string.replace(new RegExp("\\b(" + escapeRegExp(Object.keys(twitchSmileMap).join("|")) + ")\\b", "g"), function(matched) {
		return "<img src='" + twitchUrlMask.replace("{id}", twitchSmileMap[matched]) + "'/>";
	});
	string = string.replace(new RegExp("\\b(" + escapeRegExp(Object.keys(bttvSmileMap).join("|")) + ")\\b", "g"), function(matched) {
		return "<img src='" + bttvUrlMask.replace("{id}", bttvSmileMap[matched]) + "'/>";
	});
	return string
}

(function() {
	GameEvents.Subscribe("custom_chat_recieve_message", RecieveMessage)
})()