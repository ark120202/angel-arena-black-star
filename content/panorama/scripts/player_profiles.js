function LoadPanelForPlayer(playerId) {
	//	var PlayerProfileBase
	$.GetContextPanel().AddClass('PanelOpened');
	var steamid = Game.GetPlayerInfo(playerId).player_steamid;
	$('#Avatar').steamid = steamid;
	$('#UserName').steamid = steamid;
	$('#PlayerVariable_Rating').text = '';
	$('#PlayerVariable_WinMatches').text = '';
	SetPagePlayerLevel(199);
	GetDataFromServer('player/' + steamid, null, function(data) {
		SetPagePlayerLevel(data.Level);
		$('#PlayerVariable_Rating').text = data.MMR;
		$('#PlayerVariable_WinMatches').text = data.Wins + '/' + data.Matches;
	}, function(e) {$.Msg(e);});
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
	if ($.GetContextPanel().BHasClass('CustomUIState_HUD')) { // Is hud element?
		$.GetContextPanel().RemoveClass('PanelOpened');
		GameEvents.Subscribe('player_profiles_show_info', function(data) {
			$.Msg('asd');
			if (Players.IsValidPlayerID(Number(data.PlayerID))) {
				LoadPanelForPlayer(Number(data.PlayerID));
			}
		});
	}
	$.GetContextPanel().LoadPanelForPlayer = LoadPanelForPlayer;
	//LoadPanelForPlayer(0)
})(); //asdasdsssssssssssdSssssssSSSSSSSCsassss
