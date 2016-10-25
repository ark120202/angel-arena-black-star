"use strict";
var MainPanel = $("#HeroSelectionBox")
var SelectedHeroData = null
var SelectedHeroPanel = null
var SelectedTabIndex = null
var SelectionTimerDuration = null
var SelectionTimerStartTime = null
var localHeroPicked = false
var PlayerTables = GameUI.CustomUIConfig().PlayerTables
var HideEvent = null
var ShowPrecacheEvent = null
var PTID = null
var HeroesPanels = []
var tabsData = {}

function HeroSelectionStart(data) {
	MainPanel.visible = true

	for (var teamNumber = 2; teamNumber <= 3; teamNumber++) {
		if ($("#team_selection_panels_team" + teamNumber) == null) {
			var TeamSelectionPanel = $.CreatePanel('Panel', $("#TeamSelectionStatusPanel"), "team_selection_panels_team" + teamNumber)
			TeamSelectionPanel.AddClass("TeamSelectionPanel")
			var TeamLabelPanel = $.CreatePanel('Panel', TeamSelectionPanel, "")
			TeamLabelPanel.AddClass("TeamLabelPanel")
			var TeamLabel = $.CreatePanel('Label', TeamLabelPanel, "")
			TeamLabel.AddClass("TeamLabel")
			TeamLabel.text = GameUI.CustomUIConfig().team_names[teamNumber]
			TeamLabel.style.color = GameUI.CustomUIConfig().team_colors[teamNumber]
		}
	}

	SelectionTimerDuration = data.SelectionTime
	SelectionTimerStartTime = Game.GetGameTime();
	$.Schedule(0.25, UpdateTimer)
	var pickPanel = null
	tabsData = data.HeroTabs
	for (var tabKey in data.HeroTabs) {
		var tabTitle = data.HeroTabs[tabKey].title
		var heroesInTab = data.HeroTabs[tabKey].Heroes
		var TabButton = $.CreatePanel('Button', $("#HeroListTabsPanel"), "HeroListTabsPanel_tabButtons_" + tabKey)
		TabButton.AddClass("HeroTabButton")
		var TabButtonLabel = $.CreatePanel('Label', TabButton, "")
		TabButtonLabel.text = $.Localize(tabTitle)
		TabButtonLabel.AddClass("HeroTabButtonLabel")
		var SelectTabAction = (function(_tabKey) {
			return function() {
				SelectHeroTab(_tabKey)
			}
		})(tabKey)
		TabButton.SetPanelEvent('onactivate', SelectTabAction)
		var TabHeroesPanel = $.CreatePanel('Panel', $("#HeroListPanel"), "HeroListPanel_tabPanels_" + tabKey)
		TabHeroesPanel.style.height = "100%;"
		TabHeroesPanel.style.width = "100%;"
		TabHeroesPanel.style.flowChildren = "right-wrap"
		var firstpickPanel = FillHeroesTable(heroesInTab, TabHeroesPanel)
		if (pickPanel == null) {
			pickPanel = firstpickPanel
		}
		TabHeroesPanel.visible = false
	}
	pickPanel()
	SelectHeroTab(1)
}

function SelectHeroTab(tabIndex) {
	if (SelectedTabIndex != tabIndex) {
		if (SelectedTabIndex != null) {
			$("#HeroListPanel_tabPanels_" + SelectedTabIndex).visible = false
			$("#HeroListTabsPanel_tabButtons_" + SelectedTabIndex).RemoveClass("HeroTabButtonSelected")
		}
		$("#HeroListPanel_tabPanels_" + tabIndex).visible = true
		$("#HeroListTabsPanel_tabButtons_" + tabIndex).AddClass("HeroTabButtonSelected")
		SelectedTabIndex = tabIndex
	}
}

