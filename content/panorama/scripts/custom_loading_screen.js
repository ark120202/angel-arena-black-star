'use strict';

var TipList = [];
var ShuffledTipList = [];

function FillTips() {
	var i = 1;
	while (true) {
		var unlocalized = 'arena_tip_' + i;
		var localized = $.Localize(unlocalized);
		if (localized !== unlocalized) {
			TipList.push({
				num: i,
				text: localized
			});
		} else {
			break;
		}
		i++;
	}
}

function shuffle(a) {
	var j, x, i;
	for (i = a.length; i; i--) {
		j = Math.floor(Math.random() * i);
		x = a[i - 1];
		a[i - 1] = a[j];
		a[j] = x;
	}
}

function NextTip() {
	if (ShuffledTipList.length === 0) {
		ShuffledTipList = TipList.slice();
		shuffle(ShuffledTipList);
	}
	var tip = ShuffledTipList.shift();

	$('#TipLabel').text = tip.text;
}

function Snippet_OptionVoting(voteName, voteData) {
	var votePanel = $.CreatePanel('Panel', $('#OptionVotings'), 'option_voting_' + voteName);
	votePanel.BLoadLayoutSnippet('OptionVoting');
	votePanel.SetDialogVariable('title', $.Localize('option_voting_' + voteName));
	var OptionVotingVariants = votePanel.FindChildTraverse('OptionVotingVariants');
	var shouldGroup = true; //voteName === 'kill_limit';
	votePanel.SetHasClass('ShouldGroup', shouldGroup);
	for (var tIndex in voteData.variants) {
		tIndex = Number(tIndex);
		var variant = voteData.variants[tIndex];
		var group = shouldGroup ? OptionVotingVariants.GetChild(Math.floor((tIndex-1) / 2)) || $.CreatePanel('Panel', OptionVotingVariants, '') : OptionVotingVariants;
		if (shouldGroup) group.AddClass('OptionVotingVariantRow');

		var button = $.CreatePanel('Button', group, 'option_variant_' + variant);
		button.AddClass('ButtonBevel');
		button.AddClass('OptionVotingVariant');
		if (shouldGroup) button.style.horizontalAlign = tIndex % 2 === 1 ? 'left' : 'right';
		button.SetPanelEvent('onactivate', (function(voteName, variant) {
			return function() {
				if (!votePanel.BHasClass('Voted')) {
					GameEvents.SendCustomGameEventToServer('options_vote', {
						name: voteName,
						vote: variant
					});
					votePanel.AddClass('Voted');
				}
			};
		})(voteName, variant));

		var label = $.CreatePanel('Label', button, '');
		label.text = typeof variant === 'string' ? $.Localize('option_voting_' + voteName + '_' + variant) : typeof variant === 'boolean' ? $.Localize(variant ? 'option_yes' : 'option_no') : variant;

		var votedataLabel = $.CreatePanel('Label', button, 'vote_data_variant_' + tIndex);
		votedataLabel.text = '{s:votes}';
		votedataLabel.style.horizontalAlign = 'right';
	}
	return votePanel;
}

function Snippet_OptionVoting_Recalculate(votePanel, voteData) {
	var amount = {};
	for (var k in voteData.variants)
		amount[voteData.variants[k]] = 0;

	var total = 0;
	//var leadingKey;
	for (var playerId in voteData.votes) {
		total += 1;
		var vote = voteData.votes[playerId];
		amount[vote] += 1;
		/*if (leadingKey == null || amount[vote] > voteData.votes[leadingKey]) {
			leadingKey = vote
		}*/
	}
	//leadingKey = leadingKey || "";
	//var leadingValue = voteData.votes[leadingKey] || 1;
	for (var variant in amount) {
		var count = amount[variant];
		var variantPanel = votePanel.FindChildTraverse('option_variant_' + variant);
		variantPanel.SetDialogVariable('votes', count + ' (' + Math.round(count/(total||1)*100) + '%)');
		//var shade = Math.round(255-255*(count/leadingValue))*2;
		//variantPanel.GetChild(1).style.color = "rgb("+shade+", 255, "+shade+")"
		//variantPanel.SetHasClass("LeadingVote", variant == leadingKey)
	}
}

function Snippet_TopPlayer(localSteamID, player, index) {
	var panel = $.CreatePanel('Panel', $('#TopPlayersList'), '');
	panel.BLoadLayoutSnippet('TopPlayer');
	panel.SetHasClass('LocalPlayer', localSteamID === player.steamid);
	panel.SetHasClass('NotInTop', index >= 5);

	panel.FindChildTraverse('PlayerAvatar').steamid = player.steamid;
	panel.FindChildTraverse('PlayerName').steamid = player.steamid;
	panel.SetDialogVariable('place', player.place || '?');
	panel.SetDialogVariable('rating', player.Rating || 'TBD');
}

function CheckStartable() {
	var player = Game.GetLocalPlayerInfo();
	if (player == null) {
		$.Schedule(0.2, CheckStartable);
	} else {
		$('#afterload_panel').visible = true;
		PlayerTables = GameUI.CustomUIConfig().PlayerTables;

		$('#TopPlayersList').RemoveAndDeleteChildren();
		GetDataFromServer('fetchTopPlayers', { steamid: player.player_steamid }, function(topPlayers) {
			$('#TopPlayers').AddClass('Loaded');
			topPlayers.forEach(Snippet_TopPlayer.bind(null, player.player_steamid));
		});

		DynamicSubscribePTListener('option_votings', function(tableName, changesObject, deletionsObject) {
			$('#OptionVotings').AddClass('Loaded');
			for (var voteName in changesObject) {
				var voteData = changesObject[voteName];
				var votePanel = $('#option_voting_' + voteName);
				if (votePanel == null) votePanel = Snippet_OptionVoting(voteName, voteData);
				Snippet_OptionVoting_Recalculate(votePanel, voteData);
			}
		});

		GameEvents.Subscribe('option_votings_refresh', function(data) {
			Snippet_OptionVoting_Recalculate($('#option_voting_' + data.name), data.data);
		});
	}
}

var russianLangs = [
	'russian',
	'ukrainian',
	'bulgarian'
];
function OnAdsClicked() {
	var context = $.GetContextPanel();
	$.Schedule(context.BHasClass('AdsClicked') ? 0 : .35, function() {
		$.DispatchEvent('ExternalBrowserGoToURL', 'https://angelarenablackstar-ark120202.rhcloud.com/ads/loading_screen/go');
	});
	if (!context.BHasClass('AdsClicked')){
		context.AddClass('AdsClicked');
		Game.EmitSound('General.CoinsBig');
		GameEvents.SendCustomGameEventToServer('on_ads_clicked', {
			source: 'loading_screen'
		});
	}
}


(function() {
	$('#AdsBanner').SetImage('https://angelarenablackstar-ark120202.rhcloud.com/ads/loading_screen/' + (russianLangs.indexOf($.Language()) !== -1 ? 'ru.png' : 'en.png'));

	$('#OptionVotings').RemoveAndDeleteChildren();
	CheckStartable();
	FillTips();
	$('#TipsPanel').visible = TipList.length > 0;
	if (TipList.length > 0) NextTip();
})();
