"use strict";
var MainPanel = $("#HeroSelectionBox")
var SelectedHeroData = null
var SelectedHeroPanel = null
var SelectedTabIndex = null
var SelectionTimerDuration = null
var SelectionTimerStartTime = null
var localHeroPicked = false
var PlayerTables = GameUI.CustomUIConfig().PlayerTables
var HideEvent = null
var ShowPrecacheEvent = null
var PTID = null
var HeroesPanels = []
var tabsData = {}
var PlayerSpawnBoxes = {}
var bgs = [
	"3_heroes_loadingscreen",
	"acolyte_vengeance_loading_screen",
	"aeol_drias_loading_screen",
	"alchemist_convicts_trophy_loading_screen",
	"alliance_abbadon_loadingscreen",
	"alliance_loading_screen",
	"amberlight_loadingscreen",
	"anarchy_loadingscreen",
	"ancient_evil_ls",
	"ancient_rhythm_loading_screen",
	"antipodeanloadscreen",
	"anuxi_drow_wurm_loading",
	"apostle_of_decay_loading_screen",
	"armature_of_the_belligerent_ram_loading_screen",
	"armor_of_tielong",
	"arms_of_the_captive_princess_loading_screen",
	"arms_of_the_onyx_crucible_loading_screen",
	"arsenal_magus_loadingscreen",
	"artgerm_axe",
	"artgerm_es",
	"artgerm_invoker",
	"artgerm_pa",
	"artgerm_wr",
	"artificial_metamorphosis_loading_screen",
	"artisan_of_havoc",
	"ascension_loadingscreen",
	"aspect_year_beast_loading_screen",
	"avarice_rider_loading_screen",
	"awakened_thirst_loading_screen",
	"axesaccess_loadingscreen",
	"babka_bewitcher_screen",
	"banished_princess_loading_screen",
	"barrier_rogue_loading_screen",
	"basim_loadingscreen",
	"battletrap_loading_screen",
	"beaverknight_loadingscreen",
	"bestowments_of_the_divine_anchor_loading_screen",
	"betaloadingscreenmiri",
	"bewitching_flare_loadingscreen",
	"bindings_dragonforge",
	"blackdeath_loadingscreen",
	"blackpool_loadingscreen",
	"blackwyrm_loadingscreen",
	"black_lotus_loading_screen",
	"blazearmor_loadingscreen",
	"blazing_lord_loading_screen",
	"blessing_of_the_crested_dawn_loading_screen",
	"bloody_ripper_loadingscreen",
	"blueice_loading_screen",
	"bogatyr_pudge_loading_screen",
	"bonds_of_madness",
	"bone_fletcher_loading_screen",
	"borealwatch_loadingscreen",
	"bounch_luna_ls",
	"bts3_loading_screen",
	"btsduskie_loadingscreen",
	"bts_ancient_beast_loadscreen",
	"bts_chirpy_loading",
	"bts_corrupted_lord_loadingscreen1",
	"bts_leshrac_loadingscreen",
	"bts_migrant_blaze_loadscreen",
	"bts_nyx_loadingscreen",
	"bts_silencer_loading_screent",
	"burial_robes_ls",
	"butterfly_cup_loading_screen",
	"cadenza_loading_screen",
	"carreau_loadingscreen",
	"centaur_relentless_warbringer_loading_screen",
	"champion_discord_closed_loading_screen",
	"chicken_hut_ward_screen",
	"cicatrixregalia_loadingscreen",
	"clockmaster_loadingscreen",
	"commander_of_the_dragon_guard",
	"consuming_tides_loading_screen",
	"coral_furryfish_loading_screen",
	"cradle_of_lights_loading_screen",
	"crescent_loading_screen",
	"crystalline_comet_loading_screen",
	"cyclopean_marauder_loading_screen",
	"d2cl_season_5_loading_screen",
	"darkangel_loadingscreen",
	"darkgabriel_loadingscreen",
	"dark_curator_loadingscreen",
	"dark_reef_loading_screen",
	"dark_sorcerer_loading_screen",
	"dazzle_yuwipi",
	"dcloadingscreen",
	"dc_bedge2",
	"dc_betaloadingscreenjugg",
	"dc_bsrkls",
	"deadreborn_loadingscreen",
	"deathbringer_loading_screen",
	"devilish_conjurer_loading_screen",
	"direancient_loadingscreen",
	"djinnslayer_loadingscreen",
	"dk_blazing_superiority",
	"donbasscup3loaddcreen",
	"donkey_loadingscreen",
	"dotapit3_sven_loadingscreen",
	"dotapit_s3_loadingscreen",
	"dotapit_s3_pudge_loadingscreen",
	"dota_keyart_alchemist_loadingscreen",
	"dota_keyart_disruptor_loadingscreen",
	"dota_keyart_io_loadingscreen",
	"dota_keyart_jakirohuskarbatrider_loadingscreen",
	"dota_keyart_keeperofthelight_loadingscreen",
	"dota_keyart_lycan_loadingscreen",
	"dota_keyart_naga_loadingscreen",
	"dota_keyart_ogremagi_loadingscreen",
	"dota_keyart_outworlddevourer_loadingscreen",
	"dota_keyart_phantomlancer_loadingscreen",
	"dota_keyart_slark_loadingscreen",
	"dota_keyart_ti4_loadingscreen",
	"dota_keyart_treant_loadingscreen",
	"dota_keyart_visage_loadingscreen",
	"dota_keyart_windrangerjugg_loadingscreen",
	"dragonfire2_loading",
	"dragonstouch_loading_screen",
	"dragonterror_loading_screen",
	"dreadhawk_loadingscreen",
	"dreamhack_sniper_loadingscreen",
	"dreamleague_vindictive_loadingscreen",
	"drowning_trench_loadingscreen",
	"dusklight_loadingscreen",
	"echoes_eyrie_loading_screen",
	"eldertitan_worldforger",
	"emberbark_loadingscreen",
	"ember_crane_loading",
	"emerald_ocean_loading_screen",
	"emperor_of_the_nyx_dynasty_loading_screen",
	"empire_of_the_lightning_lord_loading_screen",
	"entropy_loading_screen",
	"envious_archer",
	"envisioning_invoker_loading_screen",
	"envisioning_juggernaut_loading_screen",
	"envisioning_legion_commander_loading_screen",
	"envisioning_meepo_loading_screen",
	"envisioning_ogre_magi_loading_screen",
	"envisioning_outworld_devourer_loading_screen",
	"envisioning_phantom_assassin_loading_screen",
	"envisioning_phantom_lancer_loading_screen",
	"envisioning_queen_of_pain_loading_screen",
	"envisioning_tidehunter_loading_screen",
	"envisioning_treant_protector_loading_screen",
	"envisioning_weaver_loading_screen",
	"envisioning_winter_wyvern_loading_screen",
	"envisioning_witch_doctor_loading_screen",
	"envisioning_wraith_king_loading_screen",
	"epitaphic_bonds_loading_screen",
	"equine_loadingscreen",
	"erlkonig_loadingscreen",
	"errant_commander",
	"escape_master_loading_screen",
	"esl_avenging_crusader_loading_screen",
	"esl_blossoming_harmony_loading_screen",
	"esl_dashing_bladelord_loadingscreen",
	"esl_demonic_affliction_loadingscreen",
	"esl_divine_flame_ls",
	"esl_frozen_lotus_loading_screen",
	"esl_nether_star_loading_screen",
	"esl_one_2014_loadingscreen",
	"esl_relics_loadingscreen",
	"es_demon_stone",
	"eternalnymph_loadingscreen",
	"eternalseasons_loadingscreen",
	"eternal_fire_loading_screen",
	"everlastingheat_loadingscreen",
	"evil_genius_loadingscreen",
	"fallenprincess_loadingscreen",
	"fatal_blossom_loading_screen",
	"father_loadingscreen",
	"fei_lian_loading_screen",
	"ff_type0_hd_loading_screen",
	"fiend_cleaver_demon_screen",
	"fierce_heart_loading_screen",
	"fireborn_hud_loading_screen",
	"fireborn_loading_screen",
	"firedragon_loadingscreen",
	"firefly_loadingscreen",
	"firestarter_loading_screen",
	"fires_of_baphomet_loading_screen",
	"flames_of_prosperity_-_loading_screen",
	"forgemaster_loadingscreen",
	"forge_warrior_loading_screen",
	"fortuneteller_loading_screen",
	"free2play_doom_hyhy",
	"free2play_loadingscreen_fear",
	"frostbringer_loadingscreen",
	"ftp_dendi_loading_screen",
	"fungal_protector_loading_screen",
	"g17_flying_fortress_loading_screen",
	"garbs_of_the_eastern_range",
	"geode_loading_screen",
	"gifts_of_fortune_-_loading_screen",
	"glacial_loadingscreen",
	"glaciomarine_loading_screen",
	"greatcalamityti4_loadingscreen",
	"great_deluge_loading_screen",
	"guiding_lights_loading_screen",
	"guise_of_belligerent_ram_loading_screen",
	"gworks_loadingscreen",
	"harbingerwar_loadingscreen",
	"harlequin_loading_screen",
	"haze_atrocity_loading_screen",
	"heavenlygeneral_loadingscreen",
	"heavenlyguardian_loadingscreen",
	"heavenly_light",
	"hells_bat_loading_screen",
	"herald_of_measureless_ruin_loading_screen",
	"hiddenflower_loadingscreen",
	"honorable_brawler_loading_screen",
	"hs_abysm_dominator_loadingscreen",
	"hs_blueheart_maiden_loadingscreen",
	"hs_fiend_summoner_loadingscreen",
	"hs_fiery_slayer_loadingscreen",
	"hs_flared_master_loadingscreen",
	"hs_flying_arrow_loadingscreen",
	"hs_hidden_assassin_loadingscreen",
	"hs_sharpeyes_talent",
	"hs_sweet_toxin_loadingscreen",
	"huangs_umbra_loading_screen",
	"hunternoname_loadingscreen",
	"hunt_of_the_weeping_beast_loading_screen",
	"iceborn_trinity_loading_screen",
	"icewrack_warden_loadingscreen2",
	"immortalspride_loadingscreen",
	"immortal_warlord_loading_screen",
	"imperialrelics_loadingscreen",
	"infinite_waves_loading_screen",
	"iron_claw_loadingscreen",
	"i_league_season2_loading_screen",
	"jollyroger_loading",
	"keen_machine_loading_screen",
	"legacy_of_awakened",
	"lets_race_loading_screen",
	"lucent_gate_loading_screen",
	"lumberclaw_loadingscreen",
	"mad_destructor_loading_screen",
	"mage_eraser_loading_screen",
	"magnoceri_loadingscreen",
	"magnus_defender_matriarch_loading_screen",
	"marauders_loadingscreen",
	"marauding_pyro_loading_screen",
	"mark_of_the_mistral_fiend_loading_screen",
	"meepo_crystal_scavenger_loading_screen",
	"mega_greevil_loadingscreen",
	"mei_nei_rabbit_loading_screen",
	"mentor_high_plains",
	"midlane_loadingscreen",
	"mini_heroes_loadingscreen",
	"mischievous_loadingscreen",
	"moonrift_loading_screen",
	"moonshard_loadingscreen",
	"mourning_mother_loading_screen",
	"mpgl_beastmaster_loadingscreen",
	"mysticcoils_loadingscreen",
	"necronub_load_screen",
	"necro_immemorial_emperor_black",
	"necro_immemorial_emperor_red",
	"necro_robes_heretic",
	"neptunian_servant_loading__screen",
	"oblivion_blazer_loading_screen",
	"obsidianguard_loadingscreen",
	"oceanconquerer_loadingscreen",
	"ogre_ancestral_loadingscreen",
	"orchid_flowersong_loading_screen",
	"pernicious_firebrand_loading_screen",
	"phantasmal_disruptions_loading_screen",
	"poison_flytrap_ls",
	"primeval_loadingscreen",
	"promo_arms_of_the_onyx_crucible_loading_screen",
	"promo_bloody_ripper_loadingscreen",
	"promo_bone_fletcher_loading_screen",
	"promo_gilded_loading_screen",
	"promo_trapper_loading_screen",
	"pudge_delicacies_of_butchery",
	"pyxl_ancients",
	"radiantancient_loadingscreen",
	"ragethree_loadingscreen",
	"raiment_of_the_sacred_blossom_loading_screen",
	"rainmaker_loadingscreen",
	"ravening_loading_screen",
	"ravenous_loadingscreen",
	"raven_vesture_loadscreen",
	"redbull_clinkz_loading_screen",
	"redbull_sandking_loadingscreen",
	"redrage_crawler_loadingscreen",
	"regalia_loading_screen",
	"regalia_of_the_ill_wind_loading_screen",
	"regalia_of_the_wraith_lord_loading_screen",
	"regal_ruin_loading_screen",
	"reminiscence_loading_screen",
	"renewed_jade_comet_loading_screen",
	"rhinoceros_loadingscreen",
	"rightful_heir_loading_screen",
	"riki_frozen_blood",
	"riki_golden_saboteur_loading_screen",
	"roshan_greed",
	"roshan_rage",
	"sacredmemories_loadingscreen",
	"samurai_soul_loading_screen",
	"sandsofluxor_loadingscreen",
	"sanguine_royalty_loading_screen",
	"scavenger_of_basilisk",
	"scions_of_the_sky",
	"scouringdunes_loadingscreen",
	"searing_annihilator_loading_screen",
	"selemenes_eclipse_loading_screen",
	"serpent_warbler_loading_screen",
	"shadowflame_loadingscreen",
	"shivshell_loadingscreen",
	"silencer_whisper_tribunal",
	"silentchampion_loadingscreen",
	"sinisterlightning_loadingscreen",
	"skadi_rising_loading_screen",
	"skyhigh_gyro_loading_screen",
	"sltvx_loadingscreen",
	"sltv_lich_loadingscreen",
	"sltv_loadingscreen",
	"sl_loadingscreen",
	"snowstorm_loadingscreen_jinky",
	"splintering_radiance_loading_screen",
	"stalwart_loadingscreen",
	"staticlord_loadingscreen",
	"steam_chopper_loading_screen",
	"steelcrow_loading_screen",
	"stonehall_loading",
	"stormlands_loadingscreen",
	"storm_spring_loadingscreen",
	"stumpgrinder_loadingscreen",
	"summit2_loadingscreen",
	"sundererd_loadingscreen",
	"sunwarrior_loading_screen",
	"tangki_loadingscreen",
	"tarantula_loading",
	"ta_butterfly_loading_screen",
	"team_empire_loading_screen",
	"techies_arcana",
	"tempestwrath_loadingscreen",
	"tevent_2_gatekeeper_loading_screen",
	"the_hunter_of_kings_loading_screen",
	"the_wolf_hunter_loading_screen",
	"the_wolf_hunter_spirit_bear_loading_screen",
	"thunder_ram_loading_screen",
	"tidosaurus_loading_screen",
	"timberthaw_loadingscreen",
	"toll_of_the_fearful_aria_loading_screen",
	"toplane_loadingscreen",
	"tranquility_loadingscreen",
	"transmuted_armaments_loading_screen",
	"trapper_loading_screen",
	"traxex_loadingscreen",
	"treasureofthedeep_loadingscreen",
	"treepunisher_loadingscreen",
	"tribal_terror_loading_screen",
	"true_crow",
	"tv_hud_fop_springloading",
	"twilights_rest_loading_screen",
	"twinblades_loadingscreen",
	"umbral_descent_loadingscreen",
	"umbra_rider_loading_screen",
	"ursa_cryogenic_embrace_loadscreen",
	"vagabond_loading_screen",
	"valkyrie_loadingscreen",
	"valve_temp_item_screen",
	"vanquishing_demons_loading_screen",
	"vespertine_guard_loading_screen",
	"vici_gaming_loading_screen",
	"vigilante_fox_green_screen",
	"vigilante_fox_red_screen",
	"virtus_pro_loading_screen",
	"virulent_matriarch_loading_screen",
	"wailing_inferno_loadingscreen",
	"wanderer_screenofloading",
	"warhawk_vestiments",
	"warlordofhell_loadingscreen",
	"warmachine_loadscr01",
	"warmachine_loadscr2",
	"webs_of_perception",
	"windranger_wild_wind_loading",
	"witch_hunter_loading_screen",
	"world_splitter_loading_screen",
	"wrath_of_the_hellrunner_loading_screen",
	"wurmblood_loading_screen",
	"year_beast_battle",
	"year_beast_fall",
	"year_beast_terror",
	"yodota2_loadingscreen",
	"zephyrus_loadingscreen",
	"zodiac_sigils",
]

