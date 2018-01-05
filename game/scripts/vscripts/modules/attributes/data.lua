ATTRIBUTE_LIST = {
	health = {
		attribute = DOTA_ATTRIBUTE_STRENGTH,
		attributeDerivedStat = DOTA_ATTRIBUTE_STRENGTH_HP,
		default = 20,

		property = MODIFIER_PROPERTY_HEALTH_BONUS,
		getter = "GetModifierHealthBonus",
	},
	health_regen_pct = {
		attribute = DOTA_ATTRIBUTE_STRENGTH,
		attributeDerivedStat = DOTA_ATTRIBUTE_STRENGTH_HP_REGEN_PERCENT,
		stack = 0.01,
		default = 0.006,

		-- property = MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
		-- getter = "GetModifierHealthRegenPercentage",
	},
	perk_status_resistance_pct = {
		attribute = DOTA_ATTRIBUTE_STRENGTH,
		attributeDerivedStat = DOTA_ATTRIBUTE_STRENGTH_STATUS_RESISTANCE_PERCENT,
		primary = true,
		stack = 0.01,
		default = 0.0005,

		-- property = MODIFIER_PROPERTY_STATUS_RESISTANCE,
		-- getter = "GetModifierStatusResistance",
	},
	armor = {
		attribute = DOTA_ATTRIBUTE_AGILITY,
		attributeDerivedStat = DOTA_ATTRIBUTE_AGILITY_ARMOR,
		default = 1 / 6,
		recalculate = function(hero, attribute)
			local adjustment = Attributes:GetAdjustmentForProp(hero, "armor")
			local armor = attribute * adjustment
			hero:SetPhysicalArmorBaseValue(hero:GetKeyValue("ArmorPhysical") + armor)
		end,
	},
	attackspeed = {
		attribute = DOTA_ATTRIBUTE_AGILITY,
		attributeDerivedStat = DOTA_ATTRIBUTE_AGILITY_ATTACK_SPEED,
		default = 1,

		property = MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		getter = "GetModifierAttackSpeedBonus_Constant",
	},
	perk_movement_speed_pct = {
		attribute = DOTA_ATTRIBUTE_AGILITY,
		attributeDerivedStat = DOTA_ATTRIBUTE_AGILITY_MOVE_SPEED_PERCENT,
		primary = true,
		stack = 0.01,
		default = 0.0006,

		property = MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		getter = "GetModifierMoveSpeedBonus_Percentage",
	},
	mana = {
		attribute = DOTA_ATTRIBUTE_INTELLECT,
		attributeDerivedStat = DOTA_ATTRIBUTE_INTELLIGENCE_MANA,
		default = 12,

		property = MODIFIER_PROPERTY_MANA_BONUS,
		getter = "GetModifierManaBonus",
	},
	mana_regen_pct = {
		attribute = DOTA_ATTRIBUTE_INTELLECT,
		attributeDerivedStat = DOTA_ATTRIBUTE_INTELLIGENCE_MANA_REGEN_PERCENT,
		stack = 0.01,
		default = 0.02,

		-- property = MODIFIER_PROPERTY_MANA_REGEN_PERCENTAGE,
		-- getter = "GetModifierPercentageManaRegen",
	},
	spell_amplify_pct = {
		attribute = DOTA_ATTRIBUTE_INTELLECT,
		attributeDerivedStat = DOTA_ATTRIBUTE_INTELLIGENCE_SPELL_AMP_PERCENT,
		stack = 0.01,
		default = 1 / 15,

		property = MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		getter = "GetModifierSpellAmplify_Percentage",
	},
	perk_magic_resistance_pct = {
		attribute = DOTA_ATTRIBUTE_INTELLECT,
		attributeDerivedStat = DOTA_ATTRIBUTE_INTELLIGENCE_MAGIC_RESISTANCE_PERCENT,
		primary = true,
		stack = 0.01,
		default = 0.0005,

		property = MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		getter = "GetModifierMagicalResistanceBonus",
	},
}
