"use strict";
var MainPanel = $("#HeroSelectionBox")
var SelectedHeroPanel,
	SelectedTabIndex,
	SelectionTimerEndTime = 0,
	HideEvent,
	DOTA_ACTIVE_GAMEMODE,
	CustomChatLinesPanel,
	MinimapPTIDs = [],
	HeroesPanels = [],
	tabsData = {},
	PlayerSpawnBoxes = {},
	HeroSelectionState = -1,
	PlayerPanels = [],
	LocalPlayerStatus = {},
	InitializationStates = {},
	HasBanPoint = true;
var SteamIDSpecialBGs = {
	//ark120202
	/*109792606: [
		"https://pp.userapi.com/c638727/v638727976/1134a/d1RxLF8mWkE.jpg",
	],*/
	//Murzik
	82292900: [
		"https://wallpaperscraft.ru/image/kot_morda_pushistyj_polosatyj_97082_1920x1080.jpg",
		"http://file.mobilmusic.ru/b2/19/29/836852.jpg",
		"https://wallpaperscraft.ru/image/koshka_kot_seryy_poroda_russkaya_golubaya_glaza_zelenye_vzglyad_chernyy_fon_81774_1920x1080.jpg",
		"http://anywalls.com/pic/201304/1920x1080/anywalls.com-64496.jpg",
		"http://file.mobilmusic.ru/8f/8e/b8/768273.jpg",
	],
}

function HeroSelectionStart(HeroesServerData) {
	tabsData = HeroesServerData.HeroTabs
	for (var tabKey in tabsData) {
		var TabHeroesPanel = $.CreatePanel('Panel', $("#HeroListPanel"), "HeroListPanel_tabPanels_" + tabKey)
		TabHeroesPanel.BLoadLayoutSnippet("HeroesPanel")
		FillHeroesTable(tabsData[tabKey], TabHeroesPanel)
		TabHeroesPanel.visible = false
	}
	SelectHeroTab(1)
}

function HeroSelectionEnd(bImmidate) {
	$.GetContextPanel().style.opacity = 0
	$.Schedule(bImmidate ? 0 : 3.5, function() { //4 + 1.5 [+ 0.1] - 2 (dota delay)
		hud.GetChild(0).RemoveClass("IsBeforeGameplay")
	})
	$.Schedule(bImmidate ? 0 : 5.6, function() { //4 + 1.5 + 0.1
		MainPanel.visible = false
		FindDotaHudElement("PausedInfo").style.opacity = 1;
		if (HideEvent != null)
			GameEvents.Unsubscribe(HideEvent)
		if ($.GetContextPanel().PTID_hero_selection) PlayerTables.UnsubscribeNetTableListener($.GetContextPanel().PTID_hero_selection)
		if (MinimapPTIDs.length > 0)
			for (var i = 0; i < MinimapPTIDs.length; i++) {
				PlayerTables.UnsubscribeNetTableListener(MinimapPTIDs[i])
			}
		$.GetContextPanel().DeleteAsync(0)
	})
}

function ChooseHeroPanelHero() {
	ChooseHeroUpdatePanels()
	if (!IsLocalHeroLockedOrPicked()) {
		GameEvents.SendCustomGameEventToServer("hero_selection_player_hover", {
			hero: SelectedHeroName
		})
	}
}

function SelectHero() {
	if (!IsLocalHeroPicked()) {
		GameEvents.SendCustomGameEventToServer("hero_selection_player_select", {
			hero: SelectedHeroName
		})
		Game.EmitSound("ui.pick_play")
	}
}

function RandomHero() {
	if (!IsLocalHeroLockedOrPicked()) {
		GameEvents.SendCustomGameEventToServer("hero_selection_player_random", {})
	}
}

