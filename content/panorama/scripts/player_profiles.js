function LoadPanelForPlayer(playerId) {
	//	var PlayerProfileBase
	$.GetContextPanel().AddClass("PanelOpened")
	var player_info = Game.GetPlayerInfo(playerId)
	var steamid = player_info.player_steamid
	$("#Avatar").steamid = steamid
	$("#UserName").steamid = steamid
	$("#PlayerVariable_Rating").text = "--"
	$("#PlayerVariable_WinMatches").text = "0/0";
	SetPagePlayerLevel(1)
	$.AsyncWebRequest('http://127.0.0.1:3228/getPlayerInfo/' + steamid, {
		type: 'GET',
		success: function(data) {
			$.Msg('Server Reply: ', data)
			if (data) {
				SetPagePlayerLevel(data.Level)
				$("#PlayerVariable_Rating").text = data.MMR;
				$("#PlayerVariable_WinMatches").text = data.Wins + "/" + data.Matches;
			}
		}
	});
}

function SetPagePlayerLevel(level) {
	var ProfileBadge = $("#ProfileBadge")
	var levelbg = Math.floor(level / 100)
	ProfileBadge.FindChildTraverse("BackgroundImage").SetImage("file://{images}/profile_badges/bg_" + ('0' + (levelbg + 1)).slice(-2) + ".psd")
	ProfileBadge.FindChildTraverse("ItemImage").SetImage("file://{images}/profile_badges/level_" + ('0' + (level - levelbg * 100)).slice(-2) + ".png")
	ProfileBadge.FindChildTraverse("ProfileLevel").SetImage("file://{images}/profile_badges/bg_number_01.psd")
	ProfileBadge.FindChildTraverse("ProfileLevel").GetChild(0).text = level
}

(function() {
	//LoadPanelForPlayer()
	$.GetContextPanel().RemoveClass("PanelOpened")
	GameEvents.Subscribe("player_profiles_show_info", function(data) {
		if (data != null && data.playerId != null && Players.IsValidPlayerID(Number(data.playerId))) {
			LoadPanelForPlayer(Number(data.playerId))
		}
	});
	//LoadPanelForPlayer(0)
})() //asdasdsssssssssssdSssssssSSSSSSSCsassss