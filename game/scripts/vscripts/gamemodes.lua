DOTA_GAMEMODE_5V5 = 0
DOTA_GAMEMODE_HOLDOUT_5 = 1
--[[DOTA_GAMEMODE_10V10 = 1
DOTA_GAMEMODE_1V1 = 2
DOTA_GAMEMODE_X4 = 3]]

DOTA_GAMEMODE_TYPE_ALLPICK = 100
DOTA_GAMEMODE_TYPE_RANDOM_OMG = 101
DOTA_GAMEMODE_TYPE_ABILITY_SHOP = 102

ARENA_GAMEMODE_MAP_NONE = 200
ARENA_GAMEMODE_MAP_CUSTOM_ABILITIES = 201

DOTA_ACTIVE_GAMEMODE = DOTA_GAMEMODE_5V5
DOTA_ACTIVE_GAMEMODE_TYPE = DOTA_GAMEMODE_TYPE_ALLPICK
ARENA_ACTIVE_GAMEMODE_MAP = ARENA_GAMEMODE_MAP_NONE--ARENA_GAMEMODE_MAP_CUSTOM_ABILITIES

if GameModes == nil then
	_G.GameModes = class({})

	GameModes.MapNamesToGamemode = {
		["5v5"] = {gamemode = DOTA_GAMEMODE_5V5, type = DOTA_GAMEMODE_TYPE_ALLPICK},
		--DOTA_GAMEMODE_TYPE_RANDOM_OMG || DOTA_GAMEMODE_TYPE_ABILITY_SHOP
		["5v5_romg"] = {gamemode = DOTA_GAMEMODE_5V5, type = nil, map = ARENA_GAMEMODE_MAP_CUSTOM_ABILITIES},
		--["arena_holdout"] = {gamemode = DOTA_GAMEMODE_HOLDOUT_5, type = DOTA_GAMEMODE_TYPE_ALLPICK},
	}

	GameModes.Settings = {
		[DOTA_GAMEMODE_HOLDOUT_5] = {
			requirements = {
				"data/holdout_data",
				"holdout",
			},
		},
	}
end

local mapName = GetMapName()
if GameModes.MapNamesToGamemode[mapName] then
	DOTA_ACTIVE_GAMEMODE = GameModes.MapNamesToGamemode[mapName].gamemode
	DOTA_ACTIVE_GAMEMODE_TYPE = GameModes.MapNamesToGamemode[mapName].type
	ARENA_ACTIVE_GAMEMODE_MAP = GameModes.MapNamesToGamemode[mapName].map
end

function GameModes:Preload()
	GameModes:PreloadGamemodeSettingsFromTable(GameModes.Settings[DOTA_ACTIVE_GAMEMODE])
	GameModes:PreloadGamemodeSettingsFromTable(GameModes.Settings[DOTA_ACTIVE_GAMEMODE_TYPE])
	GameModes:PreloadGamemodeSettingsFromTable(GameModes.Settings[ARENA_ACTIVE_GAMEMODE_MAP])
end

function GameModes:PreloadGamemodeSettingsFromTable(t)
	if not t then return end
	if t.requirements and type(t.requirements) == "table" then
		for _,v in ipairs(t.requirements) do
			require(v)
		end
	end
end