var CurrentEntityHoveredPanel, CurrentEntityHoveredIndex;
var Check = function() {
	var CursorTargetEnts = [];
	$.Each(GameUI.FindScreenEntities(GameUI.GetCursorPosition()), function(target) {
		var ent = Number(target.entityIndex);
		CursorTargetEnts.push(ent);
		var entTooltipInfo = GameUI.CustomUIConfig().custom_entity_values[ent];
		if (entTooltipInfo != null && entTooltipInfo.custom_tooltip != null && CurrentEntityHoveredPanel == null) {
			CurrentEntityHoveredIndex = ent;
			CurrentEntityHoveredPanel = $.CreatePanel("Panel", $.GetContextPanel(), "");
			var abs = Entities.GetAbsOrigin(ent);
			CurrentEntityHoveredPanel.style.position = ((Game.WorldToScreenX(abs[0], abs[1], abs[2]) / Game.GetScreenWidth()) * 100) + "% " + ((Game.WorldToScreenY(abs[0], abs[1], abs[2]) / Game.GetScreenHeight()) * 100) + "% 0";
			CurrentEntityHoveredPanel.style.tooltipPosition = "bottom";
				//CurrentEntityHoveredPanel.style.tooltipBodyPosition = "50%"
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
//attackable runes?
/*Game.MouseEvents.OnLeftPressed.push(function(ClickBehaviors, eventName, arg) {
	if (ClickBehaviors === CLICK_BEHAVIORS.DOTA_CLICK_BEHAVIOR_ATTACK) {
		var CursorTarget = GameUI.FindScreenEntities(GameUI.GetCursorPosition());
		$.Each(CursorTarget, function(target) {
			var ent = Number(target.entityIndex)
			CursorTargetEnts.push(ent)
			var entTooltipInfo = PossibleEntities[ent];
			if (entTooltipInfo != null && CurrentEntityHoveredPanel == null) {
				CurrentEntityHoveredIndex = ent;
				CurrentEntityHoveredPanel = $.CreatePanel("Panel", $.GetContextPanel(), "");
				var abs = Entities.GetAbsOrigin(ent)
				CurrentEntityHoveredPanel.style.position = Game.WorldToScreenX(abs[0], abs[1], abs[2]) + "px " + Game.WorldToScreenY(abs[0], abs[1], abs[2]) + "px 0"
				CurrentEntityHoveredPanel.style.transform = "translateX(14px) translateY(-36px)";
				$.DispatchEvent("DOTAShowTitleTextTooltip", CurrentEntityHoveredPanel, entTooltipInfo.title, entTooltipInfo.text /*DOTAShowTitleTextTooltipStyled , "RuneClass" )
			}
		});
	}
})*/
