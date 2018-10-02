var DOTA_ACTIVE_GAMEMODE_TYPE = null;
var AbilityShopData = {};
var AllAbilityPanels = [];
var ParsedAbilityData = {};
var SelectedTabIndex = null;
var SearchingFor = '';
var SearchingPurchasedChecked = false;
var SearchingAbLevels = null;
var SelectedHeroPanel = null;

function GetLocalAbilityNamesInfo() {
	var ab = {};
	var hero = Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID());
	for (var i = 0; i < Entities.GetAbilityCount(hero); ++i) {
		var ability = Entities.GetAbility(hero, i);
		if (ability !== -1 && !Abilities.IsHidden(ability)) {
			ab[Abilities.GetAbilityName(ability)] = {
				level: Abilities.GetLevel(ability),
				maxLevel: Abilities.GetMaxLevel(ability)
			};
		}
	}
	return ab;
}

function GetBannedAbilities() {
	var b = [];
	for (var a in GetLocalAbilityNamesInfo()) {
		var abinf = ParsedAbilityData[a];
		if (abinf != null)
			for (var v in abinf.banned_with)
				if (b.indexOf(abinf.banned_with[v]) === -1)
					b.push(abinf.banned_with[v]);
	}
	return b;
}

function CreateSnippet_Ability(panel, abilityname, heroname, cost) {
	panel.abilityname = abilityname;
	panel.heroname = heroname;
	panel.BLoadLayoutSnippet('Ability');

	panel.FindChildTraverse('PointCost').text = cost;
	panel.FindChildTraverse('AbilityImage').abilityname = abilityname;
	panel.SetPanelEvent('onmouseover', function() {
		$.DispatchEvent('DOTAShowAbilityTooltip', panel, abilityname);
	});
	panel.SetPanelEvent('onmouseout', function() {
		$.DispatchEvent('DOTAHideAbilityTooltip', panel);
	});
	panel.SetPanelEvent('onactivate', function() {
		if (GameUI.IsShiftDown()) {
			GameEvents.SendCustomGameEventToServer('ability_shop_sell', {
				ability: abilityname
			});
		} else if (!panel.BHasClass('MaxUpgraded'))
			GameEvents.SendCustomGameEventToServer('ability_shop_buy', {
				ability: abilityname
			});
	});
	panel.SetPanelEvent('oncontextmenu', function() {
		if (GameUI.IsShiftDown()) {
			GameEvents.SendCustomGameEventToServer('ability_shop_downgrade', {
				ability: abilityname
			});
		} else if (!panel.BHasClass('MaxUpgraded'))
			GameEvents.SendCustomGameEventToServer('ability_shop_buy', {
				ability: abilityname
			});
	});
	return panel;
}

function Search() {
	var abLevels = GetLocalAbilityNamesInfo();
	var SearchText = $('#SearchBar').text.toLowerCase();
	if (SearchingFor !== SearchText || SearchingPurchasedChecked !== $('#PurchasedAbilitiesToggle').checked || !_.isEqual(SearchingAbLevels, abLevels)) {
		SearchingFor = SearchText;
		SearchingPurchasedChecked = $('#PurchasedAbilitiesToggle').checked;
		SearchingAbLevels = abLevels;
		var ShopSearchOverlay = $('#MainSearchRoot');
		_.each(ShopSearchOverlay.Children(), function(child) {
			var index = AllAbilityPanels.indexOf(child);
			if (index > -1) {
				child.visible = false;
				AllAbilityPanels.splice(index, 1);
			}
		});
		ShopSearchOverlay.RemoveAndDeleteChildren();
		var ShowSearch = SearchText.length > 0 || SearchingPurchasedChecked;
		$.GetContextPanel().SetHasClass('InSearchMode', ShowSearch);
		if (ShowSearch) {
			var FoundAbilities = [];
			if (AbilityShopData) {
				_.each(AbilityShopData, function(tabContent) {
					_.each(tabContent, function(heroData) {
						var hero = heroData.heroKey;
						_.each(heroData.abilities, function(abilityData) {
							if ((hero.toLowerCase().indexOf(SearchText) !== -1 || abilityData.ability.toLowerCase().indexOf(SearchText) !== -1 || $.Localize('#' + hero.toLowerCase()).toLowerCase().indexOf(SearchText) !== -1 || $.Localize(abilityData.ability.toLowerCase()).toLowerCase().indexOf(SearchText) !== -1) && (!SearchingPurchasedChecked || (SearchingPurchasedChecked && abLevels[abilityData.ability] != null))) {
								FoundAbilities.push({
									name: abilityData.ability,
									data: abilityData,
									hero: hero
								});
							}
						});
					});
				});
			}
			_.each(_.sortBy(FoundAbilities, 'name'), function(abilityInfo) {
				AllAbilityPanels.push(CreateSnippet_Ability($.CreatePanel('Panel', ShopSearchOverlay, ''), abilityInfo.name, abilityInfo.hero, abilityInfo.data.cost));
			});
		}
	}
}

function CalculateDowngradeCost(abilityname, upgradecost) {
	return (upgradecost * 60) + (upgradecost * 10 * Math.floor(Game.GetDOTATime(false, false) / 60));
}

