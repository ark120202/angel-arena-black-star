var HeroesData = {},
  SelectedHeroName = '',
  BannedHeroes = [],
  LocalPlayerStatus = {};
DynamicSubscribePTListener('hero_selection_heroes_data', function(
  tableName,
  changesObject,
  deletionsObject,
) {
  HeroesData = changesObject;
  //if (OnRecieveHeroesData) OnRecieveHeroesData();
});

function IsHeroPicked(name) {
  var hero_selection_table = PlayerTables.GetAllTableValues('hero_selection');
  if (hero_selection_table != null) {
    for (var teamKey in hero_selection_table) {
      for (var playerIdInSelection in hero_selection_table[teamKey]) {
        if (
          hero_selection_table[teamKey][playerIdInSelection].hero === name &&
          hero_selection_table[teamKey][playerIdInSelection].status === 'picked'
        ) {
          return true;
        }
      }
    }
  }
  return false;
}

function IsHeroLocked(name) {
  var hero_selection_table = PlayerTables.GetAllTableValues('hero_selection');
  if (hero_selection_table != null) {
    for (var teamKey in hero_selection_table) {
      for (var playerIdInSelection in hero_selection_table[teamKey]) {
        if (
          hero_selection_table[teamKey][playerIdInSelection].hero === name &&
          hero_selection_table[teamKey][playerIdInSelection].status === 'locked'
        ) {
          return true;
        }
      }
    }
  }
  return false;
}

function IsHeroBanned(name) {
  return BannedHeroes.indexOf(name) !== -1;
}

function IsHeroUnreleased(name) {
  return HeroesData[name] && HeroesData[name].Unreleased;
}

function IsHeroDisabledInRanked(name) {
  return (
    HeroesData[name] &&
    HeroesData[name].DisabledInRanked &&
    Options.IsEquals('EnableRatingAffection')
  );
}

function IsLocalHeroPicked() {
  return (
    (LocalPlayerStatus || Players.GetHeroSelectionPlayerInfo(Game.GetLocalPlayerID())).status ===
    'picked'
  );
}

function IsLocalHeroLocked() {
  return (
    (LocalPlayerStatus || Players.GetHeroSelectionPlayerInfo(Game.GetLocalPlayerID())).status ===
    'locked'
  );
}

function IsLocalHeroLockedOrPicked() {
  return IsLocalHeroPicked() || IsLocalHeroLocked();
}

