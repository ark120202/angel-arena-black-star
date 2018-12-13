-- The overall game state has changed
function GameMode:OnGameRulesStateChange(keys)
	local newState = GameRules:State_Get()
	if newState == DOTA_GAMERULES_STATE_PRE_GAME then
		HeroSelection:CollectPD()
		HeroSelection:HeroSelectionStart()
		GameMode:OnHeroSelectionStart()
	end
end

-- An NPC has spawned somewhere in game.	This includes heroes
function GameMode:OnNPCSpawned(keys)
	local npc = EntIndexToHScript(keys.entindex)
	if not npc:IsHero() then return end
	if HeroSelection:GetState() < HERO_SELECTION_PHASE_END then return end
	local tempest_modifier = npc:FindModifierByName("modifier_arc_warden_tempest_double")
	if tempest_modifier then
		local caster = tempest_modifier:GetCaster()
		if npc:GetUnitName() == "npc_dota_hero" then
			npc:SetUnitName("npc_dota_hero_arena_base")
			npc:AddNewModifier(unit, nil, "modifier_dragon_knight_dragon_form", {duration = 0})
		end
		if npc.tempestDoubleSecondSpawn then
			--Tempest Double resets stats and stuff, so everything needs to be put back where they belong
			Illusions:_copyAbilities(caster, npc)
			npc:ModifyStrength(caster:GetBaseStrength() - npc:GetBaseStrength())
			npc:ModifyIntellect(caster:GetBaseIntellect() - npc:GetBaseIntellect())
			npc:ModifyAgility(caster:GetBaseAgility() - npc:GetBaseAgility())
			npc.Additional_str = caster.Additional_str
			npc.Additional_int = caster.Additional_int
			npc.Additional_agi = caster.Additional_agi
			npc:SetHealth(caster:GetHealth())
			npc:SetMana(caster:GetMana())
		else
			Illusions:_copyEverything(caster, npc)
			npc.tempestDoubleSecondSpawn = true
		end
	end
	Timers:NextTick(function()
		if not IsValidEntity(npc) or not npc:IsAlive() then return end
		local illusionParent = npc:GetIllusionParent()
		if illusionParent then Illusions:_copyEverything(illusionParent, npc) end

		DynamicWearables:AutoEquip(npc)
		if npc.ModelOverride then
			npc:SetModel(npc.ModelOverride)
			npc:SetOriginalModel(npc.ModelOverride)
		end
		if not npc:IsWukongsSummon() then
			npc:AddNewModifier(npc, nil, "modifier_arena_hero", nil)
			if npc:IsTrueHero() then
				npc:ApplyDelayedTalents()

				PlayerTables:SetTableValue("player_hero_indexes", npc:GetPlayerID(), npc:GetEntityIndex())
				CustomAbilities:RandomOMGRollAbilities(npc)
				if not npc.OnDuel and Duel:IsDuelOngoing() then
					Duel:SetUpVisitor(npc)
				end
			end
		end
	end)
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
	--[[if itemEntity.CanOverrideOwner and unitEntity and (unitEntity:IsHero() or unitEntity:IsConsideredHero()) then
		itemEntity:SetOwner(PlayerResource:GetSelectedHeroEntity(keys.PlayerID))
		itemEntity:SetPurchaser(PlayerResource:GetSelectedHeroEntity(keys.PlayerID))
		itemEntity.CanOverrideOwner = nil
	end]]
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
	end
end

