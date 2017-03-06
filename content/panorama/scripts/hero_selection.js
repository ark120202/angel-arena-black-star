"use strict";
var MainPanel = $("#HeroSelectionBox")
var SelectedHeroData,
	SelectedHeroPanel,
	SelectedTabIndex,
	SelectionTimerDuration,
	SelectionTimerStartTime = 0,
	HideEvent,
	PTID,
	DOTA_ACTIVE_GAMEMODE,
	CustomChatLinesPanel,
	localHeroPicked = false,
	MinimapPTIDs = [],
	HeroesPanels = [],
	tabsData = {},
	PlayerSpawnBoxes = {},
	HeroSelectionState = -1,
	PlayerPanels = [];

var SteamIDSpecialBGs = {
	//ark120202
	109792606: [
		"https://pp.userapi.com/c638727/v638727976/1134a/d1RxLF8mWkE.jpg",
	],
	//Murzik
	82292900: [
		"https://wallpaperscraft.ru/image/kot_morda_pushistyj_polosatyj_97082_1920x1080.jpg",
		"http://file.mobilmusic.ru/b2/19/29/836852.jpg",
		"https://wallpaperscraft.ru/image/koshka_kot_seryy_poroda_russkaya_golubaya_glaza_zelenye_vzglyad_chernyy_fon_81774_1920x1080.jpg",
		"http://anywalls.com/pic/201304/1920x1080/anywalls.com-64496.jpg",
		"http://file.mobilmusic.ru/8f/8e/b8/768273.jpg",
	],
}
$.GetContextPanel().visible = false;