function UpdateAbilities() {
	var points = Entities.GetAbilityPoints(Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID()));
	$('#InfoContainerPointsLabel').text = '+' + points;
	var abLevels = GetLocalAbilityNamesInfo();
	var banned_with = GetBannedAbilities();
	_.each(AllAbilityPanels, function(panel) {
		var abilityname = panel.abilityname;
		var purchasedInfo = abLevels[abilityname];
		var cost = Number(panel.FindChildTraverse('PointCost').text);
		panel.SetHasClass('NoPoints', cost > points);
		panel.SetHasClass('Purchased', purchasedInfo != null);
		if (purchasedInfo != null) {
			panel.SetHasClass('MaxUpgraded', purchasedInfo.level == purchasedInfo.maxLevel);
			panel.FindChildTraverse('AbilityLevel').text = 'x' + purchasedInfo.level;
		} else
			panel.RemoveClass('MaxUpgraded');

		if (panel.BHasClass('Purchased') && GameUI.IsShiftDown()) {
			panel.AddClass('CanDelete');
			panel.FindChildTraverse('SellReturn').text = '+' + cost * purchasedInfo.level;
			panel.FindChildTraverse('SellCost').text = '-' + CalculateDowngradeCost(abilityname, cost) * purchasedInfo.level;

			/*GameEvents.SendEventClientSide("dota_hud_error_message", {
				"splitscreenplayer": 0,
				"reason": 80,
				"message": "#dota_hud_error_not_enough_gold"
			});
			Game.EmitSound("General.NoGold")*/
		} else
			panel.RemoveClass('CanDelete');
		panel.SetHasClass('Banned', banned_with.indexOf(abilityname) !== -1);
	});
}

function SwitchTab() {
	SelectHeroTab(SelectedTabIndex === 1 ? 2 : 1);
}

function SelectHeroTab(tabIndex) {
	if (SelectedTabIndex !== tabIndex) {
		if (SelectedTabIndex != null) {
			$('#HeroListPanel_tabPanels_' + SelectedTabIndex).visible = false;
		}
		$('#HeroListPanel_tabPanels_' + tabIndex).visible = true;
		$('#SwitchHeroesButton').RemoveClass('ActiveTab' + SelectedTabIndex);
		$('#SwitchHeroesButton').AddClass('ActiveTab' + tabIndex);
		SelectedTabIndex = tabIndex;
	}
}

function UpdateHeroAbilityList(hero, abilities) {
	var abilitiesroot = $('#HeroAbilitiesRoot');
	_.each(abilitiesroot.Children(), function(child) {
		var index = AllAbilityPanels.indexOf(child);
		if (index > -1) {
			child.visible = false;
			AllAbilityPanels.splice(index, 1);
		}
	});
	abilitiesroot.RemoveAndDeleteChildren();

	_.each(abilities, function(abilityInfo) {
		AllAbilityPanels.push(CreateSnippet_Ability($.CreatePanel('Panel', abilitiesroot, ''), abilityInfo.ability, hero, abilityInfo.cost));
	});

	UpdateAbilities();
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
		var heroData = heroesData[herokey];
		var StatPanel = panel.FindChildTraverse('HeroesByAttributes_' + heroData.attribute_primary);
		var HeroImagePanel = $.CreatePanel('Image', StatPanel, 'HeroListPanel_element_' + heroData.heroKey);
		HeroImagePanel.SetImage(TransformTextureToPath(heroData.heroKey));
		HeroImagePanel.AddClass('HeroListElement');
		if (heroData.isChanged) {
			HeroImagePanel.AddClass('ChangedHeroPanel');
		}
		var SelectHeroAction = (function(_heroData, _herokey, _panel) {
			return function() {
				if (SelectedHeroPanel !== _panel) {
					SelectedHeroData = _heroData;
					if (SelectedHeroPanel != null) {
						SelectedHeroPanel.RemoveClass('HeroPanelSelected');
					}
					_panel.AddClass('HeroPanelSelected');
					SelectedHeroPanel = _panel;
					UpdateHeroAbilityList(_herokey, _heroData.abilities);
				}
			};
		})(heroData, herokey, HeroImagePanel);
		HeroImagePanel.SetPanelEvent('onactivate', SelectHeroAction);
		HeroImagePanel.SelectHeroAction = SelectHeroAction;
		for (var k in heroData.abilities) {
			var abinf = heroData.abilities[k];
			ParsedAbilityData[abinf.ability] = abinf;
		}
	}
}

(function() {
	DynamicSubscribePTListener('ability_shop_data', function(tableName, changesObject, deletionsObject) {
		$('#AbilityShopBase').visible = true;
		AbilityShopData = changesObject;
		for (var tab in changesObject) {
			var TabHeroesPanel = $.CreatePanel('Panel', $('#MainHeroesList'), 'HeroListPanel_tabPanels_' + tab);
			TabHeroesPanel.BLoadLayoutSnippet('HeroesPanel');
			TabHeroesPanel.visible = false;
			Fill(changesObject[tab], TabHeroesPanel);
		}
		SelectHeroTab(1);
	});
	Game.DisableWheelPanels.push($('#MainContainer'));

	(function autoUpdate() {
		Search();
		UpdateAbilities();
		$('#ShiftStateLabel').text = $.Localize(GameUI.IsShiftDown() ? '#ability_shop_shift_yes' : '#ability_shop_shift_no');
		$.Schedule(0.15, autoUpdate);
	})();
})();
