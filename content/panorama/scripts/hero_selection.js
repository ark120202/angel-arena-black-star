'use strict';
var MainPanel = $('#HeroSelectionBox');
var SelectedHeroPanel,
  SelectedTabIndex,
  SelectionTimerEndTime = 0,
  HideEvent,
  DOTA_ACTIVE_GAMEMODE,
  CustomChatLinesPanel,
  MinimapPTIDs = [],
  HeroesPanels = [],
  tabsData = {},
  PlayerSpawnBoxes = {},
  HeroSelectionState = -1,
  PlayerPanels = [],
  InitializationStates = {},
  HasBanPoint = true;

function HeroSelectionEnd(bImmidate) {
  $.GetContextPanel().style.opacity = 0;
  dotaHud.GetChild(0).RemoveClass('IsBeforeGameplay');
  $.Schedule(bImmidate ? 0 : 1.6, function() {
    //1.5 + 0.1
    MainPanel.visible = false;
    if (HideEvent != null) GameEvents.Unsubscribe(HideEvent);
    if ($.GetContextPanel().PTID_hero_selection)
      PlayerTables.UnsubscribeNetTableListener($.GetContextPanel().PTID_hero_selection);
    if (MinimapPTIDs.length > 0)
      for (var i = 0; i < MinimapPTIDs.length; i++) {
        PlayerTables.UnsubscribeNetTableListener(MinimapPTIDs[i]);
      }
    $.GetContextPanel().DeleteAsync(0);
  });
}

function ChooseHeroPanelHero() {
  ChooseHeroUpdatePanels();
  if (!IsLocalHeroLockedOrPicked()) {
    GameEvents.SendCustomGameEventToServer('hero_selection_player_hover', {
      hero: SelectedHeroName,
    });
  }
}

function SelectHero() {
  if (!IsLocalHeroPicked()) {
    GameEvents.SendCustomGameEventToServer('hero_selection_player_select', {
      hero: SelectedHeroName,
    });
    Game.EmitSound('ui.pick_play');
  }
}

function RandomHero() {
  if (!IsLocalHeroLockedOrPicked()) {
    GameEvents.SendCustomGameEventToServer('hero_selection_player_random', {});
  }
}

function UpdateSelectionButton() {
  var selectedHeroData = HeroesData[SelectedHeroName];
  $.GetContextPanel().SetHasClass(
    'RandomingEnabled',
    !IsLocalHeroPicked() &&
      !IsLocalHeroLocked() &&
      HeroSelectionState > HERO_SELECTION_PHASE_BANNING,
  );

  var canPick =
    !IsLocalHeroPicked() &&
    !IsHeroPicked(SelectedHeroName) &&
    !IsHeroBanned(SelectedHeroName) &&
    !IsHeroUnreleased(SelectedHeroName) &&
    !IsHeroDisabledInRanked(SelectedHeroName) &&
    (!IsLocalHeroLocked() || SelectedHeroName === LocalPlayerStatus.hero);

  var context = $.GetContextPanel();
  var mode = 'pick';
  if (HeroSelectionState === HERO_SELECTION_PHASE_BANNING) {
    mode = 'ban';
    canPick = canPick && HasBanPoint;
  } else if (selectedHeroData && selectedHeroData.linked_heroes) {
    mode =
      IsLocalHeroLocked() && selectedHeroData.heroKey === LocalPlayerStatus.hero
        ? 'unlock'
        : 'lock';
  }
  context.SetHasClass('LocalHeroLockButton', mode === 'lock');
  context.SetHasClass('LocalHeroUnlockButton', mode === 'unlock');
  context.SetHasClass('LocalHeroBanButton', mode === 'ban');

  $('#SelectedHeroSelectButton').enabled = canPick;
}

