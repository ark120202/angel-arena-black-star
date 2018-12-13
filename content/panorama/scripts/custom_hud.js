var ONCLICK_PURGABLE_MODIFIERS = [
	'modifier_doppelganger_mimic',
	'modifier_tether_ally_aghanims'
];
var CustomChatLinesPanel,
	BossDropVoteTimers = [],
	HookedAbilityPanelsCount = 0;

function UpdatePanoramaHUD() {
	var unit = Players.GetLocalPlayerPortraitUnit();
	var queryUnit = Players.GetQueryUnit(Players.GetLocalPlayer());
	var unitName = GetHeroName(unit);
	var CustomModifiersList = $('#CustomModifiersList');
	var VisibleModifiers = [];
	for (var i = 0; i < Entities.GetNumBuffs(unit); ++i) {
		var buffSerial = Entities.GetBuff(unit, i);
		if (buffSerial !== -1) {
			var buffName = Buffs.GetName(unit, buffSerial);
			VisibleModifiers.push(buffName);
			if (ONCLICK_PURGABLE_MODIFIERS.indexOf(buffName) !== -1) {
				if (CustomModifiersList.FindChildTraverse(buffName) == null) {
					var panel = $.CreatePanel('DOTAAbilityImage', CustomModifiersList, buffName);
					panel.abilityname = Buffs.GetTexture(unit, buffSerial);
					panel.SetPanelEvent('onactivate', (function(_buffName) {
						return function() {
							GameEvents.SendCustomGameEventToServer('modifier_clicked_purge', {
								unit: unit,
								modifier: _buffName
							});
						};
					})(buffName));
					panel.SetPanelEvent('onmouseover', (function(_panel, _buffName) {
						return function() {
							$.DispatchEvent('DOTAShowTitleTextTooltip', _panel, $.Localize('DOTA_Tooltip_' + _buffName), $.Localize('hud_modifier_click_to_remove'));
						};
					})(panel, buffName));
					panel.SetPanelEvent('onmouseout', (function(_panel) {
						return function() {
							$.DispatchEvent('DOTAHideTitleTextTooltip', _panel);
						};
					})(panel));
				}
			}
		}
	}

	_.each(CustomModifiersList.Children(), function(child) {
		if (VisibleModifiers.indexOf(child.id) === -1) child.DeleteAsync(0);
	});

	var GoldLabel = FindDotaHudElement('ShopButton').FindChildTraverse('GoldLabel');
	var QueryGoldLabel = FindDotaHudElement('QueryUnit').FindChildTraverse('GoldLabel');
	var playerTeam = Players.GetTeam(Game.GetLocalPlayerID());
	UpdateGoldLabel(playerTeam, unit, GoldLabel);
	UpdateGoldLabel(playerTeam, queryUnit, QueryGoldLabel);
	var sw = Game.GetScreenWidth();
	var sh = Game.GetScreenHeight();
	var minimap = FindDotaHudElement('minimap_block');
	$('#DynamicMinimapRoot').style.height = ((minimap.actuallayoutheight + minimap.contentheight - minimap.actuallayoutheight) / sh * 100) + '%';
	$('#DynamicMinimapRoot').style.width = ((minimap.actuallayoutwidth + minimap.contentwidth - minimap.actuallayoutwidth) / sw * 100) + '%';
	var pcs = FindDotaHudElement('PortraitContainer').GetPositionWithinWindow();
	if (pcs != null && !isNaN(pcs.x) && !isNaN(pcs.y))
		CustomModifiersList.style.position = (pcs.x / sw * 100) + '% ' + (pcs.y / sh * 100) + '% 0';
	var abilities = FindDotaHudElement('abilities');
	if (HookedAbilityPanelsCount !== abilities.GetChildCount()) {
		HookedAbilityPanelsCount = abilities.GetChildCount();
		_.each(abilities.Children(), function(child, index) {
			var btn = child.FindChildTraverse('AbilityButton');
			btn.SetPanelEvent('onactivate', function() {
				if (GameUI.IsAltDown()) {
					var unit = Players.GetLocalPlayerPortraitUnit();
					GameEvents.SendCustomGameEventToServer('custom_chat_send_message', {
						ability: GetVisibleAbilityInSlot(unit, index)
					});
				}
			});
		});
	}

	// Chat redirect
	var ChatLinesPanel = FindDotaHudElement('ChatLinesPanel');
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
		$.Localize('DOTA_Chat_CantUnpauseTeam')
	];
	var escaped = _.escapeRegExp(redirectedPhrases.map(function(x) {return $.Localize(x).replace(/%s\d/g, '.*');}).join('|'));
	var regexp = new RegExp('^(' + escaped + ')$');
	for (var i = 0; i < ChatLinesPanel.GetChildCount(); i++) {
		var child = ChatLinesPanel.GetChild(i);
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

function AutoUpdatePanoramaHUD() {
	$.Schedule(0.2, AutoUpdatePanoramaHUD);
	UpdatePanoramaHUD();
}

function HookPanoramaPanels() {
	FindDotaHudElement('QuickBuyRows').visible = false;
	FindDotaHudElement('shop').visible = false;
	FindDotaHudElement('HUDSkinMinimap').visible = false;
	FindDotaHudElement('combat_events').visible = false;
	FindDotaHudElement('ChatEmoticonButton').visible = false;
	FindDotaHudElement('StatBranchIcon').visible = false;
	FindDotaHudElement('StatBranchDrawer').visible = false;
	FindDotaHudElement('topbar').visible = false;
	FindDotaHudElement('DeliverItemsButton').style.horizontalAlign = 'right';
	FindDotaHudElement('LevelLabel').style.width = '100%';
	FindDotaHudElement('stash').style.marginBottom = '47px';

	var shopbtn = FindDotaHudElement('ShopButton');
	var StatBranch = FindDotaHudElement('StatBranch');
	var level_stats_frame = FindDotaHudElement('level_stats_frame');
	var chat = FindDotaHudElement('ChatLinesWrapper');
	var StatsLevelUpTab = level_stats_frame.FindChildTraverse('LevelUpTab');

	FindDotaHudElement('QueryUnit').FindChildTraverse('BuybackContainer').visible = false;
	shopbtn.FindChildTraverse('BuybackHeader').visible = false;
	shopbtn.ClearPanelEvent('onactivate');
	shopbtn.ClearPanelEvent('onmouseover');
	shopbtn.ClearPanelEvent('onmouseout');
	shopbtn.SetPanelEvent('onactivate', function() {
		if (GameUI.IsAltDown()) {
			GameEvents.SendCustomGameEventToServer('custom_chat_send_message', {
				GoldUnit: Players.GetLocalPlayerPortraitUnit()
			});
		} else {
			GameEvents.SendEventClientSide('panorama_shop_open_close', {});
		}
	});

	StatBranch.ClearPanelEvent('onactivate');
	StatBranch.ClearPanelEvent('onmouseover');
	StatBranch.ClearPanelEvent('onmouseout');
	StatBranch.hittestchildren = false;

	level_stats_frame.ClearPanelEvent('onmouseover');
	StatsLevelUpTab.ClearPanelEvent('onmouseover');
	StatsLevelUpTab.ClearPanelEvent('onmouseout');
	StatsLevelUpTab.ClearPanelEvent('onactivate');
	StatsLevelUpTab.SetPanelEvent('onactivate', function() {
		GameEvents.SendEventClientSide('custom_talents_toggle_tree', {});
	});
	var DebugChat = false;

	chat.FindChildTraverse('ChatLinesPanel').visible = DebugChat;
	if (chat.FindChildTraverse('SelectionChatMessages'))
		chat.FindChildTraverse('SelectionChatMessages').DeleteAsync(0);
	CustomChatLinesPanel = $.CreatePanel('Panel', chat, 'SelectionChatMessages');
	CustomChatLinesPanel.visible = !DebugChat;
	CustomChatLinesPanel.hittest = false;
	CustomChatLinesPanel.hittestchildren = false;
	AddStyle(CustomChatLinesPanel, {
		'width': '100%',
		'flow-children': 'down',
		'vertical-align': 'top',
		'overflow': 'squish noclip',
		'padding-right': '14px',
		'background-color': 'gradient( linear, 0% 0%, 100% 0%, from( #0000 ), color-stop( 0.01, #0000 ), color-stop( 0.1, #0000 ), to( #0000 ) )',
		'transition-property': 'background-color',
		'transition-duration': '0.23s',
		'transition-timing-function': 'ease-in-out'
	});

	var stats_region = FindDotaHudElement('stats_tooltip_region');
	stats_region.SetPanelEvent('onmouseover', function() {
		$.DispatchEvent('DOTAHUDShowDamageArmorTooltip', stats_region);
		var _unit = Players.GetLocalPlayerPortraitUnit();
		var custom_entity_value = GameUI.CustomUIConfig().custom_entity_values[_unit];
		var DOTAHUDDamageArmorTooltip = FindDotaHudElement('DOTAHUDDamageArmorTooltip');
		if (DOTAHUDDamageArmorTooltip != null && custom_entity_value != null) {
			var attackRate = custom_entity_value.AttackRate != null ? custom_entity_value.AttackRate : Entities.GetBaseAttackTime(_unit);
			var batModifier = attackRate / Entities.GetBaseAttackTime(_unit);
			var secondsPerAttack = Entities.GetSecondsPerAttack(_unit) * batModifier;
			DOTAHUDDamageArmorTooltip.SetDialogVariable('seconds_per_attack', '(' + secondsPerAttack.toFixed(2) + 's)');

			// https://dota2.gamepedia.com/Attack_speed#Attack_speed_representation
			var attackSpeedTooltip = Entities.GetAttackSpeed(_unit) * 100 * (1.7 / attackRate);
			DOTAHUDDamageArmorTooltip.SetDialogVariableInt('base_attack_speed', Math.round(attackSpeedTooltip));
			if (custom_entity_value.IdealArmor != null)
				DOTAHUDDamageArmorTooltip.SetDialogVariable('agility_armor', custom_entity_value.IdealArmor.toFixed(1));
			if (custom_entity_value.AgilityCriticalDamage != null)
				DOTAHUDDamageArmorTooltip.SetDialogVariable('agility_critical_damage', custom_entity_value.AgilityCriticalDamage.toFixed(1));

			if (custom_entity_value.AttributeStrengthGain != null)
				DOTAHUDDamageArmorTooltip.SetDialogVariable('strength_per_level', custom_entity_value.AttributeStrengthGain.toFixed(1));
			if (custom_entity_value.AttributeAgilityGain != null)
				DOTAHUDDamageArmorTooltip.SetDialogVariable('agility_per_level', custom_entity_value.AttributeAgilityGain.toFixed(1));
			if (custom_entity_value.AttributeIntelligenceGain != null)
				DOTAHUDDamageArmorTooltip.SetDialogVariable('intelligence_per_level', custom_entity_value.AttributeIntelligenceGain.toFixed(1));

			DOTAHUDDamageArmorTooltip.FindChildTraverse('StrengthDetails').text = $.Localize('#arena_hud_tooltip_details_strength', DOTAHUDDamageArmorTooltip);
			DOTAHUDDamageArmorTooltip.FindChildTraverse('StrengthDetails').style.textOverflow = 'shrink';
			DOTAHUDDamageArmorTooltip.FindChildTraverse('AgilityDetails').text = $.Localize('#arena_hud_tooltip_details_agility', DOTAHUDDamageArmorTooltip);
			DOTAHUDDamageArmorTooltip.FindChildTraverse('AgilityDetails').style.textOverflow = 'shrink';
			DOTAHUDDamageArmorTooltip.FindChildTraverse('IntelligenceDetails').text = $.Localize('#arena_hud_tooltip_details_intelligence', DOTAHUDDamageArmorTooltip);
			DOTAHUDDamageArmorTooltip.FindChildTraverse('IntelligenceDetails').style.textOverflow = 'shrink';
		}
	});
	stats_region.SetPanelEvent('onmouseout', function() {
		$.DispatchEvent('DOTAHUDHideDamageArmorTooltip');
	});
	var InventoryContainer = FindDotaHudElement('InventoryContainer');
	_.each(InventoryContainer.FindChildrenWithClassTraverse('InventoryItem'), function(child, index) {
		child.FindChildTraverse('AbilityButton').SetPanelEvent('onactivate', function() {
			var item = Entities.GetItemInSlot(Players.GetLocalPlayerPortraitUnit(), index);
			if (item > -1) {
				if (GameUI.IsAltDown()) {
					GameEvents.SendCustomGameEventToServer('custom_chat_send_message', {
						ability: item
					});
				} else {
					GameEvents.SendEventClientSide('panorama_shop_show_item_if_open', {
						'itemName': Abilities.GetAbilityName(item)
					});
					var _unit = Players.GetLocalPlayerPortraitUnit();
					if (Entities.IsControllableByPlayer(_unit, Game.GetLocalPlayerID())) {
						Abilities.ExecuteAbility(item, _unit, false);
					}
				}
			}
		});
	});
	var xpRoot = FindDotaHudElement('xp');
	_.each([xpRoot.FindChildTraverse('LevelBackground'), xpRoot.FindChildTraverse('CircularXPProgress'), xpRoot.FindChildTraverse('XPProgress')], function(p) {
		p.SetPanelEvent('onactivate', function() {
			if (GameUI.IsAltDown()) {
				GameEvents.SendCustomGameEventToServer('custom_chat_send_message', {
					xpunit: Players.GetLocalPlayerPortraitUnit()
				});
			}
		});
	});
}

function OnUpdateQueryUnit() {
	var unitName = GetHeroName(Players.GetQueryUnit(Players.GetLocalPlayer()));
	FindDotaHudElement('UnitName').text = $.Localize(unitName).toUpperCase();
	OnUpdateSelectedUnit();
}

function OnUpdateSelectedUnit() {
	var unitName = GetHeroName(Players.GetLocalPlayerPortraitUnit());
	FindDotaHudElement('UnitNameLabel').text = $.Localize(unitName).toUpperCase();
	OnSkillPoint();
}

function OnSkillPoint() {
	var unit = Players.GetLocalPlayerPortraitUnit();
	level_stats_frame = FindDotaHudElement('level_stats_frame');
	level_stats_frame.visible = Entities.GetAbilityPoints(unit) > 0 && Entities.IsControllableByPlayer(unit, Game.GetLocalPlayerID());
}

// On Death
function OnDeath(data) {
	if (data.entindex_killed === SafeGetPlayerHeroEntityIndex(Game.GetLocalPlayerID())) {
		var killerOwner = Entities.GetPlayerOwnerID(data.entindex_attacker);
		var attacker = Players.IsValidPlayerID(killerOwner) ? SafeGetPlayerHeroEntityIndex(killerOwner) : data.entindex_attacker;
		FindDotaHudElement('KilledByHeroName').text = $.Localize(GetHeroName(attacker)).toUpperCase();
	}
}

// Toasts
function CreateCustomToast(data) {
	var row = $.CreatePanel('Panel', $('#CustomToastManager'), '');
	row.BLoadLayoutSnippet('ToastPanel');
	row.AddClass('ToastPanel');
	var rowText = '';

	if (data.type === 'kill') {
		var byNeutrals = data.killerPlayer == null;
		var isSelfKill = data.victimPlayer === data.killerPlayer;
		var isAllyKill = !byNeutrals && data.victimPlayer != null && Players.GetTeam(data.victimPlayer) === Players.GetTeam(data.killerPlayer);
		var isVictim = data.victimPlayer === Game.GetLocalPlayerID();
		var isKiller = data.killerPlayer === Game.GetLocalPlayerID();
		var teamVictim = byNeutrals || Players.GetTeam(data.victimPlayer) === Players.GetTeam(Game.GetLocalPlayerID());
		var teamKiller = !byNeutrals && Players.GetTeam(data.killerPlayer) === Players.GetTeam(Game.GetLocalPlayerID());
		row.SetHasClass('AllyEvent', teamKiller);
		row.SetHasClass('EnemyEvent', byNeutrals || !teamKiller);
		row.SetHasClass('LocalPlayerInvolved', isVictim || isKiller);
		row.SetHasClass('LocalPlayerKiller', isKiller);
		row.SetHasClass('LocalPlayerVictim', isVictim);
		if (isKiller)
			Game.EmitSound('notification.self.kill');
		else if (isVictim)
			Game.EmitSound('notification.self.death');
		else if (teamKiller)
			Game.EmitSound('notification.teammate.kill');
		else if (teamVictim)
			Game.EmitSound('notification.teammate.death');
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
			if (data.teamInverted === 1)
				teamVictim = !teamVictim;
			row.SetHasClass('AllyEvent', teamVictim);
			row.SetHasClass('EnemyEvent', !teamVictim);
		} else
			row.AddClass('AllyEvent');
		rowText = $.Localize(data.text);
	}

	rowText = rowText.replace('{denied_icon}', "<img class='DeniedIcon'/>").replace('{killed_icon}', "<img class='CombatEventKillIcon'/>").replace('{time_dota}', "<font color='lime'>" + secondsToMS(Game.GetDOTATime(false, false), true) + '</font>');
	if (data.player != null)
		rowText = rowText.replace('{player_name}', CreateHeroElements(data.player));
	if (data.victimPlayer != null)
		rowText = rowText.replace('{victim_name}', CreateHeroElements(data.victimPlayer));
	if (data.killerPlayer != null) {
		rowText = rowText.replace('{killer_name}', CreateHeroElements(data.killerPlayer));
	}
	if (data.victimUnitName)
		rowText = rowText.replace('{victim_name}', "<font color='red'>" + $.Localize(data.victimUnitName) + '</font>');
	if (data.team != null)
		rowText = rowText.replace('{team_name}', "<font color='" + GameUI.CustomUIConfig().team_colors[data.team] + "'>" + GameUI.CustomUIConfig().team_names[data.team] + '</font>');
	if (data.gold != null)
		rowText = rowText.replace('{gold}', "<font color='gold'>" + FormatGold(data.gold) + "</font> <img class='CombatEventGoldIcon' />");
	if (data.runeType != null)
		rowText = rowText.replace('{rune_name}', "<font color='#" + RUNES_COLOR_MAP[data.runeType] + "'>" + $.Localize('custom_runes_rune_' + data.runeType + '_title') + '</font>');
	if (data.variables)
		for (var k in data.variables) {
			rowText = rowText.replace(k, $.Localize(data.variables[k]));
		}
	if (rowText.indexOf('<img') === -1)
		row.AddClass('SimpleText');
	row.FindChildTraverse('ToastLabel').text = rowText;
	$.Schedule(10, function() {
		row.AddClass('Collapsed');
	});
	row.DeleteAsync(10.3);
};

