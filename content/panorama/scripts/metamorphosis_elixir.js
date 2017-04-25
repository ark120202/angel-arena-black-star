"use strict";
var MainPanel = $("#MainBox")
var SelectedHeroPanel;
var SelectedTabIndex;
var HeroesPanels = [];
var DOTA_ACTIVE_GAMEMODE_TYPE;
var AutoSearchHeroThinker;

function OpenMenu(data) {
	if (!MainPanel.visible) {
		MainPanel.SetHasClass("ForcedHeroChange", data.forced == true)
		MainPanel.visible = true
		SelectHeroTab(1)
		SelectFirstHeroPanel()
		AutoSearchHero()
	}
}

function CreateMenu(data) {
	for (var tabKey in data.HeroTabs) {
		var TabHeroesPanel = $.CreatePanel('Panel', $("#HeroListPanel"), "HeroListPanel_tabPanels_" + tabKey)
		TabHeroesPanel.BLoadLayoutSnippet("HeroesPanel")
		FillHeroesTable(data.HeroTabs[tabKey], TabHeroesPanel)
		TabHeroesPanel.visible = false
	}
	SelectHeroTab(1);
	SelectFirstHeroPanel();
}

function ChooseHeroPanelHero() {
	ChooseHeroUpdatePanels()
}

function SelectHero() {
	GameEvents.SendCustomGameEventToServer("metamorphosis_elixir_cast", {
		hero: SelectedHeroName
	})
	CloseMenu()
	Game.EmitSound("HeroPicker.Selected")
}

function UpdateSelectionButton() {
	$("#SelectedHeroSelectButton").enabled = HeroesData[SelectedHeroName] == null || !IsHeroPicked(SelectedHeroName)
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
			heroPanel.SetHasClass("Picked", IsHeroPicked(heroPanel.id.substring("HeroListPanel_element_".length)))
			heroPanel.SetHasClass("Locked", IsHeroLocked(heroPanel.id.substring("HeroListPanel_element_".length)))
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
	DynamicSubscribePTListener("hero_selection", UpdateHeroesSelected)
	DynamicSubscribePTListener("hero_selection_available_heroes", function(tableName, changesObject, deletionsObject) {
		
		return;
		if (changesObject.HeroTabs != null) {
			CreateMenu(changesObject);
		};
	});
})()