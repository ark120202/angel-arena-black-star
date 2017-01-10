-- This file contains all barebones-registered events and has already set up the passed-in parameters for your use.

-- Cleanup a player when they leave
function GameMode:OnDisconnect(keys)
	local name = keys.name
	local networkid = keys.networkid
	local reason = keys.reason
	local userid = keys.userid
end
-- The overall game state has changed
function GameMode:OnGameRulesStateChange(keys)
	local newState = GameRules:State_Get()
	if newState == DOTA_GAMERULES_STATE_PRE_GAME then
		local Counters = {}
		for i = 0, DOTA_MAX_TEAM_PLAYERS-1 do
			if PlayerResource:IsValidPlayerID(i) then
				local team = PlayerResource:GetTeam(i)
				if PLAYERS_COLORS[team] then
					Counters[team] = (Counters[team] or 0) + 1
					local color = PLAYERS_COLORS[team][Counters[team]]
					PLAYER_DATA[i].Color = color
					PlayerResource:SetCustomPlayerColor(i, color[1], color[2], color[3])
				end
			end
		end
		HeroSelection:CollectPD()
		GameModes:OnAllVotesSubmitted()
		HeroSelection:HeroSelectionStart()
	end
end

-- An NPC has spawned somewhere in game.	This includes heroes
function GameMode:OnNPCSpawned(keys)
	local npc = EntIndexToHScript(keys.entindex)
	if npc:IsHero() then
		if not HeroSelection.SelectionEnd then
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
				if not npc:IsWukongsSummon() then
					npc:AddNewModifier(npc, nil, "modifier_arena_hero", nil)
					if npc:IsRealHero() and not npc:HasModifier("modifier_arc_warden_tempest_double") then
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
			end
		end)
	end
end

-- An item was picked up off the ground
function GameMode:OnItemPickedUp(keys)
	local unitEntity = nil
	if keys.UnitEntitIndex then
		unitEntity = EntIndexToHScript(keys.UnitEntitIndex)
	elseif keys.HeroEntityIndex then
		unitEntity = EntIndexToHScript(keys.HeroEntityIndex)
	end

	local itemEntity = EntIndexToHScript(keys.ItemEntityIndex)
	local player = PlayerResource:GetPlayer(keys.PlayerID)
	local itemname = keys.itemname
	if itemEntity.CanOverrideOwner and unitEntity and (unitEntity:IsHero() or unitEntity:IsConsideredHero()) then
		itemEntity:SetOwner(PlayerResource:GetSelectedHeroEntity(keys.PlayerID))
		itemEntity:SetPurchaser(PlayerResource:GetSelectedHeroEntity(keys.PlayerID))
		itemEntity.CanOverrideOwner = nil
	end
end

-- A player has reconnected to the game.	This function can be used to repaint Player-based particles or change
-- state as necessary
function GameMode:OnPlayerReconnect(keys)

end

-- An ability was used by a player
function GameMode:OnAbilityUsed(keys)
	local player = PlayerResource:GetPlayer(keys.PlayerID)

	local hero = PlayerResource:GetSelectedHeroEntity(keys.PlayerID)
	local abilityname = keys.abilityname
	if hero then
		local ability = hero:FindAbilityByName(abilityname)
		if not ability then ability = FindItemInInventoryByName(hero, abilityname, true) end
		if abilityname == "night_stalker_darkness" and ability then
			CustomGameEventManager:Send_ServerToAllClients("time_nightstalker_darkness", {duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel()-1)})
		end
		--HeroVoice:OnAbilityUsed(hero, ability)
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
	--local abilityname = keys.abilityname
end

-- A player changed their name
function GameMode:OnPlayerChangedName(keys)
	--local newName = keys.newname
	--local oldName = keys.oldName
end

-- A player leveled up an ability
function GameMode:OnPlayerLearnedAbility( keys)
	--local player = EntIndexToHScript(keys.player)
	--local abilityname = keys.abilityname
end

-- A channelled ability finished by either completing or being interrupted
function GameMode:OnAbilityChannelFinished(keys)
	--local abilityname = keys.abilityname
	--local interrupted = keys.interrupted == 1
end

-- A player leveled up
function GameMode:OnPlayerLevelUp(keys)
	--[[local player = EntIndexToHScript(keys.player)
	local level = keys.level]]
end

-- A player last hit a creep, a tower, or a hero
function GameMode:OnLastHit(keys)
	--[[local isFirstBlood = keys.FirstBlood == 1
	local isHeroKill = keys.HeroKill == 1
	local isTowerKill = keys.TowerKill == 1
	local player = PlayerResource:GetPlayer(keys.PlayerID)
	local killedEnt = EntIndexToHScript(keys.EntKilled)]]
