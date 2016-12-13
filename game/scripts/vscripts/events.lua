-- This file contains all barebones-registered events and has already set up the passed-in parameters for your use.

-- Cleanup a player when they leave
function GameMode:OnDisconnect(keys)
	DebugPrint('[BAREBONES] Player Disconnected ' .. tostring(keys.userid))
	DebugPrintTable(keys)

	local name = keys.name
	local networkid = keys.networkid
	local reason = keys.reason
	local userid = keys.userid
end
-- The overall game state has changed
function GameMode:OnGameRulesStateChange(keys)
	DebugPrint("[BAREBONES] GameRules State Changed")
	DebugPrintTable(keys)

	local newState = GameRules:State_Get()
	if newState == DOTA_GAMERULES_STATE_PRE_GAME then
		GameModes:OnAllVotesSubmitted()
		HeroSelection:HeroSelectionStart()
	end
end

-- An NPC has spawned somewhere in game.	This includes heroes
function GameMode:OnNPCSpawned(keys)
	DebugPrint("[BAREBONES] NPC Spawned")
	DebugPrintTable(keys)
	local npc = EntIndexToHScript(keys.entindex)
	if npc:IsHero() then
		if not HeroSelection.SelectionEnd then
			npc:AddNoDraw()
			--UTIL_Remove(npc)
			return
		end
		HeroVoice:OnNPCSpawned(npc)
		Timers:CreateTimer(function()
			if npc and not npc:IsNull() and npc:IsAlive() and npc:IsHero() and npc:GetPlayerOwner() then
				local base_hero = npc:GetPlayerOwner():GetAssignedHero()
				if base_hero and base_hero ~= npc and npc:GetModelName() == base_hero:GetModelName() and base_hero.WearablesRemoved then
					npc.WearablesRemoved = true
				end
				Physics:Unit(npc)
		    	npc:SetAutoUnstuck(true)
				CustomWearables:EquipWearables(npc)
				if npc:IsRealHero() and not npc:HasModifier("modifier_arc_warden_tempest_double") then
					npc:AddNewModifier(npc, nil, "modifier_arena_hero", nil)
					AbilityShop:RandomOMGRollAbilities(npc)
					if npc.BloodstoneDummies then
						for _,v in ipairs(npc.BloodstoneDummies) do
							UTIL_Remove(v)
						end
					end
					if npc.PocketHostEntity ~= nil then
						UTIL_Remove(npc.PocketItem)
						npc.PocketItem = nil
						npc.PocketHostEntity = nil
					end
					if Duel.DuelStatus == DOTA_DUEL_STATUS_IN_PROGRESS then
						Duel:SetUpVisitor(npc)
					end
				end
			end
		end)
	end
end

-- An item was picked up off the ground
function GameMode:OnItemPickedUp(keys)
	DebugPrint( '[BAREBONES] OnItemPickedUp' )
	DebugPrintTable(keys)

	local unitEntity = nil
	if keys.UnitEntitIndex then
		unitEntity = EntIndexToHScript(keys.UnitEntitIndex)
	elseif keys.HeroEntityIndex then
		unitEntity = EntIndexToHScript(keys.HeroEntityIndex)
	end

	local itemEntity = EntIndexToHScript(keys.ItemEntityIndex)
	local player = PlayerResource:GetPlayer(keys.PlayerID)
	local itemname = keys.itemname
end

-- A player has reconnected to the game.	This function can be used to repaint Player-based particles or change
-- state as necessary
function GameMode:OnPlayerReconnect(keys)
	DebugPrint( '[BAREBONES] OnPlayerReconnect' )
	DebugPrintTable(keys)
end

-- An item was purchased by a player
function GameMode:OnItemPurchased( keys )
	DebugPrint( '[BAREBONES] OnItemPurchased' )
	DebugPrintTable(keys)

	local plyID = keys.PlayerID
	if not plyID then return end
	local itemName = keys.itemname
	local itemcost = keys.itemcost
	HeroVoice:OnItemPurchased(plyID, itemName, itemcost)
end

