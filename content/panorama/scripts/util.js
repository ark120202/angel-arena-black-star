'use strict';

//Libraries
var PlayerTables = GameUI.CustomUIConfig().PlayerTables;
var _ = GameUI.CustomUIConfig()._;
var Options = GameUI.CustomUIConfig().Options;

var console = {
	log: function() {
		var args = Array.prototype.slice.call(arguments);
		return $.Msg(args.map(function(x) {return typeof x === 'object' ? JSON.stringify(x, null, 4) : x;}).join('\t'));
	},
	error: function() {
		var args = Array.prototype.slice.call(arguments);
		_.each(args, function(arg) {
			console.log(arg instanceof Error ? arg.stack : new Error(arg).stack);
		});
	}
};

var ServerAddress = 'https://stats.dota-aabs.com/';

var HERO_SELECTION_PHASE_NOT_STARTED = 0;
var HERO_SELECTION_PHASE_BANNING = 1;
var HERO_SELECTION_PHASE_HERO_PICK = 2;
var HERO_SELECTION_PHASE_STRATEGY = 3;
var HERO_SELECTION_PHASE_END = 4;

var DOTA_TEAM_SPECTATOR = 1;

var RUNES_COLOR_MAP = {
	0: 'FF7800',
	1: 'FFEC5E',
	2: 'F62817',
	3: 'FFD700',
	4: '8B008B',
	5: '7FFF00',
	6: 'FD3AFB',
	7: 'FF4D00',
	8: '0D0080',
	9: 'C800FF',
	10: '4A0746',
	11: 'B35F5F',
};

String.prototype.encodeHTML = function() {
	return this.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&apos;');
};

String.prototype.endsWith = function(suffix) {
	return this.indexOf(suffix, this.length - suffix.length) !== -1;
};

Entities.GetNetworkableEntityInfo = function(ent, key) {
	var t = GameUI.CustomUIConfig().custom_entity_values[ent];
	if (t != null) {
		return key == null ? t : t[key];
	}
};

Players.GetStatsData = function(playerId) {
	return PlayerTables.GetTableValue('stats_client', playerId) || {};
};

Players.GetHeroSelectionPlayerInfo = function(playerId) {
	return Players.IsValidPlayerID(playerId) ? PlayerTables.GetTableValue('hero_selection', Players.GetTeam(playerId))[playerId] : {};
};

function GetDataFromServer(path, params, resolve, reject) {
	var encodedParams = params == null ? '' : '?' + Object.keys(params).map(function(key) {
	    return encodeURIComponent(key) + '=' + encodeURIComponent(params[key]);
	}).join('&');
	$.AsyncWebRequest(ServerAddress + path + encodedParams, {
		type: 'GET',
		success: function(data) {
			if (resolve) resolve(data || {});
		},
		error: function(e) {
			if (reject) reject(e);
		}
	});
}

function MongoObjectIDToDate(objectId) {
	return new Date(parseInt(objectId.substring(0, 8), 16) * 1000);
}

function IsHeroName(str) {
	return IsDotaHeroName(str) || IsArenaHeroName(str);
}

function IsBossName(str) {
	return str.lastIndexOf('npc_arena_boss_') === 0;
}

function IsDotaHeroName(str) {
	return str.lastIndexOf('npc_dota_hero_') === 0;
}

function IsArenaHeroName(str) {
	return str.lastIndexOf('npc_arena_hero_') === 0;
}

var bossesMap = {
	npc_arena_boss_freya: 'file://{images}/heroes/npc_arena_hero_freya.png',
	npc_arena_boss_zaken: 'file://{images}/heroes/npc_arena_hero_zaken.png',
};
function TransformTextureToPath(texture, optPanelImageStyle) {
	if (IsHeroName(texture)) {
		return optPanelImageStyle === 'portrait' ?
			'file://{images}/heroes/selection/' + texture + '.png' :
			optPanelImageStyle === 'icon' ?
				'file://{images}/heroes/icons/' + texture + '.png' :
				'file://{images}/heroes/' + texture + '.png';
	} else if (IsBossName(texture)) {
		return bossesMap[texture] || 'file://{images}/custom_game/units/' + texture + '.png';
	} else if (texture.lastIndexOf('npc_') === 0) {
		return optPanelImageStyle === 'portrait' ?
			'file://{images}/custom_game/units/portraits/' + texture + '.png' :
			'file://{images}/custom_game/units/' + texture + '.png';
	} else {
		return optPanelImageStyle === 'item' ?
			'raw://resource/flash3/images/items/' + texture + '.png' :
			'raw://resource/flash3/images/spellicons/' + texture + '.png';
	}
}

function GetHeroName(unit) {
	var data = GameUI.CustomUIConfig().custom_entity_values[unit || -1];
	return data != null && data.unit_name != null ? data.unit_name : Entities.GetUnitName(unit);
}

