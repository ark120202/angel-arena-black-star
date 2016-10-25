"use strict";
var ChatShown = false;
var DoubleClick = false

function EnterPressed() {
	if (!DoubleClick) {
		DoubleClick = true
		$.Schedule(0.03, function() {
			DoubleClick = false
		})
		if (ChatShown) {
			$("#SelectionChatEntry").text = ""
			SetPanelVisible(false)
			var dummyPanel = $.CreatePanel('TextEntry', $.GetContextPanel(), "")
			dummyPanel.SetFocus()
			dummyPanel.DeleteAsync(0)
		} else {
			$("#SelectionChatEntry").text = ""
			SetPanelVisible(true)
			$.GetContextPanel().TeamOnlyChat = !GameUI.IsShiftDown()
			if (GameUI.IsShiftDown()) {
				$("#MessageScopeLabel").text = "[A]"
				$("#MessageScopeLabel").style.color = "red"
			} else {
				$("#MessageScopeLabel").text = "[T]"
				$("#MessageScopeLabel").style.color = "lime"
			}
			$("#SelectionChatEntry").SetFocus()
		}
	}
}

function SetPanelVisible(visible) {
	ChatShown = visible
	$("#SelectionChatEntry").enabled = visible
	$.GetContextPanel().SetHasClass("Shown", visible)
}

(function() {
	Game.Events.EnterPressed.push(EnterPressed)
	SetPanelVisible(false)
	$.GetContextPanel().OnChatEvent = EnterPressed
})()