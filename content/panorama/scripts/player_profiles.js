function LoadPanelForPlayer(playerId) {
	//	var PlayerProfileBase
	$.GetContextPanel().AddClass('PanelOpened');
	var steamid = Game.GetPlayerInfo(playerId).player_steamid;
	$('#Avatar').steamid = steamid;
	$('#UserName').steamid = steamid;
	var stats = Players.GetStatsData(playerId);
	SetPagePlayerLevel(Math.floor((stats.experience || 0) / 100) + 1);
	$('#PlayerVariable_Rating').text = stats.Rating || 'TBD';
	$('#PlayerVariable_WinMatches').text = (stats.gamesWon || 0) + '/' + (stats.gamesPlayed || 0);
	// TODO: use rest api for other features
}

function SetPagePlayerLevel(level) {
	var ProfileBadge = $('#ProfileBadge');
	var levelbg = Math.floor(level / 100);
	ProfileBadge.FindChildTraverse('BackgroundImage').SetImage('file://{images}/profile_badges/bg_' + ('0' + (levelbg + 1)).slice(-2) + '.psd');
	ProfileBadge.FindChildTraverse('ItemImage').SetImage('file://{images}/profile_badges/level_' + ('0' + (level - levelbg * 100)).slice(-2) + '.png');
	ProfileBadge.FindChildTraverse('ProfileLevel').SetImage('file://{images}/profile_badges/bg_number_01.psd');
	ProfileBadge.FindChildTraverse('ProfileLevel').GetChild(0).text = level;
}

(function() {
	//LoadPanelForPlayer()
	if ($.GetContextPanel().id !== 'LocalPlayerData') {
		GameEvents.Subscribe('player_profiles_show_info', function(data) {
			if (Players.IsValidPlayerID(Number(data.PlayerID))) {
				LoadPanelForPlayer(Number(data.PlayerID));
			}
		});
	}

	$.GetContextPanel().LoadPanelForPlayer = LoadPanelForPlayer;
	//LoadPanelForPlayer(0)
})();

