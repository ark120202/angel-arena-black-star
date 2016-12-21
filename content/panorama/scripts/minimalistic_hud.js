"use strict";
var ONCLICK_PURGABLE_MODIFIERS = [
	"modifier_rubick_personality_steal",
	"modifier_tether_ally_aghanims"
];
var DOTA_ACTIVE_GAMEMODE = -1,
	DOTA_ACTIVE_GAMEMODE_TYPE = -1,
	hud = GetDotaHud();

function UpdatePanoramaHUD() {
	var unit = Players.GetLocalPlayerPortraitUnit()
	hud.FindChildTraverse("UnitNameLabel").text = $.Localize(GetHeroName(unit)).toUpperCase();
	var inventory_items = hud.FindChildTraverse("inventory_items")
	for (var i = 0; i <= 14; i++) {
		var item = Entities.GetItemInSlot(unit, i)
		var custom_entity_value = GameUI.CustomUIConfig().custom_entity_values[item];
		if (item > -1) {
			if (custom_entity_value != null && custom_entity_value.ability_texture != null) {
				var itemPanel = inventory_items.FindChildTraverse("inventory_slot_" + i)
				if (itemPanel != null)
					itemPanel.FindChildTraverse("ItemImage").SetImage(TransformTextureToPath(custom_entity_value.ability_texture));
			}
		}
	}
	$("#rubick_personality_steal_hud").visible = false;
	for (var i = 0; i < Entities.GetNumBuffs(unit); ++i) {
		var buffSerial = Entities.GetBuff(unit, i);
		if (buffSerial != -1) {
			var buffName = Buffs.GetName(unit, buffSerial)
			if (ONCLICK_PURGABLE_MODIFIERS.indexOf(buffName) != -1) {
				$("#rubick_personality_steal_hud").visible = true;
				$("#rubick_personality_steal_hud").buffSerial = buffSerial;
			}
		}
	}

	var attribute_bonus_arena = Entities.GetAbilityByName(unit, "attribute_bonus_arena")
	hud.FindChildTraverse("level_stats_frame").visible = attribute_bonus_arena != -1 && Entities.IsControllableByPlayer(unit, Game.GetLocalPlayerID()) && Entities.GetAbilityPoints(unit) > 0;

	var GoldLabel = hud.FindChildTraverse("ShopButton").FindChildTraverse("GoldLabel")
	GoldLabel.text = "";
	goldCheck:
		if (Players.GetTeam(Game.GetLocalPlayerID()) == Entities.GetTeamNumber(unit)) {
			var goldTable = PlayerTables.GetTableValue("arena", "gold")
			for (var i = 0; i < 23; i++) {
				if (Players.GetPlayerHeroEntityIndex(i) == unit) {
					if (goldTable && goldTable[i] != null) {
						GoldLabel.text = goldTable[i]
						break goldCheck
					}
				}
			}
		}
	var apw = hud.FindChildTraverse("abilities").GetParent().actuallayoutwidth;
	if (!isNaN(apw) && apw > 0)
		hud.FindChildTraverse("HUDSkinAbilityContainerBG").style.width = ((hud.FindChildTraverse("abilities").actuallayoutwidth + 16) / apw * 100) + "%";
	var sw = Game.GetScreenWidth()
	var sh = Game.GetScreenHeight()
	var minimap = hud.FindChildTraverse("minimap_block");
	$("#DynamicMinimapRoot").style.height = ((minimap.actuallayoutheight + 8) / sh * 100) + "%";
	$("#DynamicMinimapRoot").style.width = ((minimap.actuallayoutwidth + 8) / sw * 100) + "%";

	var pcs = hud.FindChildTraverse("PortraitContainer").GetPositionWithinWindow()
	if (pcs != null && !isNaN(pcs.x) && !isNaN(pcs.y))
		$("#rubick_personality_steal_hud").style.position = (pcs.x / sw * 100) + "% " + ((pcs.y + 12) / sh * 100) + "% 0"
}

function AutoUpdatePanoramaHUD() {
	$.Schedule(0.2, AutoUpdatePanoramaHUD)
	UpdatePanoramaHUD();
}

