"use strict";
var PlayerTables = GameUI.CustomUIConfig().PlayerTables;

var DOTA_GAMEMODE_5V5 = 0
var DOTA_GAMEMODE_HOLDOUT_5 = 1
var DOTA_GAMEMODE_4V4V4V4 = 2

var DOTA_GAMEMODE_TYPE_ALLPICK = 100
var DOTA_GAMEMODE_TYPE_RANDOM_OMG = 101
var DOTA_GAMEMODE_TYPE_ABILITY_SHOP = 102

var ARENA_GAMEMODE_MAP_NONE = 200
var ARENA_GAMEMODE_MAP_CUSTOM_ABILITIES = 201

var RUNES_COLOR_MAP = {
	0: "FF7800",
	1: "FFEC5E",
	2: "F62817",
	3: "FFD700",
	4: "8B008B",
	5: "7FFF00",
	6: "FD3AFB",
	7: "FF4D00",
	8: "0D0080",
	9: "C800FF",
}

function IsHeroName(str) {
	return str.lastIndexOf("npc_dota_hero_") == 0 || str.lastIndexOf("npc_arena_hero_") == 0
}

function TransformTextureToPath(texture, optPanelHeroimagestyle, optTeamNumber) {
	if (IsHeroName(texture)) {
		if (optPanelHeroimagestyle == "portrait")
			return "file://{images}/heroes/selection/" + texture + ".png"
		else if (optPanelHeroimagestyle == "icon")
			return "file://{images}/heroes/icons/" + texture + ".png"
		else
			return "file://{images}/heroes/" + texture + ".png"
	} else if (texture.lastIndexOf("npc_") == 0) {
		if (optPanelHeroimagestyle == "portrait") {
			return "file://{images}/custom_game/units/portraits/" + texture + ".png"
		} else
			return "file://{images}/custom_game/units/" + texture + ".png"
	} else {
		if (texture.lastIndexOf("item_") == -1)
			return "raw://resource/flash3/images/spellicons/" + texture + ".png"
		else {
			if (texture.lastIndexOf("item_recipe", 0) == 0)
				return "raw://resource/flash3/images/items/recipe.png"
			else
				return "raw://resource/flash3/images/items/" + texture.substring(5) + ".png"
		}
	}
}

function SendAlert(type) {
	//TODO
	$.Msg("TODO: alerts, " + type)
}

function GetHeroName(unit) {
	if (unit > -1) {
		var data = GameUI.CustomUIConfig().custom_entity_values[unit]
		if (data != null && data.unit_name != null)
			return data.unit_name
		else
			return Entities.GetUnitName(unit)
	} else
		return ""
}

function GetPlayerHeroName(playerId) {
	if (playerId > -1) {
		var ServersideData = PlayerTables.GetTableValue("player_hero_entities", playerId)
		if (ServersideData != null)
			return GetHeroName(ServersideData)
		else
			return GetHeroName(Players.GetPlayerHeroEntityIndex(playerId))
	} else
		return ""
}

function GetPlayerGold(iPlayerID) {
	var goldTable = PlayerTables.GetTableValue("arena", "gold")
	if (goldTable != null)
		return goldTable[iPlayerID]
	else
		return 0
}

function dynamicSort(property) {
	var sortOrder = 1;
	if (property[0] === "-") {
		sortOrder = -1;
		property = property.substr(1);
	}
	return function(a, b) {
		var result = (a[property] < b[property]) ? -1 : (a[property] > b[property]) ? 1 : 0;
		return result * sortOrder;
	}
}

function GetItemCountInInventory(nEntityIndex, itemName, bStash) {
	var counter = 0
	var endPoint = 8
	if (bStash)
		endPoint = 14
	for (var i = endPoint; i >= 0; i--) {
		var item = Entities.GetItemInSlot(nEntityIndex, i)
		if (Abilities.GetAbilityName(item) == itemName)
			counter = counter + 1
	}
	return counter
}

function GetItemCountInCourier(nEntityIndex, itemName, bStash) {
	var courier = FindCourier(nEntityIndex)
	if (courier == null)
		return 0
	var counter = 0
	var endPoint = 8
	if (bStash)
		endPoint = 14
	for (var i = endPoint; i >= 0; i--) {
		var item = Entities.GetItemInSlot(courier, i)
		if (Abilities.GetAbilityName(item) == itemName && Items.GetPurchaser(item) == nEntityIndex)
			counter = counter + 1
	}
	return counter
}