function UpdateSelectionButton() {
	var selectedHeroData = HeroesData[SelectedHeroName];
	$.GetContextPanel().SetHasClass("RandomingEnabled", !IsLocalHeroPicked() && !IsLocalHeroLocked() && HeroSelectionState > HERO_SELECTION_PHASE_BANNING)
	
	var canPick = !IsLocalHeroPicked()
		&& !IsHeroPicked(SelectedHeroName)
		&& !IsHeroBanned(SelectedHeroName)
		&& (!IsLocalHeroLocked() || SelectedHeroName == LocalPlayerStatus.hero);

	var context = $.GetContextPanel()
	var mode = "pick";
	if (HeroSelectionState == HERO_SELECTION_PHASE_BANNING) {
		mode = "ban"
		canPick = canPick && HasBanPoint
	} else if (selectedHeroData && selectedHeroData.linked_heroes) {
		mode = IsLocalHeroLocked() && selectedHeroData.heroKey == LocalPlayerStatus.hero ? "unlock" : "lock"
	}
	context.SetHasClass("LocalHeroLockButton", mode == "lock");
	context.SetHasClass("LocalHeroUnlockButton", mode == "unlock");
	context.SetHasClass("LocalHeroBanButton", mode == "ban");

	$("#SelectedHeroSelectButton").enabled = canPick
}

function UpdateTimer() {
	$.Schedule(0.2, UpdateTimer);
	var SelectionTimerRemainingTime = (SelectionTimerEndTime || Number.MIN_SAFE_INTEGER) - Game.GetGameTime()
	if (SelectionTimerRemainingTime > 0) {
		if (HeroSelectionState < HERO_SELECTION_PHASE_END) {
			hud.GetChild(0).AddClass("IsBeforeGameplay")
		}
		$("#HeroSelectionTimer").text = Math.ceil(SelectionTimerRemainingTime);
		SearchHero();
		for (var pid in PlayerPanels) {
			var panel = PlayerPanels[pid]
			var playerInfo = Game.GetPlayerInfo(Number(PlayerPanels));
			if (playerInfo != null) {
				panel.SetHasClass("player_connection_abandoned", playerInfo.player_connection_state == DOTAConnectionState_t.DOTA_CONNECTION_STATE_ABANDONED);
				panel.SetHasClass("player_connection_failed", playerInfo.player_connection_state == DOTAConnectionState_t.DOTA_CONNECTION_STATE_FAILED);
				panel.SetHasClass("player_connection_disconnected", playerInfo.player_connection_state == DOTAConnectionState_t.DOTA_CONNECTION_STATE_DISCONNECTED);
			}
		}
		_.each($MinimapSpawnBoxes().Children(), function(child) {
			var childrencount = child.GetChildCount()
			child.SetHasClass("SpawnBoxUnitPanelChildren2", childrencount >= 2)
			child.SetHasClass("SpawnBoxUnitPanelChildren3", childrencount >= 3)
			child.SetHasClass("SpawnBoxUnitPanelChildren5", childrencount >= 5)
		});
	} else {
		$("#HeroSelectionTimer").text = 0
	}
}

function Snippet_PlayerPanel(pid, rootPanel) {
	if (PlayerPanels[pid] == null) {
		var panel = $.CreatePanel("Panel", rootPanel, "")
		panel.BLoadLayoutSnippet("PlayerPanel")
		panel.SetDialogVariable("player_name", Players.GetPlayerName(pid))
		panel.SetDialogVariable("player_mmr", "Infinity")
		panel.FindChildTraverse("SlotColor").style.backgroundColor = GetHEXPlayerColor(pid)
		/*panel.FindChildTraverse("ImageHost").SetPanelEvent("", function() {

		})*/
		PlayerPanels[pid] = panel
	}
	return PlayerPanels[pid]
}

function IsLocalHeroPicked() {
	return LocalPlayerStatus.status == "picked"
}

function IsLocalHeroLocked() {
	return LocalPlayerStatus.status == "locked"
}

function IsLocalHeroLockedOrPicked() {
	return IsLocalHeroPicked() || IsLocalHeroLocked()
}