function HookPanoramaPanels() {
	hud.FindChildTraverse("QuickBuyRows").visible = false;
	hud.FindChildTraverse("shop").visible = false;
	hud.FindChildTraverse("RadarButton").visible = false;
	var shopbtn = hud.FindChildTraverse("ShopButton")
	shopbtn.FindChildTraverse("BuybackHeader").visible = false;
	shopbtn.ClearPanelEvent("onactivate")
	shopbtn.ClearPanelEvent("onmouseover")
	shopbtn.ClearPanelEvent("onmouseout")
	shopbtn.SetPanelEvent("onactivate", function() {
		GameEvents.SendEventClientSide("panorama_shop_open_close", {})
	})
	hud.FindChildTraverse("LevelLabel").style.width = "100%"
	hud.FindChildTraverse("stash").style.marginBottom = "47px"

	//hud.FindChildTraverse("StatBranchChannel").visible = false;
	hud.FindChildTraverse("StatBranch").ClearPanelEvent("onactivate")
	hud.FindChildTraverse("StatBranch").ClearPanelEvent("onmouseover")
	hud.FindChildTraverse("StatBranch").ClearPanelEvent("onmouseout")
	hud.FindChildTraverse("StatBranch").hittestchildren = false;
	//hud.FindChildTraverse("StatBranchGraphics").hittestchildren = false;

	var level_stats_frame = hud.FindChildTraverse("level_stats_frame")
	level_stats_frame.ClearPanelEvent("onmouseover")
	var StatsLevelUpTab = level_stats_frame.FindChildTraverse("LevelUpTab")
	StatsLevelUpTab.ClearPanelEvent("onmouseover")
	StatsLevelUpTab.ClearPanelEvent("onmouseout")
	StatsLevelUpTab.ClearPanelEvent("onactivate")
	StatsLevelUpTab.SetPanelEvent("onactivate", function() {
		var unit = Players.GetLocalPlayerPortraitUnit()
		var attribute_bonus_arena = Entities.GetAbilityByName(unit, "attribute_bonus_arena")
		if (Entities.GetAbilityPoints(unit) > 0 && Entities.IsControllableByPlayer(unit, Game.GetLocalPlayerID()))
			Abilities.AttemptToUpgrade(attribute_bonus_arena);
	})
	hud.FindChildTraverse("combat_events").FindChildTraverse("ToastManager").visible = false;
	hud.FindChildTraverse("HudChat").FindChildTraverse("ChatLinesContainer").visible = false;
}

String.prototype.encodeHTML = function() {
	return this.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&apos;');
};