function SafeGetPlayerHeroEntityIndex(playerId) {
	var clientEnt = Players.GetPlayerHeroEntityIndex(playerId);
	return clientEnt === -1 ? (Number(PlayerTables.GetTableValue('player_hero_indexes', playerId)) || -1) : clientEnt;
}

function GetPlayerHeroName(playerId) {
	if (Players.IsValidPlayerID(playerId)) {
		//Is it causes lots of table copies? TODO: Check how that affects perfomance
		//return PlayerTables.GetTableValue("hero_selection", Players.GetTeam(playerId))[playerId].hero;
		return GetHeroName(SafeGetPlayerHeroEntityIndex(playerId));
	}
	return '';
}

function GetPlayerGold(iPlayerID) {
	return +PlayerTables.GetTableValue('gold', iPlayerID);
}

function dynamicSort(property) {
	var sortOrder = 1;
	if (property[0] === '-') {
		sortOrder = -1;
		property = property.substr(1);
	}
	return function(a, b) {
		var result = (a[property] < b[property]) ? -1 : (a[property] > b[property]) ? 1 : 0;
		return result * sortOrder;
	};
}

function GetItemCountInInventory(nEntityIndex, itemName, bStash) {
	var counter = 0;
	var endPoint = 8;
	if (bStash)
		endPoint = 14;
	for (var i = endPoint; i >= 0; i--) {
		var item = Entities.GetItemInSlot(nEntityIndex, i);
		if (Abilities.GetAbilityName(item) === itemName)
			counter = counter + 1;
	}
	return counter;
}

function GetItemCountInCourier(nEntityIndex, itemName, bStash) {
	var courier = FindCourier(nEntityIndex);
	if (courier == null)
		return 0;
	var counter = 0;
	var endPoint = 8;
	if (bStash)
		endPoint = 14;
	for (var i = endPoint; i >= 0; i--) {
		var item = Entities.GetItemInSlot(courier, i);
		if (Abilities.GetAbilityName(item) === itemName && Items.GetPurchaser(item) === nEntityIndex)
			counter = counter + 1;
	}
	return counter;
}

function FindCourier(unit) {
	return _.each(Entities.GetAllEntitiesByClassname('npc_dota_courier'), function(ent) {
		if (Entities.GetTeamNumber(ent) === Entities.GetTeamNumber(unit)) {
			return ent;
		}
	})[0];
}

function DynamicSubscribePTListener(table, callback, OnConnectedCallback) {
	if (PlayerTables.IsConnected()) {
		//$.Msg("Update " + table + " / PT connected")
		var tableData = PlayerTables.GetAllTableValues(table);
		if (tableData != null)
			callback(table, tableData, {});
		var ptid = PlayerTables.SubscribeNetTableListener(table, callback);
		if (OnConnectedCallback != null) {
			OnConnectedCallback(ptid);
		}
	} else {
		//$.Msg("Update " + table + " / PT not connected, repeat")
		$.Schedule(0.1, function() {
			DynamicSubscribePTListener(table, callback, OnConnectedCallback);
		});
	}
}

function DynamicSubscribeNTListener(table, callback, OnConnectedCallback) {
	var tableData = CustomNetTables.GetAllTableValues(table);
	if (tableData != null) {
		_.each(tableData, function(ent) {
			callback(table, ent.key, ent.value);
		});
	}
	var ptid = CustomNetTables.SubscribeNetTableListener(table, callback);
	if (OnConnectedCallback != null) {
		OnConnectedCallback(ptid);
	}
}

function getRandomArbitrary(min, max) {
	return Math.random() * (max - min) + min;
}

function getRandomInt(min, max) {
	return Math.floor(Math.random() * (max - min + 1)) + min;
}

function GetDotaHud() {
	var p = $.GetContextPanel();
	while (true) {
		var parent = p.GetParent();
		if (parent == null)
			return p;
		else
			p = parent;
	}
}

function GetSteamID(pid, type) {
	var playerInfo = Game.GetPlayerInfo(pid);
	if (!playerInfo) return 0;
	var steamID64 = playerInfo.player_steamid,
		steamID32 = String(Number(steamID64.substring(3)) - 61197960265728);
	return type === 64 ? steamID64 : steamID32;
}

function _DynamicMinimapSubscribe(minimapPanel, OnConnectedCallback) {
	_.each(Game.GetAllTeamIDs(), function(team) {
		DynamicSubscribePTListener('dynamic_minimap_points_' + team, function(tableName, changesObject, deletionsObject) {
			for (var index in changesObject) {
				var panel = $('#minimap_point_id_' + index);
				if (panel == null) {
					panel = $.CreatePanel('Panel', minimapPanel, 'minimap_point_id_' + index);
					panel.hittest = false;
					panel.AddClass('icon');
				}
				_.each(changesObject[index].styleClasses.split(' '), function(ss) {
					panel.AddClass(ss);
				});
				panel.style.position = changesObject[index].position + ' 0';
				panel.visible = changesObject[index].visible === 1;
			}
		}, OnConnectedCallback);
	});
}

