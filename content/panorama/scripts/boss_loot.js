function SetBossDropItemVotingsVisible() {
	$.GetContextPanel().ToggleClass('ShowBossDrop');
}

function SnippetBossDropItemVoteItemPanel(rootPanel, id, entry, entryid) {
	var itemRow = $.CreatePanel('Panel', rootPanel, 'boss_item_vote_id_' + id + '_item_' + entryid);
	itemRow.BLoadLayoutSnippet('BossDropItemVoteItemPanel');
	var BossDropItemIcon = itemRow.FindChildTraverse('BossDropItemIcon');
	if (entry.item) BossDropItemIcon.itemname = entry.item; else
	if (entry.hero) {
		BossDropItemIcon.SetImage(TransformTextureToPath(entry.hero));
		var msg = $.Localize('boss_loot_vote_hero') + $.Localize(entry.hero);
		BossDropItemIcon.style.tooltipPosition = 'left';
		BossDropItemIcon.SetPanelEvent('onmouseover', function() {
			$.DispatchEvent('DOTAShowTextTooltip', BossDropItemIcon, msg);
		});
		BossDropItemIcon.SetPanelEvent('onmouseout', function() {
			$.DispatchEvent('DOTAHideTextTooltip');
		});
	}
	if (entry.weight) itemRow.FindChildTraverse('BossDropScoreCost').text = entry.weight;
	(entry.votes ? itemRow : itemRow.FindChildTraverse('BossDropPlayersTake')).SetPanelEvent('onactivate', function() {
		GameEvents.SendCustomGameEventToServer('bosses_vote_for_item', {
			voteid: id,
			entryid: entryid
		});
	});
	itemRow.SetHasClass('HasTakeButton', entry.votes == null);
}

function CreateBossItemVote(id, data) {
	var row = $.CreatePanel('Panel', $('#BossDropItemVotingsListContainer'), 'boss_item_vote_id_' + id);
	row.BLoadLayoutSnippet('BossDropItemVote');
	var BossTakeLootTime = row.FindChildTraverse('BossTakeLootTime');
	BossTakeLootTime.max = data.time;
	(function Update() {
		var diff = Game.GetGameTime() - data.killtime;
		if (diff <= data.time) {
			BossTakeLootTime.value = BossTakeLootTime.max - diff;
			$.Schedule(0.1, Update);
		}
	})();

	var BossDropHideShowInfo = row.FindChildTraverse('BossDropHideShowInfo');
	row.FindChildTraverse('KilledBossName').text = $.Localize(data.boss);
	row.FindChildTraverse('KilledBossImage').SetImage(TransformTextureToPath(data.boss));
	var localPlayerScore = data.damagePcts[Game.GetLocalPlayerID()] || 0;
	var BossPlayerScore = row.FindChildTraverse('BossPlayerScore');
	BossPlayerScore.text = localPlayerScore.toFixed();

	var r = localPlayerScore<50 ? 255 : Math.floor(255-(localPlayerScore*2-100)*255/100), g = localPlayerScore>50 ? 255 : Math.floor((localPlayerScore*2)*255/100);
	BossPlayerScore.style.color = 'rgb('+r+','+g+',0)';
	_.each(data.rollableEntries, function(entry, entryid) {
		SnippetBossDropItemVoteItemPanel(row.FindChildTraverse('BossItemList'), id, entry, entryid);
	});
}

function UpdateBossItemVote(id, data) {
	var localPlayerId = Game.GetLocalPlayerID();
	if ($('#boss_item_vote_id_' + id) == null) CreateBossItemVote(id, data);
	var panel = $('#boss_item_vote_id_' + id);
	_.each(data.rollableEntries, function(entry, entryid) {
		var itempanel = panel.FindChildTraverse('boss_item_vote_id_' + id + '_item_' + entryid);
		if (entry.votes) {
			itempanel.FindChildTraverse('BossDropPlayersRow').RemoveAndDeleteChildren();
			//var localPlayerPickedTotalScore = 0;
			itempanel.SetHasClass('LocalPlayerSelected', entry.votes[localPlayerId] === 1);
			_.each(entry.votes, function(voteval, playerId) {
				if (voteval === 1) {
					playerId = Number(playerId);
					var img = $.CreatePanel('Image', itempanel.FindChildTraverse('BossDropPlayersRow'), '');
					img.SetImage(TransformTextureToPath(GetPlayerHeroName(playerId), 'icon'));
					img.SetPanelEvent('onmouseover', function() {
						$.DispatchEvent('DOTAShowTextTooltip', img, Players.GetPlayerName(playerId));
					});
					img.SetPanelEvent('onmouseout', function() {
						$.DispatchEvent('DOTAHideTextTooltip');
					});
				}
			});
		}
	});
}

function CreateInactiveList() {
	var row = $.CreatePanel('Panel', $('#BossDropItemVotingsListContainer'), 'boss_item_vote_id_-1');
	var label = $.CreatePanel('Label', row, '');
	label.text = $.Localize('boss_loot_vote_inactive');
	$.CreatePanel('Panel', row, 'boss_item_vote_id_-1_container');
}

(function() {
	$('#BossDropItemVotingsListContainer').RemoveAndDeleteChildren();
	CreateInactiveList();

	if ($.GetContextPanel().PTID_hero_bosses_loot_drop_votes) PlayerTables.UnsubscribeNetTableListener($.GetContextPanel().PTID_hero_bosses_loot_drop_votes);
	DynamicSubscribePTListener('bosses_loot_drop_votes', function(tableName, changesObject, deletionsObject) {
		for (var id in changesObject) {
			var splittedId = id.split('_');
			if (Number(splittedId[0]) === Players.GetTeam(Game.GetLocalPlayerID())) {
				if (splittedId[1] === '-1') {
					$('#boss_item_vote_id_-1_container').RemoveAndDeleteChildren();
					_.each(changesObject[id], function(entry, entryid) {
						if (!$('#boss_item_vote_id_' + id + '_item_' + entryid)) SnippetBossDropItemVoteItemPanel($('#boss_item_vote_id_-1_container'), id, entry, entryid);
					});
				} else {
					UpdateBossItemVote(id, changesObject[id]);
				}
			}
		}
		for (var id in deletionsObject) {
			if ($('#boss_item_vote_id_' + id) != null) {
				$('#boss_item_vote_id_' + id).DeleteAsync(0);
			}
		}
	}, function(ptid) {$.GetContextPanel().PTID_hero_bosses_loot_drop_votes = ptid;});

	(function Update() {
		var context = $.GetContextPanel();
		var activeBossDropVotingsCount = $('#BossDropItemVotingsListContainer').GetChildCount() - 1;
		var inactiveBossDropVotingsCount = $('#boss_item_vote_id_-1_container').GetChildCount();
		$('#BossDropActiveItemVotingsCounter').text = activeBossDropVotingsCount;
		$('#BossDropInactiveItemVotingsCounter').text = inactiveBossDropVotingsCount;
		context.SetHasClass('hideActiveBossItemVotings', activeBossDropVotingsCount === 0);
		context.SetHasClass('hideInactiveBossItemVotings', inactiveBossDropVotingsCount === 0);
		if (context.BHasClass('ShowBossDrop') && activeBossDropVotingsCount === 0 && inactiveBossDropVotingsCount === 0) context.RemoveClass('ShowBossDrop');
		$.Schedule(0.2, Update);
	})();
})();