function CreateCustomToast(data) {
	var lastLine = $("#CustomToastManager").GetChild(0);
	var row = $.CreatePanel("Panel", $("#CustomToastManager"), "");
	row.BLoadLayoutSnippet("ToastPanel")
	row.AddClass("ToastPanel")
	var rowText = "";
	var CreateHeroElements = function(id) {
		var playerColor = Players.GetPlayerColor(id).toString(16)
		if (playerColor != null) {
			playerColor = "#" + playerColor.substring(6, 8) + playerColor.substring(4, 6) + playerColor.substring(2, 4) + playerColor.substring(0, 2)
		} else {
			playerColor = "#000000";
		}
		return "<img src='" + TransformTextureToPath(GetPlayerHeroName(id), "icon") + "' class='CombatEventHeroIcon'/> <font color='" + playerColor + "'>" + Players.GetPlayerName(id).encodeHTML() + "</font>"
	}

	if (data.type == "kill") {
		var byNeutrals = data.killerPlayer == null
		var isSelfKill = data.victimPlayer == data.killerPlayer
		var isAllyKill = !byNeutrals && data.victimPlayer != null && Players.GetTeam(data.victimPlayer) == Players.GetTeam(data.killerPlayer)
		var isVictim = data.victimPlayer == Game.GetLocalPlayerID()
		var isKiller = data.killerPlayer == Game.GetLocalPlayerID()
		var teamVictim = byNeutrals || Players.GetTeam(data.victimPlayer) == Players.GetTeam(Game.GetLocalPlayerID())
		var teamKiller = !byNeutrals && Players.GetTeam(data.killerPlayer) == Players.GetTeam(Game.GetLocalPlayerID())
		row.SetHasClass("AllyEvent", teamKiller)
		row.SetHasClass("EnemyEvent", !teamKiller && teamVictim)
		row.SetHasClass("LocalPlayerInvolved", isVictim || isKiller)
		row.SetHasClass("LocalPlayerKiller", isKiller)
		row.SetHasClass("LocalPlayerVictim", isVictim)
		if (isKiller)
			Game.EmitSound("notification.self.kill")
		else if (isVictim)
			Game.EmitSound("notification.self.death")
		else if (teamKiller)
			Game.EmitSound("notification.teammate.kill")
		else if (teamVictim)
			Game.EmitSound("notification.teammate.death")
		if (isSelfKill) {
			Game.EmitSound("notification.self.kill")
			rowText = $.Localize("custom_toast_PlayerDeniedSelf")
		} else if (isAllyKill) {
			rowText = $.Localize("#custom_toast_PlayerDenied")
		} else {
			if (byNeutrals) {
				rowText = $.Localize("#npc_dota_neutral_creep")
			} else {
				rowText = "{killer_name}"
			}
			rowText = rowText + " {killed_icon} {victim_name} {gold}";
		}
	} else if (data.type == "kill_streak_ended") {
		var isVictim = data.victimPlayer == Game.GetLocalPlayerID()
		var teamVictim = Players.GetTeam(data.victimPlayer) == Players.GetTeam(Game.GetLocalPlayerID())
		row.SetHasClass("AllyEvent", teamVictim)
		row.SetHasClass("EnemyEvent", !teamVictim)
		row.SetHasClass("LocalPlayerInvolved", isVictim)
		row.SetHasClass("LocalPlayerVictim", isVictim)
		rowText = $.Localize("#custom_toast_KillStreak_Ended")
	} else if (data.type == "generic") {
		row.AddClass("AllyEvent")
		rowText = $.Localize(data.text)
	}

	rowText = rowText.replace("{denied_icon}", "<img class='DeniedIcon'/>").replace("{killed_icon}", "<img class='CombatEventKillIcon'/>").replace("{time_dota}", "<font color='lime'>" + secondsToMS(Game.GetDOTATime(false, false), true) + "</font>");
	if (data.player != null)
		rowText = rowText.replace("{player_name}", CreateHeroElements(data.player))
	if (data.victimPlayer != null)
		rowText = rowText.replace("{victim_name}", CreateHeroElements(data.victimPlayer))
	if (data.killerPlayer != null)
		rowText = rowText.replace("{killer_name}", CreateHeroElements(data.killerPlayer))
	if (data.gold != null)
		rowText = rowText.replace("{gold}", "<font color='gold'>" + data.gold + "</font> <img class='CombatEventGoldIcon' />")
	if (data.kill_streak != null)
		rowText = rowText.replace("{kill_streak}", data.kill_streak)
	if (data.runeType != null)
		rowText = rowText.replace("{rune_name}", "<font color='#" + RUNES_COLOR_MAP[data.runeType] + "'>" + $.Localize("custom_runes_rune_" + data.runeType + "_title") + "</font>")
	if (data.variables != null)
		for (var k in data.variables) {
			rowText = rowText.replace(k, data.variables[k])
		}
	if (rowText.indexOf("<img") == -1)
		row.AddClass("SimpleText")
	row.FindChildTraverse("ToastLabel").text = rowText
	$.Schedule(10, function() {
		row.AddClass("Collapsed");
	})
	row.DeleteAsync(10.3)
};

(function() {
	HookPanoramaPanels();
	DynamicSubscribePTListener("arena", function(tableName, changesObject, deletionsObject) {
		if (changesObject["gamemode_settings"] != null && changesObject["gamemode_settings"]["gamemode"] != null) {
			DOTA_ACTIVE_GAMEMODE = changesObject["gamemode_settings"]["gamemode"]
			if ($("#PlayerControls_1x1") != null)
				$("#PlayerControls_1x1").visible = DOTA_ACTIVE_GAMEMODE != DOTA_GAMEMODE_HOLDOUT_5
		}
		if (changesObject["gamemode_settings"] != null && changesObject["gamemode_settings"]["gamemode_type"] != null) {
			DOTA_ACTIVE_GAMEMODE_TYPE = changesObject["gamemode_settings"]["gamemode_type"]
		}
	})
	_DynamicMinimapSubscribe($("#DynamicMinimapRoot"));

	AutoUpdatePanoramaHUD();
	GameEvents.Subscribe("create_custom_toast", CreateCustomToast);
})()