end

-- A tree was cut down by tango, quelling blade, etc
function GameMode:OnTreeCut(keys)
	--[[local treeX = keys.tree_x
	local treeY = keys.tree_y
	if RollPercentage(10) then
		GameMode:CreateTreeDrop(Vector(treeX, treeY, 0), "item_tree_banana")
	end]]
end

function GameMode:CreateTreeDrop(location, item)
	local item = CreateItemOnPositionSync(location, CreateItem(item, nil, nil))
	item:SetAbsOrigin(GetGroundPosition(location, item)) 
end

-- A player killed another player in a multi-team context
function GameMode:OnTeamKillCredit(keys)
	local killerPlayer = PlayerResource:GetPlayer(keys.killer_userid)
	local victimPlayer = PlayerResource:GetPlayer(keys.victim_userid)
	--local numKills = keys.herokills
	--local killerTeamNumber = keys.teamnumber
	if killerPlayer then
		Kills:OnEntityKilled(victimPlayer, killerPlayer)
	end
end

-- An entity died
function GameMode:OnEntityKilled(keys)
	local killedUnit = EntIndexToHScript( keys.entindex_killed )
	local killerEntity = nil
	if keys.entindex_attacker ~= nil then
		killerEntity = EntIndexToHScript( keys.entindex_attacker )
	end
	--[[
	local killerAbility = nil
	if keys.entindex_inflictor ~= nil then
		killerAbility = EntIndexToHScript( keys.entindex_inflictor )
	end
	]]
	
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
				killedUnit:SetTimeUntilRespawn(killedUnit:CalculateRespawnTime())
			end
			CustomWearables:UnequipAllWearables(killedUnit)
		end

		if killedUnit:IsHoldoutUnit() then
			Holdout:RegisterKilledUnit(killedUnit)
		end

		if killedUnit:IsRealCreep() then
			Spawner.Creeps[killedUnit.SSpawner] = Spawner.Creeps[killedUnit.SSpawner] - 1
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

			if killerEntity:GetTeamNumber() ~= killedUnit:GetTeamNumber() and (killerEntity.GetPlayerID or killerEntity.GetPlayerOwnerID) then
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
		end

		--[[local dropTables = DROP_TABLE[killedUnit:GetUnitName()]
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
		end]]
	end
end

-- This function is called 1 to 2 times as the player connects initially but before they 
-- have completely connected
function GameMode:PlayerConnect(keys)

end

-- This function is called once when the player fully connects and becomes "Ready" during Loading
function GameMode:OnConnectFull(keys)
	--[[local entIndex = keys.index+1
	local ply = EntIndexToHScript(entIndex)
	local playerID = ply:GetPlayerID()]]
end

-- This function is called whenever an item is combined to create a new item
function GameMode:OnItemCombined(keys)
	local plyID = keys.PlayerID
	if not plyID then return end
	local player = PlayerResource:GetPlayer(plyID)
	local itemName = keys.itemname 
	local hero = player:GetAssignedHero()
	local itemcost = keys.itemcost

	local recipe = "item_recipe_" .. string.gsub(itemName, "item_", "")
	if GetKeyValue(recipe) and GetKeyValue(recipe, "ItemUseCharges") then
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
	--local player = PlayerResource:GetPlayer(keys.PlayerID)
	--local abilityName = keys.abilityname
end

-- This function is called whenever a player changes there custom team selection during Game Setup 
function GameMode:OnPlayerSelectedCustomTeam(keys)
	--[[local player = PlayerResource:GetPlayer(keys.player_id)
	local success = (keys.success == 1)
	local team = keys.team_id]]
end

-- This function is called whenever an NPC reaches its goal position/target
function GameMode:OnNPCGoalReached(keys)
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

function CustomChatSay(playerId, text, teamonly)
	if GameMode:CustomChatFilter(playerId, text, teamonly) then
		local hero = PlayerResource:GetSelectedHeroEntity(playerId)
		local heroName
		if hero then
			heroName = GetFullHeroName(hero)
		end
		if teamonly then
			CustomGameEventManager:Send_ServerToTeam(PlayerResource:GetTeam(playerId), "custom_chat_recieve_message", {text=text, playerId=playerId, teamonly=teamonly, hero=heroName})
		else
			CustomGameEventManager:Send_ServerToAllClients("custom_chat_recieve_message", {text=text, playerId=playerId, teamonly=teamonly, hero=heroName})
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