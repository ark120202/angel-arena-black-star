"use strict";
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_PROTECT, false);
GameUI.CustomUIConfig().team_colors = {}
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_GOODGUYS] = "#008000";
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_BADGUYS] = "#FF0000";
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_1] = "#c54da8";
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_2] = "#FF6C00";
/*GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_3] = "#3455FF";
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_4] = "#65d413";
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_5] = "#815336";
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_6] = "#1bc0d8";
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_7] = "#c7e40d";
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_8] = "#8c2af4";*/

//GameUI.CustomUIConfig().team_icons = {}
//GameUI.CustomUIConfig().team_icons[DOTATeam_t.DOTA_TEAM_GOODGUYS] = "file://{images}//team_icons/radiant.png";
//GameUI.CustomUIConfig().team_icons[DOTATeam_t.DOTA_TEAM_BADGUYS ] = "file://{images}//team_icons/dire.png";
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
/*GameUI.CustomUIConfig().team_names[DOTATeam_t.DOTA_TEAM_CUSTOM_3] = $.Localize("#DOTA_Custom3");
GameUI.CustomUIConfig().team_names[DOTATeam_t.DOTA_TEAM_CUSTOM_4] = $.Localize("#DOTA_Custom4");
GameUI.CustomUIConfig().team_names[DOTATeam_t.DOTA_TEAM_CUSTOM_5] = $.Localize("#DOTA_Custom5");
GameUI.CustomUIConfig().team_names[DOTATeam_t.DOTA_TEAM_CUSTOM_6] = $.Localize("#DOTA_Custom6");
GameUI.CustomUIConfig().team_names[DOTATeam_t.DOTA_TEAM_CUSTOM_7] = $.Localize("#DOTA_Custom7");
GameUI.CustomUIConfig().team_names[DOTATeam_t.DOTA_TEAM_CUSTOM_8] = $.Localize("#DOTA_Custom8");*/

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
Game.DisableWheelPanels = [];
GameUI.SetMouseCallback(function(eventName, arg) {
	var result = false;
	var ClickBehaviors = GameUI.GetClickBehaviors()
	if (eventName == "pressed") {
		if (arg === 0) {
			if (Game.MouseEvents.OnLeftPressed.length > 0) {
				for (var k in Game.MouseEvents.OnLeftPressed) {
					var r = Game.MouseEvents.OnLeftPressed[k](ClickBehaviors, eventName, arg);
					if (r === true)
						result = r;
				}
			}
		} else if (ClickBehaviors === CLICK_BEHAVIORS.DOTA_CLICK_BEHAVIOR_NONE && (arg === 5 || arg === 6)) {
			for (var index in Game.DisableWheelPanels) {
				if (IsCursorOnPanel(Game.DisableWheelPanels[index])) {
					return true;
				}
			}
		};
	};
	return result;
});
RegisterKeybind("F4Pressed");
RegisterKeybind("F5Pressed");
RegisterKeybind("F8Pressed");

GameUI.CustomUIConfig().custom_entity_values = GameUI.CustomUIConfig().custom_entity_values || {};
DynamicSubscribeNTListener("custom_entity_values", function(tableName, key, value) {
	GameUI.CustomUIConfig().custom_entity_values[key] = value;
});