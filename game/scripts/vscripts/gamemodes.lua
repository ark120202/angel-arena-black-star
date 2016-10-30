DOTA_GAMEMODE_5V5 = 0
--[[DOTA_GAMEMODE_10V10 = 1
DOTA_GAMEMODE_1V1 = 2
DOTA_GAMEMODE_X4 = 3]]

DOTA_GAMEMODE_TYPE_ALLPICK = 10
DOTA_GAMEMODE_TYPE_RANDOM_OMG = 11
DOTA_GAMEMODE_TYPE_ABILITY_SHOP = 12
DOTA_GAMEMODE_TYPE_ABILITY_DRAFT = 13

if GameModes == nil then
	_G.GameModes = class({})

	GameModes.MapNamesToGamemode = {
		["5v5"] = {gamemode = DOTA_GAMEMODE_5V5, type = DOTA_GAMEMODE_TYPE_ALLPICK},
		["5v5_romg"] = {gamemode = DOTA_GAMEMODE_5V5, type = DOTA_GAMEMODE_TYPE_RANDOM_OMG},
		["5v5_abilityshop"] = {gamemode = DOTA_GAMEMODE_5V5, type = DOTA_GAMEMODE_TYPE_ABILITY_SHOP},
		["new_5v5"] = {gamemode = DOTA_GAMEMODE_5V5, type = DOTA_GAMEMODE_TYPE_ABILITY_SHOP},
	--	["arena1v1"] = {gamemode = DOTA_GAMEMODE_1V1, type = DOTA_GAMEMODE_TYPE_ALLPICK},
	--	["arena10v10"] = {gamemode = DOTA_GAMEMODE_10V10, type = DOTA_GAMEMODE_TYPE_ALLPICK},
	--	["arenaX4"] = {gamemode = DOTA_GAMEMODE_X4, type = DOTA_GAMEMODE_TYPE_ALLPICK},
	}

	GameModes.Settings = {
		[DOTA_GAMEMODE_5V5] = {

		},
		--[[[DOTA_GAMEMODE_1V1] = {
		
		},
		[DOTA_GAMEMODE_10V10] = {

		},
		[DOTA_GAMEMODE_X4] = {

		},]]
		[DOTA_GAMEMODE_TYPE_ALLPICK] = {
			
		},
		[DOTA_GAMEMODE_TYPE_RANDOM_OMG] = {
			requirements = {
				"data/random_omg",
			},
		},
		[DOTA_GAMEMODE_TYPE_ABILITY_SHOP] = {
			requirements = {
				"data/ability_shop",
				"ability_shop",
			},
		},
	}
end

if GameModes.MapNamesToGamemode[GetMapName()] then
	_G.DOTA_ACTIVE_GAMEMODE = GameModes.MapNamesToGamemode[GetMapName()].gamemode
	_G.DOTA_ACTIVE_GAMEMODE_TYPE = GameModes.MapNamesToGamemode[GetMapName()].type
end

function GameModes:Preload()
	GameModes:PreloadGamemodeSettingsFromTable(GameModes.Settings[DOTA_ACTIVE_GAMEMODE])
	GameModes:PreloadGamemodeSettingsFromTable(GameModes.Settings[DOTA_ACTIVE_GAMEMODE_TYPE])
end

function GameModes:PreloadGamemodeSettingsFromTable(t)
	if t.requirements and type(t.requirements) == "table" then
		for _,v in ipairs(t.requirements) do
			require(v)
		end
	end
end