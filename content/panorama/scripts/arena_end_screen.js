GAME_RESULT = {};

function FinishGame() {
	$.GetContextPanel().AddClass('FadeOut');
	$.Schedule(1, function() {
		Game.FinishGame();
	});
}

/**
 * Creates Panel snippet and sets all player-releated information
 *
 * @param {Number} playerID Player ID
 * @param {Panel} rootPanel Panel that will be parent for that player
 */
function Snippet_Player(playerID, rootPanel, index, isRight) {
	var panel = $.CreatePanel('Panel', rootPanel, '');
	panel.BLoadLayoutSnippet('Player');
	panel.SetHasClass('IsRight', isRight);
	var playerData = GAME_RESULT.playerData[playerID];
	var playerInfo = Game.GetPlayerInfo(playerID);
	panel.FindChildTraverse('PlayerAvatar').steamid = playerInfo.player_steamid;
	panel.FindChildTraverse('PlayerAvatar').SetPanelEvent('onactivate', function() {
		GameEvents.SendEventClientSide('player_profiles_show_info', {PlayerID: playerID});
	});


	panel.FindChildTraverse('HeroIcon').SetImage(TransformTextureToPath(playerData.hero));
	panel.SetDialogVariableInt('hero_level', Players.GetLevel(playerID));
	panel.SetDialogVariable('hero_name', $.Localize(playerData.hero));
	panel.SetDialogVariableInt('kills', Players.GetKills(playerID));
	panel.SetDialogVariableInt('deaths', Players.GetDeaths(playerID));
	panel.SetDialogVariableInt('assists', Players.GetAssists(playerID));
	panel.SetDialogVariableInt('last_hits', Players.GetLastHits(playerID));
	panel.SetDialogVariableInt('hero_damage', playerData.damage);
	var mmrString;
	// playerData.ratingNew
	// playerData.ratingOld
	if (typeof playerData.ratingNew === 'number') {
		if (typeof playerData.ratingOld === 'number') {
			var delta = playerData.ratingNew - playerData.ratingOld;
			mmrString = delta > 0 ?
				'<font color="lime">+' + delta + '</font>' :
				delta < 0 ? '<font color="red">' + delta + '</font>' : '±0';
			mmrString = playerData.ratingNew + ' (' + mmrString + ')';
		} else mmrString = 'TBD -> ' + playerData.ratingNew;
	} else mmrString = 'TBD';
	panel.SetDialogVariable('rating', mmrString);

	panel.SetDialogVariableInt('net_worth', playerData.netWorth);
	panel.style.animationDelay = index * 0.6 + 's';
	$.Schedule(index * 0.6, function() {
		panel.opacity = 1;
		panel.AddClass('AnimationEnd');
	});

	var ItemsContainer = panel.FindChildTraverse('ItemsContainer');
	var BackpackItemsContainer = panel.FindChildTraverse('BackpackItemsContainer');
	var playerItems = Game.GetPlayerItems(playerID);
	for (var i = playerItems.inventory_slot_min; i < playerItems.inventory_slot_max; i++) {
		var item = playerItems.inventory[i];
		var isBackpack = i >= 6;
		var itemContainer = panel.FindChildTraverse(isBackpack ? 'BackpackItemsContainer' : 'ItemsContainer');
		var itemPanel = $.CreatePanel('DOTAItemImage', itemContainer, '');

		if (item) itemPanel.itemname = item.item_name;
	}
}

/**
 * Creates Team snippet and all in-team information
 *
 * @param {Number} team Team Index
 */
function Snippet_Team(team) {
	var isRight = team % 2 !== 0;
	var panel = $.CreatePanel('Panel', $('#TeamsContainer'), '');
	panel.BLoadLayoutSnippet('Team');
	panel.SetDialogVariable('team_name', GameUI.CustomUIConfig().team_names[team]);
	var teamDetails = Game.GetTeamDetails(team);
	panel.SetDialogVariableInt('team_score', teamDetails.team_score);
	panel.SetHasClass('IsWinner', GAME_RESULT.winner === team);

	var teamColor = GameUI.CustomUIConfig().team_colors[team];
	panel.FindChildTraverse('TeamName').style.textShadow = '0px 0px 6px 1.0 ' + teamColor;
	//panel.FindChildTraverse('TeamScore').style.textShadow = '0px 0px 6px 1.0 ' + teamColor;
	//panel.FindChildTraverse('TeamInfo').style.backgroundColor = 'gradient(linear, 0 0, 0 100%, from(#373d35), to(' + teamColor + '))';

	_.each(/*Game.GetPlayerIDsOnTeam(team)*/[0], function(playerID, i) {
		Snippet_Player(playerID, panel, i, isRight);
		Snippet_Player(playerID, panel, i+1, isRight);
		Snippet_Player(playerID, panel, i+2, isRight);
		Snippet_Player(playerID, panel, i+3, isRight);
		Snippet_Player(playerID, panel, i+4, isRight);
		Snippet_Player(playerID, panel, i+5, isRight);
		Snippet_Player(playerID, panel, i+6, isRight);
		Snippet_Player(playerID, panel, i+7, isRight);
	});
}

function OnGameResult(gameResult) {
	GAME_RESULT = gameResult;
	$.GetContextPanel().SetDialogVariable('winning_team_name', GameUI.CustomUIConfig().team_names[GAME_RESULT.winner]);
	$('#TeamsContainer').RemoveAndDeleteChildren();
	_.each(Game.GetAllTeamIDs(), function(team) {
		Snippet_Team(team);
	});
}

(function() {
	GameEvents.Subscribe('stats_client_game_result', OnGameResult);
	OnGameResult({
		winner: Game.GetGameWinner(),
		playerData: {
			0: {
				hero: 'npc_dota_hero_slark',
				netWorth: 600000,
				damage: 30000,
				ratingNew: 10000,
				ratingOld: 'TBD'
			}
		}
	});
	GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ENDGAME, false);
	GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ENDGAME_CHAT, false);
	FindDotaHudElement('GameEndContainer').visible = false;
})();
