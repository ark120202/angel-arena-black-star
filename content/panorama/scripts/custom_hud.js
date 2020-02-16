const ONCLICK_PURGABLE_MODIFIERS = new Set([
  'modifier_doppelganger_mimic',
  'modifier_tether_ally_aghanims',
]);

var BossDropVoteTimers = [],
  HookedAbilityPanelsCount = 0;

const goldLabel = FindDotaHudElement('ShopButton').FindChildTraverse('GoldLabel');
const abilitiesPanel = FindDotaHudElement('abilities');
const minimapBlock = FindDotaHudElement('minimap_block');
const portraitContainer = FindDotaHudElement('PortraitContainer');
const chatLinesPanel = FindDotaHudElement('ChatLinesPanel');
const levelStatsFrame = FindDotaHudElement('level_stats_frame');
const dynamicMinimapRoot = $('#DynamicMinimapRoot');
const customModifiersList = $('#CustomModifiersList');
function updatePanoramaHacks() {
  $.Schedule(0.2, updatePanoramaHacks);
  const unit = Players.GetLocalPlayerPortraitUnit();
  const seenPurgableBuffs = new Set();
  for (let i = 0; i < Entities.GetNumBuffs(unit); ++i) {
    const buffId = Entities.GetBuff(unit, i);
    if (buffId === -1) continue;

    const buffName = Buffs.GetName(unit, buffId);
    seenPurgableBuffs.add(buffName);
    if (!ONCLICK_PURGABLE_MODIFIERS.has(buffName)) continue;
    if (customModifiersList.FindChildTraverse(buffName)) continue;

    const panel = $.CreatePanel('DOTAAbilityImage', customModifiersList, buffName);
    panel.abilityname = Buffs.GetTexture(unit, buffId);
    panel.SetPanelEvent('onactivate', () => {
      GameEvents.SendCustomGameEventToServer('modifier_clicked_purge', {
        unit,
        modifier: buffName,
      });
    });
    panel.SetPanelEvent('onmouseover', () => {
      $.DispatchEvent(
        'DOTAShowTitleTextTooltip',
        panel,
        $.Localize(`DOTA_Tooltip_${buffName}`),
        $.Localize('hud_modifier_click_to_remove'),
      );
    });
    panel.SetPanelEvent('onmouseout', () => {
      $.DispatchEvent('DOTAHideTitleTextTooltip', panel);
    });
  }

  for (const child of customModifiersList.Children()) {
    if (!seenPurgableBuffs.has(child.id)) {
      child.DeleteAsync(0);
    }
  }

  const playerTeam = Players.GetTeam(Game.GetLocalPlayerID());
  UpdateGoldLabel(playerTeam, unit, goldLabel);

  const screenWidth = Game.GetScreenWidth();
  const screenHeight = Game.GetScreenHeight();

  dynamicMinimapRoot.style.width = (minimapBlock.contentwidth / screenWidth) * 100 + '%';
  dynamicMinimapRoot.style.height = (minimapBlock.contentheight / screenHeight) * 100 + '%';

  const portraitPosition = portraitContainer.GetPositionWithinWindow();
  if (!Number.isNaN(portraitPosition.x) && !Number.isNaN(portraitPosition.y)) {
    customModifiersList.style.x = `${(portraitPosition.x / screenWidth) * 100}%`;
    customModifiersList.style.y = `${(portraitPosition.y / screenHeight) * 100}%`;
  }

  if (HookedAbilityPanelsCount !== abilitiesPanel.GetChildCount()) {
    HookedAbilityPanelsCount = abilitiesPanel.GetChildCount();
    _.each(abilitiesPanel.Children(), function(child, index) {
      child.FindChildTraverse('AbilityButton').SetPanelEvent('onactivate', () => {
        if (GameUI.IsAltDown()) {
          var unit = Players.GetLocalPlayerPortraitUnit();
          GameEvents.SendCustomGameEventToServer('custom_chat_send_message', {
            ability: GetVisibleAbilityInSlot(unit, index),
          });
        }
      });
    });
  }

  // Chat redirect
  var redirectedPhrases = [
    $.Localize('DOTA_Chat_CantPause'),
    $.Localize('DOTA_Chat_NoPausesLeft'),
    $.Localize('DOTA_Chat_CantPauseYet'),
    $.Localize('DOTA_Chat_PauseCountdown'),
    $.Localize('DOTA_Chat_Paused'),
    $.Localize('DOTA_Chat_UnpauseCountdown'),
    $.Localize('DOTA_Chat_Unpaused'),
    $.Localize('DOTA_Chat_AutoUnpaused'),
    $.Localize('DOTA_Chat_YouPaused'),
    $.Localize('DOTA_Chat_CantUnpauseTeam'),
  ];
  // TODO: Doesn't work
  var escaped = _.escapeRegExp(
    redirectedPhrases
      .map(function(x) {
        return $.Localize(x).replace(/%s\d/g, '.*');
      })
      .join('|'),
  );
  var regexp = new RegExp('^(' + escaped + ')$');
  for (var i = 0; i < chatLinesPanel.GetChildCount(); i++) {
    var child = chatLinesPanel.GetChild(i);
    if (child.text && child.text.match(regexp)) {
      RedirectMessage(child);
    }
  }
}

