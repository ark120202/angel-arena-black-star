var SelectedBuild = {},
	CustomBuildToggleButton = {};

function UpdateItembuildsForHero() {
	var heroName = GetPlayerHeroName(Game.GetLocalPlayerID());
	if (LastHero !== heroName && heroName && heroName !== 'npc_dota_hero_arena_base' && heroName !== 'npc_dota_hero_target_dummy') {
		LastHero = heroName;
		LoadGuidesForHero(heroName);
	}
}

function LoadGuidesForHero(heroName, skipAutoSelect, callback) {
	GetDataFromServer('GetGuides', {steamID: Game.GetLocalPlayerInfo().player_steamid, hero: heroName}, function(builds) {
		if (LastHero === heroName) {
			var autoSelectedBuild;
			var best = builds.best;
			$('#GuidesAvaliableList').RemoveAndDeleteChildren();
			if (builds.standard) Snippet_GuideListEntry(builds.standard);

			CustomBuildToggleButton = Snippet_GuideListEntry({steamID: -1});
			_.each(best, function(build) {
				if (!autoSelectedBuild) autoSelectedBuild = build;
				Snippet_GuideListEntry(build);
			});
			if (!autoSelectedBuild) autoSelectedBuild = builds.standard;
			if (!skipAutoSelect) SelectItembuild(autoSelectedBuild);
			if (callback) callback();
		}
	}, function(error) {
		if (LastHero === heroName) {
			$('#GuidesAvaliableList').RemoveAndDeleteChildren();
			CustomBuildToggleButton = Snippet_GuideListEntry({steamID: -1});
			if (!skipAutoSelect) SelectItembuild(null);
		}
	});
}

function SelectItembuild(build) {
	SelectedBuild = build;
	var groupsRoot = $('#ItembuildPanelsRoot');
	$('#ItembuildPanelsRoot').RemoveAndDeleteChildren();
	if (build != null) {
		$('#Itembuild_version').text = build.version || '';
		UpdateSelectedItembuildAuthorData(build.steamID, build.title);
		_.each(build.items, function(groupData) {
			CreateItembuildGroup(groupsRoot, build.steamID === -1 ? $.Localize(groupData.title) : groupData.title, groupData.content);
		});
	} else {
		UpdateSelectedItembuildAuthorData(-1);
	}
}

function UpdateSelectedItembuildAuthorData(steamID, title) {
	var Itembuild_author_player = $('#Itembuild_author_player');
	$('#Itembuild_title').text = steamID === 0 ? $.Localize('DOTA_UI_default_build') : steamID === -1 ? $.Localize('DOTA_UI_scratch_build_for').replace('%s', $.Localize(LastHero)) : title || '';
	Itembuild_author_player.visible = typeof steamID === 'string';
	Itembuild_author_player.steamid = steamID;
	Itembuild_author_player.SetAttributeString('steamid', steamID);
}

function AddNewGroupToItembuild() {
	CreateItembuildGroup($('#ItembuildPanelsRoot'), 'New Group', []);
}

function CreateItembuildGroup(groupsRoot, title, content) {
	var groupRoot = $.CreatePanel('Panel', groupsRoot, '');
	groupRoot.BLoadLayoutSnippet('ItembuildGroup');
	var groupTitle = groupRoot.FindChildTraverse('ItembuildItemGroupTitle');
	groupTitle.text = title;
	groupTitle.enabled = $.GetContextPanel().BHasClass('EditMode');
	var itemsRoot = groupRoot.FindChildTraverse('ItembuildItemGroupItemRoot');
	var createPanelForGroup = function(item) {
		var itemPanel = SnippetCreate_SmallItem($.CreatePanel('Panel', itemsRoot, 'shop_itembuild_items_' + item), item, false, function(panel) {
			if ($.GetContextPanel().BHasClass('EditMode')) panel.visible = false;
			return true;
		}, function(panel) {
			if ($.GetContextPanel().BHasClass('EditMode')) {
				panel.DeleteAsync(0);
				UpdateSelectedItembuildAuthorData(-1);
			}
		});
		$.RegisterEventHandler('DragDrop', itemPanel, function(panelId, draggedPanel) {
			if ($.GetContextPanel().BHasClass('EditMode') && draggedPanel.itemname != null) {
				itemsRoot.MoveChildBefore(createPanelForGroup(draggedPanel.itemname), itemPanel);
				return true;
			}
		});
		return itemPanel;
	};

	$.RegisterEventHandler('DragStart', itemsRoot, function(panelId, dragCallbacks) {
		//$.GetContextPanel().AddClass("DropDownMode")
		if (!$.GetContextPanel().BHasClass('EditMode')) return false;
		var displayPanel = $.CreatePanel('Label', groupRoot, '');
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
		if ($.GetContextPanel().BHasClass('EditMode') && draggedPanel.itemname) {
			createPanelForGroup(draggedPanel.itemname);
			UpdateSelectedItembuildAuthorData(-1);
			return true;
		} else if (draggedPanel.ItembuildParentPanel != null) {
			groupsRoot.MoveChildBefore(draggedPanel.ItembuildParentPanel, groupRoot);
			UpdateSelectedItembuildAuthorData(-1);
		}
	});
	_.each(content, createPanelForGroup);
}