function HeroSelectionStart(data) {
	MainPanel.visible = true
	SelectionTimerDuration = data.SelectionTime
	SelectionTimerStartTime = Game.GetGameTime();
	$.Schedule(0.25, UpdateTimer)
	$("#GameModeInfoGamemodeLabel").text = $.Localize("#hero_selection_mode_" + data.GameModeType)
	if (data.GameModeType != "all_pick") {
		$("#SwitchTabButton").visible = false
	}
	tabsData = data.HeroTabs
	for (var tabKey in data.HeroTabs) {
		var tabTitle = data.HeroTabs[tabKey].title
		var heroesInTab = data.HeroTabs[tabKey].Heroes
		var TabHeroesPanel = $.CreatePanel('Panel', $("#HeroListPanel"), "HeroListPanel_tabPanels_" + tabKey)
		TabHeroesPanel.BLoadLayoutSnippet("HeroesPanel")
		FillHeroesTable(heroesInTab, TabHeroesPanel)
		TabHeroesPanel.visible = false
	}
	SelectHeroTab(1)
	SelectFirstHeroPanel();
}

function SelectHeroTab(tabIndex) {
	if (SelectedTabIndex != tabIndex) {
		if (SelectedTabIndex != null) {
			$("#HeroListPanel_tabPanels_" + SelectedTabIndex).visible = false
				//$("#HeroListTabsPanel_tabButtons_" + SelectedTabIndex).RemoveClass("HeroTabButtonSelected")
		}
		//$("#HeroListTabsPanel_tabButtons_" + tabIndex).AddClass("HeroTabButtonSelected")
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
			playerId: Game.GetLocalPlayerID(),
			hero: SelectedHeroData.heroKey
		})
	}
}

