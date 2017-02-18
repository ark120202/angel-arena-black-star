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
}

NOT_DAMAGE_REFRLECTABLE_ABILITIES = {
	freya_pain_reflection = true,
	centaur_return = true,
	stargazer_inverse_field = true,
	item_blade_mail_arena = true,
	item_blade_mail_2 = true,
	item_blade_mail_3 = true,
	item_sacred_blade_mail = true,
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

REFRESH_LIST_IGNORE_REARM = {
	"tinker_rearm_arena",
	"item_refresher_arena",
	"item_aegis_arena",
	"item_refresher_core",
	"item_titanium_bar",
	
	"item_pipe",
	"item_arcane_boots",
	"item_helm_of_the_dominator",
	"item_hand_of_midas",
	"item_sphere",
	"item_necronomicon",
	"item_heart_cyclone",
	"item_hand_of_midas_arena",
	"item_hand_of_midas_2_arena",
	"item_hand_of_midas_3_arena",
	"item_black_king_bar_arena",
	"item_black_king_bar_2",
	"item_black_king_bar_3",
	"item_black_king_bar_4",
	"item_black_king_bar_5",
	"item_black_king_bar_6",
	
	"earthshaker_echo_slam",
	"juggernaut_omni_slash",
	"warlock_rain_of_chaos_arena",
	"skeleton_king_reincarnation_arena",
	"faceless_void_time_freeze",
	"call_down_arena",
	"bane_fiends_grip",
	"omniknight_repel_lua",
	"omniknight_guardian_angel_lua",
	"mirana_invis",
	"nevermore_requiem",
	"razor_eye_of_the_storm",
	"zuus_thundergods_wrath",
	"kunkka_ghostship",
	"lina_laguna_blade",
	"lich_chain_frost",
	"lion_finger_of_death",
	"shadow_shaman_mass_serpent_ward",
	"tidehunter_ravage",
	"enigma_black_hole",
	"necrolyte_reapers_scythe",
	"queenofpain_sonic_wave",
	"luna_eclipse",
	"dazzle_shallow_grave",
	"dazzle_weave",
	"rattletrap_hookshot",
	"dark_seer_wall_of_replica",
	"weaver_time_lapse",
	"batrider_flaming_lasso",
	"ursa_enrage",
	"silencer_global_silence",
	"treant_overgrowth",
	"slark_shadow_dance",
	"centaur_stampede",
	"abaddon_borrowed_time",
	"oracle_false_promise",
	"furion_wrath_of_nature",
	"spectre_haunt",
	"ancient_apparition_ice_blast",
	"stargazer_cosmic_countdown",
	"zen_gehraz_superposition",
	"furion_force_of_nature",
	"doom_bringer_devour",
	"omniknight_select_enemies",
	"omniknight_select_allies",
	"magnataur_reverse_polarity",
	"queenofblades_alter_ego",
}

REFRESH_LIST_IGNORE_REFRESHER = {
	"tinker_rearm_arena",
	"item_refresher_arena",
	"item_aegis_arena",
	"item_refresher_core",
	"item_titanium_bar",
}

REFRESH_LIST_IGNORE_OMNIKNIGHT_SELECT = {
	"tinker_rearm_arena",
	"item_refresher_arena",
	"item_aegis_arena",
	"item_refresher_core",
	"item_titanium_bar",

	"omniknight_select_allies",
	"omniknight_select_enemies",
}

BOSS_BANNED_ABILITIES = {
	"item_heart_cyclone",
	"item_blink_staff",
	"huskar_life_break",
	"necrolyte_reapers_scythe",
	"death_prophet_spirit_siphon",
	"rubick_personality_steal",
	"item_urn_of_demons",
	"apocalypse_king_slayer",
	"apocalypse_armor_tear",
}

PERSONALITY_STEAL_BANNED_HEROES = {
	["npc_dota_hero_wisp"] = true,
	["npc_dota_hero_invoker"] = true,
	["npc_arena_hero_sara"] = true,
}

SPELL_AMPLIFY_NOT_SCALABLE_MODIFIERS = {
	["zuus_static_field"] = true,
	["enigma_midnight_pulse"] = true,
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