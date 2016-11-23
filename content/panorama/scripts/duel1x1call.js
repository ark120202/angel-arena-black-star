"use strict";
var enemiesPanels = []
var selectedEnemyID = -1
var HaveVisibleDuelMenu = false;
var MainPanel = $("#ElementBox")

function CallMenu(data) {
	if (!HaveVisibleDuelMenu) {
		ShowCallMenu(data)
	} else {
		HideCallMenu()
	}
}

function ShowCallMenu(data) {
	var ids = Game.GetAllPlayerIDs()
	var enemyIDs = []
	for (var id in ids) {
		if (Players.GetTeam(Number(id)) != Players.GetTeam(Number(Game.GetLocalPlayerID()))) {
			enemyIDs.push(Number(id))
		}
	}
	for (var i = 0; i <= enemyIDs.length - 1; i++) {
		var panel = $.CreatePanel('DOTAHeroImage', $('#DuelOpponents'), "dropDown_heroIcon_" + enemyIDs[i])
		panel.AddClass("EnemySelectionIcon")
		panel.playerid = enemyIDs[i]
		panel.heroname = Players.GetPlayerSelectedHero(enemyIDs[i])
		var _SetEnemySelected = (function(_panel) {
			return function() {
				SetEnemySelected(_panel)
			}
		})(panel)
		panel.SetPanelEvent('onactivate', _SetEnemySelected)
		enemiesPanels.push(panel)
	}
	MainPanel.visible = true
	HaveVisibleDuelMenu = true
}

function HideCallMenu() {
	$('#DuelOpponents').RemoveAndDeleteChildren()
	MainPanel.visible = false
	HaveVisibleDuelMenu = false
	enemiesPanels = []
	selectedEnemyID = -1
	$("#call_duel_button").enabled = false
}

function SetEnemySelected(panel) {
	selectedEnemyID = panel.playerid
	$("#call_duel_button").enabled = true
	for (var enemyPanel in enemiesPanels) {
		if (enemiesPanels[enemyPanel].BHasClass("EnemySelectionIconSelected")) {
			enemiesPanels[enemyPanel].RemoveClass("EnemySelectionIconSelected")
			enemiesPanels[enemyPanel].AddClass("EnemySelectionIcon")
		}
	}
	panel.AddClass("EnemySelectionIconSelected")
	panel.RemoveClass("EnemySelectionIcon")
}

function CallForDuel() {
	if (isNaN($("#GameGoldCost").text)) {
		$("#GameGoldCost").AddClass("RedOutlineForGoldNaN")
	} else {
		$("#GameGoldCost").RemoveClass("RedOutlineForGoldNaN")
		var data = {
			selectedEnemyID: selectedEnemyID,
			gold: $("#GameGoldCost").text,
			message: $("#GameMessage").text
		}
		GameEvents.SendCustomGameEventToServer("duel1x1call_send_call", data);
		HideCallMenu()
	}
}

(function() {
	MainPanel.visible = false
	GameEvents.Subscribe("duel1x1call_call", CallMenu);
})()