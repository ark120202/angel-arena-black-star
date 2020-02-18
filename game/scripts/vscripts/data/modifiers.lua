MODIFIERS_DEATH_PREVENTING = {
	"modifier_invulnerable",
	"modifier_dazzle_shallow_grave",
	"modifier_abaddon_aphotic_shield",
	"modifier_abaddon_borrowed_time",
	"modifier_nyx_assassin_spiked_carapace",
	"modifier_item_titanium_bar_active",
	"modifier_fountain_aura_arena",
	"modifier_mana_shield_arena",
	"modifier_saber_avalon_invulnerability",
}

MODIFIERS_TRUESIGHT = {
	"modifier_item_dustofappearance",
	"modifier_bounty_hunter_track",
	"modifier_slardar_amplify_damage",
}

ONCLICK_PURGABLE_MODIFIERS = { "modifier_doppelganger_mimic" }

UNDESTROYABLE_MODIFIERS = {
	modifier_razor_static_link_debuff = true,
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
	},
	pure_damage = {
		modifier_item_piercing_blade = 1,
		modifier_item_soulcutter = 2,
	},
}
