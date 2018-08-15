MODIFIERS_DEATH_PREVENTING = {
	"modifier_invulnerable",
	"modifier_dazzle_shallow_grave",
	"modifier_abaddon_aphotic_shield",
	"modifier_abaddon_borrowed_time",
	"modifier_nyx_assassin_spiked_carapace",
	"modifier_skeleton_king_reincarnation_life_saver",
	"modifier_skeleton_king_reincarnation_ally",
	"modifier_item_titanium_bar_active",
	"modifier_fountain_aura_arena",
	"modifier_mana_shield_arena",
	"modifier_saber_avalon_invulnerability",
	"modifier_fountain_aura_invulnerability"
}

DUEL_PURGED_MODIFIERS = {
	"modifier_life_stealer_infest",
	"modifier_tether_ally_aghanims",
	"modifier_life_stealer_assimilate",
	"modifier_life_stealer_assimilate_effect",
	"modifier_item_black_king_bar_arena_active",
	"modifier_item_titanium_bar_active"
}

MODIFIERS_TRUESIGHT = {
	"modifier_item_dustofappearance",
	"modifier_bounty_hunter_track",
	"modifier_slardar_amplify_damage",
}

ONCLICK_PURGABLE_MODIFIERS = {
	"modifier_doppelganger_mimic",
	"modifier_tether_ally_aghanims"
}

UNDESTROYABLE_MODIFIERS = {
	modifier_razor_static_link_debuff = true,
}

MOVEMENT_SPEED_MODIFIERS = {
	modifier_lycan_shapeshift_speed = function(unit)
		local ability = unit:FindAbilityByName("lycan_shapeshift")
		return ability and ability:GetSpecialValueFor("speed") or 0
	end,

	modifier_bloodseeker_thirst_speed = function(unit)
		return math.huge
	end,
	modifier_weaver_shukuchi = function(unit)
		return math.huge
	end,

	modifier_talent_movespeed_limit = function(unit)
		return unit:GetModifierStackCount("modifier_talent_movespeed_limit", unit)
	end,
	modifier_arena_rune_haste = function(unit)
		return unit:GetModifierStackCount("modifier_arena_rune_haste", unit)
	end,

	modifier_item_scythe_of_sun_hex = function(unit)
		return unit:FindModifierByName("modifier_item_scythe_of_sun_hex"):GetModifierMoveSpeed_Limit()
	end,
	modifier_destroyer_frenzy = function(unit)
		return unit:FindModifierByName("modifier_destroyer_frenzy"):GetModifierMoveSpeed_Limit()
	end,
}

COOLDOWN_REDUCTION_MODIFIERS = {
	modifier_octarine_unique_cooldown_reduction = function(unit)
		return GetAbilitySpecial(unit:HasModifier("modifier_item_refresher_core") and "item_refresher_core" or "item_octarine_core_arena", "bonus_cooldown_pct")
	end,
	--TODO Make it work without that table, rewrite modifier_octarine_unique_cooldown_reduction in modifier_lua
	modifier_arena_rune_arcane = function(unit)
		return unit:FindModifierByName("modifier_arena_rune_arcane"):GetModifierPercentageCooldown()
	end,
	modifier_talent_cooldown_reduction_pct = function(unit)
		return unit:FindModifierByName("modifier_talent_cooldown_reduction_pct"):GetModifierPercentageCooldown()
	end
}

ATTACK_MODIFIERS = {
	{
		modifier = "modifier_item_skadi_arena",
		projectile = "particles/items2_fx/skadi_projectile.vpcf",
	},
	{
		modifier = "modifier_item_skadi_2",
		projectile = "particles/items2_fx/skadi_projectile.vpcf",
	},
	{
		modifier = "modifier_item_desolator2_arena",
		projectile = "particles/arena/items_fx/desolator2_projectile.vpcf",
	},
	{
		modifier = "modifier_item_skadi_4",
		projectile = "particles/items2_fx/skadi_projectile.vpcf",
	},
	{
		modifier = "modifier_item_desolator3_arena",
		projectile = "particles/arena/items_fx/desolator2_projectile.vpcf",
	},
	{
		modifier = "modifier_item_skadi_8",
		projectile = "particles/items2_fx/skadi_projectile.vpcf",
	},
	{
		modifier = "modifier_item_golden_eagle_relic_unique",
		projectile = "particles/arena/items_fx/golden_eagle_relic_projectile.vpcf",
	},
	{
		modifier = "modifier_item_desolator4_arena",
		projectile = "particles/arena/items_fx/desolator4_projectile.vpcf",
	},
	{
		modifier = "modifier_item_desolator5_arena",
		projectile = "particles/arena/items_fx/desolator5_projectile.vpcf",
	},
	{
		modifier = "modifier_item_desolator6_arena",
		projectile = "particles/arena/items_fx/desolator6_projectile.vpcf",
	},
	--[[{
		modifiers = {
			""
			"modifier_item_desolator6_arena",
		},
		projectile = "particles/arena/items_fx/desolator6_projectile.vpcf",
	}]]
}

MODIFIER_PROC_PRIORITY = {
	desolator = {
		modifier_item_desolator2_arena = 1,
		modifier_item_desolator3_arena = 2,
		modifier_item_desolator4_arena = 3,
		modifier_item_desolator5_arena = 4,
		modifier_item_desolator6_arena = 5,
	}
}
