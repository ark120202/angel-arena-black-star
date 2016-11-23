"use strict";
var MainPanel = $("#MainBox")
var SelectedHeroData = null
var SelectedHeroPanel = null
var SelectedTabIndex = null
var HeroesPanels = []
var PlayerTables = GameUI.CustomUIConfig().PlayerTables
var PTID = null

function OpenMenu(data) {
	MainPanel.visible = true
	SelectFirstHeroPanel()
}

function CreateMenu(data) {
	FillHeroesTable(data, $("#HeroListPanel"), true)
	SelectFirstHeroPanel()
}

function ChooseHeroPanelHero() {
	ChooseHeroUpdatePanels()
}

function SelectHero() {
	if ($.GetContextPanel().BHasClass("HellBase")) {
		GameEvents.SendCustomGameEventToServer("hell_hero_change_cast", {
		hero: SelectedHeroData.heroKey
	})
	} else if ($.GetContextPanel().BHasClass("HeavenBase")) {
		GameEvents.SendCustomGameEventToServer("heaven_hero_change_cast", {
		hero: SelectedHeroData.heroKey
	})
	}

	CloseMenu()
	Game.EmitSound("HeroPicker.Selected")
}

function UpdateSelectionButton() {
	if (SelectedHeroData != null && !IsHeroPicked(SelectedHeroData.heroKey)) {
		$("#SelectedHeroSelectButton").enabled = true
	} else {
		$("#SelectedHeroSelectButton").enabled = false
	}
}

function CloseMenu() {
	MainPanel.visible = false
}

function UpdateHeroList() {
	var hero_selection_available_heroes = null
	if ($.GetContextPanel().BHasClass("HellBase")) {
		hero_selection_available_heroes = PlayerTables.GetAllTableValues("hero_selection_available_heroes_hell")
	} else if ($.GetContextPanel().BHasClass("HeavenBase")) {
		hero_selection_available_heroes = PlayerTables.GetAllTableValues("hero_selection_available_heroes_heaven")
	}

	if (hero_selection_available_heroes != null) {
		if (hero_selection_available_heroes.disabled != 1) {
			CreateMenu(hero_selection_available_heroes)
		} else {
			PlayerTables.UnsubscribeNetTableListener(PTID)
		}
	} else {
		$.Schedule(0.03, UpdateHeroList)
	}
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

(function() {
	if ($.GetContextPanel().BHasClass("HellBase")) {
		GameEvents.Subscribe("hell_hero_change_show_menu", OpenMenu)
	} else if ($.GetContextPanel().BHasClass("HeavenBase")) {
		GameEvents.Subscribe("heaven_hero_change_show_menu", OpenMenu)
	}
	MainPanel.visible = false
	PTID = PlayerTables.SubscribeNetTableListener("hero_selection", UpdateHeroesSelected)
	UpdateHeroList()
})()