"use strict";
var MainPanel = $("#HeroSelectionBox")
var SelectedHeroData,
	SelectedHeroPanel,
	SelectedTabIndex,
	SelectionTimerEndTime = 0,
	HideEvent,
	PTID,
	DOTA_ACTIVE_GAMEMODE,
	CustomChatLinesPanel,
	MinimapPTIDs = [],
	HeroesPanels = [],
	tabsData = {},
	PlayerSpawnBoxes = {},
	HeroSelectionState = -1,
	PlayerPanels = [],
	LocalPlayerStatus = {},
	InitializationStates = {};
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
	$.GetContextPanel().visible = true;
	tabsData = HeroesServerData.HeroTabs
	for (var tabKey in tabsData) {
		var TabHeroesPanel = $.CreatePanel('Panel', $("#HeroListPanel"), "HeroListPanel_tabPanels_" + tabKey)
		TabHeroesPanel.BLoadLayoutSnippet("HeroesPanel")
		FillHeroesTable(tabsData[tabKey], TabHeroesPanel)
		TabHeroesPanel.visible = false
	}
	$("#SwitchTabButton").visible = tabsData[2] != null;
	SelectHeroTab(1)
}

function HeroSelectionEnd(bImmidate) {
	$.GetContextPanel().style.opacity = 0
	$.Schedule(bImmidate ? 0 : 3.5, function() { //4 + 1.5 [+ 0.1] - 2 (dota delay)
		hud.GetChild(0).RemoveClass("IsBeforeGameplay")
	})
	$.Schedule(bImmidate ? 0 : 5.6, function() { //4 + 1.5 + 0.1
		MainPanel.visible = false
		//FindDotaHudElement("PausedInfo").style.opacity = 1;
		if (HideEvent != null)
			GameEvents.Unsubscribe(HideEvent)
		if (PTID != null)
			PlayerTables.UnsubscribeNetTableListener(PTID)
		if (MinimapPTIDs.length > 0)
			$.Each(MinimapPTIDs, function(ptid) {
				PlayerTables.UnsubscribeNetTableListener(ptid)
			})
		$.GetContextPanel().DeleteAsync(0)
	})
}

function ChooseHeroPanelHero() {
	ChooseHeroUpdatePanels()
	if (!IsLocalHeroLockedOrPicked()) {
		GameEvents.SendCustomGameEventToServer("hero_selection_player_hover", {
			hero: SelectedHeroData.heroKey
		})
	}
}

function SelectHero() {
	if (!IsLocalHeroPicked()) {
		GameEvents.SendCustomGameEventToServer("hero_selection_player_select", {
			hero: SelectedHeroData.heroKey
		})
		Game.EmitSound("HeroPicker.Selected")
	}
}

function RandomHero() {
	if (!IsLocalHeroLockedOrPicked()) {
		GameEvents.SendCustomGameEventToServer("hero_selection_player_random", {})
		Game.EmitSound("HeroPicker.Selected")
	}
}

function UpdateSelectionButton() {
	var canPick = SelectedHeroData == null || (!IsHeroPicked(SelectedHeroData.heroKey) && !IsLocalHeroPicked())
	$("#SelectedHeroSelectButton").enabled = canPick && (!IsLocalHeroLocked() || SelectedHeroData.heroKey == LocalPlayerStatus.hero)
	$("#HeroRandomButton").enabled = canPick && !IsLocalHeroLocked()
	if (SelectedHeroData != null) {
		var context = $.GetContextPanel()
		var mode = "pick";
		if (HeroSelectionState == "Banning") {
			mode = "ban"
		} else if (SelectedHeroData.linked_heroes != null) {
			mode = IsLocalHeroLocked() && SelectedHeroData.heroKey == LocalPlayerStatus.hero ? "unlock" : "lock"
		}
		context.SetHasClass("LocalHeroLockButton", mode == "lock");
		context.SetHasClass("LocalHeroUnlockButton", mode == "unlock");
		context.SetHasClass("LocalHeroBanButton", mode == "ban");
	}
}

