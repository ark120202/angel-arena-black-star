DOTA_DEFAULT_ATTRIBUTES = {
	health = {
		attribute = DOTA_ATTRIBUTE_STRENGTH,
		default = 20,
	},
	health_regen_pct = {
		attribute = DOTA_ATTRIBUTE_STRENGTH,
		stack = 0.01,
		default = 0.7,
	},
	-- TODO
	perk_status_resistance_pct = {
		attribute = DOTA_ATTRIBUTE_STRENGTH,
		primary = true,
		stack = 0.01,
		default = 0.15,
	},
	armor = {
		attribute = DOTA_ATTRIBUTE_AGILITY,
		default = 1 / 6,
		recalculate = function(hero, attribute)
			local adjustment = Attributes:GetAdjustmentForProp(hero, "armor")
			local armor = agility * adjustment
			hero:SetPhysicalArmorBaseValue(hero:GetKeyValue("ArmorPhysical") + armor)
		end,
	},
	attackspeed = {
		attribute = DOTA_ATTRIBUTE_AGILITY,
		default = 1,
	},
	perk_movement_speed_pct = {
		attribute = DOTA_ATTRIBUTE_AGILITY,
		primary = true,
		stack = 0.01,
		default = 0.06,
	},
	mana = {
		attribute = DOTA_ATTRIBUTE_INTELLECT,
		default = 12,
	},
	mana_regen_pct = {
		attribute = DOTA_ATTRIBUTE_INTELLECT,
		stack = 0.01,
		default = 2,
	},
	spell_amplify_pct = {
		attribute = DOTA_ATTRIBUTE_INTELLECT,
		stack = 0.01,
		default = 1 / 14,
	},
	perk_magic_resistance_pct = {
		attribute = DOTA_ATTRIBUTE_INTELLECT,
		primary = true,
		stack = 0.01,
		default = 0.15,
	},
}

GLOBAL_ATTRIBUTE_ADJUSTMENTS = {}