function UpdateHeroesSelected(tableName, changesObject, deletionsObject) {
	for (var teamNumber in changesObject) {
		if ($("#team_selection_panels_team" + teamNumber) == null) {
			var isRight = teamNumber % 2 != 0;
			var TeamSelectionPanel = $.CreatePanel('Panel', $(isRight ? "#RightTeams" : "#LeftTeams"), "team_selection_panels_team" + teamNumber)
			TeamSelectionPanel.AddClass("TeamSelectionPanel")
			var color = GameUI.CustomUIConfig().team_colors[teamNumber]
			TeamSelectionPanel.style.backgroundColor = "gradient(linear, 100% 100%, 0% 100%, from( " + color + "4D" + " ), to( transparent ))"
			//TeamSelectionPanel.style.opacityMask = "url('s2r://panorama/images/masks/hero_model_opacity_mask_png.vtex')"
		}
		var TeamSelectionPanel = $("#team_selection_panels_team" + teamNumber)
		for (var playerIdInTeam in changesObject[teamNumber]) {
			var playerData = changesObject[teamNumber][playerIdInTeam]
			var PlayerPanel = Snippet_PlayerPanel(Number(playerIdInTeam), TeamSelectionPanel)

			var isLocalPlayer = playerIdInTeam == Game.GetLocalPlayerID()
			var isLocalTeam = teamNumber == Players.GetTeam(Game.GetLocalPlayerID())

			if (isLocalPlayer) {
				LocalPlayerStatus = playerData
				$.GetContextPanel().SetHasClass("LocalPlayerLocked", playerData.status == "locked")
				if (!$.GetContextPanel().BHasClass("LocalPlayerPicked") && playerData.status == "picked") {
					OnLocalPlayerPicked()
				} else if ($.GetContextPanel().BHasClass("LocalPlayerPicked") && playerData.status != "picked") {
					ToggleHeroPreviewHeroList(false)
				}
				$.GetContextPanel().SetHasClass("LocalPlayerPicked", playerData.status == "picked")
			}

			PlayerPanel.SetHasClass("HeroPickHovered", playerData.status == "hover")
			PlayerPanel.SetHasClass("HeroPickLocked", playerData.status == "locked")
			if (playerData.status == "hover" || playerData.status == "locked") {
				if (isLocalTeam) {
					PlayerPanel.FindChildTraverse("HeroImage").SetImage(TransformTextureToPath(playerData.hero))
					PlayerPanel.SetDialogVariable("dota_hero_name", $.Localize(playerData.hero))
				}
			} else if (playerData.status == "picked") {
				PlayerPanel.FindChildTraverse("HeroImage").SetImage(TransformTextureToPath(playerData.hero))
				PlayerPanel.SetDialogVariable("dota_hero_name", $.Localize(playerData.hero))
			}
			var heroPanel = $("#HeroListPanel_element_" + playerData.hero)
			heroPanel.SetHasClass("AlreadyPicked", IsHeroPicked(playerData.hero))
			heroPanel.SetHasClass("Locked", IsHeroLocked(playerData.hero))
			if (isLocalTeam) {
				if (playerData.SpawnBoxes != null) {
					if (PlayerSpawnBoxes[playerIdInTeam] == null)
						PlayerSpawnBoxes[playerIdInTeam] = [];
					var PlayerSPBoxesTable = PlayerSpawnBoxes[playerIdInTeam];
					var checkedPanels = [];
					for (var index in playerData.SpawnBoxes) {
						var SPBoxInfoGroup = playerData.SpawnBoxes[index]
						var SPBoxID = "MinimapSpawnBoxPlayerIcon_" + SPBoxInfoGroup + "_" + playerIdInTeam;
						var SpawnBoxUnitPanel = $("#" + SPBoxID);
						var RootPanel = $MinimapSpawnBoxes().FindChildTraverse("MinimapSpawnBox_" + SPBoxInfoGroup);
						if (SpawnBoxUnitPanel == null) {
							SpawnBoxUnitPanel = $.CreatePanel("Image", RootPanel, SPBoxID)
							SpawnBoxUnitPanel.AddClass("SpawnBoxUnitPanel")
						}
						SpawnBoxUnitPanel.SetImage(TransformTextureToPath(playerData.hero, "icon"))
						SpawnBoxUnitPanel.SetHasClass("hero_selection_hover", playerData.status == "hover")
						checkedPanels.push(SpawnBoxUnitPanel);
						if (PlayerSPBoxesTable.indexOf(SpawnBoxUnitPanel) == -1)
							PlayerSPBoxesTable.push(SpawnBoxUnitPanel);
					}
					for (var index in PlayerSPBoxesTable) {
						var panel = PlayerSPBoxesTable[index]
						if (checkedPanels.indexOf(panel) == -1) {
							try {
								panel.DeleteAsync(0);
							} catch (e) {} finally {
								PlayerSPBoxesTable.splice(index, 1);
							}
						}
					}
				}
			}
		}
	}
	UpdateSelectionButton()
}

