"use strict";
var PlayerTables = GameUI.CustomUIConfig().PlayerTables;

var DOTA_GAMEMODE_5V5 = 0
var DOTA_GAMEMODE_HOLDOUT_5 = 1
var DOTA_GAMEMODE_TYPE_ALLPICK = 10
var DOTA_GAMEMODE_TYPE_RANDOM_OMG = 11
var DOTA_GAMEMODE_TYPE_ABILITY_SHOP = 12
var DOTA_GAMEMODE_TYPE_ABILITY_DRAFT = 13

var TeamCaredUnits = [
	"npc_dota_courier",
]

function TransformTextureToPath(texture, optPanelHeroimagestyle, optTeamNumber) {
	if (texture.lastIndexOf("npc_dota_hero_") == 0 || texture.lastIndexOf("alternative_npc_dota_hero_") == 0) {
		if (optPanelHeroimagestyle == "portrait")
			return "file://{images}/heroes/selection/" + texture + ".png"
		else if (optPanelHeroimagestyle == "icon")
			return "file://{images}/heroes/icons/" + texture + ".png"
		else
			return "file://{images}/heroes/" + texture + ".png"
	} else if (texture.lastIndexOf("npc_") == 0) {
		if (optPanelHeroimagestyle == "portrait") {
			if (TeamCaredUnits.indexOf(texture) > -1) {
				if (optTeamNumber != null)
					return "file://{images}/custom_game/units/portraits/" + texture + "_team" + optTeamNumber + ".png"
				else
					return "file://{images}/custom_game/units/portraits/" + texture + "_team2.png"
			} else
				return "file://{images}/custom_game/units/portraits/" + texture + ".png"
		} else {
			if (TeamCaredUnits.indexOf(texture) > -1) {
				if (optTeamNumber != null)
					return "file://{images}/custom_game/units/" + texture + "_team" + optTeamNumber + ".png"
				else
					return "file://{images}/custom_game/units/" + texture + "_team2.png"
			} else
				return "file://{images}/custom_game/units/" + texture + ".png"
		}
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
		var ServersideData = PlayerTables.GetTableValue("entity_attributes", unit)
		if (ServersideData != null)
			return ServersideData.hero_name
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
	if (goldTable && goldTable[iPlayerID])
		return goldTable[iPlayerID]
	else
		return Players.GetGold(iPlayerID)
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
	var endPoint = 5
	if (bStash)
		endPoint = 11
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
	var endPoint = 5
	if (bStash)
		endPoint = 11
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

function DynamicSubscribePTListener(table, callback) {
	if (PlayerTables.IsConnected()) {
		var tableData = PlayerTables.GetAllTableValues(table)
		if (tableData != null)
			callback(table, tableData, {})
		PlayerTables.SubscribeNetTableListener(table, callback)
	} else {
		$.Schedule(1 / 30, function() {
			DynamicSubscribePTListener(table, callback)
		})
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

function SetPannelDraggedChild(displayPanel, checker) {
	var dragcheck = function() {
		if (displayPanel != null) {
			try {
				if (checker())
					displayPanel.DeleteAsync(0)
				else
					$.Schedule(0.2, dragcheck);
			} catch (e) {}
		}
	}
	dragcheck();
}

function _DynamicMinimapSubscribe(minimapPanel) {
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
		});
	});
}