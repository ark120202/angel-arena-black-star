var groupLevelMap = [];
var actualGroupIndex = 0;
var LearntTalents = {};
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

function SpecialValuesArrayToString(values, level) {
	if (typeof values != "object")
		return "<font color='gold'>" + values + "</font>"
	else {
		var text = "";
		$.Each(values, function(value, index) {
			if (index++ == level)
				value = "<font color='gold'>" + value + "</font>"
			text = text + value + "\/"
		})
		text = text.slice(0, -1);
		return text
	}

}

function CreateTalent(talent, root) {
	var panel = $.CreatePanel("Panel", root, "talent_icon_" + talent.name);
	panel.BLoadLayoutSnippet("TalentIcon");
	panel.SetPanelEvent("onmouseover", function() {
		var description = "+{damage}" //$.Localize("custom_talents_talent_" + talent.name + "_description");
		$.Each(talent.special_values, function(values, key) {
			description = description.replace("{" + key + "}", SpecialValuesArrayToString(values, LearntTalents[talent.name] == null ? -1 : LearntTalents[talent.name].level))
		});
		$.DispatchEvent("UIShowCustomLayoutParametersTooltip", panel, "TalentTooltip", "file://{resources}/layout/custom_game/custom_talent_tooltip.xml", "title=" + $.Localize("custom_talents_talent_" + talent.name) + "&description=" + description + "&cost=" + talent.cost + "&requirements=" + talent.requirement);
	});
	panel.SetPanelEvent("onmouseout", function() {
		$.DispatchEvent("UIHideCustomLayoutTooltip", panel, "TalentTooltip");
	});
	panel.SetPanelEvent("onactivate", function() {
		if (panel.BHasClass("CanLearn")) {
			GameEvents.SendCustomGameEventToServer("custom_talents_upgrade", {
				talent: talent.name
			});
			$.DispatchEvent("UIHideCustomLayoutTooltip", panel, "TalentTooltip");
		}
	});
	TalentsInfo[talent.name] = talent;
}

function Update() {
	var unit = Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID())
	var points = Entities.GetAbilityPoints(unit)
	$.Each($("#TalentListContainer").Children(), function(group, group_index) {
		var CompletedGroup = true;
		var GroupAvaliable = Entities.GetLevel(unit) >= group.RequiredLevel && group_index <= actualGroupIndex
		$.Each(group.FindChildTraverse("TalentColumnInner").Children(), function(icon) {
			var tn = icon.id.replace("talent_icon_", "")
			var requirement = TalentsInfo[tn].requirement
			var Error_Requirement = requirement != null && ((IsHeroName(requirement) && GetHeroName(unit) != requirement) || Entities.GetAbilityByName(unit, requirement) == -1)
			var Error_Points = points < TalentsInfo[tn].cost
			icon.SetHasClass("Error_Requirement", Error_Requirement)
			icon.SetHasClass("Error_Points", Error_Points)
			icon.SetHasClass("CanLearn", !Error_Requirement && !Error_Points && GroupAvaliable);

			icon.SetHasClass("Learnt", LearntTalents[tn] != null && LearntTalents[tn].level == (TalentsInfo[tn].max_level || 1))
			if (!icon.BHasClass("Learnt"))
				CompletedGroup = false;
		})
		group.SetHasClass("CompletedColumn", CompletedGroup)
		group.SetHasClass("EnabledColumn", !CompletedGroup && GroupAvaliable)
	})
	$.Schedule(0.1, Update)
}

(function() {
	GameEvents.Subscribe("custom_talents_toggle_tree", function() {
		$.GetContextPanel().ToggleClass("PanelOpened")
	});
	DynamicSubscribePTListener("custom_talents_data", function(tableName, changesObject, deletionsObject) {
		groupLevelMap = changesObject.groupLevelMap
		LoadTalentTable(changesObject.talentList)
	});
	DynamicSubscribePTListener("custom_talents_selected", function(tableName, changesObject, deletionsObject) {
		var info = changesObject[Game.GetLocalPlayerID()]
		if (info != null) {
			actualGroupIndex = info.actualGroup
			LearntTalents = info.talents || {}
		}
	});
	$('#ToggleHideRequirementErrors').checked = true;
	Update();
})();