function UpdateTimer() {
	$.Schedule(0.2, UpdateTimer);
	var SelectionTimerRemainingTime = SelectionTimerEndTime - Game.GetGameTime()
	if (SelectionTimerRemainingTime > 0) {
		if (HeroSelectionState != HERO_SELECTION_PHASE_END) {
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
		$.Each($(DOTA_ACTIVE_GAMEMODE == DOTA_GAMEMODE_4V4V4V4 ? "#MinimapImage4v4v4v4" : "#MinimapImage").GetChild(1).Children(), function(child) {
			var childrencount = child.GetChildCount()
			child.SetHasClass("SpawnBoxUnitPanelChildren2", childrencount >= 2)
			child.SetHasClass("SpawnBoxUnitPanelChildren3", childrencount >= 3)
			child.SetHasClass("SpawnBoxUnitPanelChildren5", childrencount >= 5)
		});
	} else {
		$("#HeroSelectionTimer").text = 0
	}
}

function Snippet_PlayerPanel(pid, root) {
	if (PlayerPanels[pid] == null) {
		var panel = $.CreatePanel('Panel', root, "")
		panel.BLoadLayoutSnippet("PlayerPanel")
		panel.FindChildTraverse("NickName").text = Players.GetPlayerName(pid)
		panel.FindChildTraverse("ImageHost").style.borderColor = GetHEXPlayerColor(pid)
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
			var TeamSelectionPanel = $.CreatePanel('Panel', $("#TeamSelectionStatusPanel"), "team_selection_panels_team" + teamNumber)
			TeamSelectionPanel.AddClass("TeamSelectionPanel")
			var color = GameUI.CustomUIConfig().team_colors[teamNumber]
			TeamSelectionPanel.style.backgroundColor = "gradient(linear, 100% 100%, 0% 100%, from( " + color + "4D" + " ), to( transparent ))"
			TeamSelectionPanel.style.borderColor = color + "99";
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

			PlayerPanel.SetHasClass("HoveredHero", playerData.status == "hover")
			PlayerPanel.SetHasClass("LockedHero", playerData.status == "locked")
			if (playerData.status == "hover" || playerData.status == "locked") {
				if (isLocalTeam) {
					PlayerPanel.FindChildTraverse("HeroImage").SetImage(TransformTextureToPath(playerData.hero))
				}
			} else if (playerData.status == "picked") {
				PlayerPanel.FindChildTraverse("HeroImage").SetImage(TransformTextureToPath(playerData.hero))
			}
			var heroPanel = $("#HeroListPanel_element_" + playerData.hero)
			heroPanel.SetHasClass("Picked", IsHeroPicked(playerData.hero))
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
						var RootPanel = $(DOTA_ACTIVE_GAMEMODE == DOTA_GAMEMODE_4V4V4V4 ? "#MinimapImage4v4v4v4" : "#MinimapImage").FindChildTraverse("MinimapSpawnBox_" + SPBoxInfoGroup);
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

function OnLocalPlayerPicked() {
	var localHeroData = {};
	//TODO: Tab data shoud be set of Hero - Info
	hero_tabs_iter:
		for (var tabkey in tabsData) {
			for (var herokey in tabsData[tabkey]) {
				var heroData = tabsData[tabkey][herokey]
				if (heroData.heroKey == LocalPlayerStatus.hero) {
					localHeroData = heroData
					break hero_tabs_iter
				}
			}
		}

	var heroImageXML = localHeroData.custom_scene_camera != null ? "<DOTAScenePanel particleonly='false' allowrotation='true' yawmin='-15' yawmax='15' pitchmin='-3' pitchmax='3' map='custom_scenes_map' camera='" + localHeroData.custom_scene_camera + "'/>" : localHeroData.custom_scene_image != null ? "<Image src='" + localHeroData.custom_scene_image + "'/>" : "<DOTAScenePanel particleonly='false' allowrotation='true' yawmin='-15' yawmax='15' pitchmin='-3' pitchmax='3' unit='" + localHeroData.model + "'/>";
	var ScenePanel = $("#HeroPreviewScene")
	ScenePanel.RemoveAndDeleteChildren()
	ScenePanel.BCreateChildren(heroImageXML);
	$("#HeroPreviewAbilities").RemoveAndDeleteChildren()
	FillAbilitiesUI($("#HeroPreviewAbilities"), localHeroData.abilities, "HeroPreviewAbility")
	FillAttributeUI($("#HeroPreviewAttributes"), localHeroData);
					
	//var HeroLabel = $.CreatePanel('Label', PlayerInTeamPanel, "")
	//HeroLabel.AddClass("PrecacheHeroLabel")
	//HeroLabel.text = $.Localize("#" + LocalPlayerStatus.hero);

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
	$.Msg("ENTER STRATEGY STATE!")
	//FindDotaHudElement("PausedInfo").style.opacity = 0;
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
			StartStrategyTime()
		case HERO_SELECTION_PHASE_ALLPICK:
			if (!InitializationStates[HERO_SELECTION_PHASE_ALLPICK]) {
				InitializationStates[HERO_SELECTION_PHASE_ALLPICK] = true;
				UpdateTimer();
				SelectFirstHeroPanel();
			}
	}
	var context = $.GetContextPanel()
	HeroSelectionState = newState;
	InitializationStates[newState] = true;
}

(function() {
	$.GetContextPanel().visible = false;
	$.GetContextPanel().RemoveClass("LocalPlayerPicked")
	if (Players.GetTeam(Game.GetLocalPlayerID()) != DOTA_TEAM_SPECTATOR) {
		DynamicSubscribePTListener("hero_selection_available_heroes", UpdateMainTable);
		DynamicSubscribePTListener("arena", function(tableName, changesObject, deletionsObject) {
			if (changesObject["gamemode_settings"] != null && changesObject["gamemode_settings"]["gamemode"] != null) {
				DOTA_ACTIVE_GAMEMODE = changesObject["gamemode_settings"]["gamemode"]
				_DynamicMinimapSubscribe($(DOTA_ACTIVE_GAMEMODE == DOTA_GAMEMODE_4V4V4V4 ? "#MinimapImage4v4v4v4" : "#MinimapImage").GetChild(0), function(ptid) {
					MinimapPTIDs.push(ptid)
				});
			}
			if (changesObject["gamemode_settings"] != null && changesObject["gamemode_settings"]["gamemode_type"] != null) {
				var DOTA_ACTIVE_GAMEMODE_TYPE = changesObject["gamemode_settings"]["gamemode_type"]
				$("#GameModeInfoGamemodeLabel").text = $.Localize("#arena_game_mode_type_" + DOTA_ACTIVE_GAMEMODE_TYPE)
			}
		})
		DynamicSubscribePTListener("hero_selection", UpdateHeroesSelected, function(ptid) {
			PTID = ptid
		})

		var steamid = GetSteamID(Game.GetLocalPlayerID(), 32)
		var bglist = SteamIDSpecialBGs[steamid];
		$.GetContextPanel().SetHasClass("CustomSelectionBackground", bglist != null)
		if (bglist)
			$("#HeroSelectionCustomBackground").SetImage(bglist[Math.floor(Math.random() * bglist.length)]);
		$("#AdsBanner").visible = adsEnabledLangs.indexOf($.Language()) > -1
	}
})();