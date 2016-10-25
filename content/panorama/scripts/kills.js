"use strict";

function CreateMessageTooltip(data) {
	var MainPanel = $.GetContextPanel()
	if (data != null) {
		var lastLine = MainPanel.GetChild(0);
		var TooltipLineBase = $.CreatePanel("Panel", MainPanel, "")
		TooltipLineBase.AddClass("TooltipLine")
		TooltipLineBase.hittest = false

		var TooltipLineBg = $.CreatePanel("Panel", TooltipLineBase, "")
		TooltipLineBg.AddClass("TooltipLineBg")
		TooltipLineBg.hittest = false

		var TooltipLine = $.CreatePanel("Panel", TooltipLineBase, "")
		TooltipLine.style.height = "100%"
		TooltipLine.style.flowChildren = "right"
		TooltipLine.hittest = false

		for (var panelKey in data) {
			var panelData = data[panelKey]
			var panel = $.CreatePanel("Panel", TooltipLine, "")
			panel.AddClass("TooltipLine_BasicSubPanel")
			panel.hittest = false
			if (panelData.p_style != null) {
				for (var style in panelData.p_style) {
					panel.style[style] = panelData.p_style[style]
				}
			}
			var element = null
			if (panelData.type == "heroIcon") {
				var element = $.CreatePanel("Image", panel, "")
				element.SetImage(TransformTextureToPath(panelData.heroName, "icon"))
				element.style.height = "48px"
				element.style.width = "48px"
			} else if (panelData.type == "picture") {
				var element = $.CreatePanel("Image", panel, "")
				element.SetImage("file://{images}/custom_game/kills/action_" + panelData.pictureType + ".png")
				element.style.height = "48px"
				element.style.width = "48px"
			} else if (panelData.type == "text") {
				var element = $.CreatePanel("Label", panel, "")
				element.text = panelData.text
				panel.width = "auto"
			}
			element.hittest = false
			element.style.align = "center center"
			if (panelData.style != null) {
				for (var style in panelData.style) {
					element.style[style] = panelData.style[style]
				}
			}
		}

		TooltipLineBase.DeleteAsync(20)

		if (lastLine != null) {
			MainPanel.MoveChildBefore(TooltipLine, lastLine);
		}
	}

}

(function() {
	GameEvents.Subscribe("kills_create_kill_tooltip", CreateMessageTooltip)
})()