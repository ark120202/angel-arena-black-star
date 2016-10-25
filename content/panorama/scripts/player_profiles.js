function LoadPanelForPlayer(playerId) {
	//	var PlayerProfileBase
	$.GetContextPanel().AddClass("PanelOpened")
	var player_info = Game.GetPlayerInfo(playerId)
	var steamid = player_info.player_steamid
	$("Avatar").steamid = steamid
	$.AsyncWebRequest('http://127.0.0.1:3228/getPlayerInfo/' + steamid, {
		type: 'GET',
		success: function(data) {
			$.Msg('Server Reply: ', data)
			if (data && data.MMR != null) {

			}
		}
	});
}

function HidePanel() {
	$.GetContextPanel().RemoveClass("PanelOpened")
}

(function() {
	//LoadPanelForPlayer()
	HidePanel()
	GameEvents.Subscribe("player_profiles_show_info", function(data) {
		if (data != null && data.playerId != null && Players.IsValidPlayerID(Number(data.playerId))) {
			LoadPanelForPlayer(Number(data.playerId))
		}
	})
})() //asdasdsssssssssssdSssssssSSSSSSSCsassss