function IsCursorOnPanel(panel) {
	var panelCoords = panel.GetPositionWithinWindow();
	var cursorPos = GameUI.GetCursorPosition();
	return cursorPos[0] > panelCoords.x && cursorPos[1] > panelCoords.y && cursorPos[0] < panelCoords.x + panel.actuallayoutwidth && cursorPos[1] < panelCoords.y + panel.actuallayoutheight;
}

function secondsToMS(seconds, bTwoChars) {
	var sec_num = parseInt(seconds, 10);
	var minutes = Math.floor(sec_num / 60);
	var seconds = Math.floor(sec_num - minutes * 60);

	if (bTwoChars && minutes < 10)
		minutes = '0' + minutes;
	if (seconds < 10)
		seconds = '0' + seconds;
	return minutes + ':' + seconds;
}

function escapeRegExp(string) {
	return String(string).replace(/[()]/g, function(s) {
		return '\\' + s;
	});
}

function AddStyle(panel, table) {
	for (var k in table) {
		panel.style[k] = table[k];
	}
}

function AddJSClass(panel, classname) {
	if (JSStyleMap[classname] != null)
		AddStyle(panel, JSStyleMap[classname]);
	else
		$.Msg('[AddJSClass] Critical error - style map has no ' + classname + ' class');
}

function FindDotaHudElement(id) {
	return hud.FindChildTraverse(id);
}

function GetHEXPlayerColor(playerId) {
	var playerColor = Players.GetPlayerColor(playerId).toString(16);
	return playerColor == null ? '#000000' : ('#' + playerColor.substring(6, 8) + playerColor.substring(4, 6) + playerColor.substring(2, 4) + playerColor.substring(0, 2));
}

function hexToRgb(hex) {
	var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
	return result ? {
		r: parseInt(result[1], 16),
		g: parseInt(result[2], 16),
		b: parseInt(result[3], 16)
	} : null;
}

function rgbToHex(r, g, b) {
	return '#' + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1);
}

function shadeColor2(color, percent) {
	var f = parseInt(color.slice(1), 16),
		t = percent < 0 ? 0 : 255,
		p = percent < 0 ? percent * -1 : percent,
		R = f >> 16,
		G = f >> 8 & 0x00FF,
		B = f & 0x0000FF;
	return '#' + (0x1000000 + (Math.round((t - R) * p) + R) * 0x10000 + (Math.round((t - G) * p) + G) * 0x100 + (Math.round((t - B) * p) + B)).toString(16).slice(1);
}

function shuffle(a) {
	var j, x, i;
	for (i = a.length; i; i--) {
		j = Math.floor(Math.random() * i);
		x = a[i - 1];
		a[i - 1] = a[j];
		a[j] = x;
	}
}

function FormatGold(value) {
	return (GameUI.IsAltDown() ? value : value > 9999999 ? (value/1000000).toFixed(2) + 'M' : value > 99999 ? (value/1000).toFixed(1) + 'k' : value)
		.toString()
		.replace(/\B(?=(\d{3})+(?!\d))/g, ' ');
}

function SortPanelChildren(panel, sortFunc, compareFunc) {
	var tlc = panel.Children().sort(sortFunc);
	_.each(tlc, function(child) {
		for (var k in tlc) {
			var child2 = tlc[k];
			if (child !== child2 && compareFunc(child, child2)) {
				panel.MoveChildBefore(child, child2);
				break;
			}
		}
	});
};

function JoinUrlParams(params) {
	return params == null ? '' : '?' + Object.keys(params).map(function(key) {
	    return encodeURIComponent(key) + '=' + encodeURIComponent(params[key]);
	}).join('&');
}

function GetTeamInfo(team) {
	var t = PlayerTables.GetTableValue('teams', team) || {};
	return {
		score: t.score || 0,
		kill_weight: t.kill_weight || 1,
	};
}

function SetPagePlayerLevel(ProfileBadge, level) {
	var levelbg = Math.floor(level / 100);
	ProfileBadge.FindChildTraverse('BackgroundImage').SetImage('file://{images}/profile_badges/bg_' + ('0' + (levelbg + 1)).slice(-2) + '.psd');
	ProfileBadge.FindChildTraverse('ItemImage').SetImage('file://{images}/profile_badges/level_' + ('0' + (level - levelbg * 100)).slice(-2) + '.png');
	ProfileBadge.FindChildTraverse('ProfileLevel').SetImage('file://{images}/profile_badges/bg_number_01.psd');
	ProfileBadge.FindChildTraverse('ProfileLevel').GetChild(0).text = level;
}

var hud = GetDotaHud();

