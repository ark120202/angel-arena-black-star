"use strict";
var MainPanel = $("#MainBox")
var SelectedHeroData;
var SelectedHeroPanel;
var SelectedTabIndex;
var HeroesPanels = [];
var DOTA_ACTIVE_GAMEMODE_TYPE;
var AutoSearchHeroThinker;

function OpenMenu() {
	MainPanel.visible = true
	SelectHeroTab(1)
	SelectFirstHeroPanel()
	AutoSearchHero()
}

function CreateMenu(data) {
	for (var tabKey in data.HeroTabs) {
		var tabTitle = data.HeroTabs[tabKey].title
		var heroesInTab = data.HeroTabs[tabKey].Heroes
		var TabHeroesPanel = $.CreatePanel('Panel', $("#HeroListPanel"), "HeroListPanel_tabPanels_" + tabKey)
		TabHeroesPanel.BLoadLayoutSnippet("HeroesPanel")
		FillHeroesTable(heroesInTab, TabHeroesPanel)
		TabHeroesPanel.visible = false
	}
	SelectHeroTab(1);
	SelectFirstHeroPanel();
}

function SwitchTab() {
	if (SelectedTabIndex == 1)
		SelectHeroTab(2)
	else
		SelectHeroTab(1)
}

function SelectHeroTab(tabIndex) {
	if (SelectedTabIndex != tabIndex) {
		if (SelectedTabIndex != null) {
			$("#HeroListPanel_tabPanels_" + SelectedTabIndex).visible = false
		}
		$("#HeroListPanel_tabPanels_" + tabIndex).visible = true
		SelectedTabIndex = tabIndex
	}
}

function ChooseHeroPanelHero() {
	ChooseHeroUpdatePanels()
}

function SelectHero() {
	GameEvents.SendCustomGameEventToServer("metamorphosis_elixir_cast", {
		hero: SelectedHeroData.heroKey
	})
	CloseMenu()
	Game.EmitSound("HeroPicker.Selected")
}

function UpdateSelectionButton() {
	$("#SelectedHeroSelectButton").enabled = SelectedHeroData != null && !IsHeroPicked(SelectedHeroData.heroKey)
}

function CloseMenu() {
	MainPanel.visible = false
	if (AutoSearchHeroThinker != null)
		$.CancelScheduled(AutoSearchHeroThinker)
}

function UpdateHeroesSelected(tableName, changesObject, deletionsObject) {
	for (var k in HeroesPanels) {
		var heroPanel = HeroesPanels[k]
		if (heroPanel != null) {
			heroPanel.SetHasClass("HeroListElementPickedBySomeone", IsHeroPicked(heroPanel.id.substring("HeroListPanel_element_".length)))
		}
	}
	UpdateSelectionButton()
}

function AutoSearchHero() {
	SearchHero()
	AutoSearchHeroThinker = $.Schedule(0.3, AutoSearchHero)
}

(function() {
	GameEvents.Subscribe("metamorphosis_elixir_show_menu", OpenMenu)
	MainPanel.visible = false
	PlayerTables.SubscribeNetTableListener("hero_selection", UpdateHeroesSelected)
	UpdateHeroesSelected("hero_selection", PlayerTables.GetAllTableValues("hero_selection"))
	DynamicSubscribePTListener("hero_selection_available_heroes", function(tableName, changesObject, deletionsObject) {
		if (changesObject.HeroTabs != null) {
			CreateMenu(changesObject);
		};
	});
	DynamicSubscribePTListener("arena", function(tableName, changesObject, deletionsObject) {
		if (changesObject["gamemode_settings"] != null && changesObject["gamemode_settings"]["gamemode_type"] != null)
			$("#SwitchTabButton").visible = changesObject["gamemode_settings"]["gamemode_type"] != DOTA_GAMEMODE_TYPE_RANDOM_OMG && changesObject["gamemode_settings"]["gamemode_type"] != DOTA_GAMEMODE_TYPE_ABILITY_SHOP
	});
})()