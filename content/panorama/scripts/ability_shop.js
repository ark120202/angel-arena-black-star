var DOTA_ACTIVE_GAMEMODE_TYPE = null;
var AbilityShopData = {};
var AllAbilityPanels = [];
var ParsedAbilityData = {};
var SelectedTabIndex = null;
var SearchingFor = "";
var SearchingPurchasedChecked = false;
var SearchingAbLevels = null;
var SelectedHeroPanel = null;

function GetLocalAbilityNamesInfo() {
	var ab = {};
	var hero = Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID())
	for (var i = 0; i < Entities.GetAbilityCount(hero); ++i) {
		var ability = Entities.GetAbility(hero, i);
		if (ability != -1) {
			var levels = Abilities.GetLevel(ability)
			if (Abilities.GetAbilityName(ability) == "attribute_bonus_arena")
				levels--;
			ab[Abilities.GetAbilityName(ability)] = {
				level: levels,
				maxLevel: Abilities.GetMaxLevel(ability)
			};
		}
	}
	return ab;
}

function GetBannedAbilities() {
	var b = []
	for (var a in GetLocalAbilityNamesInfo()) {
		var abinf = ParsedAbilityData[a];
		if (abinf != null)
			for (var v in abinf.banned_with)
				if (b.indexOf(abinf.banned_with[v]) == -1)
					b.push(abinf.banned_with[v])
	}
	return b;
}

function CreateSnippet_Ability(panel, abilityname, heroname, cost) {
	panel.abilityname = abilityname
	panel.heroname = heroname
	panel.BLoadLayoutSnippet("Ability");

	panel.FindChildTraverse("PointCost").text = cost;
	panel.FindChildTraverse("AbilityImage").abilityname = abilityname;
	panel.SetPanelEvent("onmouseover", function() {
		$.DispatchEvent("DOTAShowAbilityTooltip", panel, abilityname);
	})
	panel.SetPanelEvent("onmouseout", function() {
		$.DispatchEvent("DOTAHideAbilityTooltip", panel)
	})
	panel.SetPanelEvent("onactivate", function() {
		if (GameUI.IsShiftDown()) {
			GameEvents.SendCustomGameEventToServer("ability_shop_sell", {
				ability: abilityname
			});
		} else if (!panel.BHasClass("MaxUpgraded"))
			GameEvents.SendCustomGameEventToServer("ability_shop_buy", {
				ability: abilityname
			});
	})
	panel.SetPanelEvent("oncontextmenu", function() {
		if (GameUI.IsShiftDown()) {
			GameEvents.SendCustomGameEventToServer("ability_shop_downgrade", {
				ability: abilityname
			});
		} else if (!panel.BHasClass("MaxUpgraded"))
			GameEvents.SendCustomGameEventToServer("ability_shop_buy", {
				ability: abilityname
			});
	})
	return panel
}

function Search() {
	var abLevels = GetLocalAbilityNamesInfo();
	var SearchText = $("#SearchBar").text.toLowerCase();
	if (SearchingFor != SearchText || SearchingPurchasedChecked != $("#PurchasedAbilitiesToggle").checked || JSON.stringify(SearchingAbLevels) != JSON.stringify(abLevels)) {
		SearchingFor = SearchText;
		SearchingPurchasedChecked = $("#PurchasedAbilitiesToggle").checked;
		SearchingAbLevels = abLevels;
		var ShopSearchOverlay = $("#MainSearchRoot")
		$.Each(ShopSearchOverlay.Children(), function(child) {
			var index = AllAbilityPanels.indexOf(child);
			if (index > -1) {
				child.visible = false
				AllAbilityPanels.splice(index, 1);
			}
		})
		ShopSearchOverlay.RemoveAndDeleteChildren()
		var ShowSearch = SearchText.length > 0 || SearchingPurchasedChecked
		$.GetContextPanel().SetHasClass("InSearchMode", ShowSearch)
		if (ShowSearch) {
			var FoundAbilities = []
			if (AbilityShopData) {
				for (var tab in AbilityShopData) {
					for (var heroKey in AbilityShopData[tab]) {
						var hero = AbilityShopData[tab][heroKey].heroKey;
						var abs = AbilityShopData[tab][heroKey].abilities;
						for (var ability in abs) {
							if ((hero.toLowerCase().indexOf(SearchText) != -1 || abs[ability].ability.toLowerCase().indexOf(SearchText) != -1 || $.Localize("#" + hero.toLowerCase()).toLowerCase().indexOf(SearchText) != -1 || $.Localize(abs[ability].ability.toLowerCase()).toLowerCase().indexOf(SearchText) != -1) && (!SearchingPurchasedChecked || (SearchingPurchasedChecked && abLevels[abs[ability].ability] != null))) {
								FoundAbilities.push({
									name: abs[ability].ability,
									data: abs[ability],
									hero: hero
								})
							}
						}
					}
				}
			}
			FoundAbilities.sort(dynamicSort("name"));
			$.Each(FoundAbilities, function(abilityInfo) {
				AllAbilityPanels.push(CreateSnippet_Ability($.CreatePanel("Panel", ShopSearchOverlay, ""), abilityInfo.name, abilityInfo.hero, abilityInfo.data.cost));
			});
		}
	}
}

function CalculateDowngradeCost(abilityname, upgradecost) {
	return (upgradecost * 60) + (upgradecost * 10 * Math.floor(Game.GetDOTATime(false, false) / 60))
}