function UpdateGoldLabel(playerTeam, unit, label) {
  if (playerTeam === Entities.GetTeamNumber(unit)) {
    var ownerId = Entities.GetPlayerOwnerID(unit);
    label.text = FormatGold(GetPlayerGold(ownerId === -1 ? Game.GetLocalPlayerID() : ownerId));
  } else {
    label.text = '';
  }
}

function applyPanoramaHacks() {
  FindDotaHudElement('QuickBuyRows').visible = false;
  FindDotaHudElement('shop').visible = false;
  FindDotaHudElement('HUDSkinMinimap').visible = false;
  FindDotaHudElement('combat_events').visible = false;
  FindDotaHudElement('ChatEmoticonButton').visible = false;
  FindDotaHudElement('topbar').visible = false;
  FindDotaHudElement('DeliverItemsButton').style.horizontalAlign = 'right';
  FindDotaHudElement('LevelLabel').style.width = '100%';
  FindDotaHudElement('stash').style.marginBottom = '47px';

  const shopButton = FindDotaHudElement('ShopButton');
  const statBranch = FindDotaHudElement('StatBranch');
  const chatLinesWrapper = FindDotaHudElement('ChatLinesWrapper');
  const statsLevelUpTab = levelStatsFrame.FindChildTraverse('LevelUpTab');

  shopButton.FindChildTraverse('BuybackHeader').visible = false;
  shopButton.ClearPanelEvent('onactivate');
  shopButton.ClearPanelEvent('onmouseover');
  shopButton.ClearPanelEvent('onmouseout');
  shopButton.SetPanelEvent('onactivate', function() {
    if (GameUI.IsAltDown()) {
      GameEvents.SendCustomGameEventToServer('custom_chat_send_message', {
        GoldUnit: Players.GetLocalPlayerPortraitUnit(),
      });
    } else {
      CustomHooks.panorama_shop_open_close.call();
    }
  });

  statBranch.ClearPanelEvent('onactivate');
  statBranch.ClearPanelEvent('onmouseover');
  statBranch.ClearPanelEvent('onmouseout');
  statBranch.hittestchildren = false;

  levelStatsFrame.ClearPanelEvent('onmouseover');
  statsLevelUpTab.ClearPanelEvent('onmouseover');
  statsLevelUpTab.ClearPanelEvent('onmouseout');
  statsLevelUpTab.ClearPanelEvent('onactivate');
  statsLevelUpTab.SetPanelEvent('onactivate', function() {
    CustomHooks.custom_talents_toggle_tree.call();
  });

  var debugChat = false;
  chatLinesWrapper.FindChildTraverse('ChatLinesPanel').visible = debugChat;
  if (chatLinesWrapper.FindChildTraverse('CustomChatContainer')) {
    chatLinesWrapper.FindChildTraverse('CustomChatContainer').DeleteAsync(0);
  }

  const chatContainer = $.CreatePanel('Panel', chatLinesWrapper, 'CustomChatContainer');
  chatContainer.visible = !debugChat;
  chatContainer.hittest = false;
  chatContainer.hittestchildren = false;
  AddStyle(chatContainer, {
    width: '100%',
    'flow-children': 'down',
    'vertical-align': 'top',
    overflow: 'squish noclip',
    'padding-right': '14px',
    'background-color':
      'gradient( linear, 0% 0%, 100% 0%, from( #0000 ), color-stop( 0.01, #0000 ), color-stop( 0.1, #0000 ), to( #0000 ) )',
    'transition-property': 'background-color',
    'transition-duration': '0.23s',
    'transition-timing-function': 'ease-in-out',
  });
  setCustomChatContainer(chatContainer);

  const statsTooltipRegion = FindDotaHudElement('stats_tooltip_region');
  statsTooltipRegion.SetPanelEvent('onmouseout', () => {
    $.DispatchEvent('DOTAHUDHideDamageArmorTooltip');
  });
  statsTooltipRegion.SetPanelEvent('onmouseover', () => {
    $.DispatchEvent('DOTAHUDShowDamageArmorTooltip', statsTooltipRegion);

    const unit = Players.GetLocalPlayerPortraitUnit();
    const customValues = Entities.GetNetworkableEntityInfo(unit);
    const tooltip = FindDotaHudElement('DOTAHUDDamageArmorTooltip');
    if (!tooltip || !customValues) return;

    const attackRate =
      customValues.AttackRate != null ? customValues.AttackRate : Entities.GetBaseAttackTime(unit);
    const batModifier = attackRate / Entities.GetBaseAttackTime(unit);
    const secondsPerAttack = Entities.GetSecondsPerAttack(unit) * batModifier;
    tooltip.SetDialogVariable('seconds_per_attack', '(' + secondsPerAttack.toFixed(2) + 's)');

    // https://dota2.gamepedia.com/Attack_speed#Attack_speed_representation
    const attackSpeedTooltip = Entities.GetAttackSpeed(unit) * 100 * (1.7 / attackRate);
    tooltip.SetDialogVariableInt('base_attack_speed', Math.round(attackSpeedTooltip));

    for (const { key, variable } of [
      { key: 'IdealArmor', variable: 'agility_armor' },
      { key: 'AgilityCriticalDamage', variable: 'agility_critical_damage' },
      { key: 'AttributeStrengthGain', variable: 'strength_per_level' },
      { key: 'AttributeAgilityGain', variable: 'agility_per_level' },
      { key: 'AttributeIntelligenceGain', variable: 'intelligence_per_level' },
    ]) {
      if (customValues[key] != null) {
        tooltip.SetDialogVariable(variable, customValues[key].toFixed(1));
      }
    }

    for (const { id, label } of [
      { id: 'StrengthDetails', label: '#arena_hud_tooltip_details_strength' },
      { id: 'AgilityDetails', label: '#arena_hud_tooltip_details_agility' },
      { id: 'IntelligenceDetails', label: '#arena_hud_tooltip_details_intelligence' },
    ]) {
      const panel = tooltip.FindChildTraverse(id);
      panel.style.textOverflow = 'shrink';
      panel.text = $.Localize(label, tooltip);
    }
  });

  const InventoryContainer = FindDotaHudElement('InventoryContainer');
  _.each(InventoryContainer.FindChildrenWithClassTraverse('InventoryItem'), (child, index) => {
    child.FindChildTraverse('AbilityButton').SetPanelEvent('onactivate', () => {
      const item = Entities.GetItemInSlot(Players.GetLocalPlayerPortraitUnit(), index);
      if (item === -1) return;

      if (GameUI.IsAltDown()) {
        GameEvents.SendCustomGameEventToServer('custom_chat_send_message', { ability: item });
      } else {
        CustomHooks.panorama_shop_show_item_if_open.call(Abilities.GetAbilityName(item));
        const unit = Players.GetLocalPlayerPortraitUnit();
        if (Entities.IsControllableByPlayer(unit, Game.GetLocalPlayerID())) {
          Abilities.ExecuteAbility(item, unit, false);
        }
      }
    });
  });

  var xpRoot = FindDotaHudElement('xp');
  for (const panel of [
    xpRoot.FindChildTraverse('LevelBackground'),
    xpRoot.FindChildTraverse('CircularXPProgress'),
    xpRoot.FindChildTraverse('XPProgress'),
  ]) {
    panel.SetPanelEvent('onactivate', function() {
      if (GameUI.IsAltDown()) {
        GameEvents.SendCustomGameEventToServer('custom_chat_send_message', {
          xpunit: Players.GetLocalPlayerPortraitUnit(),
        });
      }
    });
  }
}

