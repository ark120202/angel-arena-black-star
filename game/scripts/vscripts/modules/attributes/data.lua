DOTA_DEFAULT_ATTRIBUTES = {
	health = {
		attribute = DOTA_ATTRIBUTE_STRENGTH,
		default = 20,

		property = MODIFIER_PROPERTY_HEALTH_BONUS,
		getter = "GetModifierHealthBonus",
	},
	health_regen_pct = {
		attribute = DOTA_ATTRIBUTE_STRENGTH,
		stack = 0.01,
		default = 0.7,

		property = MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		getter = "GetModifierConstantHealthRegen",
	},
	perk_status_resistance_pct = {
		attribute = DOTA_ATTRIBUTE_STRENGTH,
		primary = true,
		stack = 0.01,
		default = 0.15,

		-- TODO: Not works now
		property = MODIFIER_PROPERTY_STATUS_RESISTANCE,
		getter = "GetModifierStatusResistance",
	},
	armor = {
		attribute = DOTA_ATTRIBUTE_AGILITY,
		default = 1 / 6,
		recalculate = function(hero, attribute)
			local adjustment = Attributes:GetAdjustmentForProp(hero, "armor")
			local armor = attribute * adjustment
			hero:SetPhysicalArmorBaseValue(hero:GetKeyValue("ArmorPhysical") + armor)
		end,
	},
	attackspeed = {
		attribute = DOTA_ATTRIBUTE_AGILITY,
		default = 1,

		property = MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		getter = "GetModifierAttackSpeedBonus_Constant",
	},
	perk_movement_speed_pct = {
		attribute = DOTA_ATTRIBUTE_AGILITY,
		primary = true,
		stack = 0.01,
		default = 0.06,

		property = MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		getter = "GetModifierMoveSpeedBonus_Percentage",
	},
	mana = {
		attribute = DOTA_ATTRIBUTE_INTELLECT,
		default = 12,

		property = MODIFIER_PROPERTY_MANA_BONUS,
		getter = "GetModifierManaBonus",
	},
	mana_regen_pct = {
		attribute = DOTA_ATTRIBUTE_INTELLECT,
		stack = 0.01,
		default = 2,

		property = MODIFIER_PROPERTY_MANA_REGEN_PERCENTAGE,
		getter = "GetModifierPercentageManaRegen",
	},
	spell_amplify_pct = {
		attribute = DOTA_ATTRIBUTE_INTELLECT,
		stack = 0.01,
		default = 1 / 14,

		property = MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		getter = "GetModifierSpellAmplify_Percentage",
	},
	perk_magic_resistance_pct = {
		attribute = DOTA_ATTRIBUTE_INTELLECT,
		primary = true,
		stack = 0.01,
		default = 0.15,

		property = MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		getter = "GetModifierMagicalResistanceBonus",
	},
}

GLOBAL_ATTRIBUTE_ADJUSTMENTS = {}
