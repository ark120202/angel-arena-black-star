"use strict";

function IsHeroPicked(name) {
	var hero_selection_table = PlayerTables.GetAllTableValues("hero_selection")
	if (hero_selection_table != null) {
		for (var teamKey in hero_selection_table) {
			for (var playerIdInSelection in hero_selection_table[teamKey]) {
				if (hero_selection_table[teamKey][playerIdInSelection].hero == name && hero_selection_table[teamKey][playerIdInSelection].status == "picked") {
					return true
				}
			}
		}
	}
	return false
}

function SearchHero() {
	if ($("#HeroSearchTextEntry") != null) {
		var SearchString = $("#HeroSearchTextEntry").text.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&");
		if (SearchString.length > 0) {
			for (var key in HeroesPanels) {
				var heroName = $.Localize(HeroesPanels[key].id.replace("HeroListPanel_element_", ""))
				if (heroName.search(new RegExp(SearchString, "i")) > -1) {
					HeroesPanels[key].visible = true
				} else {
					HeroesPanels[key].visible = false
				}
			}
		} else {
			for (var key in HeroesPanels) {
				HeroesPanels[key].visible = true
			}
		}
	}
}

function FillHeroesTable(heroesData, panel, big) {
	for (var herokey in heroesData) {
		var heroData = heroesData[herokey]

		var HeroImagePanel = null
		if (big) {
			HeroImagePanel = $.CreatePanel('DOTAHeroMovie', panel, "HeroListPanel_element_" + heroData.heroKey)
			HeroImagePanel.heroname = heroData.heroKey
		} else {
			var StatPanel = panel.FindChildTraverse("HeroesByAttributes_" + heroData.attributes.attribute_primary + "_" + heroData.attributes.team.toLowerCase())
			HeroImagePanel = $.CreatePanel('Image', StatPanel, "HeroListPanel_element_" + heroData.heroKey)
			HeroImagePanel.SetImage(TransformTextureToPath(heroData.heroKey))
		}
		HeroImagePanel.AddClass("HeroListElement")
		if (heroData.isChanged) {
			HeroImagePanel.AddClass("ChangedHeroPanel")
		}
		var SelectHeroAction = (function(_heroData, _panel) {
			return function() {
				if (SelectedHeroPanel != _panel) {
					SelectedHeroData = _heroData
					if (SelectedHeroPanel != null) {
						SelectedHeroPanel.RemoveClass("HeroPanelSelected")
					}
					_panel.AddClass("HeroPanelSelected")
					SelectedHeroPanel = _panel
					ChooseHeroPanelHero()
				}
			}
		})(heroData, HeroImagePanel)
		HeroImagePanel.SetPanelEvent('onactivate', SelectHeroAction)
		HeroImagePanel.SelectHeroAction = SelectHeroAction
		HeroesPanels.push(HeroImagePanel)
	}
}

function SelectFirstHeroPanel() {
	var p;
	for (var key in HeroesPanels) {
		var heroName = HeroesPanels[key].id.replace("HeroListPanel_element_", "")
		if (heroName == "npc_dota_hero_abaddon") {
			p = HeroesPanels[key]
		}
	}
	if (p == null) {
		for (var key in HeroesPanels) {
			return HeroesPanels[key].SelectHeroAction();
		}
	}
	return p.SelectHeroAction();
}

function ChooseHeroUpdatePanels() {
	/*$("#SelectedHeroLabel").text = $.Localize("#" + SelectedHeroData.heroKey)
	UpdateSelectionButton()
	$("#SelectedHeroAbilitiesPanelInner").RemoveAndDeleteChildren()
	var abilitiesCount = GameUI.CustomUIConfig().GetArrayLength(SelectedHeroData.abilities)
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
	*/

	/*
		$("#SelectedHeroDescriptionText").text = $.Localize(SelectedHeroData.notes)
		if ($("#SelectedHeroScene").innerUnitModel != SelectedHeroData.model) {
			$("#SelectedHeroScene").RemoveAndDeleteChildren()
			$("#SelectedHeroScene").BCreateChildren("<DOTAScenePanel style=\"width: 100%; height: 100%;\" unit=\"" + SelectedHeroData.model + "\"/>");
			$("#SelectedHeroScene").innerUnitModel = SelectedHeroData.model
		}
	*/
	var BioPanel = $("#SelectedHeroDescriptionText")
	if (BioPanel != null)
		BioPanel.text = $.Localize("#" + SelectedHeroData.heroKey + "_bio")
	var ScenePanel = $("#SelectedHeroScene")
	if (ScenePanel != null) {
		if (ScenePanel.innerUnitModel != SelectedHeroData.model) {
			ScenePanel.RemoveAndDeleteChildren()
			ScenePanel.BCreateChildren("<DOTAScenePanel style=\"width: 100%; height: 100%;\" unit=\"" + SelectedHeroData.model + "\"/>");
			ScenePanel.innerUnitModel = SelectedHeroData.model
		}
	}
	UpdateSelectionButton()
	$("#SelectedHeroSelectHeroName").text = $.Localize("#" + SelectedHeroData.heroKey).toUpperCase()
	$("#SelectedHeroAbilitiesPanelInner").RemoveAndDeleteChildren()
	for (var key in SelectedHeroData.abilities) {
		var abilityName = SelectedHeroData.abilities[key]
		var abilityPanel = $.CreatePanel('DOTAAbilityImage', $("#SelectedHeroAbilitiesPanelInner"), "")
		abilityPanel.AddClass("SelectedHeroAbility")
		abilityPanel.abilityname = abilityName
		abilityPanel.SetPanelEvent('onmouseover', (function(_abilityName, _panel) {
			return function() {
				$.DispatchEvent("DOTAShowAbilityTooltip", _panel, _abilityName);
			}
		})(abilityName, abilityPanel))
		abilityPanel.SetPanelEvent('onmouseout', (function(_panel) {
			return function() {
				$.DispatchEvent("DOTAHideAbilityTooltip", _panel);
			}
		})(abilityPanel))
	}

	for (var i = 2; i >= 0; i--) {
		$("#DotaAttributePic_" + (i + 1)).SetHasClass("PrimaryAttribute", SelectedHeroData.attributes.attribute_primary == i)
		$("#HeroAttributes_" + (i + 1)).text = SelectedHeroData.attributes["attribute_base_" + i] + " + " + Number(SelectedHeroData.attributes["attribute_gain_" + i]).toFixed(1)
	}
	$("#HeroAttributes_damage").text = SelectedHeroData.attributes.damage_min + " - " + SelectedHeroData.attributes.damage_max
	$("#HeroAttributes_speed").text = SelectedHeroData.attributes.movespeed
	$("#HeroAttributes_armor").text = SelectedHeroData.attributes.armor
	$("#HeroAttributes_bat").text = Number(SelectedHeroData.attributes.attackrate).toFixed(1)
}