function $MinimapSpawnBoxes() {
	var vs = $("#MinimapPanel").FindChildrenWithClassTraverse("MinimapSpawnBoxes");
	for (var i = 0; i < vs.length; i++) {
		if (vs[i].BHasClass("only_map_landscape_" + Options.GetMapInfo().landscape))
			return vs[i];
	}
}

function OnLocalPlayerPicked() {
	var heroName = LocalPlayerStatus.hero;
	var localHeroData = HeroesData[heroName];
	$("#HeroPreviewName").text = $.Localize(heroName).toUpperCase();
	var bio = $.Localize(heroName + "_bio");
	$("#HeroPreviewLore").text = bio != heroName + "_bio" ? bio : "";
	var hype = $.Localize(heroName + "_hype");
	$("#HeroPreviewOverview").text = hype != heroName + "_hype" ? hype : "";

	var heroImageXML = localHeroData.custom_scene_camera != null ? "<DOTAScenePanel particleonly='false' allowrotation='true' yawmin='-15' yawmax='15' pitchmin='-3' pitchmax='3' map='custom_scenes_map' camera='" + localHeroData.custom_scene_camera + "'/>" : localHeroData.custom_scene_image != null ? "<Image src='" + localHeroData.custom_scene_image + "'/>" : "<DOTAScenePanel particleonly='false' allowrotation='true' yawmin='-15' yawmax='15' pitchmin='-3' pitchmax='3' unit='" + localHeroData.model + "'/>";
	var ScenePanel = $("#HeroPreviewScene")
	ScenePanel.RemoveAndDeleteChildren()
	ScenePanel.BCreateChildren(heroImageXML);

	$("#HeroPreviewAbilities").RemoveAndDeleteChildren()
	FillAbilitiesUI($("#HeroPreviewAbilities"), localHeroData.abilities, "HeroPreviewAbility")
	FillAttributeUI($("#HeroPreviewAttributes"), localHeroData);
	
	var GlobalLoadoutItems = FindDotaHudElement("GlobalLoadoutItems");
	if (GlobalLoadoutItems) {
		GlobalLoadoutItems.SetParent($("#GlobalLoadoutContainer"));
		//Custom styles
		_.each(GlobalLoadoutItems.FindChildrenWithClassTraverse("HasItemsForSlot"), function(child) {
			child.SetParent(GlobalLoadoutItems);
			child.style.width = "180px";
			//child.DeleteAsync(0)
		})
		_.each(GlobalLoadoutItems.FindChildrenWithClassTraverse("GlobalLoadoutSlotCategory"), function(child) {
			child.visible = false;
		})
		if (GlobalLoadoutItems.FindChildrenWithClassTraverse("HasItemsForSlot").length === 0 && !GlobalLoadoutItems.FindChildTraverse("GlobalLoadoutItemsArenaMessage")) {
			var label = $.CreatePanel("Label", GlobalLoadoutItems, "GlobalLoadoutItemsArenaMessage");
			label.text = $.Localize("hero_selection_loadout_items_first_game");
			label.style.fontSize = "22px";
			label.style.align = "center center";
		}
		//These wearables are useless, hide them
		try{ GlobalLoadoutItems.FindChildrenWithClassTraverse("ItemSlot_terrain")[0].GetParent().GetParent().visible = false; } catch(e) {}
		try{ GlobalLoadoutItems.FindChildrenWithClassTraverse("ItemSlot_heroic_statue")[0].GetParent().GetParent().visible = false; } catch(e) {}
		try{ GlobalLoadoutItems.FindChildrenWithClassTraverse("ItemSlot_loading_screen")[0].GetParent().GetParent().visible = false; } catch(e) {}
	}
	ToggleHeroPreviewHeroList(true)
}

function ToggleHeroPreviewHeroList(isPreview) {
	$.GetContextPanel().SetHasClass("HeroPreview", isPreview != null ? isPreview : !$.GetContextPanel().BHasClass("HeroPreview"))
}

function OnMinimapClickSpawnBox(team, level, index) {
	GameEvents.SendCustomGameEventToServer("hero_selection_minimap_set_spawnbox", {
		team: team,
		level: level,
		index: index,
	});
}

var adsurl = "https://goo.gl/wQpngH"; //dota2.sgm-luck.ru
var adsEnabledLangs = [
	"russian",
	"ukrainian",
	"bulgarian",
];

