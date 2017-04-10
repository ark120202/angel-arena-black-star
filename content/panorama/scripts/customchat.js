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
	//data.shop_item_name = "item_rapier"
	//data.text = null;
	//data.gold = 123;
	if (playerID != null && !Game.IsPlayerMuted(playerID)) {
		//var localPlayerId = Game.GetLocalPlayerID()
		var SenderHero = GetPlayerHeroName(playerID);
		var html = "";
		var rootPanel = CustomChatLinesPanel || $("#SelectionChatMessages");
		var playerColor = GetHEXPlayerColor(playerID);
		if (SenderHero != "npc_dota_hero_target_dummy")
			html = "<img src='" + TransformTextureToPath(SenderHero) + "' class='HeroIcon' style='vertical-align: top;'/> ";
		html += data.teamonly == 1 ? "<font color='lime'>[T]</font>" : "<font color='darkred'>[A]</font>";
		html += " <font color='" + playerColor + "'>" + Players.GetPlayerName(playerID).encodeHTML() + "</font>: ";
		if (data.text != null) {
			html += AddSmiles(String(data.text).encodeHTML());
		} else if (data.gold != null && data.player != null) {
			html += "<img src='file://{images}/control_icons/chat_wheel_icon.png' class='ChatWheelIcon' />";
			var localized = $.Localize(data.player == playerID ? "chat_message_gold_self" : "chat_message_gold_ally")
			localized = localized.replace("{gold}", "<font color='gold'>" + FormatGold(data.gold) + "</font>")
			localized = localized.replace("{player}", "<font color='" + GetHEXPlayerColor(data.player) + "'>" + $.Localize(GetPlayerHeroName(data.player)) + "</font>")
			html += localized
		} else if (data.ability != null && data.player != null && data.unit != null) {
			html += "<img src='file://{images}/control_icons/chat_wheel_icon.png' class='ChatWheelIcon' />";
			var localized;
			var cooldown = Abilities.GetCooldownTimeRemaining(data.ability)
			if (Players.GetTeam(data.player) == Players.GetTeam(playerID)) {
				if (Abilities.GetLevel(data.ability) == 0) {
					localized = "chat_message_ability_not_learned"
				} else if (!Abilities.IsOwnersManaEnough(data.ability)) {
					localized = "chat_message_ability_mana"
				} else if (cooldown > 0) {
					localized = "chat_message_ability_cooldown"
				} else if (Abilities.IsPassive(data.ability)) {
					localized = "chat_message_ability_passive"
				} else {
					localized = "chat_message_ability_ready"
				}
				if (data.player != playerID) {
					localized = localized.replace("chat_message_ability_", "chat_message_ability_ally_")
				}
			} else {
				localized = "chat_message_ability_enemy"
			}
			if (Abilities.IsItem(data.ability) && Abilities.GetLevel(data.ability) == 1 && (localized.endsWith("_passive") || localized.endsWith("_ready") || localized.endsWith("_enemy"))) {
				localized = localized.replace("chat_message_ability_", "chat_message_item_")
			}
			localized = $.Localize(localized)
			localized = localized.replace("{ability_level}", Abilities.GetLevel(data.ability))
			localized = localized.replace("{ability_name}", $.Localize("DOTA_Tooltip_ability_" + Abilities.GetAbilityName(data.ability)))
			localized = localized.replace("{ability_cooldown}", cooldown.toFixed(0))
			localized = localized.replace("{mana_need}", Math.round(Abilities.GetManaCost(data.ability) - Entities.GetMana(data.unit)))
			localized = localized.replace("{player}", "<font color='" + GetHEXPlayerColor(data.player) + "'>" + $.Localize(GetPlayerHeroName(data.player)) + "</font>")
			html += localized
		} else if (data.shop_item_name != null) {
			html += "<img src='file://{images}/control_icons/chat_wheel_icon.png' class='ChatWheelIcon' />";
			var localized = data.boss_drop ? "chat_message_shop_purchase_boss" : data.stock_time != null ? "chat_message_shop_purchase_no_stock" : data.gold != null ? (data.isQuickbuy ? "chat_message_shop_purchase_quickbuy_no_gold" : "chat_message_shop_purchase_no_gold") : (data.isQuickbuy ? "chat_message_shop_purchase_quickbuy" : "chat_message_shop_purchase")
			
			localized = $.Localize(localized)
			localized = localized.replace("{item_name}", $.Localize("DOTA_Tooltip_ability_" + data.shop_item_name))
			localized = localized.replace("{gold}", data.gold)
			localized = localized.replace("{stock_time}", data.stock_time)
			html += localized
		} else if (data.level != null) {
			html += "<img src='file://{images}/control_icons/chat_wheel_icon.png' class='ChatWheelIcon' />";
			var localized = ((data.xpToNextLevel == null && !data.isNeutral) ? "chat_message_level_side_capped" : "chat_message_level_side")
			var unitSide = data.unit == Players.GetPlayerHeroEntityIndex(playerID) ? "self" : Entities.GetTeamNumber(data.unit) == Players.GetTeam(playerID) ? "ally" : "enemy"
			localized = localized.replace("side", unitSide)
			localized = $.Localize(localized)

			localized = localized.replace("{level_next}", data.level + 1)
			localized = localized.replace("{level}", data.level)
			localized = localized.replace("{xp}", data.xpToNextLevel)
			localized = localized.replace("{player}", "<font color='" + (data.player == -1 ? "#FFFFFF" : GetHEXPlayerColor(data.player)) + "'>" + $.Localize(GetHeroName(data.unit)) + "</font>")
			html += localized
		}

		var lastLine = rootPanel.GetChild(0);
		var msgBox = $.CreatePanel("Label", rootPanel, "");
		msgBox.AddClass("ChatLine");
		msgBox.style.transform = "scaleY(-1)";
		msgBox.html = true;
		$.Schedule(7.5, function() {
			msgBox.AddClass("Expired");
		})
		if (lastLine != null) {
			rootPanel.MoveChildBefore(msgBox, lastLine);
		}
		msgBox.text = html;
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