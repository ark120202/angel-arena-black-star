var groupLevelMap = [];
var TalentsInfo = {};

function LoadTalentTable(table) {
  _.each(table, function(group, group_index) {
    var grouppanel = $.CreatePanel(
      'Panel',
      $('#TalentListContainer'),
      'talent_group_' + group_index,
    );
    grouppanel.BLoadLayoutSnippet('TalentColumn');
    grouppanel.FindChildTraverse('TalentColumnHeader').text = groupLevelMap[group_index];
    grouppanel.RequiredLevel = groupLevelMap[group_index];
    _.each(group, function(talent) {
      CreateTalent(talent, grouppanel.FindChildTraverse('TalentColumnInner'));
    });
  });
}

const formatTalentSpecialValues = (values, level, percent) =>
  Object.values(values)
    .map((value, index) => {
      const formatted = percent ? value + '%' : value;
      return index + 1 === level ? "<font color='gold'>" + formatted + '</font>' : formatted;
    })
    .join('/');

function getTalentTitle(talent) {
  if (!talent.name.startsWith('special_bonus_unique_')) {
    return $.Localize('custom_talents_' + talent.name);
  }

  const rawToken = $.Localize('DOTA_Tooltip_ability_' + talent.name, $.GetContextPanel());
  return rawToken.replace(/\[!s:(.+)\]%?/g, (match, specialName) =>
    match.endsWith('%') ? `{%${specialName}%}` : `{${specialName}}`,
  );
}

function CreateTalent(talent, root) {
  var panel = $.CreatePanel('Image', root, 'talent_icon_' + talent.name);
  panel.AddClass('TalentIcon');
  panel.SetImage(TransformTextureToPath(talent.icon, 'icon'));
  var CreateTooltip = function() {
    const talentLevel = GetTalentLevel(
      Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID()),
      talent.name,
    );

    let title = getTalentTitle(talent);
    let description = tryLocalize(`custom_talents_${talent.name}_description`);
    for (const [key, values] of Object.entries(talent.special_values || {})) {
      title = title
        .replace(`{${key}}`, formatTalentSpecialValues(values, talentLevel))
        .replace(`{%${key}%}`, formatTalentSpecialValues(values, talentLevel, true));

      if (description) {
        description = description
          .replace(`{${key}}`, formatTalentSpecialValues(values, talentLevel))
          .replace(`{%${key}%}`, formatTalentSpecialValues(values, talentLevel, true));
      }
    }

    title = title.replace('+', '%2B');
    if (description) description = description.replace('+', '%2B');

    var params =
      'title=' +
      title +
      '&description=' +
      description +
      '&cost=' +
      talent.cost +
      '&requirements=' +
      talent.requirement +
      '&levelText=' +
      $.Localize('custom_talents_level') +
      talentLevel +
      '/' +
      (talent.max_level || 1);

    $.DispatchEvent(
      'UIShowCustomLayoutParametersTooltip',
      panel,
      'TalentTooltip',
      'file://{resources}/layout/custom_game/custom_talent_tooltip.xml',
      params,
    );
  };
  panel.SetPanelEvent('onmouseover', CreateTooltip);
  panel.SetPanelEvent('onmouseout', function() {
    $.DispatchEvent('UIHideCustomLayoutTooltip', panel, 'TalentTooltip');
  });
  panel.SetPanelEvent('onactivate', function() {
    if (panel.BHasClass('CanLearn')) {
      GameEvents.SendCustomGameEventToServer('custom_talents_upgrade', {
        talent: talent.name,
      });

      $.DispatchEvent('UIHideCustomLayoutTooltip', panel, 'TalentTooltip');
      $.Schedule(0.1, function() {
        if (panel.BHasHoverStyle()) CreateTooltip();
      });
    }
  });
  TalentsInfo[talent.name] = talent;
}

function GetTalentLevel(unit, talent) {
  var t = GameUI.CustomUIConfig().custom_entity_values[unit];
  if (t != null && t.LearntTalents != null && t.LearntTalents[talent] != null)
    return t.LearntTalents[talent].level;
  return 0;
}

function GetActualTalentGroup(unit) {
  var t = GameUI.CustomUIConfig().custom_entity_values[unit];
  var highest = 0;
  if (t != null && t.LearntTalents != null && TalentsInfo != null) {
    for (var k in t.LearntTalents) {
      var level = t.LearntTalents[k].level;
      var group = TalentsInfo[k].group;
      highest = group > highest ? group : highest;
    }
  }
  return highest;
}

function Update() {
  $.Schedule(0.35, Update);
  var unit = Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID());
  var points = Entities.GetAbilityPoints(unit);
  $('#AbilityPointsLabel').text = points;
  _.each($('#TalentListContainer').Children(), function(group, group_index) {
    var CompletedGroup = true;
    var GroupAvaliable =
      Entities.GetLevel(unit) >= group.RequiredLevel && group_index <= GetActualTalentGroup(unit);
    _.each(group.FindChildTraverse('TalentColumnInner').Children(), function(icon) {
      var tn = icon.id.replace('talent_icon_', '');

      var Error_Requirement = false;
      if (TalentsInfo[tn].requirement) {
        var requirement = TalentsInfo[tn].requirement;
        Error_Requirement = IsHeroName(requirement)
          ? GetHeroName(unit) !== requirement
          : Entities.GetAbilityByName(unit, requirement) === -1;
      }
      var Error_Points = points < TalentsInfo[tn].cost;
      var level = GetTalentLevel(unit, tn);
      var Learnt = level === (Number(TalentsInfo[tn].max_level) || 1);
      icon.SetHasClass('Error_Requirement', Error_Requirement);
      icon.SetHasClass('Error_Points', Error_Points);
      icon.SetHasClass('Learnt', Learnt);
      icon.SetHasClass(
        'CanLearn',
        !Learnt && !Error_Requirement && !Error_Points && GroupAvaliable,
      );
      icon.SetHasClass('Selected', level > 0);
      if (icon.visible && !icon.BHasClass('Learnt')) CompletedGroup = false;
    });
    group.SetHasClass('CompletedColumn', CompletedGroup);
    group.SetHasClass('EnabledColumn', !CompletedGroup && GroupAvaliable);
  });
}

(function() {
  $('#TalentListContainer').RemoveAndDeleteChildren();
  CustomHooks.custom_talents_toggle_tree.tap(function() {
    $.GetContextPanel().ToggleClass('PanelOpened');
  });
  DynamicSubscribePTListener('custom_talents_data', (_name, changesObject) => {
    groupLevelMap = changesObject.groupLevelMap;
    LoadTalentTable(changesObject.talentList);
  });
  $('#ToggleHideRequirementErrors').checked = true;
  Update();
  Game.DisableWheelPanels.push($('#TalentsBase'));
})();
