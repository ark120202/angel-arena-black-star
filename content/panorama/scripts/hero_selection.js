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
	MinimapPTIDs = [],
	HeroesPanels = [],
	tabsData = {},
	PlayerSpawnBoxes = {},
	HeroSelectionState = -1,
	PlayerPanels = [],
	LocalPlayerStatus = {};
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

function HeroSelectionStart(HeroesServerData) {
	$.GetContextPanel().visible = true;
	SelectionTimerDuration = HeroesServerData.SelectionTime;
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
		context.SetHasClass("LocalHeroLockButton", SelectedHeroData.linked_heroes != null && (!IsLocalHeroLocked() || SelectedHeroData.heroKey != LocalPlayerStatus.hero));
		context.SetHasClass("LocalHeroUnlockButton", SelectedHeroData.linked_heroes != null && IsLocalHeroLocked() && SelectedHeroData.heroKey == LocalPlayerStatus.hero);
	}
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
		$("#HeroSelectionTimer").text = 0
	}
}

function Snippet_PlayerPanel(pid, root) {
	if (PlayerPanels[pid] == null) {
		var panel = $.CreatePanel('Panel', root, "")
		panel.BLoadLayoutSnippet("PlayerPanel")
		panel.FindChildTraverse("NickName").text = Players.GetPlayerName(pid)
		panel.FindChildTraverse("ImageHost").style.borderColor = GetHEXPlayerColor(pid)
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
	return LocalPlayerStatus.status == "locked" || LocalPlayerStatus.status == "locked"
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
			var PlayerPanel = Snippet_PlayerPanel(Number(playerIdInTeam), TeamSelectionPanel)

			var isLocalPlayer = playerIdInTeam == Game.GetLocalPlayerID()
			var isLocalTeam = teamNumber == Players.GetTeam(Game.GetLocalPlayerID())

			if (isLocalPlayer) {
				LocalPlayerStatus = playerData
				$.GetContextPanel().SetHasClass("LocalPlayerLocked", playerData.status == "locked")
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
			PlayerInTeamNickname.style.color = GetHEXPlayerColor(Number(playerIdInTeam))
			hero_tabs_iter:
				for (var tabkey in tabsData) {
					for (var herokey in tabsData[tabkey]) {
						var heroData = tabsData[tabkey][herokey]
						if (heroData.heroKey == SelectedPlayerHeroData.hero) {
							if (heroData.custom_scene_camera != null)
								PlayerInTeamPanel.BCreateChildren("<DOTAScenePanel particleonly='false' rotateonhover='true' yawmin='-15' yawmax='15' pitchmin='-3' pitchmax='3' map='custom_scenes_map' camera='" + heroData.custom_scene_camera + "'/>");
							else if (heroData.custom_scene_image != null)
								PlayerInTeamPanel.BCreateChildren("<Image style='opacity-mask: url(\"s2r://panorama/images/masks/softedge_box_png.vtex\");' src='" + heroData.custom_scene_image + "'/>");
							else
								PlayerInTeamPanel.BCreateChildren("<DOTAScenePanel particleonly='false' rotateonhover='true' yawmin='-15' yawmax='15' pitchmin='-3' pitchmax='3' unit='" + heroData.model + "'/>");
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
	$.GetContextPanel().visible = false;
	if (Players.GetTeam(Game.GetLocalPlayerID()) != DOTA_TEAM_SPECTATOR) {
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
	}
})();