LINKED_ABILITIES = {
	shredder_chakram_2 = {"shredder_return_chakram_2"},
	shredder_chakram = {"shredder_return_chakram"},
	kunkka_x_marks_the_spot = {"kunkka_return"},
	life_stealer_infest = {"life_stealer_control", "life_stealer_consume"},
	rubick_telekinesis = {"rubick_telekinesis_land"},
	bane_nightmare = {"bane_nightmare_end"},
	phoenix_icarus_dive = {"phoenix_icarus_dive_stop"},
	phoenix_fire_spirits = {"phoenix_launch_fire_spirit"},
	ancient_apparition_ice_blast = {"ancient_apparition_ice_blast_release"},
	wisp_tether_aghanims = {"wisp_tether_break_aghanims"},
	alchemist_unstable_concoction = {"alchemist_unstable_concoction_throw"},
	monkey_king_mischief = {"monkey_king_untransform"},
	monkey_king_primal_spring = {"monkey_king_primal_spring_early"},
}

NOT_MULTICASTABLE_ABILITIES = {
	"ogre_magi_bloodlust",
	"ogre_magi_fireblast",
	"ogre_magi_ignite",
	"ogre_magi_unrefined_fireblast",
	"ogre_magi_multicast_arena",
	"invoker_quas",
	"invoker_wex",
	"invoker_exort",
	"invoker_invoke",
	"shredder_chakram",
	"alchemist_unstable_concoction",
	"alchemist_unstable_concoction_throw",
	"riki_pocket_riki",
	"elder_titan_ancestral_spirit",
	"elder_titan_return_spirit",
	"ember_spirit_sleight_of_fist",
}

REFRESH_LIST_IGNORE_REFRESHER = {
	item_refresher_arena = true,
	item_aegis_arena = true,
	item_refresher_core = true,
	dazzle_shallow_grave = true,
	omniknight_select_allies = true,
	omniknight_select_enemies = true,
	destroyer_body_reconstruction = true,
	item_coffee_bean = true,
}

REFRESH_LIST_IGNORE_OMNIKNIGHT_SELECT = {
	item_refresher_arena = true,
	item_aegis_arena = true,
	item_refresher_core = true,
	item_titanium_bar = true,
	item_coffee_bean = true,

	omniknight_select_allies = true,
	omniknight_select_enemies = true,
}

REFRESH_LIST_IGNORE_BODY_RECONSTRUCTION = {
	item_refresher_arena = true,
	item_aegis_arena = true,
	item_refresher_core = true,
	item_titanium_bar = true,
	item_black_king_bar_arena = true,
	item_black_king_bar_2 = true,
	item_black_king_bar_3 = true,
	item_black_king_bar_4 = true,
	item_black_king_bar_5 = true,
	item_black_king_bar_6 = true,

	destroyer_body_reconstruction = true,
}

REFRESH_LIST_IGNORE_REARM = {
	tinker_rearm_arena = true,
	item_refresher_arena = true,
	item_aegis_arena = true,
	item_refresher_core = true,
	item_titanium_bar = true,
	item_guardian_greaves_arena = true,

	omniknight_select_allies = true,
	omniknight_select_enemies = true,

	item_black_king_bar_arena = true,
	item_black_king_bar_2 = true,
	item_black_king_bar_3 = true,
	item_black_king_bar_4 = true,
	item_black_king_bar_5 = true,
	item_black_king_bar_6 = true,

	destroyer_body_reconstruction = true,

	item_pipe = true,
	item_arcane_boots = true,
	item_helm_of_the_dominator = true,
	item_sphere = true,
	item_necronomicon = true,
	item_hand_of_midas_arena = true,
	item_hand_of_midas_2_arena = true,
	item_hand_of_midas_3_arena = true,
	item_mekansm_arena = true,
	item_mekansm_2 = true,

	earthshaker_echo_slam = true,
	juggernaut_omni_slash = true,
	warlock_rain_of_chaos_arena = true,
	skeleton_king_reincarnation_arena = true,
	faceless_void_time_freeze = true,
	call_down_arena = true,
	bane_fiends_grip = true,
	omniknight_repel_lua = true,
	omniknight_guardian_angel_lua = true,
	mirana_invis = true,
	nevermore_requiem = true,
	razor_eye_of_the_storm = true,
	zuus_thundergods_wrath = true,
	kunkka_ghostship = true,
	lina_laguna_blade = true,
	lich_chain_frost = true,
	lion_finger_of_death = true,
	shadow_shaman_mass_serpent_ward = true,
	tidehunter_ravage = true,
	enigma_black_hole = true,
	necrolyte_reapers_scythe = true,
	queenofpain_sonic_wave = true,
	luna_eclipse = true,
	dazzle_shallow_grave = true,
	dazzle_weave = true,
	rattletrap_hookshot = true,
	dark_seer_wall_of_replica = true,
	weaver_time_lapse = true,
	batrider_flaming_lasso = true,
	ursa_enrage = true,
	silencer_global_silence = true,
	treant_overgrowth = true,
	slark_shadow_dance = true,
	centaur_stampede = true,
	abaddon_borrowed_time = true,
	oracle_false_promise = true,
	furion_wrath_of_nature = true,
	spectre_haunt = true,
	ancient_apparition_ice_blast = true,
	stargazer_cosmic_countdown = true,
	zen_gehraz_superposition = true,
	furion_force_of_nature = true,
	doom_bringer_devour_arena = true,
	magnataur_reverse_polarity = true,
	queenofblades_alter_ego = true,
	saber_excalibur = true,
}