-- An ability was used by a player
function GameMode:OnAbilityUsed(keys)
	DebugPrint('[BAREBONES] AbilityUsed')
	DebugPrintTable(keys)

	local player = PlayerResource:GetPlayer(keys.PlayerID)

	local hero
	if player then hero = player:GetAssignedHero() end
	local abilityname = keys.abilityname
	if hero then
		local ability = hero:FindAbilityByName(abilityname)
		if not ability then ability = FindItemInInventoryByName(hero, abilityname, true) end
		if abilityname == "night_stalker_darkness" and ability then
			CustomGameEventManager:Send_ServerToAllClients("time_nightstalker_darkness", {duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel()-1)})
			--Ульта луны тоже должна делать ночь, но с оригинальными часами это тоже не работает
		end
		
		HeroVoice:OnAbilityUsed(hero, ability)
		if abilityname == "item_tree_banana" then
			hero:ModifyStrength(4)
			hero:ModifyAgility(2)
			hero:ModifyIntellect(6)
		end
		if hero:HasModifier("modifier_item_pocket_riki_permanent_invisibility") or hero:HasModifier("modifier_item_pocket_riki_consumed_permanent_invisibility") then
			local item = FindItemInInventoryByName(hero, "item_pocket_riki", false)
			if not item then
				item = FindItemInInventoryByName(hero, "item_pocket_riki_consumed", false)
			end
			if item then
				hero:AddNewModifier(hero, item, "modifier_invisible", {})
			end
		end
	end
end

-- A non-player entity (necro-book, chen creep, etc) used an ability
function GameMode:OnNonPlayerUsedAbility(keys)
	DebugPrint('[BAREBONES] OnNonPlayerUsedAbility')
	DebugPrintTable(keys)

	local abilityname = keys.abilityname
end

-- A player changed their name
function GameMode:OnPlayerChangedName(keys)
	DebugPrint('[BAREBONES] OnPlayerChangedName')
	DebugPrintTable(keys)

	local newName = keys.newname
	local oldName = keys.oldName
end

-- A player leveled up an ability
function GameMode:OnPlayerLearnedAbility( keys)
	DebugPrint('[BAREBONES] OnPlayerLearnedAbility')
	DebugPrintTable(keys)

	local player = EntIndexToHScript(keys.player)
	local abilityname = keys.abilityname
end

-- A channelled ability finished by either completing or being interrupted
function GameMode:OnAbilityChannelFinished(keys)
	DebugPrint('[BAREBONES] OnAbilityChannelFinished')
	DebugPrintTable(keys)

	local abilityname = keys.abilityname
	local interrupted = keys.interrupted == 1
end

-- A player leveled up
function GameMode:OnPlayerLevelUp(keys)
	DebugPrint('[BAREBONES] OnPlayerLevelUp')
	DebugPrintTable(keys)

	local player = EntIndexToHScript(keys.player)
	local level = keys.level
end

-- A player last hit a creep, a tower, or a hero
function GameMode:OnLastHit(keys)
	DebugPrint('[BAREBONES] OnLastHit')
	DebugPrintTable(keys)

	local isFirstBlood = keys.FirstBlood == 1
	local isHeroKill = keys.HeroKill == 1
	local isTowerKill = keys.TowerKill == 1
	local player = PlayerResource:GetPlayer(keys.PlayerID)
	local killedEnt = EntIndexToHScript(keys.EntKilled)
end

-- A tree was cut down by tango, quelling blade, etc
function GameMode:OnTreeCut(keys)
	DebugPrint('[BAREBONES] OnTreeCut')
	DebugPrintTable(keys)

	local treeX = keys.tree_x
	local treeY = keys.tree_y
	if RollPercentage(10) then
		GameMode:CreateTreeDrop(Vector(treeX, treeY, 0), "item_tree_banana")
	end
end

function GameMode:CreateTreeDrop(location, item)
	local item = CreateItemOnPositionSync(location, CreateItem(item, nil, nil))
	item:SetAbsOrigin(GetGroundPosition(location, item)) 
end

-- A player killed another player in a multi-team context
function GameMode:OnTeamKillCredit(keys)
	DebugPrint('[BAREBONES] OnTeamKillCredit')
	DebugPrintTable(keys)

	local killerPlayer = PlayerResource:GetPlayer(keys.killer_userid)
	local victimPlayer = PlayerResource:GetPlayer(keys.victim_userid)
	--local numKills = keys.herokills
	--local killerTeamNumber = keys.teamnumber
	if killerPlayer then
		Kills:OnEntityKilled(victimPlayer, killerPlayer)
	end
end