DynamicSubscribeNTListener('custom_entity_values', OnUpdateSelectedUnit);
GameEvents.Subscribe('dota_player_update_selected_unit', OnUpdateSelectedUnit);
GameEvents.Subscribe('dota_player_update_query_unit', OnUpdateSelectedUnit);
function OnUpdateSelectedUnit() {
  const unitName = GetHeroName(Players.GetLocalPlayerPortraitUnit());
  FindDotaHudElement('UnitNameLabel').text = $.Localize(unitName).toUpperCase();
  OnSkillPoint();
}

GameEvents.Subscribe('dota_player_gained_level', OnSkillPoint);
GameEvents.Subscribe('dota_player_learned_ability', OnSkillPoint);
function OnSkillPoint() {
  const unit = Players.GetLocalPlayerPortraitUnit();
  const canLevelStats =
    Entities.GetAbilityPoints(unit) > 0 &&
    Entities.IsControllableByPlayer(unit, Game.GetLocalPlayerID());

  // levelStatsFrame resets `CanLevelStats` class every frame
  levelStatsFrame.GetParent().SetHasClass('CanLevelStats', canLevelStats);
  levelStatsFrame.visible = canLevelStats;
}

const killedByHeroName = FindDotaHudElement('KilledByHeroName');
GameEvents.Subscribe('entity_killed', event => {
  if (event.entindex_killed === Game.GetLocalPlayerInfo().player_selected_hero_entity_index) {
    const killerOwner = Entities.GetPlayerOwnerID(event.entindex_attacker);
    const attacker = Players.IsValidPlayerID(killerOwner)
      ? Game.GetPlayerInfo(killerOwner).player_selected_hero_entity_index
      : event.entindex_attacker;

    killedByHeroName.text = $.Localize(GetHeroName(attacker)).toUpperCase();
  }
});

