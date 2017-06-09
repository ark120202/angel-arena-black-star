var GAME_RESULT = {};

function FinishGame() {
	var maxDelay = 0;
	$.GetContextPanel().AddClass('FadeOut');
	_.each($.GetContextPanel().FindChildrenWithClassTraverse('Player'), function(panel) {
		panel.style.animationDelay = panel.index * 0.1 + 's';
		maxDelay = Math.max(maxDelay, panel.index * 0.1);
		$.Schedule(panel.index * 0.1, function() {
			panel.RemoveClass('AnimationEnd');
		});
	});
	// animation-delay + animation-duration
	$.Schedule(maxDelay + .7, function() {
		Game.FinishGame();
	});
}

/**
 * Creates Panel snippet and sets all player-releated information
 *
 * @param {Number} playerID Player ID
 * @param {Panel} rootPanel Panel that will be parent for that player
 */
function Snippet_Player(playerID, rootPanel, index) {
	var panel = $.CreatePanel('Panel', rootPanel, '');
	panel.BLoadLayoutSnippet('Player');
	var playerData = GAME_RESULT.players[playerID];
	var playerInfo = Game.GetPlayerInfo(playerID);
	panel.FindChildTraverse('PlayerAvatar').steamid = playerInfo.player_steamid;
	panel.FindChildTraverse('PlayerNameScoreboard').steamid = playerInfo.player_steamid;

	panel.index = index; // For backwards compatibility
	panel.style.animationDelay = index * 0.3 + 's';
	$.Schedule(index * 0.3, function() {
		try {
			panel.AddClass('AnimationEnd');
		} catch(e){};
	});

	panel.FindChildTraverse('HeroIcon').SetImage(TransformTextureToPath(playerData.hero));
	panel.SetDialogVariableInt('hero_level', Players.GetLevel(playerID));
	panel.SetDialogVariable('hero_name', $.Localize(playerData.hero));
	panel.SetDialogVariableInt('kills', Players.GetKills(playerID));
	panel.SetDialogVariableInt('deaths', Players.GetDeaths(playerID));
	panel.SetDialogVariableInt('assists', Players.GetAssists(playerID));
	panel.SetDialogVariableInt('last_hits', Players.GetLastHits(playerID));
	panel.SetDialogVariableInt('heroDamage', playerData.heroDamage);
	panel.SetDialogVariableInt('bossDamage', playerData.bossDamage);
	panel.SetDialogVariableInt('heroHealing', playerData.heroHealing);
	panel.SetDialogVariableInt('strength', playerData.bonus_str);
	panel.SetDialogVariableInt('agility', playerData.bonus_agi);
	panel.SetDialogVariableInt('intellect', playerData.bonus_int);
	panel.SetDialogVariableInt('net_worth', playerData.netWorth);

	var mmrString;
	if (typeof playerData.ratingNew === 'number') {
		if (typeof playerData.ratingOld === 'number') {
			var delta = playerData.ratingNew - playerData.ratingOld;
			mmrString = delta > 0 ?
				'<font color="lime">+' + delta + '</font>' :
				delta < 0 ? '<font color="red">' + delta + '</font>' : '±0';
			mmrString = playerData.ratingNew + ' (' + mmrString + ')';
		} else mmrString = 'TBD -> ' + playerData.ratingNew;
	} else mmrString = 'TBD (' + (playerData.ratingGamesRemaining || 0) + ')';
	panel.SetDialogVariable('rating', mmrString);

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
	panel.SetHasClass('IsRight', isRight);
	panel.SetDialogVariable('team_name', GameUI.CustomUIConfig().team_names[team]);
	var teamDetails = Game.GetTeamDetails(team);
	panel.SetDialogVariableInt('team_score', teamDetails.team_score);
	panel.SetHasClass('IsWinner', GAME_RESULT.winner === team);

	var teamColor = GameUI.CustomUIConfig().team_colors[team];
	panel.FindChildTraverse('TeamName').style.textShadow = '0px 0px 6px 1.0 ' + teamColor;

	_.each(Game.GetPlayerIDsOnTeam(team), function(playerID, i) {
		Snippet_Player(playerID, panel, i + 1);
	});
}

function OnGameResult(gameResult) {
	console.log(gameResult);
	if (!gameResult.players) {
		$('#LoadingPanel').visible = false;
		$('#ErrorPanel').visible = true;
		$('#ErrorMessage').text = gameResult.error || 'Unknown error';
	} else {
		$('#LoadingPanel').visible = false;
		$('#EndScreenWindow').visible = true;
		gameResult.winner = Game.GetGameWinner();
		GAME_RESULT = gameResult;
		$('#TeamsContainer').RemoveAndDeleteChildren();
		_.each(Game.GetAllTeamIDs(), function(team) {
			Snippet_Team(team);
		});
		var localData = gameResult.players[Game.GetLocalPlayerID()];

		var experienceNew = localData.experienceNew || 0;
		var experienceOld = localData.experienceOld || 0;
		SetPagePlayerLevel($('#ProfileBadge'), Math.floor(experienceNew / 100) + 1);
		$('#EndScreenVictory').text = $.Localize(Players.GetTeam(Game.GetLocalPlayerID()) === gameResult.winner ? 'arena_end_screen_victory' : 'arena_end_screen_defeat');
		$('#LevelProgressValue').text = Math.floor(experienceNew % 100) + ' / 100 XP';
		$('#LevelProgressChange').text = '+' + Math.floor(experienceNew - experienceOld) + ' XP';
		$('#LevelProgress').value = experienceOld % 100;
		$.Schedule(.5, function() {
			$('#LevelProgress').value = experienceNew % 100;
			$('#LevelProgressChange').style.opacity = 1;
		});
	}
}

(function() {
	$.GetContextPanel().SetHasClass('ShowMMR', Options.IsEquals('EnableRatingAffection'));
	$.GetContextPanel().RemoveClass('FadeOut');
	$('#LoadingPanel').visible = true;
	$('#ErrorPanel').visible = false;
	$('#EndScreenWindow').visible = false;

	DynamicSubscribePTListener('stats_game_result', function(tableName, changesObject) {
		OnGameResult(changesObject);
	});

	/*OnGameResult({
		winner: Game.GetGameWinner(),
		players: {
			0: {
				hero: 'npc_dota_hero_slark',
				hero_damage: 30000,
				netWorth: 600000,
				ratingNew: 10000,
				ratingOld: 'TBD',
				strength: 100,
				agility: 100,
				intellect: 100,
				xpNew: 100,
				xpOld: 0
			}
		}
	});*/
	GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ENDGAME, false);
	GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ENDGAME_CHAT, false);
	FindDotaHudElement('GameEndContainer').visible = false;
})();