-- An entity died
function GameMode:OnEntityKilled( keys )
	DebugPrint( '[BAREBONES] OnEntityKilled Called' )
	DebugPrintTable( keys )

	local killedUnit = EntIndexToHScript( keys.entindex_killed )
	local killerEntity = nil
	if keys.entindex_attacker ~= nil then
		killerEntity = EntIndexToHScript( keys.entindex_attacker )
	end
	--[[local killerAbility = nil
	if keys.entindex_inflictor ~= nil then
		killerAbility = EntIndexToHScript( keys.entindex_inflictor )
	end]]
	
	if killedUnit then
		if killedUnit:IsHero() then
			killedUnit:RemoveModifierByName("modifier_shard_of_true_sight") -- For some reason simple KV modifier not removes on death without this
			if killedUnit:IsRealHero() then
				if killedUnit.InArena and Duel.DuelStatus == DOTA_DUEL_STATUS_IN_PROGRESS then
					killedUnit.InArena = false
					if Duel:GetWinner() ~= nil then
						Duel.TimeUntilDuelEnd = 0
					end
				end

				if Duel.DuelStatus == DOTA_DUEL_STATUS_1X1_IN_PROGRESS and killedUnit.Duel1x1Opponent then
					Duel:End1X1(killedUnit.Duel1x1Opponent:GetPlayerOwner():GetAssignedHero(), killedUnit)
				end
				if not killerEntity or not killerEntity:IsControllableByAnyPlayer() then
					Kills:OnEntityKilled(killedUnit:GetPlayerOwner(), nil)
				elseif killerEntity == killedUnit then
					local player = killedUnit:GetPlayerOwner()
					Kills:OnEntityKilled(player, player)
				end
			end
			CustomWearables:UnequipAllWearables(killedUnit)
		end

		if killedUnit:IsHoldoutUnit() then
			Holdout:RegisterKilledUnit(killedUnit)
		end

		if killedUnit:IsRealCreep() then
			Spawner.Creeps[killedUnit.SSpawner] = Spawner.Creeps[killedUnit.SSpawner] - 1
		end

		if killerEntity and killerEntity:GetTeamNumber() ~= killedUnit:GetTeamNumber() and (killerEntity.GetPlayerID or killerEntity.GetPlayerOwnerID) then
			local plId
			if killerEntity.GetPlayerID then
				plId = killerEntity:GetPlayerID()
			else
				plId = killerEntity:GetPlayerOwnerID()
			end
			if plId > -1 then
				local gold = RandomInt(killedUnit:GetMinimumGoldBounty(), killedUnit:GetMaximumGoldBounty())
				Gold:ModifyGold(plId, gold)
				SendOverheadEventMessage(killerEntity:GetPlayerOwner(), OVERHEAD_ALERT_GOLD, killedUnit, gold, killerEntity:GetPlayerOwner())
			end
		end

		if killerEntity then
			for _, individual_hero in ipairs(HeroList:GetAllHeroes()) do
				if individual_hero:HasItemInInventory("item_bloodstone_arena") and not individual_hero:IsAlive() then
					if individual_hero:GetTeam() ~= killedUnit:GetTeam() and individual_hero:GetRangeToUnit(killedUnit) <= 1200 then
						if killedUnit:GetTeam() ~= killerEntity:GetTeam()then
							individual_hero:AddExperience(killedUnit:GetDeathXP(), false, false)
						elseif not killedUnit:IsHero() then
							individual_hero:AddExperience(killedUnit:GetDeathXP() * 0.5, false, false)  --Denied creeps grant 50% experience.  Change this value if this mechanic is ever changed.
						end
					end
				end
				if individual_hero:IsAlive() and individual_hero:HasModifier("modifier_shinobu_hide_in_shadows_invisibility") then
					local shinobu_hide_in_shadows = individual_hero:FindAbilityByName("shinobu_hide_in_shadows")
					if individual_hero:GetTeam() == killedUnit:GetTeam() and individual_hero:GetRangeToUnit(killedUnit) <= shinobu_hide_in_shadows:GetAbilitySpecial("ally_radius") then
						individual_hero:SetHealth(individual_hero:GetMaxHealth())
						shinobu_hide_in_shadows:ApplyDataDrivenModifier(individual_hero, individual_hero, "modifier_shinobu_hide_in_shadows_rage", nil)
					end
				end
			end
		end

		local dropTables = DROP_TABLE[killedUnit:GetUnitName()]
		if dropTables and not killedUnit.IsDominatedBoss then
			local items = {}
			for _,dropTable in ipairs(dropTables) do
				if RollPercentage(dropTable.DropChance) then
					table.insert(items, dropTable.Item)
				end
			end
			if #items > 0 then
				ContainersHelper:CreateLootBox(killedUnit:GetAbsOrigin() + RandomVector(100), items)
			end
		end
	end