function ChooseHeroPanelHero() {
	$("#SelectedHeroLabel").text = $.Localize("#" + SelectedHeroData.heroKey)
	$("#SelectedHeroDescriptionText").text = $.Localize(SelectedHeroData.notes)
	UpdateSelectionButton()
	$("#SelectedHeroAbilitiesPanelInner").RemoveAndDeleteChildren()
	var abilitiesCount = GameUI.CustomUIConfig().GetArrayLength(SelectedHeroData.abilities)
	if ($("#SelectedHeroScene").innerUnitModel != SelectedHeroData.model) {
		$("#SelectedHeroScene").RemoveAndDeleteChildren()
		$("#SelectedHeroScene").BCreateChildren("<DOTAScenePanel style=\"width: 100%; height: 100%;\" unit=\"" + SelectedHeroData.model + "\"/>");
		$("#SelectedHeroScene").innerUnitModel = SelectedHeroData.model
	}
	for (var key in SelectedHeroData.abilities) {
		var abilityName = SelectedHeroData.abilities[key]
		var abilityPanel = $.CreatePanel('DOTAAbilityImage', $("#SelectedHeroAbilitiesPanelInner"), "")
		abilityPanel.AddClass("SelectedHeroAbility")
		if (abilitiesCount == 5) {
			abilityPanel.AddClass("SelectedHeroAbilityx5")
		} else if (abilitiesCount == 6) {
			abilityPanel.AddClass("SelectedHeroAbilityx6")
		}
		abilityPanel.abilityname = abilityName

		var ItemShowTooltip = (function(_abilityName, _panel) {
			return function() {
				$.DispatchEvent("DOTAShowAbilityTooltip", _panel, _abilityName);
			}
		})(abilityName, abilityPanel)
		var ItemHideTooltip = (function(_panel) {
			return function() {
				$.DispatchEvent("DOTAHideAbilityTooltip", _panel);
			}
		})(abilityPanel)
		abilityPanel.SetPanelEvent('onmouseover', ItemShowTooltip)
		abilityPanel.SetPanelEvent('onmouseout', ItemHideTooltip)
	}

	for (var i = 2; i >= 0; i--) {
		$("#DotaAttributePic_" + (i + 1)).SetHasClass("PrimaryAttribute", SelectedHeroData.attributes.attribute_primary == i)
		$("#HeroAttributes_" + (i + 1)).text = SelectedHeroData.attributes["attribute_base_" + i] + " + " + Number(SelectedHeroData.attributes["attribute_gain_" + i]).toFixed(1)
	}

	$("#HeroAttributes_damage").text = SelectedHeroData.attributes.damage_min + " - " + SelectedHeroData.attributes.damage_max
	$("#HeroAttributes_speed").text = SelectedHeroData.attributes.movespeed
	$("#HeroAttributes_armor").text = SelectedHeroData.attributes.armor
	$("#HeroAttributes_bat").text = Number(SelectedHeroData.attributes.attackrate).toFixed(1)
	if (!localHeroPicked) {
		GameEvents.SendCustomGameEventToServer("hero_selection_player_hover", {
			playerId: Game.GetLocalPlayerID(),
			hero: SelectedHeroData.heroKey
		})
	}
}

function SelectHero() {
	if (!localHeroPicked) {
		localHeroPicked = true
		GameEvents.SendCustomGameEventToServer("hero_selection_player_select", {
			playerId: Game.GetLocalPlayerID(),
			hero: SelectedHeroData.heroKey
		})
		Game.EmitSound("HeroPicker.Selected")
	}
}

function RandomHero() {
	if (!localHeroPicked) {
		localHeroPicked = true
		GameEvents.SendCustomGameEventToServer("hero_selection_player_random", {
			playerId: Game.GetLocalPlayerID()
		})
		Game.EmitSound("HeroPicker.Selected")
	}
}

function UpdateSelectionButton() {
	if (SelectedHeroData != null && !IsHeroPicked(SelectedHeroData.heroKey) && !localHeroPicked) {
		$("#SelectedHeroSelectButton").enabled = true
		$("#HeroRandomButton").enabled = true
	} else {
		$("#SelectedHeroSelectButton").enabled = false
		$("#HeroRandomButton").enabled = false
	}
}

