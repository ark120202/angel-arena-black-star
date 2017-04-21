var SelectedBuild = {},
	CustomBuildToggleButton = {};
function UpdateItembuildsForHero() {
	var heroName = GetPlayerHeroName(Game.GetLocalPlayerID())
	if (LastHero != heroName && heroName != "npc_dota_hero_arena_base" && heroName != "npc_dota_hero_target_dummy") {
		LastHero = heroName;
		LoadGuidesForHero(heroName)
	}
}

function LoadGuidesForHero(heroName, skipAutoSelect, callback) {
	GetDataFromServer("GetGuides", {steamID: Game.GetLocalPlayerInfo().player_steamid, hero: heroName}, function(builds) {
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
			$.GetContextPanel().SetHasClass("ItembuildsHidden", autoSelectedBuild == null)
			if (!skipAutoSelect) SelectItembuild(autoSelectedBuild);
			if (callback) callback()
		}
	}, function(error) {
		if (LastHero == heroName) { //If hero wasn't changed while builds loaded
			$("#GuidesAvaliableList").RemoveAndDeleteChildren()
			CustomBuildToggleButton = Snippet_GuideListEntry({steamID: -1})
			$.GetContextPanel().AddClass("ItembuildsHidden")
			if (!skipAutoSelect) SelectItembuild(null);
		}
	});
}

function SelectItembuild(build) {
	SelectedBuild = build;
	var groupsRoot = $("#ItembuildPanelsRoot")
	$("#ItembuildPanelsRoot").RemoveAndDeleteChildren();
	if (build != null) {
		$("#Itembuild_patch").text = build.version || "";
		UpdateSelectedItembuildAuthorData(build.steamID, build.title)
		//MongoObjectIDToDate(build._id)
		$.Each(build.items, function(groupData) {
			CreateItembuildGroup(groupsRoot, groupData.title, groupData.content)
		})
	} else {
		UpdateSelectedItembuildAuthorData(-1)
	}
}

function UpdateSelectedItembuildAuthorData(steamID, title) {
	var Itembuild_author_player = $("#Itembuild_author_player")
	$("#Itembuild_title").text = steamID == 0 ? $.Localize("DOTA_UI_default_build") : steamID == -1 ? $.Localize("DOTA_UI_scratch_build_for").replace("%s", $.Localize(LastHero)) : title || ""
	Itembuild_author_player.visible = typeof steamID == "string"
	Itembuild_author_player.steamid = steamID
	Itembuild_author_player.SetAttributeString("steamid", steamID)
}

function AddNewGroupToItembuild() {
	CreateItembuildGroup($("#ItembuildPanelsRoot"), "New Group", [])
}

