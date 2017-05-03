var CurrentEntityHoveredPanel, CurrentEntityHoveredIndex;
var Check = function() {
	var CursorTargetEnts = [];
	_.each(GameUI.FindScreenEntities(GameUI.GetCursorPosition()), function(target) {
		var ent = Number(target.entityIndex);
		CursorTargetEnts.push(ent);
		var entTooltipInfo = GameUI.CustomUIConfig().custom_entity_values[ent];
		if (entTooltipInfo != null && entTooltipInfo.custom_tooltip != null && CurrentEntityHoveredPanel == null) {
			CurrentEntityHoveredIndex = ent;
			CurrentEntityHoveredPanel = $.CreatePanel("Panel", $.GetContextPanel(), "");
			var abs = Entities.GetAbsOrigin(ent);
			CurrentEntityHoveredPanel.style.position = ((Game.WorldToScreenX(abs[0], abs[1], abs[2]) / Game.GetScreenWidth()) * 100) + "% " + ((Game.WorldToScreenY(abs[0], abs[1], abs[2]) / Game.GetScreenHeight()) * 100) + "% 0";
			CurrentEntityHoveredPanel.style.tooltipPosition = "bottom";
			$.DispatchEvent("DOTAShowTitleTextTooltip", CurrentEntityHoveredPanel, entTooltipInfo.custom_tooltip.title, entTooltipInfo.custom_tooltip.text);
			return false;
		}
	});
	if (CurrentEntityHoveredIndex != null && CursorTargetEnts.indexOf(CurrentEntityHoveredIndex) === -1) {
		$.DispatchEvent("DOTAHideTitleTextTooltip");
		CurrentEntityHoveredPanel.visible = false;
		CurrentEntityHoveredPanel.DeleteAsync(0);
		CurrentEntityHoveredPanel = null;
		CurrentEntityHoveredIndex = null;
	}
	$.Schedule(0.1, Check);
};
Check();
