CUSTOM_TALENTS_DATA = {
	talent_Exp = {
		icon = "wtf",
		cost = 4,
		group = 1,
		max_level = 7,
		special_values = {
			["ДОП ОПЫТ"] = {10, 15, 20, 25, 30, 35, 40,}
		},
		effect = {
			modifiers = {
				["modifier_talent_damage"] = "доп опыт",
			},
		}
	},

	talent_Gold = {
		icon = "wtf",
		cost = 8,
		group = 1,
		max_level = 7,
		special_values = {
			["Доп золото"] = {5, 8, 12, 14, 16, 18, 20,}
		},
		effect = {
			modifiers = {
				["modifier_talent_damage"] = "Доп золото",
			},
		}
	},

	talent_HUD = {
		icon = "wtf",
		cost = 3,
		group = 2,
		max_level = 7,
		special_values = {
			["Dop HUD"] = {3, 6, 9, 12, 15, 18, 21,}
		},
		effect = {
			modifiers = {
				["modifier_talent_damage"] = "Dop HUD",
			},
		}
	},

	talent_damage_magical = {
		icon = "wtf",
		cost = 5,
		group = 2,
		max_level = 7,
		special_values = {
			["Damage_Magical"] = {10, 20, 30, 40, 50, 60, 70,}
		},
		effect = {
			modifiers = {
				["modifier_talent_damage"] = "Damage_Magical",
			},
		}
	},

	talent_respawn = {
		icon = "wtf",
		cost = 12,
		group = 10,
		max_level = 7,
		special_values = {
			["Respawn"] = { -10, -15, -20, -25, -30, -35, -40,}
		},
		effect = {
			modifiers = {
				["modifier_talent_damage"] = "Respawn",
			},
		}
	},

	talent_damage_physical = {
		icon = "wtf",
		cost = 2,
		group = 4,
		max_level = 7,
		special_values = {
			["damage_physical"] = {200, 400, 600, 800, 1000, 1200, 1400,}
		},
		effect = {
			modifiers = {
				["modifier_talent_damage"] = "damage_physical",
			},
		}
	},

	talent_Evasion = {
		icon = "wtf",
		cost = 4,
		group = 3,
		max_level = 7,
		special_values = {
			["evasion"] = {5, 10, 15, 20, 25, 30, 35,}
		},
		effect = {
			modifiers = {
				["modifier_talent_damage"] = "evasion",
			},
		}
	},

}

TALENT_GROUP_TO_LEVEL = {
	[1] = 10,
	[2] = 30,
	[3] = 50,
	[4] = 70,
	[5] = 90,
	[6] = 120,
	[7] = 140,
	[8] = 160,
	[10] = 180,
	[11] = 200,
	[12] = 220,
	[14] = 240,
	[15] = 260,
	[16] = 280,
	[17] = 300,
	[18] = 320,
	[19] = 340,
	[20] = 360,
	[21] = 380,
	[22] = 400,
	[23] = 430,
	[24] = 460,
	[25] = 490,
	[26] = 550,
}
