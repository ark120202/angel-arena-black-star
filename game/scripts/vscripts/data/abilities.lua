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
	item_ethereal_blade = true,
	death_prophet_spirit_siphon = true,
	witch_doctor_maledict = true,
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

-- https://dota2.gamepedia.com/Spell_Reflection#Not_reflected_abilities
SPELL_REFLECT_IGNORED_ABILITIES = {
	grimstroke_soul_chain = true,
	morphling_replicate = true,
	rubick_spell_steal = true,
}