function UpdateTimer() {
	var SelectionTimerCurrentTime = Game.GetGameTime();
	var SelectionTimerRemainingTime = SelectionTimerDuration - (SelectionTimerCurrentTime - SelectionTimerStartTime)
	$.Schedule(0.25, UpdateTimer)
	if (SelectionTimerRemainingTime > 0) {
		$("#HeroSelectionTimer").text = Math.ceil(SelectionTimerRemainingTime)
	} else {
		$.Schedule(0.03, function() {
			$("#HeroSelectionTimer").text = 0
		})
	}
}

function UpdateHeroesSelected(tableName, changesObject, deletionsObject) {
	for (var teamNumber in changesObject) {
		if ($("#team_selection_panels_team" + teamNumber) == null) {
			var TeamSelectionPanel = $.CreatePanel('Panel', $("#TeamSelectionStatusPanel"), "team_selection_panels_team" + teamNumber)
			TeamSelectionPanel.AddClass("TeamSelectionPanel")
			var TeamLabelPanel = $.CreatePanel('Panel', TeamSelectionPanel, "")
			TeamLabelPanel.AddClass("TeamLabelPanel")
			var TeamLabel = $.CreatePanel('Label', TeamLabelPanel, "")
			TeamLabel.AddClass("TeamLabel")
			TeamLabel.text = GameUI.CustomUIConfig().team_names[teamNumber]
			TeamLabel.style.color = GameUI.CustomUIConfig().team_colors[teamNumber]
		}

		var TeamSelectionPanel = $("#team_selection_panels_team" + teamNumber)
		for (var playerIdInTeam in changesObject[teamNumber]) {
			var playerData = changesObject[teamNumber][playerIdInTeam]
			if ($("#playerpickpanelimage_player" + playerIdInTeam) == null) {
				var SelectedPlayerHeroData = changesObject[teamNumber][playerIdInTeam]
				var PlayerInTeamPanel = $.CreatePanel('Panel', TeamSelectionPanel, "")
				PlayerInTeamPanel.AddClass("PlayerInTeamPanel")

				var PlayerInTeamNickname = $.CreatePanel('Label', PlayerInTeamPanel, "")
				PlayerInTeamNickname.AddClass("PlayerInTeamNickname")
				PlayerInTeamNickname.text = Players.GetPlayerName(Number(playerIdInTeam)) + ":"
				var playerColor = Players.GetPlayerColor(Number(playerIdInTeam))
				var playerColor = Players.GetPlayerColor(Number(playerIdInTeam)).toString(16)
				if (playerColor != null) {
					playerColor = "#" + playerColor.substring(6, 8) + playerColor.substring(4, 6) + playerColor.substring(2, 4) + playerColor.substring(0, 2)
				} else {
					playerColor = "#000000";
				}
				PlayerInTeamNickname.style.color = playerColor

				var HeroImagePanel = $.CreatePanel('Panel', PlayerInTeamPanel, "")
				HeroImagePanel.AddClass("PlayerInTeamHeroImagePanel")

				var HeroImage = $.CreatePanel('Image', HeroImagePanel, "playerpickpanelimage_player" + playerIdInTeam)
			}

			var HeroImage = $("#playerpickpanelimage_player" + playerIdInTeam)
			if (playerData.status == "hover") {
				if (teamNumber == Players.GetTeam(Game.GetLocalPlayerID())) {
					HeroImage.SetImage(TransformTextureToPath(playerData.hero))
				}
				HeroImage.AddClass("PlayerInTeamHeroImageHover")
			} else if (playerData.status == "picked") {
				UpdateSelectionButton()
				if ($("#HeroListPanel_element_" + playerData.hero) != null) {
					$("#HeroListPanel_element_" + playerData.hero).AddClass("HeroListElementPickedBySomeone")
				}
				HeroImage.SetImage(TransformTextureToPath(playerData.hero))
				HeroImage.RemoveClass("PlayerInTeamHeroImageHover")
			}
		}
	}
}

function HeroSelectionEnd() {
	$.GetContextPanel().style.opacity = 0
	$.Schedule(5.6, function() {
		MainPanel.visible = false
		if (HideEvent != null) {
			GameEvents.Unsubscribe(HideEvent)
		}

		if (ShowPrecacheEvent != null) {
			GameEvents.Unsubscribe(ShowPrecacheEvent)
		}

		if (PTID != null) {
			PlayerTables.UnsubscribeNetTableListener(PTID)
		}
		$.GetContextPanel().DeleteAsync(0)
	})
}

