function LoadPanelForPlayer(playerId) {
	//	var PlayerProfileBase
	$.GetContextPanel().AddClass('PanelOpened');
	var steamid = Game.GetPlayerInfo(playerId).player_steamid;
	$('#Avatar').steamid = steamid;
	$('#UserName').steamid = steamid;
	var stats = Players.GetStatsData(playerId);
	SetPagePlayerLevel($('#ProfileBadge'), Math.floor((stats.experience || 0) / 100) + 1);
	$('#PlayerVariable_Rating').text = stats.Rating || 'TBD';
	$('#PlayerVariable_WinMatches').text = (stats.gamesWon || 0) + '/' + (stats.gamesPlayed || 0);
	// TODO: use rest api for other features
}

(function() {
	//LoadPanelForPlayer()
	if ($.GetContextPanel().id !== 'LocalPlayerData') {
		GameEvents.Subscribe('player_profiles_show_info', function(data) {
			if (Players.IsValidPlayerID(Number(data.playerId))) {
				LoadPanelForPlayer(Number(data.playerId));
			}
		});
	}

	$.GetContextPanel().LoadPanelForPlayer = LoadPanelForPlayer;
	//LoadPanelForPlayer(0)
})();

