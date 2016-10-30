MODIFIERS_DEATH_PREVENTING = {
	"modifier_invulnerable",
	"modifier_dazzle_shallow_grave",
	"modifier_abaddon_aphotic_shield",
	"modifier_abaddon_borrowed_time",
	"modifier_nyx_assassin_spiked_carapace",
	"modifier_crystal_maiden_glacier_tranqulity_buff",
	"modifier_skeleton_king_reincarnation_life_saver",
	"modifier_skeleton_king_reincarnation_ally",
	"modifier_item_aegis_arena",
	"modifier_item_titanium_bar_active",
	"modifier_fountain_aura_ally_effect",
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
}

REFRESH_LIST_IGNORE_REARM = {
	"tinker_rearm_arena",
	"item_refresher_arena",
	"item_aegis_arena",
	"item_refresher_core",
	
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
	"item_titanium_bar",
	
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
}

REFRESH_LIST_IGNORE_REFRESHER = {
	"tinker_rearm_arena",
	"item_refresher_arena",
	"item_aegis_arena",
	"item_refresher_core",
}

REFRESH_LIST_IGNORE_OMNIKNIGHT_SELECT = {
	"tinker_rearm_arena",
	"item_refresher_arena",
	"item_aegis_arena",
	"item_refresher_core",

	"omniknight_select_allies",
	"omniknight_select_enemies",
}

COOLDOWN_REDUCTION_ABILITIES = { --reductionType can be "percent" and "constant"
	["item_octarine_core_arena"] = {
		reductionType = "percent",
		reduction = GetAbilitySpecial("item_octarine_core_arena", "bonus_cooldown_pct"),
	},
	["item_refresher_core"] = {
		reductionType = "percent",
		reduction = GetAbilitySpecial("item_refresher_core", "bonus_cooldown_pct"),
	},
}

ATTRIBUTE_IGNORED_ABILITIES = {
	"nyx_assassin_burrow",
	"nyx_assassin_unburrow",
	"morphling_hybrid",
	"life_stealer_assimilate",
	"treant_eyes_in_the_forest",
	"ogre_magi_unrefined_fireblast",
	"earth_spirit_petrify",
}

BOSS_BANNED_ABILITIES = {
	"item_heart_cyclone",
	"item_blink_staff",
	"huskar_life_break",
	"necrolyte_reapers_scythe",
	"death_prophet_spirit_siphon"
}

BOSS_DAMAGE_ABILITY_MODIFIERS = { -- в процентах
	zuus_static_field = 15,
	item_blade_mail = 0,
	centaur_return = 0,
	enigma_midnight_pulse = 0,
	enigma_black_hole = 0,
}

DUEL_PURGED_MODIFIERS = {
	"modifier_life_stealer_infest",
	"modifier_pocket_riki_hide",
}

ABILITY_INVULNERABLE_UNITS = {
	"npc_dota_casino_slotmachine",
	"npc_dota_casino_lina",
}

MODIFIERS_TRUESIGHT = {
	"modifier_item_dustofappearance",
	"modifier_bounty_hunter_track",
	"modifier_slardar_amplify_damage",
}

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
}

ON_DAMAGE_MODIFIER_PROCS = {
	["modifier_item_octarine_core_arena"] = function(attacker, victim, inflictor, damage, damagetype_const) if inflictor and attacker:GetTeam() ~= victim:GetTeam() then
		local heal
		if victim:IsHero() then
			heal = damage * GetAbilitySpecial("item_octarine_core_arena", "hero_lifesteal") * 0.01
			SafeHeal(attacker, heal, attacker)
		else
			heal = damage * GetAbilitySpecial("item_octarine_core_arena", "creep_lifesteal") * 0.01
			SafeHeal(attacker, heal, attacker)
		end
		if heal then
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, attacker, heal, nil)
			ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)
		end

		local item = FindItemInInventoryByName(attacker, "item_octarine_core_arena", false)
		if item and RollPercentage(GetAbilitySpecial("item_octarine_core_arena", "bash_chance")) and not attacker:HasModifier("modifier_octarine_bash_cooldown") and victim:GetTeam() ~= attacker:GetTeam() then
			victim:AddNewModifier(attacker, item, "modifier_stunned", {duration = GetAbilitySpecial("item_octarine_core_arena", "bash_duration")})
			item:ApplyDataDrivenModifier(attacker, attacker, "modifier_octarine_bash_cooldown", {})
		end
	end end,
	["modifier_item_refresher_core"] = function(attacker, victim, inflictor, damage, damagetype_const) if inflictor and attacker:GetTeam() ~= victim:GetTeam() then
		local heal
		if victim:IsHero() then
			heal = damage * GetAbilitySpecial("item_refresher_core", "hero_lifesteal") * 0.01
		else
			heal = damage * GetAbilitySpecial("item_refresher_core", "creep_lifesteal") * 0.01
		end
		SafeHeal(attacker, heal, attacker)
		if heal then
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, attacker, heal, nil)
			ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)
		end

		local item = FindItemInInventoryByName(attacker, "item_refresher_core", false)
		if item and RollPercentage(GetAbilitySpecial("item_refresher_core", "bash_chance")) and not attacker:HasModifier("modifier_octarine_bash_cooldown") and victim:GetTeam() ~= attacker:GetTeam() then
			victim:AddNewModifier(attacker, item, "modifier_stunned", {duration = GetAbilitySpecial("item_refresher_core", "bash_duration")})
			item:ApplyDataDrivenModifier(attacker, attacker, "modifier_octarine_bash_cooldown", {})
		end
	end end,
}

