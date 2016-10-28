ABILITY_SHOP_BANNED = {
	["obsidian_destroyer_essence_aura"] = {"storm_spirit_ball_lightning", "bristleback_quill_spray", "pugna_life_drain", "shredder_chakram_2", "shredder_return_chakram_2", "shredder_chakram", "shredder_return_chakram", "techies_focused_detonate", "spectre_reality", "oracle_purifying_flames", "templar_assassin_trap", "skywrath_mage_arcane_bolt", "rubick_telekinesis", "rubick_telekinesis_land", "shadow_demon_shadow_poison_release", "nyx_assassin_unburrow", "nyx_assassin_burrow", "shadow_demon_shadow_poison", },
	["batrider_sticky_napalm"] = { "sandking_sand_storm", "shadow_shaman_shackles", "doom_bringer_scorched_earth", "venomancer_venomous_gale", "venomancer_poison_nova", "ember_spirit_flame_guard", "weaver_the_swarm", "dark_seer_ion_shell", "warlock_fatal_bonds_arena", "spectre_dispersion", "shadow_demon_shadow_poison", },
	["earthshaker_aftershock"] = { "obsidian_destroyer_arcane_orb", "storm_spirit_ball_lightning", "pugna_life_drain", "shredder_chakram_2", "shredder_return_chakram_2", "shredder_chakram", "shredder_return_chakram", "techies_focused_detonate", "spectre_reality", "oracle_purifying_flames", "templar_assassin_trap", "skywrath_mage_arcane_bolt", "rubick_telekinesis", "rubick_telekinesis_land", "zuus_arc_lightning", "shadow_demon_shadow_poison_release", "nyx_assassin_unburrow", "nyx_assassin_burrow", "bristleback_quill_spray", "bristleback_viscous_nasal_goo", "shadow_demon_shadow_poison", },
	["zuus_static_field"] = { "storm_spirit_ball_lightning", "bristleback_quill_spray", "pugna_life_drain", "bristleback_viscous_nasal_goo", "shredder_chakram_2", "shredder_return_chakram_2", "shredder_chakram", "shredder_return_chakram", "techies_focused_detonate", "spectre_reality", "oracle_purifying_flames", "templar_assassin_trap", "skywrath_mage_arcane_bolt", "rubick_telekinesis", "rubick_telekinesis_land", "shadow_demon_shadow_poison_release", "nyx_assassin_unburrow", "nyx_assassin_burrow", "shadow_demon_shadow_poison", },
	["storm_spirit_overload"] = {"troll_warlord_berserkers_rage", "wisp_spirits_out_aghanims", "wisp_spirits_in_aghanims", "wisp_overcharge_aghanims", "rocket_barrage_arena", "cherub_synthesis", "pudge_rot_arena", "pudge_rot", "skeleton_king_vampiric_aura", "witch_doctor_voodoo_restoration", "leshrac_pulse_nova", "wisp_overcharge", "pugna_life_drain", "shredder_chakram_2", "shredder_return_chakram_2", "shredder_chakram", "shredder_return_chakram", "techies_focused_detonate", "spectre_reality", "oracle_purifying_flames", "templar_assassin_trap", "skywrath_mage_arcane_bolt", "rubick_telekinesis", "rubick_telekinesis_land", "shadow_demon_shadow_poison_release", "nyx_assassin_unburrow", "nyx_assassin_burrow", "bristleback_viscous_nasal_goo", "shadow_demon_shadow_poison", },
	["pudge_meat_hook_lua"] = {"furion_teleportation", "kunkka_x_marks_the_spot", "ogre_magi_multicast_arena",  "bloodseeker_thirst", "antimage_blink", "queenofpain_blink", },
	
}

ABILITY_SHOP_BANNED_GROUPS = {
	{
		"troll_warlord_berserkers_rage",
		"slardar_bash",
		"spirit_breaker_greater_bash",
		"faceless_void_time_lock_arena",
	},
	{
		"antimage_blink",
		"queenofpain_blink"
	}
}

ABILITY_SHOP_DATA = {
	["puck_ethereal_jaunt"] = { cost = 0, },
	["shadow_demon_shadow_poison_release"] = { cost = 0, },
	["spectre_reality"] = { cost = 0, },
	["templar_assassin_trap"] = { cost = 0, },
	["techies_focused_detonate"] = { cost = 0, },
	["tinker_rearm_arena"] = { cost = 16, },
	["ogre_magi_multicast_arena"] = { cost = 10, },
	["alchemist_goblins_greed"] = { cost = 4, },
	["kunkka_tidebringer"] = { cost = 3, },
	["earthshaker_enchant_totem"] = { cost = 2, },
	["medusa_split_shot_arena"] = { cost = 3, },
	["medusa_mystic_snake_arena"] = { cost = 4, },
	["medusa_mana_shield_arena"] = { cost = 2, },
	["medusa_stone_gaze_arena"] = { cost = 9, },
	["slark_essence_shift"] = { cost = 2, },
	["sven_great_cleave"] = { cost = 4, },
	["axe_counter_helix"] = { cost = 2, },
	["sandking_caustic_finale"] = { cost = 2, },
	["beastmaster_wild_axes"] = { cost = 2, },
	["weaver_geminate_attack"] = { cost = 5, },
	["riki_permanent_invisibility"] = { cost = 2, },
	["shinobu_vampire_blood"] = { cost = 7, },
	["ember_spirit_sleight_of_fist"] = { cost = 10, },
	["flak_cannon_arena"] = { cost = 4, },
	["omniknight_select_allies"] = { cost = 4, },
	["dark_seer_ion_shell"] = { cost = 5, },
	["warlock_fatal_bonds_arena"] = { cost = 2, },
	["spectre_dispersion"] = { cost = 3, },
	["rocket_barrage_arena"] = { cost = 2, },
	["keeper_of_the_light_illuminate"] = { cost = 2, },
	["magnataur_empower"] = { cost = 2, },
	["ursa_enrage"] = { cost = 8, },
	["razor_plasma_field"] = { cost = 2 },
	["doom_bringer_devour"] = { cost = 3 },
}

ABILITY_SHOP_SKIP_HEROES = {
	"npc_dota_hero_invoker",
	"npc_dota_hero_earth_spirit",
}

ABILITY_SHOP_SKIP_ABILITIES = {
	"rubick_spell_steal",
	"rubick_empty1",
	"rubick_empty2",
	"broodmother_spin_web",
	"morphling_morph",
	"morphling_morph_agi",
	"morphling_morph_str",
	"keeper_of_the_light_recall",
	"keeper_of_the_light_blinding_light",
	"wisp_empty1",
	"wisp_empty2",
	"doom_bringer_empty1",
	"doom_bringer_empty2",
	"phoenix_sun_ray",
	"phoenix_sun_ray_toggle_move_empty",
	"ogre_magi_unrefined_fireblast",
	"keeper_of_the_light_spirit_form",
}