function HeroSelectionStart(HeroesServerData) {
	$.GetContextPanel().visible = true;
	SelectionTimerDuration = HeroesServerData.SelectionTime;
	tabsData = HeroesServerData.HeroTabs
	for (var tabKey in tabsData) {
		var tabTitle = tabsData[tabKey].title
		var heroesInTab = tabsData[tabKey].Heroes
		var TabHeroesPanel = $.CreatePanel('Panel', $("#HeroListPanel"), "HeroListPanel_tabPanels_" + tabKey)
		TabHeroesPanel.BLoadLayoutSnippet("HeroesPanel")
		FillHeroesTable(heroesInTab, TabHeroesPanel)
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
		FindDotaHudElement("PausedInfo").style.opacity = 1;
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

function SelectHeroTab(tabIndex) {
	if (SelectedTabIndex != tabIndex) {
		if (SelectedTabIndex != null) {
			$("#HeroListPanel_tabPanels_" + SelectedTabIndex).visible = false
		}
		$("#HeroListPanel_tabPanels_" + tabIndex).visible = true
		SelectedTabIndex = tabIndex
	}
}

function SwitchTab() {
	if (SelectedTabIndex == 1)
		SelectHeroTab(2)
	else
		SelectHeroTab(1)
}

function ChooseHeroPanelHero() {
	ChooseHeroUpdatePanels()
	if (!localHeroPicked) {
		GameEvents.SendCustomGameEventToServer("hero_selection_player_hover", {
			hero: SelectedHeroData.heroKey
		})
	}
}

function SelectHero() {
	if (!localHeroPicked) {
		localHeroPicked = true
		GameEvents.SendCustomGameEventToServer("hero_selection_player_select", {
			hero: SelectedHeroData.heroKey
		})
		Game.EmitSound("HeroPicker.Selected")
	}
}

function RandomHero() {
	if (!localHeroPicked) {
		localHeroPicked = true
		GameEvents.SendCustomGameEventToServer("hero_selection_player_random", {})
		Game.EmitSound("HeroPicker.Selected")
	}
}

function UpdateSelectionButton() {
	var canPick = SelectedHeroData != null && !IsHeroPicked(SelectedHeroData.heroKey) && !localHeroPicked
	$("#SelectedHeroSelectButton").enabled = canPick
	$("#HeroRandomButton").enabled = canPick
}

function UpdateTimer() {
	var SelectionTimerCurrentTime = Game.GetGameTime();
	var SelectionTimerRemainingTime = SelectionTimerDuration - (SelectionTimerCurrentTime - SelectionTimerStartTime)
	if (SelectionTimerRemainingTime > 0) {
		$.Schedule(0.2, UpdateTimer);
		if (HeroSelectionState != HERO_SELECTION_STATE_END) {
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
		$.Schedule(0.03, function() {
			$("#HeroSelectionTimer").text = 0
		})
	}
}

function Snippet_PlayerPanel(pid) {
	if (PlayerPanels[pid] == null) {
		var panel = $.CreatePanel('Panel', TeamSelectionPanel, "")
		panel.BLoadLayoutSnippet("PlayerPanel")
		panel.FindChildTraverse("NickName").text = Players.GetPlayerName(Number(playerIdInTeam))
		panel.FindChildTraverse("ImageHost").style.borderColor = GetHEXPlayerColor(Number(playerIdInTeam))
		PlayerPanels[pid] = panel
	}
	return PlayerPanels[pid]
}

function UpdateHeroesSelected(tableName, changesObject, deletionsObject) {
	for (var teamNumber in changesObject) {
		if ($("#team_selection_panels_team" + teamNumber) == null) {
			var TeamSelectionPanel = $.CreatePanel('Panel', $("#TeamSelectionStatusPanel"), "team_selection_panels_team" + teamNumber)
			TeamSelectionPanel.AddClass("TeamSelectionPanel")
			var color = GameUI.CustomUIConfig().team_colors[teamNumber]
			color = color.substring(0, color.length - 1)
			TeamSelectionPanel.style.backgroundColor = "gradient(linear, 100% 100%, 0% 100%, from( " + color + "4D" + " ), to( transparent ))"
			TeamSelectionPanel.style.borderColor = color + "99";
		}
		var TeamSelectionPanel = $("#team_selection_panels_team" + teamNumber)
		for (var playerIdInTeam in changesObject[teamNumber]) {
			var playerData = changesObject[teamNumber][playerIdInTeam]

			var PlayerPanel = Snippet_PlayerPanel(playerIdInTeam)
			PlayerPanel.SetHasClass("HoveredHero", playerData.status == "hover")
			PlayerPanel.SetHasClass("LockedHero", playerData.status == "hover")
			if (playerData.status == "hover" || playerData.status == "locked") {
				if (teamNumber == Players.GetTeam(Game.GetLocalPlayerID())) {
					PlayerPanel.FindChildTraverse("HeroImage").SetImage(TransformTextureToPath(playerData.hero))
				}
			} else if (playerData.status == "picked") {
				if (playerIdInTeam == Game.GetLocalPlayerID()) {
					localHeroPicked = true
				}
				UpdateSelectionButton()
				if ($("#HeroListPanel_element_" + playerData.hero) != null) {
					$("#HeroListPanel_element_" + playerData.hero).AddClass("HeroListElementPickedBySomeone")
				}
				PlayerPanel.FindChildTraverse("HeroImage").SetImage(TransformTextureToPath(playerData.hero))
			}

			if (teamNumber == Players.GetTeam(Game.GetLocalPlayerID())) {
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
}

function ShowPrecache() {
	$("#HeroSelectionBox").visible = false
	$("#HeroSelectionPrecacheBase").visible = true
	var PlayerPickData = PlayerTables.GetAllTableValues("hero_selection")
	FindDotaHudElement("PausedInfo").style.opacity = 0;
	for (var teamNumber in PlayerPickData) {
		/*if ($("#team_selection_panels_team" + teamNumber) == null) {
			var TeamPanel = $.CreatePanel('Panel', $("#TeamSelectionStatusPanel"), "team_selection_panels_team" + teamNumber)
			TeamPanel.AddClass("TeamPanel")
		}*/

		var TeamPanel = $("#PrecacheTeamEntryTeam" + teamNumber)
		var color = GameUI.CustomUIConfig().team_colors[teamNumber]
		color = color.substring(0, color.length - 1) + "4c"
		TeamPanel.style.backgroundColor = "gradient(linear, 100% 100%, 0% 100%, from( " + color + " ), to( transparent ))"
		for (var playerIdInTeam in PlayerPickData[teamNumber]) {
			var SelectedPlayerHeroData = PlayerPickData[teamNumber][playerIdInTeam]
			var PlayerInTeamPanel = $.CreatePanel('Panel', TeamPanel, "")
			PlayerInTeamPanel.AddClass("PrecacheTeamPlayerPanel")

			var PlayerInTeamNickname = $.CreatePanel('Label', PlayerInTeamPanel, "")
			PlayerInTeamNickname.AddClass("PrecachePlayerInTeamNickname")
			PlayerInTeamNickname.text = Players.GetPlayerName(Number(playerIdInTeam))
			var playerColor = Players.GetPlayerColor(Number(playerIdInTeam)).toString(16)
			if (playerColor != null)
				playerColor = "#" + playerColor.substring(6, 8) + playerColor.substring(4, 6) + playerColor.substring(2, 4) + playerColor.substring(0, 2)
			else
				playerColor = "#000000";
			PlayerInTeamNickname.style.color = playerColor
			hero_tabs_iter:
				for (var tabkey in tabsData) {
					for (var herokey in tabsData[tabkey].Heroes) {
						var heroData = tabsData[tabkey].Heroes[herokey]
						if (heroData.heroKey == SelectedPlayerHeroData.hero) {
							if (heroData.custom_scene_camera != null)
								PlayerInTeamPanel.BCreateChildren("<DOTAScenePanel antialias='true' light='global_light' renderdeferred='false' style='width: 100%; height: 100%; opacity-mask: url(\"s2r://panorama/images/masks/softedge_box_png.vtex\");' map='custom_scenes_map' camera='" + heroData.custom_scene_camera + "'/>");
							else if (heroData.custom_scene_image != null)
								PlayerInTeamPanel.BCreateChildren("<Image style='opacity-mask: url(\"s2r://panorama/images/masks/softedge_box_png.vtex\");' src='" + heroData.custom_scene_image + "'/>");
							else
								PlayerInTeamPanel.BCreateChildren("<DOTAScenePanel antialias='true' light='global_light' renderdeferred='false' always-cache-composition-layer='true' style='width: 100%; height: 100%; opacity-mask: url(\"s2r://panorama/images/masks/softedge_box_png.vtex\");' unit='" + heroData.model + "'/>");
							break hero_tabs_iter
						}
					}
				}

			var HeroLabel = $.CreatePanel('Label', PlayerInTeamPanel, "")
			HeroLabel.AddClass("PrecacheHeroLabel")
			HeroLabel.text = $.Localize("#" + SelectedPlayerHeroData.hero);
		}
	}
}

function OnMinimapClickSpawnBox(team, level, index) {
	GameEvents.SendCustomGameEventToServer("hero_selection_minimap_set_spawnbox", {
		team: team,
		level: level,
		index: index,
	});
}

function UpdatePrecacheProgress(t) {
	var progress = 0;
	$.Each(t, function(status, hero) {
		if (status == 1)
			progress++;
	})
	$("#PrecacheProgressBar").value = progress;
	$("#PrecacheProgressBar").max = Object.keys(t).length;
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

(function() {
	DynamicSubscribePTListener("hero_selection_available_heroes", function(tableName, changesObject, deletionsObject) {
		if (changesObject.HeroSelectionState != null) {
			switch (changesObject.HeroSelectionState) {
				case HERO_SELECTION_STATE_END:
					HeroSelectionEnd(HeroSelectionState == -1);
					break;
			}
			HeroSelectionState = changesObject.HeroSelectionState;
		}
		if (HeroSelectionState != HERO_SELECTION_STATE_END) {
			if (changesObject.HeroTabs != null)
				HeroSelectionStart(changesObject);
			if (changesObject.SelectionStartTime != null) {
				SelectionTimerStartTime = changesObject.SelectionStartTime;
				UpdateTimer();
				SelectFirstHeroPanel();
			};
		}
	});
	DynamicSubscribePTListener("arena", function(tableName, changesObject, deletionsObject) {
		if (changesObject["gamemode_settings"] != null && changesObject["gamemode_settings"]["gamemode"] != null) {
			DOTA_ACTIVE_GAMEMODE = changesObject["gamemode_settings"]["gamemode"]
			if (DOTA_ACTIVE_GAMEMODE == DOTA_GAMEMODE_4V4V4V4)
				$.GetContextPanel().AddClass("Gamemode_4V4V4V4")
			_DynamicMinimapSubscribe($(DOTA_ACTIVE_GAMEMODE == DOTA_GAMEMODE_4V4V4V4 ? "#MinimapImage4v4v4v4" : "#MinimapImage").GetChild(0), function(ptid) {
				MinimapPTIDs.push(ptid)
			});
		}
		if (changesObject["gamemode_settings"] != null && changesObject["gamemode_settings"]["gamemode_type"] != null) {
			var DOTA_ACTIVE_GAMEMODE_TYPE = changesObject["gamemode_settings"]["gamemode_type"]
			$("#GameModeInfoGamemodeLabel").text = $.Localize("#arena_game_mode_type_" + DOTA_ACTIVE_GAMEMODE_TYPE)
		}
	})
	GameEvents.Subscribe("hero_selection_show_precache", ShowPrecache);
	GameEvents.Subscribe("hero_selection_update_precache_progress", UpdatePrecacheProgress);
	DynamicSubscribePTListener("hero_selection", UpdateHeroesSelected, function(ptid) {
		PTID = ptid
	})

	var steamid = GetSteamID(Game.GetLocalPlayerID(), 32)
	var bglist = SteamIDSpecialBGs[steamid];
	$.GetContextPanel().SetHasClass("CustomSelectionBackground", bglist != null)
	if (bglist)
		$("#HeroSelectionCustomBackground").SetImage(bglist[Math.floor(Math.random() * bglist.length)]);
	$("#AdsBanner").visible = adsEnabledLangs.indexOf($.Language()) > -1
})();