'use strict';
var MainPanel = $('#MainBox');
var SelectedHeroPanel;
var SelectedTabIndex;
var HeroesPanels = [];
var DOTA_ACTIVE_GAMEMODE_TYPE;
var AutoSearchHeroThinker;
var HeroTabs;

function OpenMenu(data) {
	if (!MainPanel.visible) {
		if (HeroTabs && HeroesPanels.length === 0 && HeroesData) {
			_.each(HeroTabs, function(tabContent, tabKey) {
				var TabHeroesPanel = $.CreatePanel('Panel', $('#HeroListPanel'), 'HeroListPanel_tabPanels_' + tabKey);
				TabHeroesPanel.BLoadLayoutSnippet('HeroesPanel');
				FillHeroesTable(tabContent, TabHeroesPanel);
				TabHeroesPanel.visible = false;
			});
			ListenToBanningPhase();
		}
		MainPanel.SetHasClass('ForcedHeroChange', data.forced === true);
		MainPanel.visible = true;
		SelectHeroTab(1);
		SelectFirstHeroPanel();
		AutoSearchHero();
		$('#HeroSearchTextEntry').SetFocus();
	}
}

function AutoSearchHero() {
	SearchHero();
	AutoSearchHeroThinker = $.Schedule(0.3, AutoSearchHero);
}

function CloseMenu() {
	ClearSearch();
	MainPanel.visible = false;
	if (AutoSearchHeroThinker != null)
		$.CancelScheduled(AutoSearchHeroThinker);
}

function ChooseHeroPanelHero() {
	ChooseHeroUpdatePanels();
}

function UpdateSelectionButton() {
	var selectedHeroData = HeroesData[SelectedHeroName];
	var currentHero = Players.GetHeroSelectionPlayerInfo(Game.GetLocalPlayerID()).hero;

	var canPick = !IsHeroPicked(SelectedHeroName) &&
		!IsHeroBanned(SelectedHeroName) &&
		!IsHeroUnreleased(SelectedHeroName) &&
		!IsHeroDisabledInRanked(SelectedHeroName) &&
		(!IsLocalHeroLocked() || SelectedHeroName === currentHero);

	var context = $.GetContextPanel();
	var mode = 'pick';
	if (selectedHeroData && selectedHeroData.linked_heroes) {
		mode = IsLocalHeroLocked() && selectedHeroData.heroKey === currentHero ? 'unlock' : 'lock';
	}
	context.SetHasClass('LocalHeroLockButton', mode === 'lock');
	context.SetHasClass('LocalHeroUnlockButton', mode === 'unlock');
	context.SetHasClass('LocalHeroBanButton', mode === 'ban');

	$('#SelectedHeroSelectButton').enabled = canPick;
}

function SelectHero() {
	GameEvents.SendCustomGameEventToServer('metamorphosis_elixir_cast', {
		hero: SelectedHeroName
	});
	CloseMenu();
	Game.EmitSound('HeroPicker.Selected');
}

function UpdateHeroesSelected() {
	for (var i = 0; i < HeroesPanels.length; i++) {
		var heroPanel = HeroesPanels[i];
		heroPanel.SetHasClass('Picked', IsHeroPicked(heroPanel.id.substring('HeroListPanel_element_'.length)));
		heroPanel.SetHasClass('Locked', IsHeroLocked(heroPanel.id.substring('HeroListPanel_element_'.length)));
	}
	UpdateSelectionButton();
}

(function() {
	DynamicSubscribePTListener('hero_selection_available_heroes', function(tableName, changesObject) {
		if (changesObject.HeroTabs) HeroTabs = changesObject.HeroTabs;
	});
	GameEvents.Subscribe('metamorphosis_elixir_show_menu', OpenMenu);
	MainPanel.visible = false;
	DynamicSubscribePTListener('hero_selection', UpdateHeroesSelected);
})();
