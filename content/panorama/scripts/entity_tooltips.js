var CurrentEntityHoveredPanel, CurrentEntityHoveredIndex, CurrentTitle, CurrentText;
var Check = function() {
	var CursorTargetEnts = [];
	var cursorEntities = GameUI.FindScreenEntities(GameUI.GetCursorPosition());
	for (var i = 0; i < cursorEntities.length; i++) {
		var ent = Number(cursorEntities[i].entityIndex);
		CursorTargetEnts.push(ent);
		var entTooltipInfo = GameUI.CustomUIConfig().custom_entity_values[ent];
		if (entTooltipInfo != null && entTooltipInfo.custom_tooltip != null && CurrentEntityHoveredPanel == null) {
			CurrentEntityHoveredIndex = ent;
			CurrentEntityHoveredPanel = $.CreatePanel('Panel', $.GetContextPanel(), '');
			var abs = Entities.GetAbsOrigin(ent);
			CurrentEntityHoveredPanel.style.position = ((Game.WorldToScreenX(abs[0], abs[1], abs[2]) / Game.GetScreenWidth()) * 100) + '% ' + ((Game.WorldToScreenY(abs[0], abs[1], abs[2]) / Game.GetScreenHeight()) * 100) + '% 0';
			CurrentEntityHoveredPanel.style.tooltipPosition = 'bottom';
			CurrentTitle = entTooltipInfo.custom_tooltip.title
			CurrentText = entTooltipInfo.custom_tooltip.text
			break;
		}
	}
	if (CurrentEntityHoveredIndex != null) {
		if (CursorTargetEnts.indexOf(CurrentEntityHoveredIndex) === -1) {
			$.DispatchEvent('DOTAHideTitleTextTooltip');
			CurrentEntityHoveredPanel.visible = false;
			CurrentEntityHoveredPanel.DeleteAsync(0);
			CurrentEntityHoveredPanel = null;
			CurrentEntityHoveredIndex = null;
			TooltipsTitleLabel = null
		} else {
			$.DispatchEvent('DOTAShowTitleTextTooltip', CurrentEntityHoveredPanel, CurrentTitle, CurrentText);
		}
	}
	$.Schedule(0, Check);
};
Check();
