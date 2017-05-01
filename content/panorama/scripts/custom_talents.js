var groupLevelMap = [];
var TalentsInfo = {};

function LoadTalentTable(table) {
	$.Each(table, function(group, group_index) {
		var grouppanel = $.CreatePanel("Panel", $("#TalentListContainer"), "talent_group_" + group_index);
		grouppanel.BLoadLayoutSnippet("TalentColumn");
		grouppanel.FindChildTraverse("TalentColumnHeader").text = groupLevelMap[group_index];
		grouppanel.RequiredLevel = groupLevelMap[group_index];
		$.Each(group, function(talent) {
			CreateTalent(talent, grouppanel.FindChildTraverse("TalentColumnInner"))
		})
	})
}

function SpecialValuesArrayToString(values, level, percent) {
	if (typeof values != "object") {
		if (level == 0)
			return percent ? values + "%" : values
		else
			return "<font color='gold'>" + (percent ? values + "%" : values) + "</font>"
	} else {
		var text = "";
		$.Each(values, function(value, index) {
			if (index++ == level)
				text = text + "<font color='gold'>" + (percent ? value + "%" : value) + "</font>" + "\/"
			else
				text = text + (percent ? value + "%" : value) + "\/"

		})
		text = text.slice(0, -1);
		return text
	}
}

function CreateTalent(talent, root) {
	var panel = $.CreatePanel("Image", root, "talent_icon_" + talent.name);
	panel.AddClass("TalentIcon")
	panel.SetImage(TransformTextureToPath(talent.icon));
	var CreateTooltip = function() {
		var description = $.Localize("custom_talents_" + talent.name + "_description");
		if (talent.special_values != null)
			$.Each(talent.special_values, function(values, key) {
				description = description.replace("{" + key + "}", SpecialValuesArrayToString(values, GetTalentLevel(Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID()), talent.name)))
				description = description.replace("{%" + key + "%}", SpecialValuesArrayToString(values, GetTalentLevel(Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID()), talent.name), true))
			});
		$.DispatchEvent("UIShowCustomLayoutParametersTooltip", panel, "TalentTooltip", "file://{resources}/layout/custom_game/custom_talent_tooltip.xml",
			"title=" + $.Localize("custom_talents_" + talent.name) +
			"&description=" + description.replace("+", "%2B") +
			"&cost=" + talent.cost +
			"&requirements=" + talent.requirement +
			"&levelText=" + $.Localize("custom_talents_level") + GetTalentLevel(Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID()), talent.name) + "\/" + (talent.max_level || 1)
		);
	}
	panel.SetPanelEvent("onmouseover", CreateTooltip);
	panel.SetPanelEvent("onmouseout", function() {
		$.DispatchEvent("UIHideCustomLayoutTooltip", panel, "TalentTooltip");
	});
	panel.SetPanelEvent("onactivate", function() {
		if (panel.BHasClass("CanLearn")) {
			GameEvents.SendCustomGameEventToServer("custom_talents_upgrade", {
				talent: talent.name
			});

			$.DispatchEvent("UIHideCustomLayoutTooltip", panel, "TalentTooltip");
			$.Schedule(0.1, function() {
				if (panel.BHasHoverStyle()) CreateTooltip()
			})
		}
	});
	TalentsInfo[talent.name] = talent;
}

function GetTalentLevel(unit, talent) {
	var t = GameUI.CustomUIConfig().custom_entity_values[unit]
	if (t != null && t.LearntTalents != null && t.LearntTalents[talent] != null)
		return t.LearntTalents[talent].level
	return 0
}

function GetActualTalentGroup(unit) {
	var t = GameUI.CustomUIConfig().custom_entity_values[unit]
	var highest = 0;
	if (t != null && t.LearntTalents != null && TalentsInfo != null) {
		for (var k in t.LearntTalents) {
			var level = t.LearntTalents[k].level
			var group = TalentsInfo[k].group
			highest = group > highest ? group : highest
		}
	}
	return highest
}

function Update() {
	$.Schedule(0.2, Update)
	var unit = Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID())
	var points = Entities.GetAbilityPoints(unit)
	$("#AbilityPointsLabel").text = points;
	$.Each($("#TalentListContainer").Children(), function(group, group_index) {
		var CompletedGroup = true;
		var GroupAvaliable = Entities.GetLevel(unit) >= group.RequiredLevel && group_index <= GetActualTalentGroup(unit)
		$.Each(group.FindChildTraverse("TalentColumnInner").Children(), function(icon) {
			var tn = icon.id.replace("talent_icon_", "");
			var requirement = TalentsInfo[tn].requirement;
			var Error_Requirement = requirement != null && ((IsHeroName(requirement) && GetHeroName(unit) != requirement) || Entities.GetAbilityByName(unit, requirement) == -1);
			var Error_Points = points < TalentsInfo[tn].cost;
			var level = GetTalentLevel(unit, tn);
			var Learnt = level == (TalentsInfo[tn].max_level || 1);
			icon.SetHasClass("Error_Requirement", Error_Requirement);
			icon.SetHasClass("Error_Points", Error_Points);
			icon.SetHasClass("Learnt", Learnt);
			icon.SetHasClass("CanLearn", !Learnt && !Error_Requirement && !Error_Points && GroupAvaliable);
			icon.SetHasClass("Selected", level > 0);
			if (icon.visible && !icon.BHasClass("Learnt"))
				CompletedGroup = false;
		});
		group.SetHasClass("CompletedColumn", CompletedGroup);
		group.SetHasClass("EnabledColumn", !CompletedGroup && GroupAvaliable);
	})
}

(function() {
	$("#TalentListContainer").RemoveAndDeleteChildren();
	GameEvents.Subscribe("custom_talents_toggle_tree", function() {
		$.GetContextPanel().ToggleClass("PanelOpened")
	});
	DynamicSubscribePTListener("custom_talents_data", function(tableName, changesObject, deletionsObject) {
		groupLevelMap = changesObject.groupLevelMap
		LoadTalentTable(changesObject.talentList)
	});
	$('#ToggleHideRequirementErrors').checked = true;
	Update();
})();