ON_DAMAGE_MODIFIER_PROCS_VICTIM = {
	["modifier_item_holy_knight_shield"] = function(attacker, victim, inflictor, damage, damagetype_const) if inflictor then
		local item = FindItemInInventoryByName(victim, "item_holy_knight_shield", false)
		if item and RollPercentage(GetAbilitySpecial("item_holy_knight_shield", "buff_chance")) and victim:GetTeam() ~= attacker:GetTeam() then
			if PreformAbilityPrecastActions(victim, item) then
				item:ApplyDataDrivenModifier(victim, victim, "modifier_item_holy_knight_shield_buff", {})
			end
		end
	end end
}

OUTGOING_DAMAGE_MODIFIERS = {
	["modifier_kadash_assasins_skills"] = {
		multiplier = function(attacker)
			local kadash_assasins_skills = attacker:FindAbilityByName("kadash_assasins_skills")
			if kadash_assasins_skills then
				return 1 + (kadash_assasins_skills:GetAbilitySpecial("all_damage_bonus_pct") * 0.01)
			end
		end
	},
	["modifier_kadash_strike_from_shadows"] = {
		condition = function(_, _, inflictor)
			return not inflictor
		end,
		multiplier = function(attacker, victim, _, damage)
			local kadash_strike_from_shadows = attacker:FindAbilityByName("kadash_strike_from_shadows")
			attacker:RemoveModifierByName("modifier_kadash_strike_from_shadows")
			attacker:RemoveModifierByName("modifier_invisible")
			if kadash_strike_from_shadows then
				ApplyDamage({
					victim = victim,
					attacker = attacker,
					damage = damage * kadash_strike_from_shadows:GetAbilitySpecial("magical_damage_pct") * 0.01,
					damage_type = kadash_strike_from_shadows:GetAbilityDamageType(),
					ability = kadash_strike_from_shadows
				})
				kadash_strike_from_shadows:ApplyDataDrivenModifier(attacker, victim, "modifier_kadash_strike_from_shadows_debuff", nil)
				return 0
			end
		end
	},
	["modifier_item_piercing_blade"] = {
		condition = function(_, _, inflictor)
			return not inflictor
		end,
		multiplier = function(attacker, victim, _, damage)
			local pct = GetAbilitySpecial("item_piercing_blade", "attack_damage_to_pure_pct") * 0.01
			ApplyDamage({
				victim = victim,
				attacker = attacker,
				damage = damage * pct,
				damage_type = _G[GetKeyValue("item_piercing_blade", "AbilityUnitDamageType")],
				ability = FindItemInInventoryByName(attacker, "item_piercing_blade", false)
			})
			return 1 - pct
		end
	}
}

INCOMING_DAMAGE_MODIFIERS = {
	["modifier_mana_shield_arena"] = {
		multiplier = function(attacker, victim, _, damage)
			local medusa_mana_shield_arena = victim:FindAbilityByName("medusa_mana_shield_arena")
			if medusa_mana_shield_arena and not victim:IsIllusion() and victim:IsAlive() then
				local absorption_percent = medusa_mana_shield_arena:GetAbilitySpecial("absorption_tooltip") * 0.01
				local ndamage = damage * absorption_percent
				local mana_needed = ndamage / medusa_mana_shield_arena:GetAbilitySpecial("damage_per_mana")
				if mana_needed <= victim:GetMana() then
					victim:EmitSound("Hero_Medusa.ManaShield.Proc")

					if RollPercentage(medusa_mana_shield_arena:GetAbilitySpecial("reflect_chance")) then
						ApplyDamage({
							attacker = victim,
							victim = attacker,
							ability = medusa_mana_shield_arena,
							damage = ndamage,
							damage_type = medusa_mana_shield_arena:GetAbilityDamageType(),
						})
					end
					victim:SpendMana(mana_needed, medusa_mana_shield_arena)					
					local particleName = "particles/units/heroes/hero_medusa/medusa_mana_shield_impact.vpcf"
					local particle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, victim)
					ParticleManager:SetParticleControl(particle, 0, victim:GetAbsOrigin())
					ParticleManager:SetParticleControl(particle, 1, Vector(mana_needed,0,0))
					return 1 - absorption_percent
				end
			end
		end
	}
}