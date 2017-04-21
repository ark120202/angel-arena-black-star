var SelectedBuild = {},
	CustomBuildToggleButton;
function UpdateItembuildsForHero() {
	var heroName = GetPlayerHeroName(Game.GetLocalPlayerID())
	if (LastHero != heroName) {
		LastHero = heroName;
		itembuildsEverLoaded = false;
		GetDataFromServer("GetItembuilds", {steamID: Game.GetLocalPlayerInfo().player_steamid, startFrom: "", hero: heroName}, function(builds) {
			if (LastHero == heroName) { //If hero wasn't changed while builds loaded
				var autoSelectedBuild;
				var best = builds.best;
				$("#GuidesAvaliableList").RemoveAndDeleteChildren()
				if (builds.standard) Snippet_GuideListEntry(builds.standard)
				CustomBuildToggleButton = Snippet_GuideListEntry({steamID: -1})
				$.Each(best, function(build) {
					if (!autoSelectedBuild) autoSelectedBuild = build;
					Snippet_GuideListEntry(build)
				})
				if (!autoSelectedBuild) autoSelectedBuild = builds.standard;
				//$.GetContextPanel().SetHasClass("ItembuildsHidden", autoSelectedBuild == null)
				SelectItembuild(autoSelectedBuild);
			}
		});
	}
}
function SelectItembuild(t) {
	SelectedBuild = t;
	var groupsRoot = $("#ItembuildPanelsRoot")
	$("#ItembuildPanelsRoot").RemoveAndDeleteChildren();
	if (t != null) {
		$("#Itembuild_patch").text = t.version || "";
		UpdateSelectedItembuildAuthorData(t.steamID, t.title)
		//MongoObjectIDToDate(t._id)
		$.Each(t.items, function(groupData) {
			CreateItembuildGroup(groupsRoot, groupData.title, groupData.content)
		})
	} else {
		$("#Itembuild_author").text = "";
		$("#Itembuild_patch").text = "";
	}
}

function UpdateSelectedItembuildAuthorData(steamID, title) {
	var Itembuild_author_player = $("#Itembuild_author_player")
	$("#Itembuild_title").text = steamID == 0 ? $.Localize("DOTA_UI_default_build") : steamID == -1 ? $.Localize("DOTA_UI_scratch_build_for").replace("%s", $.Localize(LastHero)) : title || ""
	Itembuild_author_player.visible = steamID > 0
	Itembuild_author_player.steamid = steamID
	Itembuild_author_player.SetAttributeString("steamid", steamID)
}

function AddNewGroupToItembuild() {
	CreateItembuildGroup($("#ItembuildPanelsRoot"), "New Group", [])
}

function CreateItembuildGroup(groupsRoot, title, content) {
	var groupRoot = $.CreatePanel("Panel", groupsRoot, "");
	groupRoot.AddClass("ItembuildItemGroup");
	groupRoot.SetDraggable(true)
	var groupTitle = $.CreatePanel("TextEntry", groupRoot, "");
	groupTitle.AddClass("ItembuildItemGroupTitle");
	groupTitle.text = title;
	groupTitle.enabled = $.GetContextPanel().BHasClass("EditMode");
	var itemsRoot = $.CreatePanel("Panel", groupRoot, "");
	itemsRoot.AddClass("ItembuildItemGroupItemRoot");
	var createPanelForGroup = function(item) {
		var itemPanel = SnippetCreate_SmallItem($.CreatePanel("Panel", itemsRoot, "shop_itembuild_items_" + item), item, false, function(panel) {
			if ($.GetContextPanel().BHasClass("EditMode")) panel.visible = false;
			return true;
		}, function(panel) {
			if ($.GetContextPanel().BHasClass("EditMode")) panel.DeleteAsync(0)
		})
		$.RegisterEventHandler('DragDrop', itemPanel, function(panelId, draggedPanel) {
			if ($.GetContextPanel().BHasClass("EditMode") && draggedPanel.itemname != null) {
				itemsRoot.MoveChildBefore(createPanelForGroup(draggedPanel.itemname), itemPanel)
				UpdateSelectedItembuildAuthorData(-1)
				return true;
			}
		});
		return itemPanel;
	}

	$.RegisterEventHandler('DragStart', groupRoot, function(panelId, dragCallbacks) {
		//$.GetContextPanel().AddClass("DropDownMode")
		if (!$.GetContextPanel().BHasClass("EditMode")) return false;
		var displayPanel = $.CreatePanel("Label", groupRoot, "");
		displayPanel.text = groupTitle.text;
		displayPanel.ItembuildParentPanel = groupRoot;
		dragCallbacks.displayPanel = displayPanel;
		dragCallbacks.offsetX = 0;
		dragCallbacks.offsetY = 0;
		return true;
	});
	
	$.RegisterEventHandler('DragEnd', groupRoot, function(panelId, draggedPanel) {
		//$.GetContextPanel().RemoveClass("DropDownMode")
		draggedPanel.DeleteAsync(0);
		return true;
	});

	$.RegisterEventHandler('DragDrop', groupRoot, function(panelId, draggedPanel) {
		if ($.GetContextPanel().BHasClass("EditMode") && draggedPanel.itemname) {
			createPanelForGroup(draggedPanel.itemname)
			UpdateSelectedItembuildAuthorData(-1)
			return true;
		} else if (draggedPanel.ItembuildParentPanel != null) {
			groupsRoot.MoveChildBefore(draggedPanel.ItembuildParentPanel, groupRoot)
			UpdateSelectedItembuildAuthorData(-1)
		}
	});
	$.Each(content, createPanelForGroup)
}