function CreateItembuildGroup(groupsRoot, title, content) {
	var groupRoot = $.CreatePanel("Panel", groupsRoot, "");
	groupRoot.BLoadLayoutSnippet("ItembuildGroup")
	var groupTitle = groupRoot.FindChildTraverse("ItembuildItemGroupTitle")
	groupTitle.text = title;
	groupTitle.enabled = $.GetContextPanel().BHasClass("EditMode");
	var itemsRoot = groupRoot.FindChildTraverse("ItembuildItemGroupItemRoot")
	var createPanelForGroup = function(item) {
		var itemPanel = SnippetCreate_SmallItem($.CreatePanel("Panel", itemsRoot, "shop_itembuild_items_" + item), item, false, function(panel) {
			if ($.GetContextPanel().BHasClass("EditMode")) panel.visible = false;
			return true;
		}, function(panel) {
			if ($.GetContextPanel().BHasClass("EditMode")) {
				panel.DeleteAsync(0)
				UpdateSelectedItembuildAuthorData(-1)
			}
		})
		$.RegisterEventHandler('DragDrop', itemPanel, function(panelId, draggedPanel) {
			if ($.GetContextPanel().BHasClass("EditMode") && draggedPanel.itemname != null) {
				itemsRoot.MoveChildBefore(createPanelForGroup(draggedPanel.itemname), itemPanel)
				return true;
			}
		});
		return itemPanel;
	}

	$.RegisterEventHandler('DragStart', itemsRoot, function(panelId, dragCallbacks) {
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
	
	$.RegisterEventHandler('DragEnd', itemsRoot, function(panelId, draggedPanel) {
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

function ParseCurrentGuide() {
	var build = {steamID: -1, items: []};
	$.Each($("#ItembuildPanelsRoot").Children(), function(group) {
		var g = {title: group.GetChild(0).text, content: []}
		$.Each(group.GetChild(1).Children(), function(item) {
			g.content.push(item.itemName)
		})
		build.items.push(g)
	})
	return build
}

function ToggleGuidesBrowser(state) {
	var newState = state != null ? state : !$.GetContextPanel().BHasClass("GuidesBrowserVisible");
	$.GetContextPanel().SetHasClass("GuidesBrowserVisible", newState)
	if (newState) {
		ToggleEditMode(false)
		if ($("#Itembuild_author_player").GetAttributeString("steamid", "-1") == "-1") {
			SelectedBuild = ParseCurrentGuide()
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
	$.GetContextPanel().SetHasClass("ShowVoteAndFavorite", typeof steamID == "string")
	$.GetContextPanel().SetHasClass("HasYouTubeVideo", build.youtube != null)
	$.GetContextPanel().SetHasClass("CanPublishBuild", steamID == -1)
	if (steamID != -1) TogglePublishMode(false)

	$.GetContextPanel().SetDialogVariable("guide_player_rating", build.score || 0)
	$("#GuidesTitleLabel").text = steamID == 0 ? $.Localize("DOTA_UI_default_build") : steamID == -1 ? $.Localize("DOTA_UI_scratch_build_for").replace("%s", $.Localize(LastHero)) : build.title || ""
	$("#GuidesBrowserDescription").text = build.description || ""
	var GuideItemBuild = $("#GuideItemBuild")
	$.Each(GuideItemBuild.FindChildrenWithClassTraverse("SmallItemPanel"), function(c) {
		c.DestroyItemPanel()
	})
	GuideItemBuild.RemoveAndDeleteChildren()
	$.Each(build.items, function(groupData) {
		CreateItembuildGroup(GuideItemBuild, groupData.title, groupData.content)
	})
}

function OpenYoutubeForGuide(build) {
	if (build && build.youtube) $.DispatchEvent("ExternalBrowserGoToURL", "https://www.youtube.com/watch?v=" + build.youtube);
}

function TogglePublishMode(state) {
	var newState = state != null ? state : !$.GetContextPanel().BHasClass("InGuidePublishMode");
	$.GetContextPanel().SetHasClass("InGuidePublishMode", newState)
	$("#GuidesTitleLabel").enabled = newState
}

function PublishGuide(build) {
	var build = CustomBuildToggleButton.build;
	build.title = $("#GuidesTitleLabel").text
	build.description = $("#GuidePublishDescription").text
	build.youtube = $("#GuidePublishYouTube").text
	if (build.title == $.Localize("DOTA_UI_scratch_build_for").replace("%s", $.Localize(LastHero))) {
		GameEvents.SendEventClientSide("dota_hud_error_message", {
			"reason": 80,
			"message": "#error_panorama_shop_publish_guide_title"
		});
	} else {
		GameEvents.SendCustomGameEventToServer("stats_client_add_guide", build)
		TogglePublishMode(false)
	}
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
	GameEvents.Subscribe("stats_client_add_guide_success", function(data) {
		$("#GuidePublishDescription").text = ""
		$("#GuidePublishYouTube").text = ""
		LoadGuidesForHero(LastHero, true, function() {
			$.Each($("#GuidesAvaliableList").Children(), function(c) {
				if (c.build && c.build._id == data.insertedId) SelectItembuild(c.build)
			})
			ToggleGuidesBrowser($.GetContextPanel().BHasClass("GuidesBrowserVisible"))

		})
	})
	TogglePublishMode(false)
})();