function UpdateTimer() {
  $.Schedule(0.2, UpdateTimer);
  var SelectionTimerRemainingTime =
    (SelectionTimerEndTime || Number.MIN_SAFE_INTEGER) - Game.GetGameTime();
  if (SelectionTimerRemainingTime > 0) {
    if (HeroSelectionState < HERO_SELECTION_PHASE_END) {
      dotaHud.GetChild(0).AddClass('IsBeforeGameplay');
    }
    $('#HeroSelectionTimer').text = Math.ceil(SelectionTimerRemainingTime);
    SearchHero();
    for (var playerId in PlayerPanels) {
      var panel = PlayerPanels[playerId];
      var playerInfo = Game.GetPlayerInfo(Number(PlayerPanels));
      if (playerInfo != null) {
        panel.SetHasClass(
          'player_connection_abandoned',
          playerInfo.player_connection_state ===
            DOTAConnectionState_t.DOTA_CONNECTION_STATE_ABANDONED,
        );
        panel.SetHasClass(
          'player_connection_failed',
          playerInfo.player_connection_state === DOTAConnectionState_t.DOTA_CONNECTION_STATE_FAILED,
        );
        panel.SetHasClass(
          'player_connection_disconnected',
          playerInfo.player_connection_state ===
            DOTAConnectionState_t.DOTA_CONNECTION_STATE_DISCONNECTED,
        );
      }
    }
    _.each($MinimapSpawnBoxes().Children(), function(child) {
      var childrencount = child.GetChildCount();
      child.SetHasClass('SpawnBoxUnitPanelChildren2', childrencount >= 2);
      child.SetHasClass('SpawnBoxUnitPanelChildren3', childrencount >= 3);
      child.SetHasClass('SpawnBoxUnitPanelChildren5', childrencount >= 5);
    });
  } else {
    $('#HeroSelectionTimer').text = 0;
  }
}

function Snippet_PlayerPanel(playerId, rootPanel) {
  if (PlayerPanels[playerId] == null) {
    var panel = $.CreatePanel('Panel', rootPanel, '');
    panel.BLoadLayoutSnippet('PlayerPanel');
    panel.SetDialogVariable('player_name', Players.GetPlayerName(playerId));
    var statsData = Players.GetStatsData(playerId);
    panel.FindChildTraverse('SlotColor').style.backgroundColor = GetHEXPlayerColor(playerId);
    PlayerPanels[playerId] = panel;
  }
  return PlayerPanels[playerId];
}