function UpdateAbilities() {
	Search();
	var shifttext = GameUI.IsShiftDown() ? "#ability_shop_shift_yes" : "#ability_shop_shift_no"
	$("#ShiftStateLabel").text = $.Localize(shifttext);
	var points = Entities.GetAbilityPoints(Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID()));
	$("#InfoContainerPointsLabel").text = "+" + points
	var abLevels = GetLocalAbilityNamesInfo();
	var banned_with = GetBannedAbilities();
	$.Each(AllAbilityPanels, function(panel) {
		var abilityname = panel.abilityname
		var purchasedInfo = abLevels[abilityname]
		var cost = Number(panel.FindChildTraverse("PointCost").text)
		panel.SetHasClass("NoPoints", cost > points)
		panel.SetHasClass("Purchased", purchasedInfo != null)
		if (purchasedInfo != null) {
			panel.SetHasClass("MaxUpgraded", purchasedInfo.level == purchasedInfo.maxLevel);
			panel.FindChildTraverse("AbilityLevel").text = "x" + purchasedInfo.level
		} else
			panel.RemoveClass("MaxUpgraded")

		if (panel.BHasClass("Purchased") && GameUI.IsShiftDown()) {
			panel.AddClass("CanDelete");
			panel.FindChildTraverse("SellReturn").text = "+" + cost * purchasedInfo.level
			panel.FindChildTraverse("SellCost").text = "-" + CalculateDowngradeCost(abilityname, cost) * purchasedInfo.level

			/*GameEvents.SendEventClientSide("dota_hud_error_message", {
				"splitscreenplayer": 0,
				"reason": 80,
				"message": "#dota_hud_error_not_enough_gold"
			});
			Game.EmitSound("General.NoGold")*/
		} else
			panel.RemoveClass("CanDelete");
		panel.SetHasClass("Banned", banned_with.indexOf(abilityname) !== -1);
	})
	$.Schedule(0.1, UpdateAbilities)
}

function HeroSelectionStart(data) {
	for (var tabKey in data.HeroTabs) {
		var heroesInTab = data.HeroTabs[tabKey]
		var TabHeroesPanel = $.CreatePanel('Panel', $("#HeroListPanel"), "HeroListPanel_tabPanels_" + tabKey)
		TabHeroesPanel.BLoadLayoutSnippet("HeroesPanel")
		FillHeroesTable(heroesInTab, TabHeroesPanel)
		TabHeroesPanel.visible = false
	}
	SelectHeroTab(1)
	SelectFirstHeroPanel();
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

function SwitchTab() {
	if (SelectedTabIndex == 1)
		SelectHeroTab(2)
	else
		SelectHeroTab(1)
}

function UpdateHeroAbilityList(hero, abilities) {
	var abilitiesroot = $("#HeroAbilitiesRoot")
	$.Each(abilitiesroot.Children(), function(child) {
		var index = AllAbilityPanels.indexOf(child);
		if (index > -1) {
			child.visible = false
			AllAbilityPanels.splice(index, 1);
		}
	})
	abilitiesroot.RemoveAndDeleteChildren();

	$.Each(abilities, function(abilityInfo) {
		AllAbilityPanels.push(CreateSnippet_Ability($.CreatePanel("Panel", abilitiesroot, ""), abilityInfo.ability, hero, abilityInfo.cost));
	});
}

function Fill(heroesData, panel) {
	/*for (var heroKey in changesObject[tab]) {
		var hero = changesObject[tab][heroKey].heroKey;

		/*var abs = changesObject[tab][heroKey].abilities;
		for (var ability in abs) {
			abs[ability].ability
		}
	}*/
	for (var herokey in heroesData) {
		var heroData = heroesData[herokey]
		var StatPanel = panel.FindChildTraverse("HeroesByAttributes_" + heroData.attribute_primary + "_" + heroData.team.toLowerCase())
		var HeroImagePanel = $.CreatePanel('Image', StatPanel, "HeroListPanel_element_" + heroData.heroKey)
		HeroImagePanel.SetImage(TransformTextureToPath(heroData.heroKey))
		HeroImagePanel.AddClass("HeroListElement")
		if (heroData.isChanged) {
			HeroImagePanel.AddClass("ChangedHeroPanel")
		}
		var SelectHeroAction = (function(_heroData, _herokey, _panel) {
			return function() {
				if (SelectedHeroPanel != _panel) {
					SelectedHeroData = _heroData
					if (SelectedHeroPanel != null) {
						SelectedHeroPanel.RemoveClass("HeroPanelSelected")
					}
					_panel.AddClass("HeroPanelSelected");
					SelectedHeroPanel = _panel;
					UpdateHeroAbilityList(_herokey, _heroData.abilities);
				}
			}
		})(heroData, herokey, HeroImagePanel)
		HeroImagePanel.SetPanelEvent('onactivate', SelectHeroAction)
		HeroImagePanel.SelectHeroAction = SelectHeroAction
		for (var k in heroData.abilities) {
			var abinf = heroData.abilities[k];
			ParsedAbilityData[abinf.ability] = abinf;
		}
	}
}

(function() {
	UpdateAbilities();
	DynamicSubscribePTListener("ability_shop_data", function(tableName, changesObject, deletionsObject) {
		$("#AbilityShopBase").visible = true;
		AbilityShopData = changesObject;
		for (var tab in changesObject) {
			var TabHeroesPanel = $.CreatePanel('Panel', $("#MainHeroesList"), "HeroListPanel_tabPanels_" + tab)
			TabHeroesPanel.BLoadLayoutSnippet("HeroesPanel");
			TabHeroesPanel.visible = false;
			Fill(changesObject[tab], TabHeroesPanel)
		}
		SelectHeroTab(1)
	});
	Game.DisableWheelPanels.push($("#MainContainer"));
})();