end



-- This function is called 1 to 2 times as the player connects initially but before they 
-- have completely connected
function GameMode:PlayerConnect(keys)
	DebugPrint('[BAREBONES] PlayerConnect')
	DebugPrintTable(keys)
end

-- This function is called once when the player fully connects and becomes "Ready" during Loading
function GameMode:OnConnectFull(keys)
	DebugPrint('[BAREBONES] OnConnectFull')
	DebugPrintTable(keys)
	
	local entIndex = keys.index+1
	-- The Player entity of the joining user
	local ply = EntIndexToHScript(entIndex)
	
	-- The Player ID of the joining player
	local playerID = ply:GetPlayerID()
end

-- This function is called whenever an item is combined to create a new item
function GameMode:OnItemCombined(keys)
	DebugPrint('[BAREBONES] OnItemCombined')
	DebugPrintTable(keys)

	-- The playerID of the hero who is buying something
	local plyID = keys.PlayerID
	if not plyID then return end
	local player = PlayerResource:GetPlayer(plyID)

	-- The name of the item purchased
	local itemName = keys.itemname 
	local hero = player:GetAssignedHero()

	-- The cost of the item purchased
	local itemcost = keys.itemcost

	local recipe = "item_recipe_" .. string.gsub(itemName, "item_", "")
	if recipe and GetKeyValue(recipe) and GetKeyValue(recipe, "ItemUseCharges") then
		for i = 0, 11 do
			local item = hero.InventorySnapshot[i]
			if item and item.name == GetKeyValue(recipe, "ItemUseCharges") and item.charges >= GetKeyValue(recipe, "ItemChargeAmount") then
				local newCharges = item.charges - GetKeyValue(recipe, "ItemChargeAmount")
				if newCharges > 0 then
					local newItem = CreateItem(item.name, hero, hero)
					newItem:SetPurchaseTime(item.PurchaseTime)
					newItem:SetPurchaser(item.Purchaser)
					newItem:SetCurrentCharges(newCharges)
					if item.CooldownTimeRemaining > 0 then
						newItem:StartCooldown(item.CooldownTimeRemaining)
					end
					newItem:SetOwner(hero)

					Timers:CreateTimer(function()
						hero:AddItem(newItem)
					end)
				end
			end
		end
	end
end

-- This function is called whenever an ability begins its PhaseStart phase (but before it is actually cast)
function GameMode:OnAbilityCastBegins(keys)
	DebugPrint('[BAREBONES] OnAbilityCastBegins')
	DebugPrintTable(keys)

	local player = PlayerResource:GetPlayer(keys.PlayerID)
	local abilityName = keys.abilityname
end

-- This function is called whenever a tower is killed
function GameMode:OnTowerKill(keys)
	DebugPrint('[BAREBONES] OnTowerKill')
	DebugPrintTable(keys)

	local gold = keys.gold
	local killerPlayer = PlayerResource:GetPlayer(keys.killer_userid)
	local team = keys.teamnumber
end

-- This function is called whenever a player changes there custom team selection during Game Setup 
function GameMode:OnPlayerSelectedCustomTeam(keys)
	--[[DebugPrint('[BAREBONES] OnPlayerSelectedCustomTeam')
	DebugPrintTable(keys)

	local player = PlayerResource:GetPlayer(keys.player_id)
	local success = (keys.success == 1)
	local team = keys.team_id]]
end

-- This function is called whenever an NPC reaches its goal position/target
function GameMode:OnNPCGoalReached(keys)
	DebugPrint('[BAREBONES] OnNPCGoalReached')
	DebugPrintTable(keys)

	local goalEntity = EntIndexToHScript(keys.goal_entindex)
	local nextGoalEntity = EntIndexToHScript(keys.next_goal_entindex)
	local npc = EntIndexToHScript(keys.npc_entindex)
end

function GameMode:OnPlayerChat(keys)
	local teamonly = keys.teamonly
	local playerID = keys.playerid
	local text = keys.text
	CustomChatSay(playerID, text, teamonly == 1)
end