function UpdateHeroesSelected(tableName, changesObject, deletionsObject) {
  _.each(changesObject, function(teamPlayers, teamNumber) {
    if ($('#team_selection_panels_team' + teamNumber) == null) {
      var isRight = teamNumber % 2 !== 0;
      var TeamSelectionPanel = $.CreatePanel(
        'Panel',
        $(isRight ? '#RightTeams' : '#LeftTeams'),
        'team_selection_panels_team' + teamNumber,
      );
      TeamSelectionPanel.BLoadLayoutSnippet('TeamBar');
      var color = GameUI.CustomUIConfig().team_colors[teamNumber];
      TeamSelectionPanel.style.backgroundColor =
        'gradient(linear, 100% 100%, 0% 100%, from(transparent), color-stop(0.15, ' +
        color +
        '4D), to(transparent))';
    }
    var TeamSelectionPanel = $('#team_selection_panels_team' + teamNumber).FindChildTraverse(
      'TeamBarPlayers',
    );
    _.each(teamPlayers, function(playerData, playerIdInTeam) {
      var PlayerPanel = Snippet_PlayerPanel(Number(playerIdInTeam), TeamSelectionPanel);

      var isLocalPlayer = Number(playerIdInTeam) === Game.GetLocalPlayerID();
      var isLocalTeam = Number(teamNumber) === Players.GetTeam(Game.GetLocalPlayerID());

      if (isLocalPlayer) {
        LocalPlayerStatus = playerData;
        $.GetContextPanel().SetHasClass('LocalPlayerLocked', playerData.status === 'locked');
        if (!$.GetContextPanel().BHasClass('LocalPlayerPicked') && playerData.status === 'picked') {
          OnLocalPlayerPicked();
        } else if (
          $.GetContextPanel().BHasClass('LocalPlayerPicked') &&
          playerData.status !== 'picked'
        ) {
          ToggleHeroPreviewHeroList(false);
        }
        $.GetContextPanel().SetHasClass('LocalPlayerPicked', playerData.status === 'picked');
      }

      PlayerPanel.SetHasClass('HeroPickHovered', playerData.status === 'hover');
      PlayerPanel.SetHasClass('HeroPickLocked', playerData.status === 'locked');
      if (playerData.status === 'hover' || playerData.status === 'locked') {
        if (isLocalTeam) {
          PlayerPanel.FindChildTraverse('HeroImage').SetImage(
            TransformTextureToPath(playerData.hero),
          );
          PlayerPanel.SetDialogVariable('dota_hero_name', $.Localize(playerData.hero));
        }
      } else if (playerData.status === 'picked') {
        PlayerPanel.FindChildTraverse('HeroImage').SetImage(
          TransformTextureToPath(playerData.hero),
        );
        PlayerPanel.SetDialogVariable('dota_hero_name', $.Localize(playerData.hero));
      }
      var heroPanel = $('#HeroListPanel_element_' + playerData.hero);
      if (heroPanel) {
        heroPanel.SetHasClass('AlreadyPicked', IsHeroPicked(playerData.hero));
        heroPanel.SetHasClass('Locked', IsHeroLocked(playerData.hero));
      }
      if (isLocalTeam) {
        if (playerData.SpawnBoxes != null) {
          var PlayerSPBoxesTable =
            PlayerSpawnBoxes[playerIdInTeam] || (PlayerSpawnBoxes[playerIdInTeam] = new Set());
          var checkedPanels = new Set();
          for (var index in playerData.SpawnBoxes) {
            var SPBoxInfoGroup = playerData.SpawnBoxes[index];
            var SPBoxID = 'MinimapSpawnBoxPlayerIcon_' + SPBoxInfoGroup + '_' + playerIdInTeam;
            var SpawnBoxUnitPanel = $('#' + SPBoxID);
            var RootPanel = $MinimapSpawnBoxes().FindChildTraverse(
              'MinimapSpawnBox_' + SPBoxInfoGroup,
            );
            if (SpawnBoxUnitPanel == null) {
              SpawnBoxUnitPanel = $.CreatePanel('Image', RootPanel, SPBoxID);
              SpawnBoxUnitPanel.AddClass('SpawnBoxUnitPanel');
            }
            SpawnBoxUnitPanel.SetImage(TransformTextureToPath(playerData.hero, 'icon'));
            SpawnBoxUnitPanel.SetHasClass('hero_selection_hover', playerData.status === 'hover');
            checkedPanels.add(SpawnBoxUnitPanel);
            PlayerSPBoxesTable.add(SpawnBoxUnitPanel);
          }

          for (const panel of PlayerSPBoxesTable) {
            if (!checkedPanels.has(panel)) {
              try {
                panel.DeleteAsync(0);
              } catch (e) {
              } finally {
                PlayerSPBoxesTable.delete(panel);
              }
            }
          }
        }
      }
    });
  });
  UpdateSelectionButton();
}

function $MinimapSpawnBoxes() {
  var vs = $('#MinimapPanel').FindChildrenWithClassTraverse('MinimapSpawnBoxes');
  for (var i = 0; i < vs.length; i++) {
    if (vs[i].BHasClass('only_map_landscape_' + Options.GetMapInfo().landscape)) return vs[i];
  }
}

