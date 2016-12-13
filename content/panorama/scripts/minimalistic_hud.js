"use strict";
var ONCLICK_PURGABLE_MODIFIERS = [
	"modifier_rubick_personality_steal",
	"modifier_tether_ally_aghanims"
];
var DOTA_ACTIVE_GAMEMODE = -1,
	DOTA_ACTIVE_GAMEMODE_TYPE = -1,
	hud = GetDotaHud();

function DisableDotaPanoramaElement(id) {
	var element = hud.FindChildTraverse(id)
	if (element != null)
		element.DeleteAsync(0);
}

function UpdatePanoramaHUD() {
	var unit = Players.GetLocalPlayerPortraitUnit()
	hud.FindChildTraverse("UnitNameLabel").text = $.Localize(GetHeroName(unit));
	var inventory_items = hud.FindChildTraverse("inventory_items")
	for (var i = 0; i <= 14; i++) {
		var item = Entities.GetItemInSlot(unit, i)
		var custom_entity_value = GameUI.CustomUIConfig().custom_entity_values[item];
		if (item > -1 && custom_entity_value != null && custom_entity_value.ability_texture != null)
			inventory_items.FindChildTraverse("inventory_slot_" + i).FindChildTraverse("ItemImage").SetImage(TransformTextureToPath(custom_entity_value.ability_texture));
	}

	hud.FindChildTraverse("HUDSkinAbilityContainerBG").style.width = (hud.FindChildTraverse("abilities").actuallayoutwidth + 16) + "px";

	var attribute_bonus_arena = Entities.GetAbilityByName(unit, "attribute_bonus_arena")
	hud.FindChildTraverse("level_stats_frame").visible = attribute_bonus_arena != -1 && Entities.IsControllableByPlayer(unit, Game.GetLocalPlayerID()) && Entities.GetAbilityPoints(unit) > 0;

	var GoldLabel = hud.FindChildTraverse("ShopButton").FindChildTraverse("GoldLabel")
	GoldLabel.text = "";
	goldCheck:
		if (Players.GetTeam(Game.GetLocalPlayerID()) == Entities.GetTeamNumber(unit)) {
			var goldTable = PlayerTables.GetTableValue("arena", "gold")
			for (var i = 0; i < 23; i++) {
				if (Players.GetPlayerHeroEntityIndex(i) == unit) {
					if (goldTable && goldTable[i]) {
						GoldLabel.text = goldTable[i]
						break goldCheck
					}
				}
			}
		}
}

function AutoUpdatePanoramaHUD() {
	$.Schedule(0.1, AutoUpdatePanoramaHUD)
	UpdatePanoramaHUD();
}

function HookPanoramaPanels() {
	var shopbtn = hud.FindChildTraverse("ShopButton")
	shopbtn.FindChildTraverse("BuybackHeader").visible = false;
	shopbtn.ClearPanelEvent("onactivate")
	shopbtn.ClearPanelEvent("onmouseover")
	shopbtn.ClearPanelEvent("onmouseout")
	shopbtn.SetPanelEvent("onactivate", function() {
		GameEvents.SendEventClientSide("panorama_shop_open_close", {})
	})
	hud.FindChildTraverse("LevelLabel").style.width = "100%"
	hud.FindChildTraverse("stash").style.marginBottom = "97px"

	//hud.FindChildTraverse("StatBranchChannel").visible = false;
	hud.FindChildTraverse("StatBranch").ClearPanelEvent("onactivate")
	hud.FindChildTraverse("StatBranch").ClearPanelEvent("onmouseover")
	hud.FindChildTraverse("StatBranch").ClearPanelEvent("onmouseout")
	hud.FindChildTraverse("StatBranch").hittestchildren = false;
	//hud.FindChildTraverse("StatBranchGraphics").hittestchildren = false;
	hud.FindChildTraverse("QuickBuyRows").visible = false;

	hud.FindChildTraverse("LevelUpTab").ClearPanelEvent("onactivate")
	hud.FindChildTraverse("LevelUpTab").SetPanelEvent("onactivate", function() {
		var unit = Players.GetLocalPlayerPortraitUnit()
		var attribute_bonus_arena = Entities.GetAbilityByName(unit, "attribute_bonus_arena")

		if (Entities.GetAbilityPoints(unit) > 0 && Entities.IsControllableByPlayer(unit, Game.GetLocalPlayerID())) {
			Abilities.AttemptToUpgrade(attribute_bonus_arena);
		}
	})
}

(function() {
	//GameUI.SetCameraDistance(-1)
	HookPanoramaPanels()
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

	DisableDotaPanoramaElement("RadarButton")
	AutoUpdatePanoramaHUD()
		//GameEvents.Subscribe("create_toast", js_value funcVal)
})()