function FindCourier(unit) {
	return $.Each(Entities.GetAllEntitiesByClassname("npc_dota_courier"), function(ent) {
		if (Entities.GetTeamNumber(ent) == Entities.GetTeamNumber(unit)) {
			return ent
		}
	})[0]
}

function DynamicSubscribePTListener(table, callback, OnConnectedCallback) {
	if (PlayerTables.IsConnected()) {
		var tableData = PlayerTables.GetAllTableValues(table)
		if (tableData != null)
			callback(table, tableData, {})
		var ptid = PlayerTables.SubscribeNetTableListener(table, callback)
		if (OnConnectedCallback != null) {
			OnConnectedCallback(ptid)
		}
	} else {
		$.Schedule(0.1, function() {
			DynamicSubscribePTListener(table, callback)
		})
	}
}

function DynamicSubscribeNTListener(table, callback, OnConnectedCallback) {
	var tableData = CustomNetTables.GetAllTableValues(table)
	if (tableData != null)
		callback(table, tableData, {})
	var ptid = CustomNetTables.SubscribeNetTableListener(table, callback)
	if (OnConnectedCallback != null) {
		OnConnectedCallback(ptid)
	}
}

function GetBaseHudPanel() {
	var panel = $.GetContextPanel()
	while (true) {
		var parent = panel.GetParent()
		if (parent != null)
			panel = parent
		else
			return panel
	}
}

function GetArrayLength(array) {
	var counter = 0
	for (var arrKey in array) {
		counter = counter + 1
	}
	return counter
}

function arraysIdentical(a, b) {
	var i = GetArrayLength(a);
	if (i != GetArrayLength(b)) return false;
	while (i--) {
		if (a[i] !== b[i]) return false;
	}
	return true;
}

function getRandomArbitrary(min, max) {
	return Math.random() * (max - min) + min;
}

function getRandomInt(min, max) {
	return Math.floor(Math.random() * (max - min + 1)) + min;
}

function GetDotaHud() {
	var p = $.GetContextPanel()
	while (true) {
		if (p.id === "Hud")
			return p
		else
			p = p.GetParent()
	}
}

function GetSteamID(pid, type) {
	var steamID64 = Game.GetPlayerInfo(pid).player_steamid,
		steamID32 = String(Number(steamID64.substring(3)) - 61197960265728);
	return type == 64 ? steamID64 : steamID32;
}

function _DynamicMinimapSubscribe(minimapPanel, OnConnectedCallback) {
	$.Each(Game.GetAllTeamIDs(), function(team) {
		DynamicSubscribePTListener("dynamic_minimap_points_" + team, function(tableName, changesObject, deletionsObject) {
			for (var index in changesObject) {
				var panel = $("#minimap_point_id_" + index);
				if (panel == null) {
					panel = $.CreatePanel("Panel", minimapPanel, "minimap_point_id_" + index);
					panel.hittest = false;
					panel.AddClass("icon");
				}
				$.Each(changesObject[index].styleClasses.split(" "), function(ss) {
					panel.AddClass(ss);
				});
				panel.style.position = changesObject[index].position + " 0";
				panel.visible = changesObject[index].visible == 1
			}
		}, OnConnectedCallback);
	});
}

function IsCursorOnPanel(panel) {
	var panelCoords = panel.GetPositionWithinWindow()
	var cursorPos = GameUI.GetCursorPosition()
	return cursorPos[0] > panelCoords.x && cursorPos[1] > panelCoords.y && cursorPos[0] < panelCoords.x + panel.actuallayoutwidth && cursorPos[1] < panelCoords.y + panel.actuallayoutheight
}

function secondsToMS(seconds, bTwoChars) {
	var sec_num = parseInt(seconds, 10);
	var minutes = Math.floor(sec_num / 60);
	var seconds = Math.floor(sec_num - minutes * 60);

	if (bTwoChars && minutes < 10)
		minutes = "0" + minutes;
	if (seconds < 10)
		seconds = "0" + seconds;
	return minutes + ':' + seconds;
}

function escapeRegExp(string) {
	return String(string).replace(/[()]/g, function(s) {
		return "\\" + s
	})
}

function AddStyle(panel, table) {
	for (var k in table) {
		panel.style[k] = table[k]
	}
}

function AddJSClass(panel, classname) {
	if (JSStyleMap[classname] != null)
		AddStyle(panel, JSStyleMap[classname])
	else
		$.Msg("[AddJSClass] Critical error - style map has no " + classname + " class");
}

String.prototype.encodeHTML = function() {
	return this.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&apos;');
};