function Initialize() {
	if (Game.GameStateIsAfter(DOTA_GameState.DOTA_GAMERULES_STATE_PRE_GAME)) {
		HeroSelectionEnd()
	} else {
		UpdatePanoramaState()
	}
}

function UpdatePanoramaState() {
	var hero_selection_available_heroes = PlayerTables.GetAllTableValues("hero_selection_available_heroes")
	$.Msg(hero_selection_available_heroes)
	if (hero_selection_available_heroes != null && typeof hero_selection_available_heroes == "object" && hero_selection_available_heroes.HeroTabs != null) {
		$.Msg("begun")
		HeroSelectionStart(hero_selection_available_heroes)
	} else {
		$.Schedule(0.03, UpdatePanoramaState)
	}
}

function ShowPrecache() {
	$("#HeroSelectionBase").visible = false
	$("#HeroSelectionPrecacheBase").visible = true
	var PlayerPickData = PlayerTables.GetAllTableValues("hero_selection")
	for (var teamNumber in PlayerPickData) {
		/*if ($("#team_selection_panels_team" + teamNumber) == null) {
			var TeamPanel = $.CreatePanel('Panel', $("#TeamSelectionStatusPanel"), "team_selection_panels_team" + teamNumber)
			TeamPanel.AddClass("TeamPanel")
		}*/

		var TeamPanel = $("#PrecacheTeamEntryTeam" + teamNumber)
		for (var playerIdInTeam in PlayerPickData[teamNumber]) {
			var SelectedPlayerHeroData = PlayerPickData[teamNumber][playerIdInTeam]
			var PlayerInTeamPanel = $.CreatePanel('Panel', TeamPanel, "")
			PlayerInTeamPanel.AddClass("PrecacheTeamPlayerPanel")

			var PlayerInTeamNickname = $.CreatePanel('Label', PlayerInTeamPanel, "")
			PlayerInTeamNickname.AddClass("PrecachePlayerInTeamNickname")
			PlayerInTeamNickname.text = Players.GetPlayerName(Number(playerIdInTeam))
			var playerColor = Players.GetPlayerColor(Number(playerIdInTeam))
			var playerColor = Players.GetPlayerColor(Number(playerIdInTeam)).toString(16)
			if (playerColor != null) {
				playerColor = "#" + playerColor.substring(6, 8) + playerColor.substring(4, 6) + playerColor.substring(2, 4) + playerColor.substring(0, 2)
			} else {
				playerColor = "#000000";
			}
			PlayerInTeamNickname.style.color = playerColor
			hero_tabs_iter:
				for (var tabkey in tabsData) {
					for (var herokey in tabsData[tabkey].Heroes) {
						var heroData = tabsData[tabkey].Heroes[herokey]
						if (heroData.heroKey == SelectedPlayerHeroData.hero) {
							PlayerInTeamPanel.BCreateChildren("<DOTAScenePanel style=\"width: 100%; height: 100%; opacity-mask: url('s2r://panorama/images/masks/softedge_box_png.vtex');\" unit=\"" + heroData.model + "\"/>");
							break hero_tabs_iter
						}
					}
				}

			var HeroLabel = $.CreatePanel('Label', PlayerInTeamPanel, "")
			HeroLabel.AddClass("PrecacheHeroLabel")
			HeroLabel.text = $.Localize("#" + SelectedPlayerHeroData.hero)
		}
	}
}

(function() {
	$("#HeroSelectionPrecacheBase").visible = false
	HideEvent = GameEvents.Subscribe("hero_selection_hide", HeroSelectionEnd)
	ShowPrecacheEvent = GameEvents.Subscribe("hero_selection_show_precache", ShowPrecache)
	PTID = PlayerTables.SubscribeNetTableListener("hero_selection", UpdateHeroesSelected)
	UpdateHeroesSelected("hero_selection", PlayerTables.GetAllTableValues("hero_selection"))
	Initialize()
})()