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
	wisp_tether = {"wisp_tether_break"},
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
	"elder_titan_ancestral_spirit",
	"elder_titan_return_spirit",
	"ember_spirit_sleight_of_fist",
}

REFRESH_LIST_IGNORE_REFRESHER = {
	item_refresher_arena = true,
	item_refresher_core = true,
}

REFRESH_LIST_IGNORE_BODY_RECONSTRUCTION = {
	item_refresher_arena = true,
	item_refresher_core = true,
	item_black_king_bar = true,
	item_titanium_bar = true,
	item_coffee_bean = true,

	destroyer_body_reconstruction = true,
}

REFRESH_LIST_IGNORE_REARM = {
	tinker_rearm_arena = true,
	item_refresher_arena = true,
	item_refresher_core = true,
	item_titanium_bar = true,
	item_guardian_greaves_arena = true,
	item_demon_king_bar = true,
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
	item_black_king_bar_arena = true,
	item_black_king_bar_2 = true,
	item_black_king_bar_3 = true,
	item_black_king_bar_4 = true,
	item_black_king_bar_5 = true,
	item_black_king_bar_6 = true,

	destroyer_body_reconstruction = true,
	stargazer_cosmic_countdown = true,
	faceless_void_chronosphere = true,
	zuus_thundergods_wrath = true,
	enigma_black_hole = true,
	freya_pain_reflection = true,
	skeleton_king_reincarnation_arena = true,
	dazzle_shallow_grave = true,
	zuus_cloud = true,
	ancient_apparition_ice_blast = true,
	silencer_global_silence = true,
	naga_siren_song_of_the_siren = true,
	slark_shadow_dance = true,
}

COFFEE_BEAN_NOT_REFRESHABLE = {
	zuus_cloud = true,
	monkey_king_boundless_strike = true,
	dazzle_shallow_grave = true,
	saitama_push_ups = true,
	saitama_squats = true,
	saitama_sit_ups = true,
}


BOSS_BANNED_ABILITIES = {
	item_heart_cyclone = true,
	item_blink_staff = true,
	item_urn_of_demons = true,
	razor_static_link = true,
	tusk_walrus_kick = true,
	death_prophet_spirit_siphon = true,
	item_force_staff = true,
	item_hurricane_pike = true,
	rubick_telekinesis = true,
	item_demon_king_bar = true,
	morphling_adaptive_strike_str = true,
	item_spirit_helix = true,
	pugna_life_drain = true,
}

-- "CalculateSpellDamageTooltip"	"0"
SPELL_AMPLIFY_NOT_SCALABLE_MODIFIERS = {
	zuus_static_field = true,
	enigma_midnight_pulse = true,
	enigma_black_hole = true,
	zaken_stitching_strikes = true,
	morphling_adaptive_strike_agi = true,
	nyx_assassin_mana_burn = true,
	elder_titan_earth_splitter = true,
	necrolyte_reapers_scythe = true,
	doom_bringer_infernal_blade = true,
	phoenix_sun_ray = true,
	silencer_glaives_of_wisdom = true,
	winter_wyvern_arctic_burn = true,
	obsidian_destroyer_sanity_eclipse = true,
	centaur_stampede = true,
	obsidian_destroyer_arcane_orb = true,
	spectre_dispersion = true,
	skywrath_mage_arcane_bolt = true,
	centaur_return = true,
	huskar_life_break = true,
	item_spirit_helix = true,
}

OCTARINE_NOT_LIFESTALABLE_ABILITIES = {
	["freya_pain_reflection"] = true,
	["spectre_dispersion"] = true,
}

ARENA_NOT_CASTABLE_ABILITIES = {
	["techies_land_mines"] = GetAbilitySpecial("techies_land_mines", "radius"),
	["techies_stasis_trap"] = GetAbilitySpecial("techies_stasis_trap", "activation_radius"),
	["techies_remote_mines"] = GetAbilitySpecial("techies_land_mines", "radius"),
	["invoker_chaos_meteor"] = 1100,
	["disruptor_thunder_strike"] = GetAbilitySpecial("disruptor_thunder_strike", "radius"),
	["pugna_nether_blast"] = GetAbilitySpecial("pugna_nether_blast", "radius"),
	["enigma_midnight_pulse"] = GetAbilitySpecial("enigma_midnight_pulse", "radius"),
	["abyssal_underlord_firestorm"] = GetAbilitySpecial("abyssal_underlord_firestorm", "radius"),
	["skywrath_mage_mystic_flare"] = GetAbilitySpecial("skywrath_mage_mystic_flare", "radius"),
}

PERCENT_DAMAGE_MODIFIERS = {
}
