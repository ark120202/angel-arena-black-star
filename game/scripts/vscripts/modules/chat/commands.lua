CUSTOMCHAT_COMMAND_LEVEL_PUBLIC = 0
CUSTOMCHAT_COMMAND_LEVEL_CHEAT = 1
CUSTOMCHAT_COMMAND_LEVEL_DEVELOPER = 2
CUSTOMCHAT_COMMAND_LEVEL_CHEAT_DEVELOPER = 3

return {
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
			hero:AddItem(CreateItem("item_blink", hero, hero))
			hero:AddItem(CreateItem("item_rapier_arena", hero, hero))
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
			DynamicWearables:EquipWearable(hero, tonumber(args[1]))
		end
	},
	["reattach"] = {
		level = CUSTOMCHAT_COMMAND_LEVEL_CHEAT,
		f = function(args, hero)
			DynamicWearables:UnequipAll(hero)
			DynamicWearables:AutoEquip(hero)
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
	["kick"] = {
		level = CUSTOMCHAT_COMMAND_LEVEL_DEVELOPER,
		f = function(args)
			PlayerResource:KickPlayer(tonumber(args[1]))
		end
	},
	["model"] = {
		level = CUSTOMCHAT_COMMAND_LEVEL_CHEAT_DEVELOPER,
		f = function(args, hero)
			hero:SetModel(args[1])
			hero:SetOriginalModel(args[1])
		end
	},
	["pick"] = {
		level = CUSTOMCHAT_COMMAND_LEVEL_CHEAT_DEVELOPER,
		f = function(args, hero, playerID)
			HeroSelection:ChangeHero(playerID, args[1], true, 0)
		end
	},
	["abandon"] = {
		level = CUSTOMCHAT_COMMAND_LEVEL_CHEAT_DEVELOPER,
		f = function(args, hero, playerID)
			if PlayerResource:IsValidPlayerID(tonumber(args[1])) then
				PlayerResource:MakePlayerAbandoned(tonumber(args[1]))
			end
		end
	},
	["ban"] = {
		level = CUSTOMCHAT_COMMAND_LEVEL_CHEAT_DEVELOPER,
		f = function(args, hero, playerID)
			local pid = tonumber(args[1])
			if not PlayerResource:IsValidPlayerID(pid) then return end

			PLAYER_DATA[pid].isBanned = true

			local data = PLAYER_DATA[pid].serverData or {}
			local clientData = table.deepcopy(data)
			clientData.TBDRating = nil
			clientData.isBanned = true
			PlayerTables:SetTableValue("stats_client", pid, clientData)

			PlayerResource:MakePlayerAbandoned(pid)
		end
	},
	["a_createhero"] = {
		level = CUSTOMCHAT_COMMAND_LEVEL_CHEAT_DEVELOPER,
		f = function(args, hero, playerID)
			--playerID = 6
			local heroName = args[1]
			local heroTableCustom = NPC_HEROES_CUSTOM[heroName]
			local baseNewHero = heroTableCustom.base_hero or heroName
			local h = CreateHeroForPlayer(baseNewHero, PlayerResource:GetPlayer(playerID))
			--local h = PlayerResource:ReplaceHeroWith(playerID, baseNewHero, 0, 0)
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
	["consts"] = {
		level = CUSTOMCHAT_COMMAND_LEVEL_CHEAT_DEVELOPER,
		f = function(args)
			for k, v in pairs(_G) do
				if string.find(k, args[1]) then
					print(k, v)
				end
			end
		end
	},
	["ccreate"] = {
		level = CUSTOMCHAT_COMMAND_LEVEL_DEVELOPER,
		f = function(args)
			local pid = tonumber(args[1])
			local pType = args[2]
			local source = args[3]
			local duration = tonumber(args[4])
			if PlayerResource:IsValidPlayerID(pid) and pType and source and (args[4] == nil or duration ~= nil) then
				CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(pid), "create_generic_panel", {
					type = pType,
					source = source,
					duration = duration
				})
			end
		end
	},
	["end"] = {
		level = CUSTOMCHAT_COMMAND_LEVEL_DEVELOPER,
		f = function(args, hero, playerID)
			local team = tonumber(args[1])
			if team then
				GameMode:OnKillGoalReached(team)
			end
		end
	},
	["weather"] = {
		level = CUSTOMCHAT_COMMAND_LEVEL_CHEAT_DEVELOPER,
		f = function(args)
			local weather = tostring(args[1])
			if weather then
				Weather:Start(weather)
			end
		end
	},
	["console"] = {
		level = CUSTOMCHAT_COMMAND_LEVEL_PUBLIC,
		f = function(_, _, playerID)
			Console:SetVisible(PlayerResource:GetPlayer(playerID))
		end
	},
}