function SelectHero() {
	if (!localHeroPicked) {
		localHeroPicked = true
		GameEvents.SendCustomGameEventToServer("hero_selection_player_select", {
			playerId: Game.GetLocalPlayerID(),
			hero: SelectedHeroData.heroKey
		})
		Game.EmitSound("HeroPicker.Selected")
	}
}

function RandomHero() {
	if (!localHeroPicked) {
		localHeroPicked = true
		GameEvents.SendCustomGameEventToServer("hero_selection_player_random", {
			playerId: Game.GetLocalPlayerID()
		})
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
	$.Schedule(0.25, UpdateTimer)
	if (SelectionTimerRemainingTime > 0) {
		$("#HeroSelectionTimer").text = Math.ceil(SelectionTimerRemainingTime)
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
			TeamSelectionPanel.style.backgroundColor = "gradient( linear, 250% -500%, 0% 100%, from( " + color + " ), to( transparent ) )"
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
				if (playerColor != null) {
					playerColor = "#" + playerColor.substring(6, 8) + playerColor.substring(4, 6) + playerColor.substring(2, 4) + playerColor.substring(0, 2)
				} else {
					playerColor = "#000000";
				}
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
					HeroImage.SetImage(TransformTextureToPath(playerData.hero, "portrait"))
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
				HeroImage.SetImage(TransformTextureToPath(playerData.hero, "portrait"))
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
						var RootPanel = $("#MinimapSpawnBox_" + SPBoxInfoGroup)
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
							panel.DeleteAsync(0);
							PlayerSPBoxesTable.splice(index, 1);
						}
					}
					$.Each($("#MinimapImage").Children(), function(child) {
						var childrencount = child.GetChildCount()
						child.SetHasClass("SpawnBoxUnitPanelChildren2", childrencount >= 2)
						child.SetHasClass("SpawnBoxUnitPanelChildren3", childrencount >= 3)
						child.SetHasClass("SpawnBoxUnitPanelChildren5", childrencount >= 5)
					})
				}
			}
		}
	}

}

