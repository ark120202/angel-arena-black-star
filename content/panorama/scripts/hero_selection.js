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
	HeroSelectionState = -1;

var SteamIDSpecialBGs = {
	//ark120202
	109792606: [
		"https://pp.vk.me/c638727/v638727976/1134a/d1RxLF8mWkE.jpg",
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

function HeroSelectionStart(HeroesServerData) {
	MainPanel.visible = true;
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
	if (SelectedHeroData != null && !IsHeroPicked(SelectedHeroData.heroKey) && !localHeroPicked) {
		$("#SelectedHeroSelectButton").enabled = true
		$("#HeroRandomButton").enabled = true
	} else {
		$("#SelectedHeroSelectButton").enabled = false
		$("#HeroRandomButton").enabled = false
	}
}

function UpdateTimer() {
	var SelectionTimerCurrentTime = Game.GetGameTime();
	var SelectionTimerRemainingTime = SelectionTimerDuration - (SelectionTimerCurrentTime - SelectionTimerStartTime)
	if (SelectionTimerRemainingTime > 0) {
		$.Schedule(0.2, UpdateTimer);
		$("#HeroSelectionTimer").text = Math.ceil(SelectionTimerRemainingTime);
		SearchHero();
		$.Each(Game.GetAllPlayerIDs(), function(id) {
			var p = $("#playerpickpanelhost_player" + id)
			if (p != null) {
				var playerInfo = Game.GetPlayerInfo(id);
				p.SetHasClass("player_connection_abandoned", playerInfo.player_connection_state == DOTAConnectionState_t.DOTA_CONNECTION_STATE_ABANDONED);
				p.SetHasClass("player_connection_failed", playerInfo.player_connection_state == DOTAConnectionState_t.DOTA_CONNECTION_STATE_FAILED);
				p.SetHasClass("player_connection_disconnected", playerInfo.player_connection_state == DOTAConnectionState_t.DOTA_CONNECTION_STATE_DISCONNECTED);
			}
		});
	} else {
		$.Schedule(0.03, function() {
			$("#HeroSelectionTimer").text = 0
		})
	}
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
			if ($("#playerpickpanelimage_player" + playerIdInTeam) == null) {
				var SelectedPlayerHeroData = changesObject[teamNumber][playerIdInTeam]
				var PlayerInTeamPanel = $.CreatePanel('Panel', TeamSelectionPanel, "")
				PlayerInTeamPanel.AddClass("PlayerInTeamPanel")

				var PlayerInTeamNickname = $.CreatePanel('Label', PlayerInTeamPanel, "")
				PlayerInTeamNickname.AddClass("PlayerInTeamNickname")
				PlayerInTeamNickname.text = Players.GetPlayerName(Number(playerIdInTeam))
				var playerColor = Players.GetPlayerColor(Number(playerIdInTeam)).toString(16)
				if (playerColor != null)
					playerColor = "#" + playerColor.substring(6, 8) + playerColor.substring(4, 6) + playerColor.substring(2, 4) + playerColor.substring(0, 2)
				else
					playerColor = "#000000";
				var HeroImageHost = $.CreatePanel("Panel", PlayerInTeamPanel, "playerpickpanelhost_player" + playerIdInTeam)
				HeroImageHost.AddClass("PlayerInTeamHeroImageHost")
				HeroImageHost.style.borderColor = playerColor
				var HeroImage = $.CreatePanel('Image', HeroImageHost, "playerpickpanelimage_player" + playerIdInTeam)
				HeroImage.AddClass("PlayerInTeamHeroImage")
				var HeroDisconnectionIndicator = $.CreatePanel('Image', HeroImageHost, "")
				HeroDisconnectionIndicator.AddClass("DisconnectionIndicator")
				HeroDisconnectionIndicator.SetImage("file://{images}/custom_game/icon_disconnect.png")
			}

			var HeroImage = $("#playerpickpanelimage_player" + playerIdInTeam)
			if (playerData.status == "hover") {
				if (teamNumber == Players.GetTeam(Game.GetLocalPlayerID())) {
					HeroImage.SetImage(TransformTextureToPath(playerData.hero))
				}
				HeroImage.AddClass("PlayerInTeamHeroImageHover")
			} else if (playerData.status == "picked") {
				if (playerIdInTeam == Game.GetLocalPlayerID()) {
					localHeroPicked = true
				}
				UpdateSelectionButton()
				if ($("#HeroListPanel_element_" + playerData.hero) != null) {
					$("#HeroListPanel_element_" + playerData.hero).AddClass("HeroListElementPickedBySomeone")
				}
				HeroImage.SetImage(TransformTextureToPath(playerData.hero))
				HeroImage.RemoveClass("PlayerInTeamHeroImageHover")
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
					$.Schedule(1, function() {
						$.Each($(DOTA_ACTIVE_GAMEMODE == DOTA_GAMEMODE_4V4V4V4 ? "#MinimapImage4v4v4v4" : "#MinimapImage").GetChild(1).Children(), function(child) {
							var childrencount = child.GetChildCount()
							child.SetHasClass("SpawnBoxUnitPanelChildren2", childrencount >= 2)
							child.SetHasClass("SpawnBoxUnitPanelChildren3", childrencount >= 3)
							child.SetHasClass("SpawnBoxUnitPanelChildren5", childrencount >= 5)
						});
					});
				}
			}
		}
	}
}

function HeroSelectionEnd(bImmidate) {
	$.GetContextPanel().style.opacity = 0
	$.Schedule(bImmidate ? 0 : 5.6, function() {
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
								PlayerInTeamPanel.BCreateChildren("<DOTAScenePanel antialias='true' light='global_light' renderdeferred='false' style='width: 100%; height: 100%; opacity-mask: url(\"s2r://panorama/images/masks/softedge_box_png.vtex\");' unit='" + heroData.model + "'/>");
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
(function() {
	DynamicSubscribePTListener("hero_selection_available_heroes", function(tableName, changesObject, deletionsObject) {
		if (changesObject.HeroTabs != null)
			HeroSelectionStart(changesObject);
		if (changesObject.HeroSelectionState != null) {
			switch (changesObject.HeroSelectionState) {
				case HERO_SELECTION_STATE_END:
					HeroSelectionEnd(HeroSelectionState == -1)
					break
			}
			HeroSelectionState = changesObject.HeroSelectionState
		}

		if (HeroSelectionState != HERO_SELECTION_STATE_END && changesObject.SelectionStartTime != null) {
			SelectionTimerStartTime = changesObject.SelectionStartTime;
			UpdateTimer();
			SelectFirstHeroPanel();
		};
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
	var lang = $.Language()
		//$("#AdsBanner").visible = lang == "russian" || lang == "ukrainian"
})();