COFFEE_BEAN_NOT_REFRESHABLE = {
	destroyer_body_reconstruction = true,
	zuus_cloud = true,
	monkey_king_boundless_strike = true,
}


BOSS_BANNED_ABILITIES = {
	item_heart_cyclone = true,
	item_blink_staff = true,
	huskar_life_break = true,
	necrolyte_reapers_scythe = true,
	death_prophet_spirit_siphon = true,
	rubick_personality_steal = true,
	item_urn_of_demons = true,
	razor_static_link = true,
}

PERSONALITY_STEAL_BANNED_HEROES = {
	["npc_dota_hero_wisp"] = true,
	["npc_dota_hero_meepo"] = true,
	["npc_arena_hero_sara"] = true,
	["npc_dota_hero_necrolyte"] = true,
	["npc_dota_hero_storm_spirit"] = true,
	["npc_dota_hero_tidehunter"] = true,
	["npc_dota_hero_arc_warden"] = true,
	["npc_dota_hero_shredder"] = true,
}

-- "CalculateSpellDamageTooltip"	"0"
SPELL_AMPLIFY_NOT_SCALABLE_MODIFIERS = {
	zuus_static_field = true,
	enigma_midnight_pulse = true,
	morphling_adaptive_strike = true,
	nyx_assassin_spiked_carapace = true,
	huskar_life_break = true,
	nyx_assassin_mana_burn = true,
	skywrath_mage_arcane_bolt = true,
	elder_titan_earth_splitter = true,
	necrolyte_reapers_scythe = true,
	doom_bringer_infernal_blade = true,
	phoenix_sun_ray = true,
	silencer_glaives_of_wisdom = true,
	winter_wyvern_arctic_burn = true,
	obsidian_destroyer_sanity_eclipse = true,
	centaur_stampede = true,
	obsidian_destroyer_arcane_orb = true,
}

OCTARINE_NOT_LIFESTALABLE_ABILITIES = {
	["freya_pain_reflection"] = true,
}

ARENA_NOT_CASTABLE_ABILITIES = {
	["techies_land_mines"] = GetAbilitySpecial("techies_land_mines", "radius"),
	["techies_stasis_trap"] = GetAbilitySpecial("techies_stasis_trap", "activation_radius"),
	["techies_remote_mines"] = GetAbilitySpecial("techies_land_mines", "radius"),
	["invoker_chaos_meteor"] = 1100,
}

PERCENT_DAMAGE_MODIFIERS = {
	["ember_spirit_flame_guard"] = GetAbilitySpecial("ember_spirit_flame_guard", "tick_interval"),
	["ember_spirit_searing_chains"] = GetAbilitySpecial("ember_spirit_searing_chains", "tick_interval"),
}

DISABLE_HELP_ABILITIES = {
	wisp_tether_aghanims = true,
	keeper_of_the_light_recall = true,
	chen_test_of_faith_teleport = true,
	oracle_purifying_flames = true,
	kunkka_x_marks_the_spot = true,
	bloodseeker_bloodrage = true,
	bane_nightmare = true,
	winter_wyvern_cold_embrace = true,
}