function OnLocalPlayerPicked() {
  var heroName = LocalPlayerStatus.hero;
  var localHeroData = HeroesData[heroName];
  $('#HeroPreviewName').text = $.Localize(heroName).toUpperCase();
  $('#HeroPreviewLore').text = tryLocalize(`${heroName}_bio`) || '';
  $('#HeroPreviewOverview').text = tryLocalize(`${heroName}_hype`) || '';

  var model = localHeroData.model;
  var heroImageXML =
    '<DOTAScenePanel particleonly="false" ' +
    (localHeroData.useCustomScene
      ? `map="scenes/heroes" camera="${heroName}" />`
      : `allowrotation="true" unit="${model}" />`);
  var ScenePanel = $('#HeroPreviewScene');
  ScenePanel.RemoveAndDeleteChildren();
  ScenePanel.BCreateChildren(heroImageXML);

  $('#HeroPreviewAbilities').RemoveAndDeleteChildren();
  FillAbilitiesUI($('#HeroPreviewAbilities'), localHeroData.abilities, 'HeroPreviewAbility');
  FillAttributeUI($('#HeroPreviewAttributes'), localHeroData.attributes);

  var GlobalLoadoutItems = findDotaHudElement('GlobalLoadoutItems');
  if (GlobalLoadoutItems) {
    GlobalLoadoutItems.SetParent($('#GlobalLoadoutContainer'));
    //Custom styles
    _.each(GlobalLoadoutItems.FindChildrenWithClassTraverse('HasItemsForSlot'), function(child) {
      child.SetParent(GlobalLoadoutItems);
      child.style.width = '180px';
      //child.DeleteAsync(0)
    });
    _.each(GlobalLoadoutItems.FindChildrenWithClassTraverse('GlobalLoadoutSlotCategory'), function(
      child,
    ) {
      child.visible = false;
    });
    if (
      GlobalLoadoutItems.FindChildrenWithClassTraverse('HasItemsForSlot').length === 0 &&
      !GlobalLoadoutItems.FindChildTraverse('GlobalLoadoutItemsArenaMessage')
    ) {
      var label = $.CreatePanel('Label', GlobalLoadoutItems, 'GlobalLoadoutItemsArenaMessage');
      label.text = $.Localize('hero_selection_loadout_items_first_game');
      label.style.fontSize = '22px';
      label.style.align = 'center center';
      label.style.textAlign = 'center';
    }

    // These wearables are useless, hide them
    for (const slot of ['terrain', 'heroic_statue', 'loading_screen']) {
      try {
        GlobalLoadoutItems.FindChildrenWithClassTraverse(`ItemSlot_${slot}`)[0]
          .GetParent()
          .GetParent().visible = false;
      } catch (e) {}
    }
  }
  ToggleHeroPreviewHeroList(true);
}

function ToggleHeroPreviewHeroList(isPreview) {
  $.GetContextPanel().SetHasClass(
    'HeroPreview',
    isPreview != null ? isPreview : !$.GetContextPanel().BHasClass('HeroPreview'),
  );
}

function OnMinimapClickSpawnBox(team, level, index) {
  GameEvents.SendCustomGameEventToServer('hero_selection_minimap_set_spawnbox', {
    team: team,
    level: level,
    index: index,
  });
}

function OnAdsClicked() {
  var context = $.GetContextPanel();
  $.Schedule(context.BHasClass('AdsClicked') ? 0 : 0.35, function() {
    $.DispatchEvent('ExternalBrowserGoToURL', 'https://goo.gl/FJynE1');
  });
  if (!context.BHasClass('AdsClicked')) {
    context.AddClass('AdsClicked');
    Game.EmitSound('General.CoinsBig');
    GameEvents.SendCustomGameEventToServer('on_ads_clicked', {});
  }
}

function StartStrategyTime() {}

function UpdateMainTable(tableName, changesObject, deletionsObject) {
  var newState = changesObject.HeroSelectionState;
  if (newState < HERO_SELECTION_PHASE_END && changesObject.HeroTabs != null) {
    if (HeroesPanels.length === 0 && HeroesData) {
      _.each(changesObject.HeroTabs, function(tabContent, tabKey) {
        var TabHeroesPanel = $.CreatePanel(
          'Panel',
          $('#HeroListPanel'),
          'HeroListPanel_tabPanels_' + tabKey,
        );
        TabHeroesPanel.BLoadLayoutSnippet('HeroesPanel');
        FillHeroesTable(tabContent, TabHeroesPanel);
        TabHeroesPanel.visible = false;
      });
      ListenToBanningPhase();
      SelectHeroTab(1);
    }
  }
  if (newState != null) {
    SetCurrentPhase(newState);
  }
  if (changesObject.TimerEndTime != null) {
    SelectionTimerEndTime = changesObject.TimerEndTime;
  }
}