function GameMode:OnPlayerSentCommand(playerID, text)
	local cmd = {}
	for v in string.gmatch(string.lower(string.sub(text, 2)), "%S+") do table.insert(cmd, v) end
	local hero = PlayerResource:GetSelectedHeroEntity(playerID)
	if GameRules:IsCheatMode() then
		if true then -- Custom chat enabled?
			--------------------------------------------------------------
		if cmd[1] == "lvlup" then
			for i = 1, tonumber(cmd[2]) do
				if XP_PER_LEVEL_TABLE[hero:GetLevel()] and XP_PER_LEVEL_TABLE[hero:GetLevel() + 1] then
					hero:AddExperience(XP_PER_LEVEL_TABLE[hero:GetLevel() + 1] - XP_PER_LEVEL_TABLE[hero:GetLevel()], 0, false, false)
				else
					break
				end
			end
		end
		if cmd[1] == "createhero" then
			local servercom = "dota_create_unit "
			if cmd[2] then
				servercom = servercom .. cmd[2] .. " "
			end
			if cmd[3] then
				servercom = servercom .. cmd[3]
			end
			SendToServerConsole(servercom)
		end
		if cmd[1] == "item" then
			local servercom = "dota_create_item "
			if cmd[2] then
				servercom = servercom .. cmd[2]
			end
			SendToServerConsole(servercom)
		end
		if cmd[1] == "givebots" then
			local servercom = "dota_bot_give_item "
			if cmd[2] then
				servercom = servercom .. cmd[2]
			end
			SendToServerConsole(servercom)
		end
		if cmd[1] == "refresh" then
			InvokeCheatCommand("dota_dev hero_refresh")
		end
		if cmd[1] == "respawn" then
			InvokeCheatCommand("dota_dev hero_respawn")
		end
		if cmd[1] == "wtf" then
			SendToServerConsole("dota_ability_debug 1")
			InvokeCheatCommand("dota_dev hero_refresh")
		end
		if cmd[1] == "unwtf" then
			SendToServerConsole("dota_ability_debug 0")
		end
		if cmd[1] == "levelbots" then
			local servercom = "dota_bot_give_level "
			if cmd[2] then
				servercom = servercom .. cmd[2]
			end
			SendToServerConsole(servercom)
		end
		if cmd[1] == "killwards" then
			InvokeCheatCommand("dota_dev killwards")
		end
		if cmd[1] == "clearwards" then
			SendToServerConsole("dota_clear_wards")
		end
		if cmd[1] == "allvision" then
			SendToServerConsole("dota_all_vision 1")
		end
		if cmd[1] == "normalvision" then
			SendToServerConsole("dota_all_vision 0")
		end
		if cmd[1] == "teleport" then
			InvokeCheatCommand("dota_dev hero_teleport")
		end
		if cmd[1] == "trees" then
			SendToServerConsole("dota_treerespawn")
		end
			--------------------------------------------------------------
		end
		if cmd[1] == "gold" then
			Gold:ModifyGold(hero, tonumber(cmd[2]))
		end
		if cmd[1] == "spawnrune" then
			CustomRunes:SpawnRunes()
		end
		if cmd[1] == "a_sn" then
			Spawner:SpawnStacks(Spawner:GetSpawnerEntities())
		end
		if cmd[1] == "a_gk" then
			hero:AddItem(CreateItem("item_boss_keeper_key", hero, hero))
		end
		if cmd[1] == "a_t" then
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
		if cmd[1] == "a_gm" then
			hero:AddExperience(1000000000.0, 0, false, true)
			Gold:ModifyGold(hero, 999999)
			hero:ModifyAgility(100000)
			hero:ModifyStrength(100000)
			hero:ModifyIntellect(100000)
		end
		if cmd[1] == "a_agm" then
			hero:ModifyAgility(-50000)
			hero:ModifyStrength(-50000)
			hero:ModifyIntellect(-50000)
		end
		if cmd[1] == "a_op" then
			Bosses:OpenPortals(hero:GetTeamNumber())
		end
		if cmd[1] == "a_sd" then
			Duel.TimeUntilDuel = 0
		end
		if cmd[1] == "a_ed" then
			Duel.TimeUntilDuelEnd = 1
		end
		if cmd[1] == "a_k" then
			local units = FindUnitsInRadius(hero:GetTeamNumber(), Vector(0, 0, 0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
			for _,v in ipairs(units) do
				v:ForceKill(true)
			end
		end
		if cmd[1] == "a_hr" then
			for i = 0, hero:GetAbilityCount() - 1 do
				local ability = hero:GetAbilityByIndex(i)
				if ability and ability:GetName() ~= "attribute_bonus_arena" then
					local n = ability:GetName()
					local l = ability:GetLevel()
					hero:RemoveAbility(n)
					hero:AddAbility(n)
					hero:SetAbilityPoints(hero:GetAbilityPoints() + l)
				end
			end
		end
		if cmd[1] == "a_oh" then
			for k,v in pairs(_G) do
				if type(k) == "string" and string.starts(k, "OVERHEAD_ALERT") then
					print(k,v)
				end
			end
		end
		if cmd[1] == "a_sn" then
			local unit = CreateUnitByName("npc_dota_neutral_easy_variant1", hero:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_NEUTRALS)
			unit.SpawnerType = "Easy"
			unit.SLevel = tonumber(cmd[2])
			Spawner:UpgradeCreep(unit, unit.SpawnerType, unit.SLevel)
		end
		if cmd[1] == "a_ts" then
			SendToServerConsole("host_timescale 0.1")
			Timers:CreateTimer(2, function()
				SendToServerConsole("host_timescale 1")
			end)
		end
		if cmd[1] == "a_col" then
			
			

			--[[collider = hero:AddColliderFromProfile("blocker")

			collider.radius = 400
			collider.draw = {color = Vector(200,50,50), alpha = 0}
			collider.test = function(self, collider, collided)
				if true then
					Physics:Unit(collided)
					return IsPhysicsUnit(collided)
				end
			end]]
		end
		if cmd[1] == "en" then
			enigma = CreateUnitByName('npc_dummy_unit', Vector(0,0,200), true, hero, hero, hero:GetTeamNumber())
			enigma:SetModel('models/heroes/enigma/enigma.vmdl')
			enigma:SetOriginalModel('models/heroes/enigma/enigma.vmdl')

			Physics:Unit(enigma)

			planet1 = CreateUnitByName('npc_dummy_unit', Vector(0,0,0), true, hero, hero, hero:GetTeamNumber())
			planet1:SetModel('models/props_gameplay/rune_doubledamage01.vmdl')
			planet1:SetOriginalModel('models/props_gameplay/rune_doubledamage01.vmdl')
			Physics:Unit(planet1)


			planet2 = CreateUnitByName('npc_dummy_unit', Vector(0,0,0), true, hero, hero, hero:GetTeamNumber())
			planet2:SetModel('models/props_gameplay/rune_haste01.vmdl')
			planet2:SetOriginalModel('models/props_gameplay/rune_haste01.vmdl')
			Physics:Unit(planet2)

			planet3 = CreateUnitByName('npc_dummy_unit', Vector(0,0,0), true, hero, hero, hero:GetTeamNumber())
			planet3:SetModel('models/props_gameplay/rune_illusion01.vmdl')
			planet3:SetOriginalModel('models/props_gameplay/rune_illusion01.vmdl')
			Physics:Unit(planet3)

			Timers:CreateTimer(function()
				enigma:SetAbsOrigin(Vector(0,0,400))

				enigma:RemoveCollider()
				collider = enigma:AddColliderFromProfile("gravity")
				collider.radius = 1000
				collider.fullRadius = 0
				collider.force = 5000
				collider.linear = false
				collider.test = function(self, collider, collided)
				  return IsPhysicsUnit(collided) and collided.GetUnitName and collided:GetUnitName() == "npc_dummy_unit"
				end

				planet1:SetAbsOrigin(Vector(-500,0,400))
				planet2:SetAbsOrigin(Vector(300,0,400))
				planet3:SetAbsOrigin(Vector(0,100,400))

				planet1:SetPhysicsVelocity(Vector(0,600,0))
				planet2:SetPhysicsVelocity(Vector(0,0,1000))
				planet3:SetPhysicsVelocity(Vector(1,0,1):Normalized() * 1200)
				planet1:SetPhysicsFriction(0)
				planet2:SetPhysicsFriction(0)
				planet3:SetPhysicsFriction(0)
			end)
		end
		if cmd[1] == "runetest" then
			for i = ARENA_RUNE_FIRST, ARENA_RUNE_LAST do
				CustomRunes:CreateRune(hero:GetAbsOrigin() + RandomVector(RandomInt(90, 300)), i)
			end
		end
	end
end

function GameMode:TrackInventory(unit)
	unit.InventorySnapshot = {}
	for i = DOTA_ITEM_SLOT_1, DOTA_STASH_SLOT_6 do
		local item = unit:GetItemInSlot(i)
		if item then
			unit.InventorySnapshot[i] = {
				name=item:GetName(),
				charges=item:GetCurrentCharges(),
				PurchaseTime = item:GetPurchaseTime(),
				Purchaser = item:GetPurchaser(),
				CooldownTimeRemaining = item:GetCooldownTimeRemaining(),
			}
		end
	end
end