function HeroSelectionEnd() {
	$.GetContextPanel().style.opacity = 0
	$.Schedule(5.6, function() {
		MainPanel.visible = false
		if (HideEvent != null)
			GameEvents.Unsubscribe(HideEvent)
		if (ShowPrecacheEvent != null)
			GameEvents.Unsubscribe(ShowPrecacheEvent)
		if (PTID != null)
			PlayerTables.UnsubscribeNetTableListener(PTID)

		$.GetContextPanel().DeleteAsync(0)
	})
}

function Initialize() {
	if (Game.GameStateIsAfter(DOTA_GameState.DOTA_GAMERULES_STATE_PRE_GAME)) {
		HeroSelectionEnd()
	} else {
		UpdatePanoramaState()
	}
}

function UpdatePanoramaState() {
	var hero_selection_available_heroes = PlayerTables.GetAllTableValues("hero_selection_available_heroes")
	if (hero_selection_available_heroes != null && typeof hero_selection_available_heroes == "object" && hero_selection_available_heroes.HeroTabs != null) {
		HeroSelectionStart(hero_selection_available_heroes)
	} else {
		$.Schedule(0.03, UpdatePanoramaState)
	}
}

function ShowPrecache() {
	$("#HeroSelectionBox").visible = false
	$("#HeroSelectionPrecacheBase").visible = true
	var PlayerPickData = PlayerTables.GetAllTableValues("hero_selection")
	for (var teamNumber in PlayerPickData) {
		/*if ($("#team_selection_panels_team" + teamNumber) == null) {
			var TeamPanel = $.CreatePanel('Panel', $("#TeamSelectionStatusPanel"), "team_selection_panels_team" + teamNumber)
			TeamPanel.AddClass("TeamPanel")
		}*/

		var TeamPanel = $("#PrecacheTeamEntryTeam" + teamNumber)
		for (var playerIdInTeam in PlayerPickData[teamNumber]) {
			var SelectedPlayerHeroData = PlayerPickData[teamNumber][playerIdInTeam]
			var PlayerInTeamPanel = $.CreatePanel('Panel', TeamPanel, "")
			PlayerInTeamPanel.AddClass("PrecacheTeamPlayerPanel")

			var PlayerInTeamNickname = $.CreatePanel('Label', PlayerInTeamPanel, "")
			PlayerInTeamNickname.AddClass("PrecachePlayerInTeamNickname")
			PlayerInTeamNickname.text = Players.GetPlayerName(Number(playerIdInTeam))
			var playerColor = Players.GetPlayerColor(Number(playerIdInTeam))
			var playerColor = Players.GetPlayerColor(Number(playerIdInTeam)).toString(16)
			if (playerColor != null) {
				playerColor = "#" + playerColor.substring(6, 8) + playerColor.substring(4, 6) + playerColor.substring(2, 4) + playerColor.substring(0, 2)
			} else {
				playerColor = "#000000";
			}
			PlayerInTeamNickname.style.color = playerColor
			hero_tabs_iter:
				for (var tabkey in tabsData) {
					for (var herokey in tabsData[tabkey].Heroes) {
						var heroData = tabsData[tabkey].Heroes[herokey]
						if (heroData.heroKey == SelectedPlayerHeroData.hero) {
							if (heroData.custom_scene_camera != null)
								PlayerInTeamPanel.BCreateChildren("<DOTAScenePanel style=\"width: 100%; height: 100%; opacity-mask: url('s2r://panorama/images/masks/softedge_box_png.vtex');\" map=\"custom_scenes_map\" camera=\"" + heroData.custom_scene_camera + "\"/>");
							else if (heroData.custom_scene_image != null)
								PlayerInTeamPanel.BCreateChildren("<Image style=\"opacity-mask: url('s2r://panorama/images/masks/softedge_box_png.vtex');\" src=\"" + heroData.custom_scene_image + "\"/>");
							else
								PlayerInTeamPanel.BCreateChildren("<DOTAScenePanel style=\"width: 100%; height: 100%; opacity-mask: url('s2r://panorama/images/masks/softedge_box_png.vtex');\" unit=\"" + heroData.model + "\"/>");
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


(function() {
	$("#HeroSelectionPrecacheBase").visible = false;
	Initialize();
	HideEvent = GameEvents.Subscribe("hero_selection_hide", HeroSelectionEnd);
	ShowPrecacheEvent = GameEvents.Subscribe("hero_selection_show_precache", ShowPrecache);
	PTID = PlayerTables.SubscribeNetTableListener("hero_selection", UpdateHeroesSelected);
	UpdateHeroesSelected("hero_selection", PlayerTables.GetAllTableValues("hero_selection"));
	var BGName = bgs[Math.floor(Math.random() * bgs.length)];
	$("#HeroSelectionBackground").SetImage("file://{images}/loadingscreens/" + BGName + "/loadingscreen.tga");
	var f = function() {
		$.Schedule(0.2, f)
		SearchHero()
		$.Each(Game.GetAllPlayerIDs(), function(id) {
			var p = $("#playerpickpanelhost_player" + id)
			if (p != null) {
				var playerInfo = Game.GetPlayerInfo(id);
				p.SetHasClass("player_connection_abandoned", playerInfo.player_connection_state == DOTAConnectionState_t.DOTA_CONNECTION_STATE_ABANDONED);
				p.SetHasClass("player_connection_failed", playerInfo.player_connection_state == DOTAConnectionState_t.DOTA_CONNECTION_STATE_FAILED);
				p.SetHasClass("player_connection_disconnected", playerInfo.player_connection_state == DOTAConnectionState_t.DOTA_CONNECTION_STATE_DISCONNECTED);
			}
		})
	}
	f()
})();