function ToggleEditMode(state) {
	var newState = state != null ? state : !$.GetContextPanel().BHasClass('EditMode');

	_.each($('#ItembuildPanelsRoot').Children(), function(child) {
		var te = child.GetChild(0);
		te.enabled = newState;
		if (te.BHasKeyFocus()) {
			$.GetContextPanel().SetFocus();
		}
	});
	if (newState) ToggleGuidesBrowser(false);
	$.GetContextPanel().SetHasClass('EditMode', newState);
}

function ParseCurrentGuide() {
	var build = {steamID: -1, items: []};
	_.each($('#ItembuildPanelsRoot').Children(), function(group) {
		var g = {title: group.GetChild(0).text, content: []};
		_.each(group.GetChild(1).Children(), function(item) {
			g.content.push(item.itemName);
		});
		build.items.push(g);
	});
	return build;
}

function ToggleGuidesBrowser(state) {
	var newState = state != null ? state : !$.GetContextPanel().BHasClass('GuidesBrowserVisible');
	$.GetContextPanel().SetHasClass('GuidesBrowserVisible', newState);
	if (newState) {
		ToggleEditMode(false);
		if ($('#Itembuild_author_player').GetAttributeString('steamid', '-1') === '-1') {
			SelectedBuild = ParseCurrentGuide();
			CustomBuildToggleButton.build = SelectedBuild;
		}
		CustomBuildToggleButton.visible = CustomBuildToggleButton.build.items != null;
		_.each($('#GuidesAvaliableList').Children(), function(c) {
			c.checked = c.build === SelectedBuild;
			c.SetHasClass('IsSelectedGuide', c.build === SelectedBuild);
		});
		GuidesBrowserLoadBuild(SelectedBuild);
	}
}

function Snippet_GuideListEntry(build) {
	var steamID = build.steamID;
	var panel = $.CreatePanel('RadioButton', $('#GuidesAvaliableList'), '');
	panel.BLoadLayoutSnippet('GuideListEntry');
	panel.SetDialogVariable('guide_entry_rating', build.votes != null ? build.votes : '');

	panel.FindChildTraverse('GuideEntryVersion').text = build.version || '';
	var GuideEntryAuthor = panel.FindChildTraverse('GuideEntryAuthor');
	GuideEntryAuthor.visible = typeof steamID === 'string';
	GuideEntryAuthor.steamid = steamID;

	panel.SetDialogVariable('guide_entry_title', steamID === 0 ? $.Localize('DOTA_UI_default_build') : steamID === -1 ? $.Localize('DOTA_UI_scratch_build_for').replace('%s', $.Localize(LastHero)) : build.title || '');
	panel.build = build;
	panel.SetPanelEvent('onactivate', function() {
		GuidesBrowserLoadBuild(panel.build);
	});
	panel.FindChildTraverse('SelectGuideButton').SetPanelEvent('onactivate', function() {
		SelectItembuild(panel.build);
		_.each($('#GuidesAvaliableList').Children(), function(c) {
			c.SetHasClass('IsSelectedGuide', c.build === SelectedBuild);
		});
	});
	return panel;
}


