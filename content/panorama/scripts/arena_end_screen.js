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
 * @param {Number} playerId Player ID
 * @param {Panel} rootPanel Panel that will be parent for that player
 */
function Snippet_Player(playerId, rootPanel, index) {
	var panel = $.CreatePanel('Panel', rootPanel, '');
	panel.BLoadLayoutSnippet('Player');
	panel.SetHasClass('IsLocalPlayer', playerId === Game.GetLocalPlayerID());
	var playerData = GAME_RESULT.players[playerId];
	var playerInfo = Game.GetPlayerInfo(playerId);
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
	panel.SetDialogVariableInt('hero_level', Players.GetLevel(playerId));
	panel.SetDialogVariable('hero_name', $.Localize(playerData.hero));
	panel.SetDialogVariableInt('kills', Players.GetKills(playerId));
	panel.SetDialogVariableInt('deaths', Players.GetDeaths(playerId));
	panel.SetDialogVariableInt('assists', Players.GetAssists(playerId));
	panel.SetDialogVariableInt('last_hits', Players.GetLastHits(playerId));
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

	for (var i = 0; i < 9; i++) {
		var item = playerData.items[i];
		var itemPanel = $.CreatePanel('DOTAItemImage', panel.FindChildTraverse(i >= 6 ? 'BackpackItemsContainer' : 'ItemsContainer'), '');
		if (item) {
			itemPanel.itemname = item.name;
			// item.charges
		}
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
	panel.SetDialogVariableInt('team_score', GetTeamInfo(team).score);
	panel.SetHasClass('IsWinner', GAME_RESULT.winner === team);

	var teamColor = GameUI.CustomUIConfig().team_colors[team];
	panel.FindChildTraverse('TeamName').style.textShadow = '0px 0px 6px 1.0 ' + teamColor;

	_.each(Game.GetPlayerIDsOnTeam(team), function(playerId, i) {
		Snippet_Player(playerId, panel, i + 1);
	});
}

function OnGameResult(gameResult) {
	if (gameResult.error === 1) {
		Game.FinishGame();
		return;
	}

	if (!gameResult.players) {
		$('#LoadingPanel').visible = false;
		$('#ErrorPanel').visible = true;
		$('#ErrorMessage').text = $.Localize(gameResult.error);
	} else {
		$('#LoadingPanel').visible = false;
		$('#EndScreenWindow').visible = true;
		gameResult.winner = Game.GetGameWinner();
		GAME_RESULT = gameResult;
		$('#TeamsContainer').RemoveAndDeleteChildren();
		_.each(Game.GetAllTeamIDs(), Snippet_Team);
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
	GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ENDGAME, false);
	GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ENDGAME_CHAT, false);
	FindDotaHudElement('GameEndContainer').visible = false;

	$.GetContextPanel().SetHasClass('ShowMMR', Options.IsEquals('EnableRatingAffection'));
	$.GetContextPanel().RemoveClass('FadeOut');
	$('#LoadingPanel').visible = true;
	$('#ErrorPanel').visible = false;
	$('#EndScreenWindow').visible = false;

	DynamicSubscribePTListener('stats_game_result', function(tableName, changesObject) {
		OnGameResult(changesObject);
	});
})();
