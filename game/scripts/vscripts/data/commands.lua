CUSTOMCHAT_COMMAND_LEVEL_PUBLIC = 0
CUSTOMCHAT_COMMAND_LEVEL_CHEAT = 1
CUSTOMCHAT_COMMAND_LEVEL_DEVELOPER = 2
CUSTOMCHAT_COMMAND_LEVEL_CHEAT_DEVELOPER = 3
CHAT_COMMANDS = {
	["command"] = {
		level = CUSTOMCHAT_COMMAND_LEVEL_CHEAT,
		f = function(args, hero, playerID)
			
		end
	},
	["gold"] = {
		level = CUSTOMCHAT_COMMAND_LEVEL_CHEAT,
		f = function(args, hero)
			Gold:ModifyGold(hero, tonumber(args[1]))
		end
	},
	["spawnrune"] = {
		level = CUSTOMCHAT_COMMAND_LEVEL_CHEAT,
		f = function()
			CustomRunes:SpawnRunes()
		end
	},
	["t"] = {
		level = CUSTOMCHAT_COMMAND_LEVEL_CHEAT,
		f = function(args, hero)
			for i = 2, 50 do
				if XP_PER_LEVEL_TABLE[hero:GetLevel()] and XP_PER_LEVEL_TABLE[hero:GetLevel() + 1] then
					hero:AddExperience(XP_PER_LEVEL_TABLE[hero:GetLevel() + 1] - XP_PER_LEVEL_TABLE[hero:GetLevel()], 0, false, false)
				else
					break
				end
			end
			hero:AddItem(CreateItem("item_rapier", hero, hero))
			hero:AddItem(CreateItem("item_blink_arena", hero, hero))
			SendToServerConsole("dota_ability_debug 1")
		end
	},
	["stats"] = {
		level = CUSTOMCHAT_COMMAND_LEVEL_CHEAT,
		f = function(args, hero)
			local i = tonumber(args[1])
			hero:ModifyAgility(i)
			hero:ModifyStrength(i)
			hero:ModifyIntellect(i)
		end
	},
	["duel"] = {
		level = CUSTOMCHAT_COMMAND_LEVEL_CHEAT,
		f = function()
			Duel:SetDuelTimer(0)
		end
	},
	["killcreeps"] = {
		level = CUSTOMCHAT_COMMAND_LEVEL_CHEAT,
		f = function(args, hero)
			for _,v in ipairs(FindUnitsInRadius(hero:GetTeamNumber(), Vector(0, 0, 0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)) do
				v:ForceKill(true)
			end
		end
	},
	["reset"] = {
		level = CUSTOMCHAT_COMMAND_LEVEL_CHEAT,
		f = function(args, hero)
			for i = 0, hero:GetAbilityCount() - 1 do
				local ability = hero:GetAbilityByIndex(i)
				if ability then
					RecreateAbility(hero, ability):SetLevel(0)
				end
			end
		end
	},
	["createcreep"] = {
		level = CUSTOMCHAT_COMMAND_LEVEL_CHEAT,
		f = function(args, hero)
			local sName = tostring(args[1]) or "medium"
			local SpawnerType = tonumber(args[2]) or 0
			local time = tonumber(args[3]) or 0
			local unitRootTable = SPAWNER_SETTINGS[sName].SpawnTypes[SpawnerType]
			PrintTable(SPAWNER_SETTINGS[sName])
			local unit = CreateUnitByName(unitRootTable[1][-1], hero:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_NEUTRALS)
			unit.SpawnerIndex = SpawnerType
			unit.SpawnerType = sName
			unit.SSpawner = -1
			unit.SLevel = time
			Spawner:UpgradeCreep(unit, unit.SpawnerType, unit.SLevel, unit.SpawnerIndex)
		end
	},
	["talents_clear"] = {
		level = CUSTOMCHAT_COMMAND_LEVEL_CHEAT,
		f = function(args, hero)
			hero:ClearTalents()
		end
	},
	["equip"] = {
		level = CUSTOMCHAT_COMMAND_LEVEL_CHEAT,
		f = function(args, hero)
			hero:EquipWearable(tonumber(args[1]))
		end
	},
	["reattach"] = {
		level = CUSTOMCHAT_COMMAND_LEVEL_CHEAT,
		f = function(args, hero)
			hero:RemoveAllWearables()
			hero:EquipItemsFromPlayerSelectionOrDefault()
		end
	},
	["maxenergy"] = {
		level = CUSTOMCHAT_COMMAND_LEVEL_CHEAT,
		f = function(args, hero, playerID)
			hero:ModifyMaxEnergy(args[1] - hero:GetMaxEnergy())
		end
	},
	["runetest"] = {
		level = CUSTOMCHAT_COMMAND_LEVEL_CHEAT,
		f = function(args, hero)
			for i = ARENA_RUNE_FIRST, ARENA_RUNE_LAST do
				CustomRunes:CreateRune(hero:GetAbsOrigin() + RandomVector(RandomInt(90, 300)), i)
			end
		end
	},


	["debugallcalls"] = {
		level = CUSTOMCHAT_COMMAND_LEVEL_DEVELOPER,
		f = function()
			DebugAllCalls()
		end
	},
	["dcs"] = {
		level = CUSTOMCHAT_COMMAND_LEVEL_DEVELOPER,
		f = function()
			_G.DebugConnectionStates = not DebugConnectionStates
		end
	},
	["cprint"] = {
		level = CUSTOMCHAT_COMMAND_LEVEL_DEVELOPER,
		f = function()
			_G.SendDebugInfoToClient = not SendDebugInfoToClient
		end
	},
	["printplayers"] = {
		level = CUSTOMCHAT_COMMAND_LEVEL_DEVELOPER,
		f = function(args, hero)
			local playerinfo = {}
			for pID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
				if PlayerResource:IsValidPlayerID(pID) then
					playerinfo[pID] = {
						nick = PlayerResource:GetPlayerName(pID),
						team = PlayerResource:GetTeam(pID),
						steamID32 = PlayerResource:GetSteamAccountID(pID),
						hero = "nil",
					}
					local tempHero = PlayerResource:GetSelectedHeroEntity(pID)
					if tempHero then
						playerinfo[pID].hero = tempHero:GetFullName()
					end
				end
			end
			CPrintTable(playerinfo)
		end
	},
	["kick"] = {
		level = CUSTOMCHAT_COMMAND_LEVEL_DEVELOPER,
		f = function(args)
			local usid = PLAYER_DATA[tonumber(args[1])].UserID
			if usid then
				SendToServerConsole("kickid " .. usid)
			end
		end
	},
	["model"] = {
		level = CUSTOMCHAT_COMMAND_LEVEL_CHEAT_DEVELOPER,
		f = function(args, hero)
			hero:SetModel(args[1])
			hero:SetOriginalModel(args[1])
		end
	},
	["lua"] = {
		level = CUSTOMCHAT_COMMAND_LEVEL_DEVELOPER,
		f = function(args)
			local str = ""
			for _,v in ipairs(args) do
				str = str .. v .. " "
			end
			EvalString(str)
		end
	},
	["pick"] = {
		level = CUSTOMCHAT_COMMAND_LEVEL_CHEAT_DEVELOPER,
		f = function(args, hero, playerID)
			HeroSelection:ChangeHero(playerID, args[1], true, 0)
		end
	},
	["ban"] = {
		level = CUSTOMCHAT_COMMAND_LEVEL_CHEAT_DEVELOPER,
		f = function(args, hero, playerID)
			if PlayerResource:IsValidPlayerID(tonumber(args[1])) then
				MakePlayerAbandoned(tonumber(args[1]))
			end
		end
	},
	["a_createhero"] = {
		level = CUSTOMCHAT_COMMAND_LEVEL_CHEAT_DEVELOPER,
		f = function(args, hero, playerID)
			playerID = 6
			local heroName = args[1]
			local heroTableCustom = NPC_HEROES_CUSTOM[heroName]
			local baseNewHero = heroTableCustom.base_hero or heroName
			--local h = CreateHeroForPlayer(baseNewHero, PlayerResource:GetPlayer(playerID))
			local h = PlayerResource:ReplaceHeroWith(playerID, baseNewHero, 0, 0)
			local team = 2
			if PlayerResource:GetTeam(playerID) == team and table.contains(args, "enemy") then
				team = 3
			end
			h:SetTeam(team)
			h:SetAbsOrigin(hero:GetAbsOrigin())
			h:SetControllableByPlayer(playerID, true)
			for i = 1, 300 do
				h:HeroLevelUp(false)
			end

			if heroTableCustom.base_hero then
				TransformUnitClass(h, heroTableCustom)
				h.UnitName = heroName
			end
		end
	},
}