var CurrentPageGuide = {};
function GuideVote(vote) {
	var newVotes = CurrentPageGuide.votes;
	if ($.GetContextPanel().BHasClass('VotedYes')) {
		if (vote > 0) return; newVotes--; vote = 0;
	} else if ($.GetContextPanel().BHasClass('VotedNo')) {
		if (vote < 0) return; newVotes++; vote = 0;
	} else
		newVotes += vote;
	$.GetContextPanel().SetHasClass('VotedYes', vote > 0);
	$.GetContextPanel().SetHasClass('VotedNo', vote < 0);

	CurrentPageGuide.votes = newVotes;
	var localSteamId = Game.GetLocalPlayerInfo().player_steamid;
	if (vote >= 0) {
		var i = CurrentPageGuide.votes_down.indexOf(localSteamId);
		if (i > -1) CurrentPageGuide.votes_down.splice(i, 1);
	}
	if (vote <= 0) {
		var i = CurrentPageGuide.votes_up.indexOf(localSteamId);
		if (i > -1) CurrentPageGuide.votes_up.splice(i, 1);
	}
	if (vote !== 0) {
		var a = CurrentPageGuide[vote > 0 ? 'votes_up' : 'votes_down'];
		if (a.indexOf(localSteamId) === -1) a.push(localSteamId);
	}
	_.each($('#GuidesAvaliableList').Children(), function(c) {
		if (c.build === CurrentPageGuide) {
			c.SetDialogVariable('guide_entry_rating', newVotes);
			return false;
		}
	});
	$.GetContextPanel().SetDialogVariable('guide_player_rating', newVotes);

	GameEvents.SendCustomGameEventToServer('stats_client_vote_guide', {id: CurrentPageGuide._id, vote: vote});
}

function GuidesBrowserLoadBuild(build) {
	var steamID = build.steamID;
	CurrentPageGuide = build;
	var localSteamId = Game.GetLocalPlayerInfo().player_steamid;
	$.GetContextPanel().SetHasClass('ShowVoteAndFavorite', typeof steamID === 'string');
	$.GetContextPanel().SetHasClass('HasYouTubeVideo', build.youtube != null);
	$.GetContextPanel().SetHasClass('CanPublishBuild', steamID === -1);

	$.GetContextPanel().SetHasClass('VotedYes', _.includes(build.votes_up, localSteamId));
	$.GetContextPanel().SetHasClass('VotedNo', _.includes(build.votes_down, localSteamId));
	$.GetContextPanel().SetDialogVariable('guide_player_rating', build.votes || 0);

	if (steamID !== -1) TogglePublishMode(false);

	$('#GuidesTitleLabel').text = steamID === 0 ? $.Localize('DOTA_UI_default_build') : steamID === -1 ? $.Localize('DOTA_UI_scratch_build_for').replace('%s', $.Localize(LastHero)) : build.title || '';
	$('#GuidesBrowserDescription').text = build.description || '';
	var GuideItemBuild = $('#GuideItemBuild');
	_.each(GuideItemBuild.FindChildrenWithClassTraverse('SmallItemPanel'), function(c) {
		c.DestroyItemPanel();
	});
	GuideItemBuild.RemoveAndDeleteChildren();
	_.each(build.items, function(groupData) {
		CreateItembuildGroup(GuideItemBuild, groupData.title, groupData.content);
	});
}

function OpenYoutubeForGuide(build) {
	if (build && build.youtube) $.DispatchEvent('ExternalBrowserGoToURL', 'https://www.youtube.com/watch?v=' + build.youtube);
}

function TogglePublishMode(state) {
	var newState = state != null ? state : !$.GetContextPanel().BHasClass('InGuidePublishMode');
	$.GetContextPanel().SetHasClass('InGuidePublishMode', newState);
	$('#GuidesTitleLabel').enabled = newState;
}

function PublishGuide(build) {
	var build = CustomBuildToggleButton.build;
	build.title = $('#GuidesTitleLabel').text;
	build.description = $('#GuidePublishDescription').text;
	build.youtube = $('#GuidePublishYouTube').text;
	if (build.title === $.Localize('DOTA_UI_scratch_build_for').replace('%s', $.Localize(LastHero)).substring(0, 20)) {
		GameEvents.SendEventClientSide('dota_hud_error_message', {
			'reason': 80,
			'message': '#error_panorama_shop_publish_guide_title'
		});
	} else {
		GameEvents.SendCustomGameEventToServer('stats_client_add_guide', build);
		TogglePublishMode(false);
	}
}

(function() {
	var groupsRoot = $('#ItembuildPanelsRoot');
	$.RegisterEventHandler('DragDrop', $('#ShopItemBasePanel'), function(panelId, draggedPanel) {
		if (draggedPanel.ItembuildParentPanel != null) {
			draggedPanel.ItembuildParentPanel.DeleteAsync(0);
			UpdateSelectedItembuildAuthorData(-1);
		}
	});
	GameEvents.Subscribe('stats_client_add_guide_success', function(data) {
		$('#GuidePublishDescription').text = '';
		$('#GuidePublishYouTube').text = '';
		LoadGuidesForHero(LastHero, true, function() {
			_.each($('#GuidesAvaliableList').Children(), function(c) {
				if (c.build && c.build._id === data.insertedId) SelectItembuild(c.build);
			});
			ToggleGuidesBrowser($.GetContextPanel().BHasClass('GuidesBrowserVisible'));

		});
	});
	TogglePublishMode(false);
})();
