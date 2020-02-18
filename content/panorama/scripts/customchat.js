'use strict';

let customChatContainer = $('#SelectionChatMessages');
function setCustomChatContainer(panel) {
  customChatContainer = panel;
}

function ChatSendMessage() {
  if ($('#SelectionChatEntry').text.length > 0) {
    GameEvents.SendCustomGameEventToServer('custom_chat_send_message', {
      text: $('#SelectionChatEntry').text,
      teamOnly: true,
    });
    $('#SelectionChatEntry').text = '';
  }
}

function withPlayerColor(playerId, content) {
  const color = GetHEXPlayerColor(playerId, '#FFFFFF');
  return `<font color='${color}'>${content}</font>`;
}

const formatChatPlayerName = playerId =>
  withPlayerColor(playerId, _.escape(Players.GetPlayerName(playerId)));

const formatChatPlayerHeroName = playerId =>
  withPlayerColor(playerId, $.Localize(GetPlayerHeroName(playerId)));

function formatChatPlayerNameAndHeroName(playerId) {
  const heroName = $.Localize(GetPlayerHeroName(playerId));
  const playerName = _.escape(Players.GetPlayerName(playerId));
  return withPlayerColor(playerId, `${playerName} (${heroName})`);
}

function RecieveMessage(data) {
  const { playerId } = data;
  if (playerId == null || Game.IsPlayerMuted(playerId)) return;

  let html = '';
  if (playerId !== -1) {
    const senderHero = GetPlayerHeroName(playerId);
    if (senderHero && senderHero !== 'npc_dota_hero_target_dummy') {
      const imagePath = TransformTextureToPath(senderHero);
      html = `<img src="${imagePath}" class="HeroIcon" style="vertical-align: top;"/> `;
    }

    html += `<font color=${data.teamonly === 1 ? '"lime">[A]' : '"darkred">[A]'}</font>`;
    html += ' ';
    html += formatChatPlayerName(playerId);
    html += ': ';
  }

  if (data.text) {
    html += AddSmiles(_.escape(String(data.text)));
  } else if (data.gold != null && data.player != null) {
    html += "<img src='file://{images}/control_icons/chat_wheel_icon.png' class='ChatWheelIcon' />";
    var localized = $.Localize(
      data.player === playerId ? 'chat_message_gold_self' : 'chat_message_gold_ally',
    );
    localized = localized.replace(
      '{gold}',
      '<font color="gold">' + FormatGold(data.gold) + '</font>',
    );
    localized = localized.replace('{player}', formatChatPlayerHeroName(data.player));
    html += localized;
  } else if (data.ability && data.player != null && data.unit) {
    html += '<img src="file://{images}/control_icons/chat_wheel_icon.png" class="ChatWheelIcon" />';
    let localized;
    const cooldown = Abilities.GetCooldownTimeRemaining(data.ability);
    if (Players.GetTeam(data.player) === Players.GetTeam(playerId)) {
      if (Abilities.GetLevel(data.ability) === 0) {
        localized = 'chat_message_ability_not_learned';
      } else if (!Abilities.IsOwnersManaEnough(data.ability)) {
        localized = 'chat_message_ability_mana';
      } else if (cooldown > 0) {
        localized = 'chat_message_ability_cooldown';
      } else if (Abilities.IsPassive(data.ability)) {
        localized = 'chat_message_ability_passive';
      } else {
        localized = 'chat_message_ability_ready';
      }
      if (data.player !== playerId) {
        localized = localized.replace('chat_message_ability_', 'chat_message_ability_ally_');
      }
    } else {
      localized = 'chat_message_ability_enemy';
    }
    if (
      Abilities.IsItem(data.ability) &&
      Abilities.GetLevel(data.ability) === 1 &&
      (localized.endsWith('_passive') ||
        localized.endsWith('_ready') ||
        localized.endsWith('_enemy'))
    ) {
      localized = localized.replace('chat_message_ability_', 'chat_message_item_');
    }
    localized = $.Localize(localized);
    localized = localized.replace('{ability_level}', Abilities.GetLevel(data.ability));
    localized = localized.replace(
      '{ability_name}',
      $.Localize(`DOTA_Tooltip_ability_${Abilities.GetAbilityName(data.ability)}`),
    );
    localized = localized.replace('{ability_cooldown}', cooldown.toFixed(0));
    localized = localized.replace(
      '{mana_need}',
      Math.round(Abilities.GetManaCost(data.ability) - Entities.GetMana(data.unit)),
    );
    localized = localized.replace('{player}', formatChatPlayerHeroName(data.player));
    html += localized;
  } else if (data.shop_item_name) {
    html += '<img src="file://{images}/control_icons/chat_wheel_icon.png" class="ChatWheelIcon" />';
    var localized = data.boss_drop
      ? 'chat_message_shop_purchase_boss'
      : data.stock_time != null
      ? 'chat_message_shop_purchase_no_stock'
      : data.gold != null
      ? data.isQuickbuy
        ? 'chat_message_shop_purchase_quickbuy_no_gold'
        : 'chat_message_shop_purchase_no_gold'
      : data.isQuickbuy
      ? 'chat_message_shop_purchase_quickbuy'
      : 'chat_message_shop_purchase';

    localized = $.Localize(localized);
    localized = localized.replace(
      '{item_name}',
      $.Localize(`DOTA_Tooltip_ability_${data.shop_item_name}`),
    );
    localized = localized.replace('{gold}', data.gold);
    localized = localized.replace('{stock_time}', data.stock_time);
    html += localized;
  } else if (data.level) {
    html += '<img src="file://{images}/control_icons/chat_wheel_icon.png" class="ChatWheelIcon" />';

    const unitSide =
      data.unit === Players.GetPlayerHeroEntityIndex(playerId)
        ? 'self'
        : Entities.GetTeamNumber(data.unit) === Players.GetTeam(playerId)
        ? 'ally'
        : 'enemy';

    let localized = $.Localize(
      data.xpToNextLevel == null && !data.isNeutral
        ? `chat_message_level_${unitSide}_capped`
        : `chat_message_level_${unitSide}`,
    );

    localized = localized.replace('{level_next}', data.level + 1);
    localized = localized.replace('{level}', data.level);
    localized = localized.replace('{xp}', data.xpToNextLevel);
    const color = GetHEXPlayerColor(data.player, '#FFFFFF');
    const unitName = $.Localize(GetHeroName(data.unit));
    localized = localized.replace('{player}', `<font color='${color}'>${unitName}</font>`);
    html += localized;
  } else if (data.localizable) {
    let localized = $.Localize(data.localizable);

    for (const [name, value] of Object.entries(data.variables || {})) {
      localized = localized.replace(name, $.Localize(value));
    }

    localized = localized.replace(/{player:(\d+)}/g, (_, playerId) =>
      formatChatPlayerName(Number(playerId)),
    );

    html += localized;
  }

  const lastLine = customChatContainer.GetChild(0);
  const messageLabel = $.CreatePanel('Label', customChatContainer, '');
  messageLabel.AddClass('ChatLine');
  messageLabel.style.transform = 'scaleY(-1)';
  messageLabel.html = true;
  $.Schedule(7.5, () => messageLabel.AddClass('Expired'));
  if (lastLine) customChatContainer.MoveChildBefore(messageLabel, lastLine);
  messageLabel.text = html;
}

