-- This is the entry-point to your game mode and should be used primarily to precache models/particles/sounds/etc

require('internal/util')
--print(PlayerResource:GetSelectedHeroEntity(0):GetAbsOrigin())
--do return end
require('gamemode')

function Precache( context )
	DebugPrint("[BAREBONES] Performing pre-load precache")
	local particles = {
		"particles/arena/items_fx/desolating_skadi_projectile.vpcf",
		"particles/arena/items_fx/gem_of_clear_mind_illusion.vpcf",
		"particles/prototype_fx/item_linkens_buff_explosion_wave.vpcf",
		"particles/arena/units/arena_statue/statue_eye.vpcf",
		"particles/econ/items/outworld_devourer/od_shards_exile/od_shards_exile_ambient_root_b.vpcf",
		"particles/generic_gameplay/generic_manaburn.vpcf",
		"particles/arena/generic_gameplay/generic_manasteal.vpcf",
		"particles/dark_smoke_test.vpcf", --TODO Different particles
		"particles/generic_gameplay/generic_purge.vpcf",
		"particles/arena/items_fx/steam_footgear.vpcf",
		"particles/arena/items_fx/eye_of_the_prophet.vpcf",
		"particles/arena/items_fx/ray_of_fate.vpcf",
		"particles/econ/courier/courier_greevil_orange/courier_greevil_orange_ambient_3.vpcf",
		"particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_blinding_light_debuff.vpcf",
		"particles/econ/events/ti4/dagon_ti4.vpcf",
		"particles/econ/events/ti5/dagon_lvl2_ti5.vpcf",
		"particles/arena/aoe_range_ring.vpcf",
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
		
		"particles/units/heroes/hero_legion_commander/legion_commander_press.vpcf",
		"particles/econ/items/legion/legion_fallen/legion_fallen_press_a.vpcf",
		"particles/econ/items/legion/legion_fallen/legion_fallen_press.vpcf",
		--"particles/econ/events/coal/coal_projectile.vpcf",
		--"particles/units/heroes/hero_techies/techies_base_attack_model.vpcf",
	}
	local models = {
		"models/items/meepo/diggers_divining_rod/diggers_divining_rod_gem_saphire.vmdl",
		"models/props_gameplay/chicken.vmdl",
		"models/heroes/items/hat_test/hat_test.vmdl",
		"models/items/tidehunter/diving_helmet/tidehunter_diving_helmet.vmdl",
		"models/heroes/earthshaker/totem.vmdl",
		--Neutrals
		"models/heroes/centaur/centaur.vmdl",
		--Wearables
		"models/items/courier/el_gato_beyond_the_summit/el_gato_beyond_the_summit.vmdl",
		"models/items/furion/treant_stump.vmdl",
	}

	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_ogre_magi.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_doombringer.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_enigma.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_vengefulspirit.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_zuus.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_lone_druid.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_lina.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_arena.vsndevts", context)
	
	PrecacheUnitByNameSync("npc_dota_hero_earth_spirit", context)
	
	PrecacheUnitByNameSync("npc_arena_boss_heaven", context)
	PrecacheUnitByNameSync("npc_arena_boss_hell", context)
	PrecacheUnitByNameSync("npc_arena_boss_central", context)
	PrecacheUnitByNameSync("npc_arena_boss_l1_v1", context)
	PrecacheUnitByNameSync("npc_arena_boss_l1_v2", context)
	PrecacheUnitByNameSync("npc_arena_boss_l2_v1", context)
	PrecacheUnitByNameSync("npc_arena_boss_l2_v2", context)

	PrecacheUnitByNameSync("npc_dota_lucifers_claw_doomling", context)
	PrecacheUnitByNameSync("npc_queenofblades_alter_ego", context)


	
	for _, handle in pairs(CUSTOM_WEARABLES_ITEM_HANDLES) do
		if handle.particles and type(handle.particles) == "table" and table.count(handle.particles) > 0 then
			for _,v in pairs(handle.particles) do
				table.insert(particles, v)
			end
		end
		if handle.models and type(handle.models) == "table" and #handle.models > 0 then
			for _,v in pairs(handle.models) do
				if v.model then
					table.insert(models, v.model)
				end
			end
		end
	end
	
	for _, v in pairs(NPC_HEROES_ALTERNATIVE) do
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

	for _,v in ipairs(particles) do
		PrecacheResource("particle", v, context)
	end
	for _,v in ipairs(models) do
		PrecacheResource("model", v, context)
	end
end

-- Create the game mode when we activate
function Activate()
	GameRules.GameMode = GameMode()
	GameRules.GameMode:_InitGameMode()
end