function SetCurrentPhase(newState) {
  switch (newState) {
    case HERO_SELECTION_PHASE_END:
      HeroSelectionEnd(HeroSelectionState === -1);
      break;
    case HERO_SELECTION_PHASE_STRATEGY:
      $.GetContextPanel().RemoveClass('CanRepick');
      StartStrategyTime();
    case HERO_SELECTION_PHASE_HERO_PICK:
    case HERO_SELECTION_PHASE_BANNING:
      if (!InitializationStates[HERO_SELECTION_PHASE_BANNING]) {
        InitializationStates[HERO_SELECTION_PHASE_BANNING] = true;
        SelectFirstHeroPanel();
      }
  }
  var context = $.GetContextPanel();
  context.SetHasClass('IsInBanPhase', newState === HERO_SELECTION_PHASE_BANNING);
  HeroSelectionState = newState;
  InitializationStates[newState] = true;
  $('#GameModeInfoCurrentPhase').text = $.Localize('hero_selection_phase_' + newState);
  UpdateSelectionButton();
}

function ShowHeroPreviewTab(tabID) {
  _.each($('#TabContents').Children(), function(child) {
    child.SetHasClass('TabVisible', child.id === tabID);
  });
}

(function() {
  $.GetContextPanel().RemoveClass('LocalPlayerPicked');
  var isRussian = $.Language() === 'russian' || $.Language() === 'ukrainian';
  $('#AdsBanner').SetHasClass('Russian', isRussian);
  $('#HeroListPanel').RemoveAndDeleteChildren();
  var localPlayerId = Game.GetLocalPlayerID();
  if (Players.IsValidPlayerID(localPlayerId) && !Players.IsSpectator(localPlayerId)) {
    _DynamicMinimapSubscribe($('#MinimapDynamicIcons'), function(ptid) {
      MinimapPTIDs.push(ptid);
    });
    DynamicSubscribePTListener('hero_selection_available_heroes', UpdateMainTable);
    $.GetContextPanel().SetHasClass('ShowMMR', Options.IsEquals('EnableRatingAffection'));
    var gamemode = Options.GetMapInfo().gamemode;
    if (gamemode === 'custom_abilities')
      gamemode = Options.IsEquals('EnableAbilityShop')
        ? 'ability_shop'
        : Options.IsEquals('EnableRandomAbilities')
        ? 'random_omg'
        : '';
    $('#GameModeInfoGamemodeLabel').text = $.Localize('arena_game_mode_type_' + gamemode);

    if ($.GetContextPanel().PTID_hero_selection)
      PlayerTables.UnsubscribeNetTableListener($.GetContextPanel().PTID_hero_selection);
    DynamicSubscribePTListener('hero_selection', UpdateHeroesSelected, function(ptid) {
      $.GetContextPanel().PTID_hero_selection = ptid;
    });

    DynamicSubscribePTListener('stats_team_rating', function(
      tableName,
      changesObject,
      deletionsObject,
    ) {
      for (var teamNumber in changesObject) {
        $('#team_selection_panels_team' + teamNumber).SetDialogVariable(
          'team_rating',
          changesObject[teamNumber],
        );
      }
    });

    DynamicSubscribePTListener('stats_client', function(tableName, changesObject, deletionsObject) {
      for (var playerId in changesObject) {
        Snippet_PlayerPanel(+playerId).SetDialogVariable(
          'player_mmr',
          changesObject[playerId].Rating || 'TBD',
        );
      }
    });
    UpdateTimer();

    var bglist = Players.GetStatsData(localPlayerId).Backgrounds;
    if (bglist)
      $('#HeroSelectionCustomBackground').SetImage(
        bglist[Math.floor(Math.random() * bglist.length)],
      );
  } else {
    HeroSelectionEnd(true);
  }
})();
