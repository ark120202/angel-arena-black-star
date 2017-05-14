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

function NextTip() {
	if (ShuffledTipList.length === 0) {
		ShuffledTipList = JSON.parse(JSON.stringify(TipList));
		shuffle(ShuffledTipList);
	}
	var shifted = ShuffledTipList.shift();

	$('#TipLabel').text = shifted.text;
}

function Snippet_OptionVoting(voteName, voteData) {
	var votePanel = $.CreatePanel('Panel', $('#OptionVotings'), 'option_voting_' + voteName);
	votePanel.BLoadLayoutSnippet('OptionVoting');
	votePanel.SetDialogVariable('title', $.Localize('option_voting_' + voteName));
	var OptionVotingVariants = votePanel.FindChildTraverse('OptionVotingVariants');
	var shouldGroup = false;
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
	for (var pid in voteData.votes) {
		total += 1;
		var vote = voteData.votes[pid];
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

function CheckStartable() {
	var player = Game.GetLocalPlayerInfo();
	if (player == null)
		$.Schedule(0.2, CheckStartable);
	else {
		$('#afterload_panel').visible = true;
		var LocalPlayerData = $('#LocalPlayerData');
		LocalPlayerData.BLoadLayout('file://{resources}/layout/custom_game/player_profiles.xml', false, false);
		LocalPlayerData.FindChildTraverse('CloseButton').vislbe = false;
		LocalPlayerData.LoadPanelForPlayer(Game.GetLocalPlayerID());
		PlayerTables = GameUI.CustomUIConfig().PlayerTables;
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

(function() {
	$('#OptionVotings').RemoveAndDeleteChildren();
	CheckStartable();
	FillTips();
	$('#TipsPanel').visible = TipList.length > 0;
	if (TipList.length > 0) NextTip();
})();