var PreviousSearchText = '';
function SearchHero() {
  if ($('#HeroSearchTextEntry') != null) {
    var SearchString = $('#HeroSearchTextEntry').text.replace(
      /[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g,
      '\\$&',
    );
    if (PreviousSearchText !== SearchString) {
      PreviousSearchText = SearchString;
      $.GetContextPanel().SetHasClass('SearchingHeroes', SearchString.length > 0);

      if (SearchString.length > 0) {
        var matchRegexp = new RegExp(SearchString, 'i');
        var first;
        for (var key in HeroesPanels) {
          var heroName = $.Localize(HeroesPanels[key].id.replace('HeroListPanel_element_', ''));
          var high = matchRegexp.test(heroName);
          HeroesPanels[key].SetHasClass('Highlighted', high);
          if (high && !first) first = HeroesPanels[key];
        }
        if (first != null) {
          first.SelectHeroAction();
        }
      } else {
        for (var key in HeroesPanels) {
          HeroesPanels[key].RemoveClass('Highlighted');
        }
      }
    }
  }
}

function FillHeroesTable(heroList, panel, big) {
  _.each(heroList, function(heroName) {
    var heroData = HeroesData[heroName];
    var StatPanel = panel.FindChildTraverse(
      'HeroesByAttributes_' + heroData.attributes.attribute_primary,
    );

    var HeroCard = $.CreatePanel('Panel', StatPanel, 'HeroListPanel_element_' + heroName);
    HeroCard.BLoadLayoutSnippet('HeroCard');
    HeroCard.FindChildTraverse('HeroImage').SetImage(TransformTextureToPath(heroName, 'portrait'));
    if (heroData.isChanged) {
      HeroCard.FindChildTraverse('HeroChangedBurstRoot').BCreateChildren(
        '<DOTAScenePanel map="scenes/hud/levelupburst" hittest="false" />',
      );
      HeroCard.AddClass('IsChanged');
    }
    if (heroData.linkedColorGroup) {
      HeroCard.AddClass('HasLinkedColorGroup');
      HeroCard.FindChildTraverse('LinkedHeroesGroupRow').style.backgroundColor =
        heroData.linkedColorGroup;
    }
    var SelectHeroAction = function() {
      if (SelectedHeroPanel !== HeroCard) {
        SelectedHeroName = heroName;
        if (SelectedHeroPanel != null) {
          SelectedHeroPanel.RemoveClass('HeroPanelSelected');
        }
        HeroCard.AddClass('HeroPanelSelected');
        SelectedHeroPanel = HeroCard;
        ChooseHeroPanelHero();
      }
    };
    var HitTarget = HeroCard.FindChildTraverse('HitTarget');
    HitTarget.SetPanelEvent('onactivate', SelectHeroAction);
    HitTarget.SetPanelEvent('oninputsubmit', SelectHeroAction);
    HitTarget.SetPanelEvent('onmouseover', function() {
      if (IsDotaHeroName(heroName)) HeroCard.FindChildTraverse('HeroMovie').heroname = heroName;
      HeroCard.AddClass('Expanded');
    });
    HitTarget.SetPanelEvent('onmouseout', function() {
      if (IsDotaHeroName(heroName)) HeroCard.FindChildTraverse('HeroMovie').heroname = null;
      HeroCard.RemoveClass('Expanded');
    });
    HeroCard.FindChildTraverse('HeroName').text = $.Localize(heroName);
    HeroCard.SelectHeroAction = SelectHeroAction;
    HeroesPanels.push(HeroCard);
  });
}

function SelectFirstHeroPanel() {
  var p;
  for (var key in HeroesPanels) {
    var heroName = HeroesPanels[key].id.replace('HeroListPanel_element_', '');
    if (heroName === 'npc_dota_hero_abaddon') {
      p = HeroesPanels[key];
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
  var selectedHeroData = HeroesData[SelectedHeroName];
  UpdateSelectionButton();
  var context = $.GetContextPanel();
  $('#SelectedHeroSelectHeroName').text = $.Localize(SelectedHeroName);
  $('#SelectedHeroOverview').text = $.Localize(SelectedHeroName + '_hype');
  context.SetHasClass('HoveredHeroHasLinked', selectedHeroData.linked_heroes != null);
  if (selectedHeroData.linked_heroes != null) {
    const linked = selectedHeroData.linked_heroes.map(hero => $.Localize(hero));
    $('#SelectedHeroLinkedHero').text = linked.join(', ');
  }
  $('#SelectedHeroAbilitiesPanelInner').RemoveAndDeleteChildren();

  $('#SelectedHeroDisabledReason').text = IsHeroUnreleased(SelectedHeroName)
    ? $.Localize('hero_selection_disabled_reason_unreleased')
    : IsHeroDisabledInRanked(SelectedHeroName)
    ? $.Localize('hero_selection_disabled_reason_disabled_in_ranked')
    : '';
  FillAbilitiesUI(
    $('#SelectedHeroAbilitiesPanelInner'),
    selectedHeroData.abilities,
    'SelectedHeroAbility',
  );
  FillAttributeUI($('#HeroListControlsGroup3'), selectedHeroData.attributes);
}

function FillAbilitiesUI(rootPanel, abilities, className) {
  _.each(abilities, function(abilityName) {
    var abilityPanel = $.CreatePanel('DOTAAbilityImage', rootPanel, '');
    abilityPanel.AddClass(className);
    abilityPanel.abilityname = abilityName;
    abilityPanel.SetPanelEvent('onmouseover', function() {
      $.DispatchEvent('DOTAShowAbilityTooltip', abilityPanel, abilityName);
    });
    abilityPanel.SetPanelEvent('onmouseout', function() {
      $.DispatchEvent('DOTAHideAbilityTooltip', abilityPanel);
    });
  });
}

function FillAttributeUI(rootPanel, attributesData) {
  for (var i = 2; i >= 0; i--) {
    rootPanel
      .FindChildTraverse('DotaAttributePic_' + (i + 1))
      .SetHasClass('PrimaryAttribute', Number(attributesData.attribute_primary) === i);
    rootPanel.FindChildTraverse('HeroAttributes_' + (i + 1)).text =
      attributesData['attribute_base_' + i] +
      ' + ' +
      Number(attributesData['attribute_gain_' + i]).toFixed(1);
  }
  rootPanel.FindChildTraverse('HeroAttributes_damage').text =
    attributesData.damage_min + ' - ' + attributesData.damage_max;
  rootPanel.FindChildTraverse('HeroAttributes_speed').text = attributesData.movespeed;
  rootPanel.FindChildTraverse('HeroAttributes_armor').text = Number(attributesData.armor).toFixed(
    1,
  );
  rootPanel.FindChildTraverse('HeroAttributes_bat').text = Number(
    attributesData.attackrate,
  ).toFixed(1);
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

function ClearSearch() {
  $.DispatchEvent('DropInputFocus', $('#HeroSearchTextEntry'));
  $('#HeroSearchTextEntry').text = '';
}

function ListenToBanningPhase() {
  DynamicSubscribePTListener('hero_selection_banning_phase', function(
    tableName,
    changesObject,
    deletionsObject,
  ) {
    for (var hero in changesObject) {
      var heroPanel = $('#HeroListPanel_element_' + hero);
      if (Number(changesObject[hero]) === Game.GetLocalPlayerID()) {
        HasBanPoint = false;
        if (UpdateSelectionButton) UpdateSelectionButton();
      }
      if (heroPanel) heroPanel.AddClass('Banned');
      BannedHeroes.push(hero);
    }
    for (var hero in deletionsObject) {
      var heroPanel = $('#HeroListPanel_element_' + hero);
      if (heroPanel) heroPanel.RemoveClass('Banned');
      var index = BannedHeroes.indexOf(hero);
      if (index > -1) BannedHeroes.splice(index, 1);
    }
  });
}
