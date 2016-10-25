"use strict";

function ShowBanPanel() {
	$("#BanPanel").visible = true
}

function HideBanPanel() {
	$("#BanPanel").visible = false
}

(function() {
	GameEvents.Subscribe("apply_moidifer_banned", ShowBanPanel)
	GameEvents.Subscribe("remove_moidifer_banned", HideBanPanel)
	HideBanPanel()
})()