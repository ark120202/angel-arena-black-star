CUSTOM_RUNE_SPAWN_TIME = 120

ARENA_RUNE_BOUNTY = 0
ARENA_RUNE_TRIPLEDAMAGE = 1
ARENA_RUNE_HASTE = 2
ARENA_RUNE_ILLUSION = 3
ARENA_RUNE_INVISIBILITY = 4
ARENA_RUNE_REGENERATION = 5
ARENA_RUNE_ARCANE = 6
ARENA_RUNE_FLAME = 7
ARENA_RUNE_ACCELERATION = 8
ARENA_RUNE_VIBRATION = 9
ARENA_RUNE_SOUL_STEAL = 10
ARENA_RUNE_SPIKES = 11

ARENA_RUNE_FIRST = 1
ARENA_RUNE_LAST = ARENA_RUNE_SPIKES

--[[
Growing Rates:
	models/props_gameplay/gold_bag.vmdl
	Multiplies all incoming and reduced gold by 1.5 for 25 seconds
Curse:
	models/props_gameplay/gem01.vmdl
	139, 0, 139
	Each attack applies a debuff that will suffer enemy until it purges it or kills any hero (damage will grow with each second: X^1.5)
Mystic Candy:
	models/props_gameplay/halloween_candy.vmdl
	color random
	Applies 3 random buffs/debuffs
Ghost From:
	models/props_gameplay/pig_blue.vmdl
	Gives unobstructed movement, disarm, silence, invisibility, 550 movement speed
Imitator:
	particles/generic_gameplay/generic_electrified_beam_b.vpcf
	Copies all features from another rune, but additionaly has.
	When picked up spawns
]]

RUNE_SETTINGS = {
	[ARENA_RUNE_TRIPLEDAMAGE] = {
		item = "item_custom_rune_tripledamage",
		particle = "particles/arena/generic_gameplay/rune_tripledamage.vpcf",
		sound = "Rune.DD",
		color = {255,125,0},
		duration = 45,
		damage_pct = 200,
	},
	[ARENA_RUNE_HASTE] = {
		item = "item_custom_rune_haste",
		particle = "particles/generic_gameplay/rune_haste.vpcf",
		sound = "Rune.Haste",
		duration = 25,
		movespeed = 625,
	},
	[ARENA_RUNE_ILLUSION] = {
		item = "item_custom_rune_illusion",
		particle = "particles/generic_gameplay/rune_illusion.vpcf",
		sound = "Rune.Illusion",
		duration = 75,
		illusion_count = 2,
		illusion_outgoing_damage = 35,
		illusion_incoming_damage = 200,
	},
	[ARENA_RUNE_INVISIBILITY] = {
		item = "item_custom_rune_invisibility",
		particle = "particles/generic_gameplay/rune_invisibility.vpcf",
		sound = "Rune.Invis",
		duration = 60
	},
	[ARENA_RUNE_REGENERATION] = {
		item = "item_custom_rune_regeneration",
		particle = "particles/generic_gameplay/rune_regeneration.vpcf",
		sound = "Rune.Regen"
	},
	[ARENA_RUNE_BOUNTY] = {
		item = "item_custom_rune_bounty",
		particle = "particles/generic_gameplay/rune_bounty.vpcf",
		sound = "Rune.Bounty",
		GetValues = function(unit)
			local m = GetDOTATimeInMinutesFull()
			local gold = 50 + (m * 2)^2 / 2.5
			local xp = 50 + m^2.2
			local gold_multiplier = 1
			local xp_multiplier = 1

			local ability_goblins_greed = unit:FindAbilityByName("alchemist_goblins_greed")
			if ability_goblins_greed and ability_goblins_greed:GetLevel() > 0 then
				gold_multiplier = gold_multiplier + ability_goblins_greed:GetAbilitySpecial("bounty_multiplier") - 1
			end
			if unit:HasModifier("modifier_item_blood_of_midas") then
				gold_multiplier = gold_multiplier + GetAbilitySpecial("item_blood_of_midas", "gold_multiplier") - 1
				xp_multiplier = xp_multiplier + GetAbilitySpecial("item_blood_of_midas", "xp_multiplier") - 1
			end
			return gold * gold_multiplier, xp * xp_multiplier
		end,
		special_value_multiplier = 1,
	},
	[ARENA_RUNE_ARCANE] = {
		item = "item_custom_rune_arcane",
		particle = "particles/generic_gameplay/rune_arcane.vpcf",
		sound = "Rune.Arcane",
		duration = 50,
		cooldown_reduction = 30, --Tooltip
		spell_amplify = 50, --Tooltip
	},
	[ARENA_RUNE_FLAME] = {
		item = "item_custom_rune_flame",
		particle = "particles/units/heroes/hero_ember_spirit/ember_spirit_flameguard.vpcf",
		color = {255, 30, 0},
		duration = 30,
		damage_per_second_max_hp_pct = 4,
		radius = 350, --Tooltip
	},
	[ARENA_RUNE_ACCELERATION] = {
		item = "item_custom_rune_acceleration",
		particle = "particles/arena/generic_gameplay/rune_acceleration.vpcf",
		color = {20, 20, 255},
		duration = 35,
		attackspeed = 50, --Tooltip
		xp_multiplier = 2,
	},
	[ARENA_RUNE_VIBRATION] = {
		item = "item_custom_rune_vibration",
		particle = "particles/arena/generic_gameplay/rune_vibration.vpcf",
		color = {0, 0, 255},
		duration = 20,
		interval = 0.8,
		minRadius = 150,
		fullRadius = 350,
		minForce = 375,
		fullForce = 700,
	},
	[ARENA_RUNE_SOUL_STEAL] = {
		item = "item_custom_rune_soul_steal",
		particle = "particles/neutral_fx/prowler_shaman_stomp_debuff_glow.vpcf",
		color = {0, 0, 0},
		duration = 45,
		aura_radius = 1200,
		damage_heal_pct = 30,
	},
	[ARENA_RUNE_SPIKES] = {
		item = "item_custom_rune_spikes",
		particle = "particles/items_fx/blademail.vpcf",
		duration = 25,
		damage_reflection_pct = 50,
	}
}