function ToggleEditMode(state) {
	var newState = state != null ? state : !$.GetContextPanel().BHasClass("EditMode");

	$.Each($("#ItembuildPanelsRoot").Children(), function(child) {
		var te = child.GetChild(0);
		te.enabled = newState
		if (te.BHasKeyFocus()) {
			$.GetContextPanel().SetFocus()
		}
	})
	if (newState) ToggleGuidesBrowser(false)
	$.GetContextPanel().SetHasClass("EditMode", newState)
}

var itembuildsEverLoaded = false;
function ToggleGuidesBrowser(state) {
	var newState = state != null ? state : !$.GetContextPanel().BHasClass("GuidesBrowserVisible");
	$.GetContextPanel().SetHasClass("GuidesBrowserVisible", newState)
	if (newState) {
		if (!itembuildsEverLoaded) {
			itembuildsEverLoaded = true;
		}
		ToggleEditMode(false)
		if ($("#Itembuild_author_player").GetAttributeString("steamid", "-1") == "-1") {
			SelectedBuild = {steamID: -1, items: []};
			$.Each($("#ItembuildPanelsRoot").Children(), function(group) {
				var g = {title: group.GetChild(0).text, content: []}
				$.Each(group.GetChild(1).Children(), function(item) {
					g.content.push(item.itemName)
				})
				SelectedBuild.items.push(g)
			})
			CustomBuildToggleButton.build = SelectedBuild
		}
		CustomBuildToggleButton.visible = CustomBuildToggleButton.build.items != null
		$.Each($("#GuidesAvaliableList").Children(), function(c) {
			c.checked = c.build == SelectedBuild
			c.SetHasClass("IsSelectedGuide", c.build == SelectedBuild)
			GuidesBrowserLoadBuild(SelectedBuild)
		})
	}
}

function Snippet_GuideListEntry(build) {
	var steamID = build.steamID
	var panel = $.CreatePanel("RadioButton", $("#GuidesAvaliableList"), "")
	panel.BLoadLayoutSnippet("GuideListEntry")
	panel.SetDialogVariable("guide_entry_rating", build.rating || "")

	panel.SetDialogVariable("guide_entry_title", steamID == 0 ? $.Localize("DOTA_UI_default_build") : steamID == -1 ? $.Localize("DOTA_UI_scratch_build_for").replace("%s", $.Localize(LastHero)) : build.title || "")
	panel.build = build
	panel.SetPanelEvent("onactivate", function() {
		GuidesBrowserLoadBuild(panel.build)
	})
	panel.FindChildTraverse("SelectGuideButton").SetPanelEvent("onactivate", function() {
		SelectItembuild(panel.build)
		$.Each($("#GuidesAvaliableList").Children(), function(c) {
			c.SetHasClass("IsSelectedGuide", c.build == SelectedBuild)
		})
	})
	return panel;
}

function GuidesBrowserLoadBuild(build) {
	var steamID = build.steamID
	$("#GuidesTitleLabel").text = steamID == 0 ? $.Localize("DOTA_UI_default_build") : steamID == -1 ? $.Localize("DOTA_UI_scratch_build_for").replace("%s", $.Localize(LastHero)) : build.title || ""
	$("#GuidesBrowserDescription").text = build.description || ""
	$.Each(t.items, function(groupData) {
		CreateItembuildGroup(groupsRoot, groupData.title, groupData.content)
	})
}

(function() {
	var groupsRoot = $("#ItembuildPanelsRoot")
	/*$.RegisterEventHandler('DragDrop', groupsRoot, function(panelId, draggedPanel) {
		if (draggedPanel.ItembuildParentPanel != null) {
			groupsRoot.MoveChildAfter(draggedPanel.ItembuildParentPanel, groupsRoot.GetChild(groupsRoot.GetChildCount() - 1))
			UpdateSelectedItembuildAuthorData(-1)
		}
	});*/
	$.RegisterEventHandler('DragDrop', $("#ShopItemBasePanel"), function(panelId, draggedPanel) {
		if (draggedPanel.ItembuildParentPanel != null) {
			draggedPanel.ItembuildParentPanel.DeleteAsync(0)
			UpdateSelectedItembuildAuthorData(-1)
		}
	});
})();