-- A tree was cut down by tango, quelling blade, etc
function GameMode:OnTreeCut(keys)
	local treeX = keys.tree_x
	local treeY = keys.tree_y
	if RollPercentage(GetAbilitySpecial("item_tree_banana", "drop_chance_pct")) then
		GameMode:CreateTreeDrop(Vector(treeX, treeY, 0), "item_tree_banana")
	end
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
	local killerEntity
	if keys.entindex_attacker then
		killerEntity = EntIndexToHScript( keys.entindex_attacker )
	end

	if killedUnit then
		local killedTeam = killedUnit:GetTeam()
		if killedUnit:IsHero() then
			killedUnit:RemoveModifierByName("modifier_shard_of_true_sight") -- For some reason simple KV modifier not removes on death without this
			if killedUnit:IsRealHero() and not killedUnit:IsReincarnating() then
				if killerEntity then
					local killerTeam = killerEntity:GetTeam()
					if killerTeam ~= killedTeam and Teams:IsEnabled(killerTeam) then
						Teams:ModifyScore(killerTeam, Teams:GetTeamKillWeight(killedTeam))
					end
				end

				local respawnTime = killedUnit:CalculateRespawnTime()
				local killedUnits = killedUnit:GetFullName() == "npc_dota_hero_meepo" and
					MeepoFixes:FindMeepos(PlayerResource:GetSelectedHeroEntity(killedUnit:GetPlayerID()), true) or
					{ killedUnit }
				for _,v in ipairs(killedUnits) do
					v:SetTimeUntilRespawn(respawnTime)
					v.RespawnTimeModifierBloodstone = nil
					v.RespawnTimeModifierSaiReleaseOfForge = nil

					if v.OnDuel then
						v.OnDuel = nil
						v.ArenaBeforeTpLocation = nil
					end
				end

				Duel:EndIfFinished()

				if not IsValidEntity(killerEntity) or not killerEntity.GetPlayerOwner or not IsValidEntity(killerEntity:GetPlayerOwner()) then
					Kills:OnEntityKilled(killedUnit:GetPlayerOwner(), nil)
				elseif killerEntity == killedUnit then
					local player = killedUnit:GetPlayerOwner()
					Kills:OnEntityKilled(player, player)
				end
			end
		end

		if killedUnit:IsBoss() and Bosses:IsLastBossEntity(killedUnit) then
			local team = DOTA_TEAM_NEUTRALS
			if killerEntity then
				team = killerEntity:GetTeam()
			end
			Bosses:RegisterKilledBoss(killedUnit, team)
		end

		if killedUnit:IsRealCreep() then
			Spawner:OnCreepDeath(killedUnit)
		end

		if not killedUnit:UnitCanRespawn() then
			killedUnit:ClearNetworkableEntityInfo()
		end

		if killerEntity then
			for _, individual_hero in ipairs(HeroList:GetAllHeroes()) do
				if individual_hero:IsAlive() and individual_hero:HasModifier("modifier_shinobu_hide_in_shadows_invisibility") then
					local shinobu_hide_in_shadows = individual_hero:FindAbilityByName("shinobu_hide_in_shadows")
					if individual_hero:GetTeam() == killedUnit:GetTeam() and individual_hero:GetRangeToUnit(killedUnit) <= shinobu_hide_in_shadows:GetAbilitySpecial("ally_radius") then
						individual_hero:SetHealth(individual_hero:GetMaxHealth())
						shinobu_hide_in_shadows:ApplyDataDrivenModifier(individual_hero, individual_hero, "modifier_shinobu_hide_in_shadows_rage", nil)
					end
				end
			end

			if killerEntity:GetTeam() ~= killedTeam and (killerEntity.GetPlayerID or killerEntity.GetPlayerOwnerID) then
				local plId = killerEntity.GetPlayerID ~= nil and killerEntity:GetPlayerID() or killerEntity:GetPlayerOwnerID()
				if plId > -1 and not (killerEntity.HasModifier and killerEntity:HasModifier("modifier_item_golden_eagle_relic_enabled")) then
					local gold = RandomInt(killedUnit:GetMinimumGoldBounty(), killedUnit:GetMaximumGoldBounty())
					Gold:ModifyGold(plId, gold)
					SendOverheadEventMessage(killerEntity:GetPlayerOwner(), OVERHEAD_ALERT_GOLD, killedUnit, gold, killerEntity:GetPlayerOwner())
				end
			end
		end
	end
end

-- This function is called once when the player fully connects and becomes "Ready" during Loading
function GameMode:OnConnectFull(keys)
	if GameRules:State_Get() >= DOTA_GAMERULES_STATE_PRE_GAME and PlayerResource:IsBanned(keys.PlayerID) then
		PlayerResource:KickPlayer(keys.PlayerID)
	end
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

					Timers:NextTick(function() hero:AddItem(newItem) end)
				end
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


function GameMode:OnKillGoalReached(team)
	--Duel:EndDuel()
	--PlayerTables:SetTableValue("arena", "duel_timer", 0)
	GameRules:SetSafeToLeave(true)
	GameRules:SetGameWinner(team)
	StatsClient:OnGameEnd(team)
end

function GameMode:OnOneTeamLeft(team)
	--Duel:EndDuel()
	--PlayerTables:SetTableValue("arena", "duel_timer", 0)
	GameRules:SetSafeToLeave(true)
	GameRules:SetGameWinner(team)
	StatsClient:OnGameEnd(team)
end