GameEvents.Subscribe('create_custom_toast', CreateCustomToast);
function CreateCustomToast(data) {
  var row = $.CreatePanel('Panel', $('#CustomToastManager'), '');
  row.BLoadLayoutSnippet('ToastPanel');
  row.AddClass('ToastPanel');
  var rowText = '';

  if (data.type === 'kill') {
    var byNeutrals = data.killerPlayer == null;
    var isSelfKill = data.victimPlayer === data.killerPlayer;
    var isAllyKill =
      !byNeutrals &&
      data.victimPlayer != null &&
      Players.GetTeam(data.victimPlayer) === Players.GetTeam(data.killerPlayer);
    var isVictim = data.victimPlayer === Game.GetLocalPlayerID();
    var isKiller = data.killerPlayer === Game.GetLocalPlayerID();
    var teamVictim =
      byNeutrals || Players.GetTeam(data.victimPlayer) === Players.GetTeam(Game.GetLocalPlayerID());
    var teamKiller =
      !byNeutrals &&
      Players.GetTeam(data.killerPlayer) === Players.GetTeam(Game.GetLocalPlayerID());
    row.SetHasClass('AllyEvent', teamKiller);
    row.SetHasClass('EnemyEvent', byNeutrals || !teamKiller);
    row.SetHasClass('LocalPlayerInvolved', isVictim || isKiller);
    row.SetHasClass('LocalPlayerKiller', isKiller);
    row.SetHasClass('LocalPlayerVictim', isVictim);
    if (isKiller) Game.EmitSound('notification.self.kill');
    else if (isVictim) Game.EmitSound('notification.self.death');
    else if (teamKiller) Game.EmitSound('notification.teammate.kill');
    else if (teamVictim) Game.EmitSound('notification.teammate.death');
    if (isSelfKill) {
      Game.EmitSound('notification.self.kill');
      rowText = $.Localize('custom_toast_PlayerDeniedSelf');
    } else if (isAllyKill) {
      rowText = $.Localize('#custom_toast_PlayerDenied');
    } else {
      if (byNeutrals) {
        rowText = $.Localize('#npc_dota_neutral_creep');
      } else {
        rowText = '{killer_name}';
      }
      rowText = rowText + ' {killed_icon} {victim_name} {gold}';
    }
  } else if (data.type === 'generic') {
    if (data.teamPlayer != null || data.teamColor != null) {
      var team = data.teamPlayer == null ? data.teamColor : Players.GetTeam(data.teamPlayer);
      var teamVictim = team === Players.GetTeam(Game.GetLocalPlayerID());
      if (data.teamInverted === 1) teamVictim = !teamVictim;
      row.SetHasClass('AllyEvent', teamVictim);
      row.SetHasClass('EnemyEvent', !teamVictim);
    } else row.AddClass('AllyEvent');
    rowText = $.Localize(data.text);
  }

  rowText = rowText
    .replace('{denied_icon}', "<img class='DeniedIcon'/>")
    .replace('{killed_icon}', "<img class='CombatEventKillIcon'/>")
    .replace(
      '{time_dota}',
      "<font color='lime'>" + secondsToMS(Game.GetDOTATime(false, false), true) + '</font>',
    );
  if (data.player != null)
    rowText = rowText.replace('{player_name}', CreateHeroElements(data.player));
  if (data.victimPlayer != null)
    rowText = rowText.replace('{victim_name}', CreateHeroElements(data.victimPlayer));
  if (data.killerPlayer != null) {
    rowText = rowText.replace('{killer_name}', CreateHeroElements(data.killerPlayer));
  }
  if (data.victimUnitName)
    rowText = rowText.replace(
      '{victim_name}',
      "<font color='red'>" + $.Localize(data.victimUnitName) + '</font>',
    );
  if (data.team != null)
    rowText = rowText.replace(
      '{team_name}',
      "<font color='" +
        GameUI.CustomUIConfig().team_colors[data.team] +
        "'>" +
        GameUI.CustomUIConfig().team_names[data.team] +
        '</font>',
    );
  if (data.gold != null)
    rowText = rowText.replace(
      '{gold}',
      "<font color='gold'>" + FormatGold(data.gold) + "</font> <img class='CombatEventGoldIcon' />",
    );
  if (data.runeType != null)
    rowText = rowText.replace(
      '{rune_name}',
      "<font color='#" +
        RUNES_COLOR_MAP[data.runeType] +
        "'>" +
        $.Localize('custom_runes_rune_' + data.runeType + '_title') +
        '</font>',
    );
  if (data.variables)
    for (var k in data.variables) {
      rowText = rowText.replace(k, $.Localize(data.variables[k]));
    }
  if (rowText.indexOf('<img') === -1) row.AddClass('SimpleText');
  row.FindChildTraverse('ToastLabel').text = rowText;
  $.Schedule(10, function() {
    row.AddClass('Collapsed');
  });
  row.DeleteAsync(10.3);
}

function CreateHeroElements(id) {
  var playerColor = GetHEXPlayerColor(id);
  return (
    "<img src='" +
    TransformTextureToPath(GetPlayerHeroName(id), 'icon') +
    "' class='CombatEventHeroIcon'/> <font color='" +
    playerColor +
    "'>" +
    _.escape(Players.GetPlayerName(id)) +
    '</font>'
  );
}

_DynamicMinimapSubscribe($('#DynamicMinimapRoot'));

const { landscape, gamemode } = Options.GetMapInfo();
hud.AddClass(`map_landscape_${landscape}`);
hud.AddClass(`map_gamesome_${gamemode}`);

$.GetContextPanel().SetHasClass('ShowMMR', Options.IsEquals('EnableRatingAffection'));
DynamicSubscribePTListener('players_abandoned', (_name, changes) => {
  if (changes[Game.GetLocalPlayerID()]) {
    $.GetContextPanel().AddClass('LocalPlayerAbandoned');
  }
});

applyPanoramaHacks();
updatePanoramaHacks();