// https://github.com/SteamDatabase/GameTracking-Dota2/blob/200e7073953e08e11fa582dc216a5fc4acc2179d/Protobufs/dota_usermessages.proto#L142
const pauseMessages = {
  31: 'DOTA_Chat_CantPause',
  32: 'DOTA_Chat_NoPausesLeft',
  33: 'DOTA_Chat_CantPauseYet',
  34: 'DOTA_Chat_Paused',
  35: 'DOTA_Chat_UnpauseCountdown',
  36: 'DOTA_Chat_Unpaused',
  37: 'DOTA_Chat_AutoUnpaused',
  38: 'DOTA_Chat_YouPaused',
  39: 'DOTA_Chat_CantUnpauseTeam',
};

GameEvents.Subscribe('dota_pause_event', event => {
  const token = pauseMessages[event.message];
  if (!token) return;

  RecieveMessage({
    playerId: -1,
    localizable: token,
    variables: { '%s1': formatChatPlayerNameAndHeroName(event.value) },
  });
});

var twitchRegExp = new RegExp(
  '\\b(' +
    Object.keys(twitchSmileMap)
      .map(_.escapeRegExp)
      .join('|') +
    ')\\b',
  'g',
);
var bttvRegExp = new RegExp(
  '\\b(' +
    Object.keys(bttvSmileMap)
      .map(_.escapeRegExp)
      .join('|') +
    ')\\b',
  'g',
);
function AddSmiles(string) {
  return string
    .replace(twitchRegExp, m => `<img src='${twitchUrlMask.replace('{id}', twitchSmileMap[m])}'/>`)
    .replace(bttvRegExp, m => `<img src='${bttvUrlMask.replace('{id}', bttvSmileMap[m])}'/>`);
}

(function() {
  GameEvents.Subscribe('custom_chat_recieve_message', RecieveMessage);
})();