function CreateHeroElements(id) {
	var playerColor = GetHEXPlayerColor(id);
	return "<img src='" + TransformTextureToPath(GetPlayerHeroName(id), 'icon') + "' class='CombatEventHeroIcon'/> <font color='" + playerColor + "'>" + _.escape(Players.GetPlayerName(id)) + '</font>';
}

(function() {
	HookPanoramaPanels();
	_DynamicMinimapSubscribe($('#DynamicMinimapRoot'));
	var mapInfo = Options.GetMapInfo();
	hud.AddClass('map_landscape_' + mapInfo.landscape);
	hud.AddClass('map_gamemode_' + mapInfo.gamemode);
	$.GetContextPanel().SetHasClass('ShowMMR', Options.IsEquals('EnableRatingAffection'));
	DynamicSubscribePTListener('players_abandoned', function(tableName, changesObject, deletionsObject) {
		if (changesObject[Game.GetLocalPlayerID()]) $.GetContextPanel().AddClass('LocalPlayerAbandoned');
	});

	AutoUpdatePanoramaHUD();
	GameEvents.Subscribe('entity_killed', OnDeath);
	DynamicSubscribeNTListener('custom_entity_values', OnUpdateQueryUnit);
	GameEvents.Subscribe('dota_player_update_selected_unit', OnUpdateSelectedUnit);
	GameEvents.Subscribe('dota_player_update_query_unit', OnUpdateQueryUnit);
	GameEvents.Subscribe('dota_player_gained_level', OnSkillPoint);
	GameEvents.Subscribe('dota_player_learned_ability', OnSkillPoint);

	GameEvents.Subscribe('create_custom_toast', CreateCustomToast);
})();
