"use strict";
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_PROTECT, false)
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_HERO_SELECTION_TEAMS, false)
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_HERO_SELECTION_GAME_NAME, false)
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_HERO_SELECTION_CLOCK, false)

// These lines set up the panorama colors used by each team (for game select/setup, etc)
GameUI.CustomUIConfig().team_colors = {}
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_GOODGUYS] = "#008000;";
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_BADGUYS] = "#FF0000;";
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_1] = "#c54da8;";
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_2] = "#FF6C00;";
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_3] = "#3455FF;";
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_4] = "#65d413;";
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_5] = "#815336;";
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_6] = "#1bc0d8;";
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_7] = "#c7e40d;";
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_8] = "#8c2af4;";

//GameUI.CustomUIConfig().team_icons = {}
//GameUI.CustomUIConfig().team_icons[DOTATeam_t.DOTA_TEAM_GOODGUYS] = "s2r://panorama/images/team_icons/radiant.png";
//GameUI.CustomUIConfig().team_icons[DOTATeam_t.DOTA_TEAM_BADGUYS ] = "s2r://panorama/images/team_icons/dire.png";
//GameUI.CustomUIConfig().team_icons[DOTATeam_t.DOTA_TEAM_CUSTOM_1] = "file://{images}/custom_game/team_icons/team_icon_dragon_01.png";
//GameUI.CustomUIConfig().team_icons[DOTATeam_t.DOTA_TEAM_CUSTOM_2] = "file://{images}/custom_game/team_icons/team_icon_dog_01.png";
//GameUI.CustomUIConfig().team_icons[DOTATeam_t.DOTA_TEAM_CUSTOM_3] = "file://{images}/custom_game/team_icons/team_icon_rooster_01.png";
//GameUI.CustomUIConfig().team_icons[DOTATeam_t.DOTA_TEAM_CUSTOM_4] = "file://{images}/custom_game/team_icons/team_icon_ram_01.png";
//GameUI.CustomUIConfig().team_icons[DOTATeam_t.DOTA_TEAM_CUSTOM_5] = "file://{images}/custom_game/team_icons/team_icon_rat_01.png";
//GameUI.CustomUIConfig().team_icons[DOTATeam_t.DOTA_TEAM_CUSTOM_6] = "file://{images}/custom_game/team_icons/team_icon_boar_01.png";
//GameUI.CustomUIConfig().team_icons[DOTATeam_t.DOTA_TEAM_CUSTOM_7] = "file://{images}/custom_game/team_icons/team_icon_snake_01.png";
//GameUI.CustomUIConfig().team_icons[DOTATeam_t.DOTA_TEAM_CUSTOM_8] = "file://{images}/custom_game/team_icons/team_icon_horse_01.png";

GameUI.CustomUIConfig().team_names = {}
GameUI.CustomUIConfig().team_names[DOTATeam_t.DOTA_TEAM_GOODGUYS] = $.Localize("#DOTA_GoodGuys");
GameUI.CustomUIConfig().team_names[DOTATeam_t.DOTA_TEAM_BADGUYS] = $.Localize("#DOTA_BadGuys");
GameUI.CustomUIConfig().team_names[DOTATeam_t.DOTA_TEAM_CUSTOM_1] = $.Localize("#DOTA_Custom1");
GameUI.CustomUIConfig().team_names[DOTATeam_t.DOTA_TEAM_CUSTOM_2] = $.Localize("#DOTA_Custom2");
GameUI.CustomUIConfig().team_names[DOTATeam_t.DOTA_TEAM_CUSTOM_3] = $.Localize("#DOTA_Custom3");
GameUI.CustomUIConfig().team_names[DOTATeam_t.DOTA_TEAM_CUSTOM_4] = $.Localize("#DOTA_Custom4");
GameUI.CustomUIConfig().team_names[DOTATeam_t.DOTA_TEAM_CUSTOM_5] = $.Localize("#DOTA_Custom5");
GameUI.CustomUIConfig().team_names[DOTATeam_t.DOTA_TEAM_CUSTOM_6] = $.Localize("#DOTA_Custom6");
GameUI.CustomUIConfig().team_names[DOTATeam_t.DOTA_TEAM_CUSTOM_7] = $.Localize("#DOTA_Custom7");
GameUI.CustomUIConfig().team_names[DOTATeam_t.DOTA_TEAM_CUSTOM_8] = $.Localize("#DOTA_Custom8");

function RegisterKeybind(command) {
	Game.Events[command] = []
	Game.AddCommand("+" + command, function() {
		for (var key in Game.Events[command]) {
			Game.Events[command][key]()
		}
	}, "", 0);
	Game.AddCommand("-" + command, function() {}, "", 0);
}

Game.Events = {};
Game.MouseEvents = {
	OnLeftPressed: []
};
GameUI.SetMouseCallback(function(eventName, arg) {
	var result = false;
	if (GameUI.GetClickBehaviors() === CLICK_BEHAVIORS.DOTA_CLICK_BEHAVIOR_NONE) {
		if (eventName == "pressed") {
			if (arg === 0) {
				if (Game.MouseEvents.OnLeftPressed.length > 0) {
					for (var k in Game.MouseEvents.OnLeftPressed) {
						var r = Game.MouseEvents.OnLeftPressed[k](eventName, arg);
						if (r === true) {
							result = r;
						}
					}
				}
			}
		}
	}

	/*if (eventName == "pressed") {
		// Left-click is move to position
		if (arg === 0) {
			var order = {};
			order.OrderType = dotaunitorder_t.DOTA_UNIT_ORDER_MOVE_TO_POSITION;
			order.Position = GameUI.GetScreenWorldPosition(GameUI.GetCursorPosition());
			order.Queue = false;
			order.ShowEffects = false;
			Game.PrepareUnitOrders(order);
			return true;
		}

		// Disable right-click
		if (arg === 1) {
			return true;
		}
	} else if (eventName === "wheeled") {
		if (arg < 0) {
			var order = {};
			order.OrderType = dotaunitorder_t.DOTA_UNIT_ORDER_MOVE_TO_POSITION;
			order.Position = GameUI.GetScreenWorldPosition(GameUI.GetCursorPosition());
			order.Queue = false;
			order.ShowEffects = false;
			Game.PrepareUnitOrders(order);
			return true;
		} else if (arg > 0) {
			var order = {};
			order.OrderType = dotaunitorder_t.DOTA_UNIT_ORDER_ATTACK_MOVE;
			order.Position = GameUI.GetScreenWorldPosition(GameUI.GetCursorPosition());
			order.Queue = false;
			order.ShowEffects = false;
			Game.PrepareUnitOrders(order);
			return true;
		}
	}*/
	return result;
});
RegisterKeybind("EnterPressed")
RegisterKeybind("F4Pressed")
RegisterKeybind("F5Pressed")
RegisterKeybind("F8Pressed")
GameUI.CustomUIConfig().IsContains = (function(array, element) {
	for (var key in array) {
		if (array[key] == element) {
			return true
		}
	}
	return false
})