function OnAdsClicked() {
	$.DispatchEvent("ExternalBrowserGoToURL", adsurl);
	//$.DispatchEvent("DOTADisplayURL", adsurl)
}

function StartStrategyTime() {
	FindDotaHudElement("PausedInfo").style.opacity = 0;
}

function UpdateMainTable(tableName, changesObject, deletionsObject) {
	var newState = changesObject.HeroSelectionState
	if (newState < HERO_SELECTION_PHASE_END && changesObject.HeroTabs != null) {
		HeroSelectionStart(changesObject);
	}
	if (newState != null) {
		SetCurrentPhase(newState)
	}
	if (changesObject.TimerEndTime != null) {
		SelectionTimerEndTime = changesObject.TimerEndTime
	}
}

function SetCurrentPhase(newState) {
	switch (newState) {
		case HERO_SELECTION_PHASE_END:
			HeroSelectionEnd(HeroSelectionState == -1);
			break;
		case HERO_SELECTION_PHASE_STRATEGY:
			$.GetContextPanel().RemoveClass("CanRepick")
			StartStrategyTime()
		case HERO_SELECTION_PHASE_HERO_PICK:
		case HERO_SELECTION_PHASE_BANNING:
			if (!InitializationStates[HERO_SELECTION_PHASE_BANNING]) {
				InitializationStates[HERO_SELECTION_PHASE_BANNING] = true;
				SelectFirstHeroPanel();
			}
	}
	var context = $.GetContextPanel()
	context.SetHasClass("IsInBanPhase", newState == HERO_SELECTION_PHASE_BANNING)
	HeroSelectionState = newState;
	InitializationStates[newState] = true;
	$("#GameModeInfoCurrentPhase").text = $.Localize("hero_selection_phase_" + newState)
	UpdateSelectionButton()
}

function ShowHeroPreviewTab(tabID) {
	_.each($("#TabContents").Children(), function(child) {
		child.SetHasClass("TabVisible", child.id == tabID);
	})
}

(function() {
	$.GetContextPanel().RemoveClass("LocalPlayerPicked")
	$("#HeroListPanel").RemoveAndDeleteChildren()
	if (Players.GetTeam(Game.GetLocalPlayerID()) != DOTA_TEAM_SPECTATOR) {
		DynamicSubscribePTListener("hero_selection_available_heroes", UpdateMainTable);
		$.GetContextPanel().SetHasClass("ShowMMR", Options.IsEquals("EnableRatingAffection"))
		DynamicSubscribePTListener("arena", function(tableName, changesObject, deletionsObject) {
			if (changesObject.gamemode_settings && changesObject.gamemode_settings.gamemode != null) {
				DOTA_ACTIVE_GAMEMODE = changesObject.gamemode_settings.gamemode
				_DynamicMinimapSubscribe($("#MinimapDynamicIcons"), function(ptid) {
					MinimapPTIDs.push(ptid)
				});
			}
			if (changesObject.gamemode_settings && changesObject.gamemode_settings.gamemode_type != null) {
				var DOTA_ACTIVE_GAMEMODE_TYPE = changesObject.gamemode_settings.gamemode_type
				$("#GameModeInfoGamemodeLabel").text = $.Localize("arena_game_mode_type_" + DOTA_ACTIVE_GAMEMODE_TYPE)
			}
		})
		if ($.GetContextPanel().PTID_hero_selection) PlayerTables.UnsubscribeNetTableListener($.GetContextPanel().PTID_hero_selection)
		DynamicSubscribePTListener("hero_selection", UpdateHeroesSelected, function(ptid) {
			$.GetContextPanel().PTID_hero_selection = ptid
		})
		UpdateTimer();

		var steamid = GetSteamID(Game.GetLocalPlayerID(), 32)
		var bglist = SteamIDSpecialBGs[steamid];
		$.GetContextPanel().SetHasClass("CustomSelectionBackground", bglist != null)
		if (bglist)
			$("#HeroSelectionCustomBackground").SetImage(bglist[Math.floor(Math.random() * bglist.length)]);
		$("#AdsBanner").visible = adsEnabledLangs.indexOf($.Language()) > -1
	} else {
		HeroSelectionEnd(true);
	}
})();