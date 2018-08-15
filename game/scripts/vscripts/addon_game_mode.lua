require('util/init')
require('gamemode')

function Precache(context)
	local particles = {
		-- items
		"particles/arena/items_fx/gem_of_clear_mind_illusion.vpcf",
		"particles/prototype_fx/item_linkens_buff_explosion_wave.vpcf",
		"particles/arena/units/arena_statue/statue_eye.vpcf",
		"particles/econ/items/outworld_devourer/od_shards_exile/od_shards_exile_ambient_root_b.vpcf",
		"particles/generic_gameplay/generic_manaburn.vpcf",
		"particles/arena/generic_gameplay/generic_manasteal.vpcf",
		"particles/dark_smoke_test.vpcf",
		"particles/generic_gameplay/generic_purge.vpcf",
		"particles/arena/items_fx/steam_footgear.vpcf",
		"particles/arena/items_fx/eye_of_the_prophet.vpcf",
		"particles/arena/items_fx/ray_of_fate.vpcf",
		"particles/econ/courier/courier_greevil_orange/courier_greevil_orange_ambient_3.vpcf",
		"particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_blinding_light_debuff.vpcf",
		"particles/econ/events/ti4/dagon_ti4.vpcf",
		"particles/econ/events/ti5/dagon_lvl2_ti5.vpcf",
		"particles/units/heroes/hero_alchemist/alchemist_lasthit_msg_gold.vpcf",
		"particles/econ/items/enchantress/enchantress_virgas/ench_impetus_virgas.vpcf",
		"particles/units/heroes/hero_leshrac/leshrac_lightning_bolt.vpcf",
		"particles/arena/units/bosses/primal/laser.vpcf",
		"particles/arena/items_fx/vermillion_robe_explosion.vpcf",
		"particles/arena/items_fx/vermillion_robe_hit.vpcf",
		"particles/arena/items_fx/dark_flow_explosion.vpcf",
		"particles/units/heroes/hero_doom_bringer/doom_bringer_scorched_earth_buff.vpcf",
		"particles/arena/items_fx/urn_of_souls_heal.vpcf",
		"particles/arena/items_fx/urn_of_souls_damage.vpcf",
		"particles/arena/range_display.vpcf",
		"particles/econ/items/antimage/antimage_weapon_basher_ti5/antimage_manavoid_lightning_ti_5.vpcf",
		"particles/arena/items_fx/golden_eagle_relic_buff.vpcf",
		"particles/arena/items_fx/golden_eagle_relic_projectile.vpcf",
		"particles/arena/items_fx/holy_knight_shield_avatar.vpcf",
		"particles/units/heroes/hero_bloodseeker/bloodseeker_rupture_b.vpcf",
		"particles/units/heroes/hero_bloodseeker/bloodseeker_rupture_nuke.vpcf",
		"particles/arena/items_fx/desolator2_projectile.vpcf",
		"particles/arena/items_fx/desolator4_projectile.vpcf",
		"particles/arena/items_fx/desolator5_projectile.vpcf",
		"particles/arena/items_fx/desolator6_projectile.vpcf",
		"particles/arena/items_fx/blade_of_discord_debuff.vpcf",
		"particles/arena/items_fx/blade_of_discord_cast.vpcf",
		"particles/arena/items_fx/tango_arena_cast.vpcf",
		"particles/units/heroes/hero_lone_druid/lone_druid_bear_spawn.vpcf",
		"particles/units/heroes/hero_lone_druid/lone_druid_spirit_bear_death.vpcf",
		"particles/items_fx/blink_dagger_end.vpcf",
		"particles/units/heroes/hero_lone_druid/lone_druid_bear_spawn.vpcf",
		"particles/units/heroes/hero_lina/lina_spell_laguna_blade.vpcf",
		"particles/arena/items_fx/lotus_sphere_buff.vpcf",
		"particles/econ/events/ti6/radiance_owner_ti6.vpcf",
		"particles/arena/items_fx/radiance_frozen_owner.vpcf",
		"particles/arena/items_fx/wand_of_midas.vpcf",
		"particles/econ/events/ti6/mekanism_ti6.vpcf",
		"particles/econ/events/ti6/mekanism_recipient_ti6.vpcf",
		"particles/arena/items_fx/scythe_of_sun.vpcf",
		"particles/econ/events/ti7/shivas_guard_active_ti7.vpcf",
		"particles/arena/items_fx/book_of_the_guardian_2_active.vpcf",
		"particles/econ/events/ti7/shivas_guard_impact_ti7.vpcf",
		"particles/econ/events/ti7/shivas_guard_slow.vpcf",
		"particles/arena/items_fx/scythe_of_the_ancients_start.vpcf",
		"particles/econ/events/ti4/dagon_beam_black_ti4.vpcf",
		-- Heroes
		"particles/units/heroes/hero_legion_commander/legion_commander_press.vpcf",
		"particles/econ/items/legion/legion_fallen/legion_fallen_press_a.vpcf",
		"particles/econ/items/legion/legion_fallen/legion_fallen_press.vpcf",
		-- Runes
		"particles/arena/generic_gameplay/rune_tripledamage.vpcf",
		"particles/arena/generic_gameplay/rune_tripledamage_owner.vpcf",
		"particles/units/heroes/hero_ember_spirit/ember_spirit_flameguard.vpcf",
		"particles/arena/generic_gameplay/rune_vibration.vpcf",
		"particles/arena/generic_gameplay/rune_vibration_owner_wave.vpcf",
		"particles/arena/generic_gameplay/rune_acceleration.vpcf",
		"particles/arena/generic_gameplay/rune_soul_steal_owner_effect.vpcf",
		"particles/neutral_fx/prowler_shaman_stomp_debuff_glow.vpcf",
		"particles/items_fx/blademail.vpcf",
		-- Weather
		"particles/econ/items/crystal_maiden/ti7_immortal_shoulder/cm_ti7_immortal_frostbite.vpcf",
		"particles/econ/items/crystal_maiden/crystal_maiden_cowl_of_ice/maiden_crystal_nova_cowlofice.vpcf",
	}
	local models = {
		"models/items/meepo/diggers_divining_rod/diggers_divining_rod_gem_saphire.vmdl",
		"models/heroes/earthshaker/totem.vmdl",
		-- Neutrals
		"models/heroes/centaur/centaur.vmdl",
		"models/custom/umbrella_rainbow.vmdl",
	}
	local units = {
		"npc_arena_boss_l1_v1",
		"npc_arena_boss_l1_v2",
		"npc_arena_boss_l2_v1",
		"npc_arena_boss_l2_v2",
		"npc_arena_boss_freya",
		"npc_arena_boss_zaken",
		"npc_arena_boss_cursed_zeld",
		"npc_arena_healer",

		"npc_arena_boss_kel_thuzad_ghost",

		"npc_dota_lucifers_claw_doomling",
		"npc_queenofblades_alter_ego",
		"npc_arena_lightning_rod",
	}

	local soundevents = {
		"soundevents/game_sounds_heroes/game_sounds_vengefulspirit.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_crystalmaiden.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_doombringer.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_ogre_magi.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_lone_druid.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_lina.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_zuus.vsndevts",
		"soundevents/game_sounds_arena.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_necrolyte.vsndevts",
	}

	for _, handle in pairs(CUSTOM_WEARABLES) do
		DynamicWearables:PrecacheUnparsedWearable(context, handle)
	end

	for _, spawner in pairs(SPAWNER_SETTINGS) do
		if type(spawner) == "table" and spawner.SpawnTypes then
			for _, spawnType in pairs(spawner.SpawnTypes) do
				for _,minutes in pairs(spawnType) do
					for minute,model in pairs(minutes) do
						if minute ~= -1 then
							table.insert(models, model)
						end
					end
				end
			end
		end
	end

	for k, v in pairs(NPC_HEROES_CUSTOM) do
		if v.Model then
			table.insert(models, v.Model)
		end
		if v.ProjectileModel then
			table.insert(particles, v.ProjectileModel)
		end
	end

	local db = LoadKeyValues("scripts/attachments.txt")
	if db['Particles'] then
		for _,v in pairs(db['Particles']) do
			for pfx,_ in pairs(v) do
				table.insert(particles, pfx)
			end
		end
	end

	for _,v in pairs(WEATHER_EFFECTS) do
		table.concat(particles, v.particles or {})
	end

	for _,v in ipairs(particles) do
		PrecacheResource("particle", v, context)
	end
	for _,v in ipairs(models) do
		PrecacheModel(v, context)
	end
	for _,v in ipairs(units) do
		PrecacheUnitByNameSync(v, context)
	end
	for _,v in ipairs(soundevents) do
		PrecacheResource("soundfile", v, context)
	end
end

function Activate()
	GameRules.GameMode = GameMode()
	GameRules.GameMode:_InitGameMode()
end
