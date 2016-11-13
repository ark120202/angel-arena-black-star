-- This is the primary barebones gamemode script and should be used to assist in initializing your game mode
BAREBONES_VERSION = "1.00"

-- Set this to true if you want to see a complete debug output of all events/processes done by barebones
-- You can also change the cvar 'barebones_spew' at any time to 1 or 0 for output/no output
BAREBONES_DEBUG_SPEW = false 
GAMEMODE_INITIALIZATION_STATUS = {}

SERVER_LOGGING = false
if GameMode == nil then
	DebugPrint( '[BAREBONES] creating barebones game mode' )
	_G.GameMode = class({})
end

local requirements = {
	"libraries/keyvalues",
	"libraries/timers",
	"libraries/physics",
	"libraries/projectiles",
	"libraries/notifications",
	"libraries/animations",
	"libraries/attachments",
	"libraries/playertables",
	"libraries/containers",
	"libraries/modmaker",
	"libraries/pathgraph",
	"libraries/selection",
	"libraries/worldpanels",
	"libraries/CosmeticLib",
	"libraries/PopupNumbers",
	"libraries/json",
	--------------------------------------------------
	"data/globals",
	"data/constants",
	"data/projectiles_table",
	"data/casino_colortable",
	"data/containers",
	"data/kv_data",
	"data/UserGroups",
	"data/modifiers",
	"data/settings",
	"data/wearables",
	"data/shop",
	"data/itembuilds",
	--------------------------------------------------
	"internal/gamemode",
	"internal/events",
	--------------------------------------------------
	"events",
	"custom_events",
	"spawner",
	"bosses",
	"duel",
	"hero_selection",
	"internal/containers",
	"internal/scepter",
	"playermessages",
	"herovoice",
	"gold",
	"kills",
	"panorama_shop",
	"gamemodes",
	"statcollection/init",
	"developer",
	"custom_wearables",
	"SimpleAI",
}
for i = 1, #requirements do
	require(requirements[i])
end

GameModes:Preload()

GameRules.CreateProjectile = Projectiles.CreateProjectile

LinkLuaModifier("modifier_state_hidden", "modifiers/modifier_state_hidden", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_banned", "modifiers/modifier_banned", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_shard_attackspeed_stack", "items/lua/modifiers/modifier_item_shard_attackspeed_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_apocalypse_apocalypse", "heroes/hero_apocalypse/modifier_apocalypse_apocalypse.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_custom_attack_range_melee", "modifiers/modifier_custom_attack_range_melee.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_charges", "libraries/modifiers/modifier_charges.lua", LUA_MODIFIER_MOTION_NONE)


function GameMode:PostLoadPrecache()
	DebugPrint("[BAREBONES] Performing Post-Load precache")
end

function GameMode:OnFirstPlayerLoaded()
	DebugPrint("[BAREBONES] First Player has loaded")
	Containers:SetItemLimit(50)
	Containers:UsePanoramaInventory(true)
	HeroSelection:PrepareTables()
	PanoramaShop:InitializeItemTable()
	local portal2 = Entities:FindByName(nil, "target_mark_teleport_river_team2")
	local portal3 = Entities:FindByName(nil, "target_mark_teleport_river_team3")
	if portal2 and portal3 then
		CreateLoopedPortal(portal2:GetAbsOrigin(), portal3:GetAbsOrigin(), 80, "particles/customgames/capturepoints/cp_wood.vpcf", "", true)
	end
	if DOTA_ACTIVE_GAMEMODE_TYPE == DOTA_GAMEMODE_TYPE_ABILITY_SHOP then
		AbilityShop:PostAbilityData()
	end
	if DOTA_ACTIVE_GAMEMODE == DOTA_GAMEMODE_HOLDOUT_5 then
		Holdout:Init()
	end
	if SERVER_LOGGING then
		InitLogFile("log/arena_log.txt", "\n\n\n\nAngel Arena Black Star Gamemode Log:\n")
	end
end

function GameMode:OnAllPlayersLoaded()
	DebugPrint("[BAREBONES] All Players have loaded into the game")
	if GAMEMODE_INITIALIZATION_STATUS[4] then
		return
	end
	GAMEMODE_INITIALIZATION_STATUS[4] = true
	HeroSelection:CollectPD()
	--Colors setup
	Timers:CreateTimer(0.03, function()
		local Counters = {}
		Counters[DOTA_TEAM_GOODGUYS] = 1
		Counters[DOTA_TEAM_BADGUYS]	= 1
		for i = 0, DOTA_MAX_TEAM_PLAYERS-1 do
			if PlayerResource:IsValidPlayerID(i) then
				local team = PlayerResource:GetTeam(i)
				if PLAYERS_COLORS[team] and Counters[team] then
					local color = PLAYERS_COLORS[team][Counters[team]]
					PLAYER_DATA[i].Color = color
					PlayerResource:SetCustomPlayerColor(i, color[1], color[2], color[3])
					Counters[team] = Counters[team] + 1
				end
			end
		end
	end)
end

--[[
	This function is called once and only once for every player when they spawn into the game for the first time.	It is also called
	if the player's hero is replaced with a new hero for any reason.	This function is useful for initializing heroes, such as adding
	levels, changing the starting gold, removing/adding abilities, adding physics, etc.

	The hero parameter is the hero entity that just spawned in
]]
function GameMode:OnHeroInGame(hero)
	DebugPrint("[BAREBONES] Hero spawned in game for first time -- " .. hero:GetUnitName())
	Timers:CreateTimer(function()
		if HeroSelection.SelectionEnd and not hero:HasModifier("modifier_arc_warden_tempest_double") and hero:IsRealHero() then

			_G.ANY_HERO_IN_GAME = true
			if not TEAMS_COURIERS[hero:GetTeamNumber()] then
				local cour_item = hero:AddItem(CreateItem("item_courier", hero, hero))
				TEAMS_COURIERS[hero:GetTeamNumber()] = true
				Timers:CreateTimer(0.03, function()
					local couriers = Entities:FindAllByClassname("npc_dota_courier")
					for _,courier in pairs(couriers) do
						if courier:GetOwner():GetPlayerID() == hero:GetPlayerID() then
							courier:UpgradeToFlyingCourier()
							TEAMS_COURIERS[hero:GetTeamNumber()] = courier
						end
					end
				end)
			end
			HeroVoice:OnHeroInGame(hero)
		end

	end)
end

--[[
	This function is called once and only once when the game completely begins (about 0:00 on the clock).	At this point,
	gold will begin to go up in ticks if configured, creeps will spawn, towers will become damageable etc.	This function
	is useful for starting any game logic timers/thinkers, beginning the first round, etc.
]]
function GameMode:OnGameInProgress()
	DebugPrint("[BAREBONES] The game has officially begun")
	if GAMEMODE_INITIALIZATION_STATUS[3] then
		return
	end
	GAMEMODE_INITIALIZATION_STATUS[3] = true
	if DOTA_ACTIVE_GAMEMODE ~= DOTA_GAMEMODE_HOLDOUT_5 then
		Bosses:InitAllBosses()
		Duel:CreateGlobalTimer()
		ContainersHelper:CreateShops()
		Spawner:RegisterTimers()

		local sum = 0
		local count = 0
		for _,v in pairs(PLAYER_DATA) do
			if v.GameModeVote then
				sum = sum + v.GameModeVote
				count = count + 1
			end
		end
		local result
		if count >= 1 then
			result = math.floor(sum / count)
		else
			result = DOTA_KILL_GOAL_VOTE_STANDART
		end
		GameRules:SetKillGoal(result)
	else
		Holdout:Start()
	end
	Scepters:SetGlobalScepterThink()
	Timers:CreateTimer(GOLD_TICK_TIME, Dynamic_Wrap(GameMode, "GameModeThink"))
end

-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function GameMode:InitGameMode()
	GameMode = self
	DebugPrint('[BAREBONES] Starting to load Barebones gamemode...')
	if GAMEMODE_INITIALIZATION_STATUS[2] then
		return
	end
	GAMEMODE_INITIALIZATION_STATUS[2] = true
	GameMode:InitFilters()
	HeroSelection:Initialize()
	GameMode:RegisterCustomListeners()
	PlayerTables:CreateTable("arena", {
		gold = {},
		gamemode_settings = {
			kill_goal_vote_min = DOTA_KILL_GOAL_VOTE_MIN,
			kill_goal_vote_max = DOTA_KILL_GOAL_VOTE_MAX,
			xp_table = XP_PER_LEVEL_TABLE,
			gamemode = DOTA_ACTIVE_GAMEMODE,
			gamemode_type = DOTA_ACTIVE_GAMEMODE_TYPE,
		},
		players_abandoned = {},
		courier_owner2 = -1,
		courier_owner3 = -1,
		courier_owner4 = -1,
		courier_owner5 = -1,
		courier_owner6 = -1,
		courier_owner7 = -1,
		courier_owner8 = -1,
		courier_owner9 = -1,
		courier_owner10 = -1,
	}, {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23})
	PlayerTables:CreateTable("entity_attributes", {}, {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23})
	PlayerTables:CreateTable("player_hero_entities", {}, {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23})
	Containers:CreateContainer({
		layout             = {24},
		range              = -1,
		closeOnOrder       = false,
		pids               = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23},
		OnDragFrom         = function(playerID, container, unit, item, fromSlot, toContainer, toSlot)
			Containers:print('Containers:OnDragFrom', playerID, container, unit, item, fromSlot, toContainer, toSlot)
			print(item:GetName(), "from")
			local canChange = Containers.itemKV[item:GetAbilityName()].ItemCanChangeContainer
			if toContainer._OnDragTo == false or canChange == 0 or playerID + 1 ~= fromSlot then return end
			local fun = nil
			if type(toContainer._OnDragTo) == "function" then
				fun = toContainer._OnDragTo
			end
			if fun then
				fun(playerID, container, unit, item, fromSlot, toContainer, toSlot)
			else
				Containers:OnDragTo(playerID, container, unit, item, fromSlot, toContainer, toSlot)
			end
			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "spellcrafting_update_slot_cad", {id = -1})
		end,
		OnDragTo           = function(playerID, container, unit, item, fromSlot, toContainer, toSlot)
			Containers:print('Containers:OnDragTo', playerID, container, unit, item, fromSlot, toContainer, toSlot)
			print(item:GetName(), "to")
			if  playerID + 1 ~= toSlot then
				return false
			end 
			local item2 = toContainer:GetItemInSlot(toSlot)
			local addItem = nil
			if item2 and IsValidEntity(item2) and (item2:GetAbilityName() ~= item:GetAbilityName() or not item2:IsStackable() or not item:IsStackable()) then
				if Containers.itemKV[item2:GetAbilityName()].ItemCanChangeContainer == 0 then
					return false
				end
				toContainer:RemoveItem(item2)
				addItem = item2
			end
			if toContainer:AddItem(item, toSlot) then
				container:ClearSlot(fromSlot)
				if addItem then
					if container:AddItem(addItem, fromSlot) then
						CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "spellcrafting_update_slot_cad", {id = item:GetEntityIndex()})
						return true
					else
						toContainer:RemoveItem(item)
						toContainer:AddItem(item2, toSlot, nil, true)
						container:AddItem(item, fromSlot, nil, true)
						return false
					end
				end
				CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "spellcrafting_update_slot_cad", {id = item:GetEntityIndex()})
				return true
			elseif addItem then
				toContainer:AddItem(item2, toSlot, nil, true)
			end
			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "spellcrafting_update_slot_cad", {id = item:GetEntityIndex()})
			return false 
		end,
		OnLeftClick        = false,
		OnRightClick       = false,
		AddItemFilter      = function(container, item, slot)
			return item:GetAbilityName() == "item_cad"
		end,
    })
	DebugPrint('[BAREBONES] Done loading Barebones gamemode!\n\n')
end

function GameMode:InitFilters()
	GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(GameMode, 'ExecuteOrderFilter'), self)
	GameRules:GetGameModeEntity():SetDamageFilter(Dynamic_Wrap(GameMode, 'DamageFilter'), self)
	GameRules:GetGameModeEntity():SetBountyRunePickupFilter(Dynamic_Wrap(GameMode, 'BountyRunePickupFilter'), self)
	GameRules:GetGameModeEntity():SetModifyGoldFilter(Dynamic_Wrap(GameMode, 'ModifyGoldFilter'), self)
end

function GameMode:ExecuteOrderFilter(filterTable)
--	PrintTable(filterTable)
	local issuer_player_id_const = filterTable.issuer_player_id_const
	local target = 			EntIndexToHScript(filterTable.entindex_target)
	local order_type = 		filterTable.order_type
	local ability = EntIndexToHScript(filterTable.entindex_ability)
	local abilityname
	if ability and ability.GetName then
		abilityname = ability:GetName()
	end
	local entindexes_units = filterTable.units
	local units = {}
	for _, v in pairs(entindexes_units) do
		local u = EntIndexToHScript(v)
		if u then
			table.insert(units, u)
		end
	end
	for _,unit in ipairs(units) do
		if unit:GetUnitName() == "npc_dota_courier" then
			local palyerTeam = PlayerResource:GetTeam(issuer_player_id_const)
			if order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION then
				PlayerTables:SetTableValue("arena", "courier_owner" .. palyerTeam, issuer_player_id_const)
				local point = Vector(filterTable.position_x, filterTable.position_y, 0)
				if CourierTimer[palyerTeam] then
					Timers:RemoveTimer(CourierTimer[palyerTeam])
				end
				CourierTimer[palyerTeam] = Timers:CreateTimer(function()
					if (unit:GetAbsOrigin() - point):Length2D() < 10 then
						PlayerTables:SetTableValue("arena", "courier_owner" .. palyerTeam, -1)
					else
						return 0.03
					end
				end)
			elseif order_type == DOTA_UNIT_ORDER_CAST_NO_TARGET and (abilityname == "courier_transfer_items" or abilityname == "courier_take_stash_and_transfer_items") then
				local hero = PlayerResource:GetSelectedHeroEntity(issuer_player_id_const)
				local can_continue = false
				if abilityname == "courier_take_stash_and_transfer_items" then
					for i = 6, 11 do
						local item = hero:GetItemInSlot(i)
						if item and item:GetOwner() == hero then
							can_continue = true
						end
					end
				end
				if not can_continue then
					for i = 0, 5 do
						local item = unit:GetItemInSlot(i)
						if item and item:GetPurchaser() == hero then
							can_continue = true
						end
					end
				end
				if can_continue then
					PlayerTables:SetTableValue("arena", "courier_owner" .. palyerTeam, issuer_player_id_const)
					if CourierTimer[palyerTeam] then
						Timers:RemoveTimer(CourierTimer[palyerTeam])
					end
					CourierTimer[palyerTeam] = Timers:CreateTimer(function()
						if (unit:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D() < 225 then
							PlayerTables:SetTableValue("arena", "courier_owner" .. palyerTeam, -1)
						else
							return 0.03
						end
					end)
				end
			elseif abilityname ~= "courier_burst" then
				PlayerTables:SetTableValue("arena", "courier_owner" .. palyerTeam, -1)
			end
		end
		if unit:IsHero() or unit:IsConsideredHero() then
			GameMode:TrackInventory(unit)
		end
		if order_type == DOTA_UNIT_ORDER_TRAIN_ABILITY and DOTA_ACTIVE_GAMEMODE_TYPE == DOTA_GAMEMODE_TYPE_ABILITY_SHOP then
			Containers:DisplayError(issuer_player_id_const, "#dota_hud_error_ability_inactive")
			return false
		end
		if order_type == DOTA_UNIT_ORDER_PURCHASE_ITEM and filterTable.entindex_ability and GetKeyValue(GetItemNameById(filterTable.entindex_ability), "ItemPurchasableFilter") == 0 then
			return false
		end
		if unit:IsRealHero() then
			if order_type == DOTA_UNIT_ORDER_CAST_TARGET then
				if ability then
					local abilityname = ability:GetName()
					if IsBossEntity(target) and table.contains(BOSS_BANNED_ABILITIES, abilityname) then
						filterTable.order_type = DOTA_UNIT_ORDER_ATTACK_TARGET
					end

					if table.contains(ABILITY_INVULNERABLE_UNITS, target:GetUnitName()) and abilityname ~= "item_casino_coin" then
						filterTable.order_type = DOTA_UNIT_ORDER_MOVE_TO_TARGET
						return true
					end
				end
			elseif order_type == DOTA_UNIT_ORDER_SELL_ITEM then
				if ability:GetName() == "item_pocket_riki" then
					local gold = Kills:GetGoldForKill(ability.RikiContainer)
					Gold:ModifyGold(unit, gold, true)
					SendOverheadEventMessage(unit:GetPlayerOwner(), OVERHEAD_ALERT_GOLD, unit, gold, unit:GetPlayerOwner())
					TrueKill(unit, ability, ability.RikiContainer)
					Kills:ClearStreak(ability.RikiContainer:GetPlayerID())
					unit:RemoveItem(ability)
					unit:RemoveModifierByName("modifier_item_pocket_riki_invisibility_fade")
					unit:RemoveModifierByName("modifier_item_pocket_riki_permanent_invisibility")
					unit:RemoveModifierByName("modifier_invisible")
					GameRules:SendCustomMessage("#riki_pocket_riki_chat_notify_text", 0, unit:GetTeamNumber()) 
				end
			end
			if filterTable.position_x ~= 0 and filterTable.position_y ~= 0 then
				if (RandomInt(0, 1) == 1 and (unit:HasModifier("modifier_item_casino_drug_pill3_debuff") or unit:GetModifierStackCount("modifier_item_casino_drug_pill3_addiction", unit) >= 8)) or unit:GetModifierStackCount("modifier_item_casino_drug_pill3_addiction", unit) >= 16 then
					local heroVector = unit:GetAbsOrigin()
					local orderVector = Vector(filterTable.position_x, filterTable.position_y, 0)
					local diff = orderVector - heroVector
					local newVector = heroVector + (diff * -1)
					filterTable.position_x = newVector.x
					filterTable.position_y = newVector.y
				end
			end
		end
	end
	return true
end

function GameMode:DamageFilter(filterTable)
	local damagetype_const = 	filterTable.damagetype_const
	local damage = 				filterTable.damage
	local inflictor
	if filterTable.entindex_inflictor_const then
		inflictor = EntIndexToHScript(filterTable.entindex_inflictor_const)
	end
	local attacker
	if filterTable.entindex_attacker_const then 
		attacker = 				EntIndexToHScript(filterTable.entindex_attacker_const)
	end
	local victim = 				EntIndexToHScript(filterTable.entindex_victim_const)
	if attacker then
		for k,v in pairs(ON_DAMAGE_MODIFIER_PROCS) do
			if attacker.HasModifier and attacker:HasModifier(k) then
				v(attacker, victim, inflictor, damage, damagetype_const)
			end
		end
		for k,v in pairs(ON_DAMAGE_MODIFIER_PROCS_VICTIM) do
			if victim.HasModifier and victim:HasModifier(k) then
				v(attacker, victim, inflictor, damage, damagetype_const)
			end
		end
		for k,v in pairs(OUTGOING_DAMAGE_MODIFIERS) do
			if attacker.HasModifier and attacker:HasModifier(k) and	(not v.condition or (v.condition and v.condition(attacker, victim, inflictor, damage, damagetype_const))) then
				if v.multiplier then
					if type(v.multiplier) == "number" then
						filterTable.damage = filterTable.damage * v.multiplier
					elseif type(v.multiplier) == "function" then
						local multiplier = v.multiplier(attacker, victim, inflictor, damage, damagetype_const)
						if multiplier then
							filterTable.damage = filterTable.damage * multiplier
						end
					end
				end
			end
		end
		for k,v in pairs(INCOMING_DAMAGE_MODIFIERS) do
			if victim.HasModifier and victim:HasModifier(k) and	(not v.condition or (v.condition and v.condition(attacker, victim, inflictor, damage, damagetype_const))) then
				if v.multiplier then
					if type(v.multiplier) == "number" then
						filterTable.damage = filterTable.damage * v.multiplier
					elseif type(v.multiplier) == "function" then
						local multiplier = v.multiplier(attacker, victim, inflictor, damage, damagetype_const)
						if multiplier then
							filterTable.damage = filterTable.damage * multiplier
						end
					end
				end
			end
		end
		if inflictor then
			if BOSS_DAMAGE_ABILITY_MODIFIERS[inflictor:GetName()] and IsBossEntity(victim) then
				filterTable.damage = damage * BOSS_DAMAGE_ABILITY_MODIFIERS[inflictor:GetName()] * 0.01
			end
			if inflictor:GetName() == "templar_assassin_psi_blades" and victim:IsRealCreep() then
				filterTable.damage = damage * 0.5
			end
		end

		if (attacker.HasModifier and (attacker:HasModifier("modifier_crystal_maiden_glacier_tranqulity_buff") or attacker:HasModifier("modifier_crystal_maiden_glacier_tranqulity_debuff"))) or (victim.HasModifier and (victim:HasModifier("modifier_crystal_maiden_glacier_tranqulity_buff") or victim:HasModifier("modifier_crystal_maiden_glacier_tranqulity_debuff"))) then
			filterTable.damage = 0
			return false
		end
	end
	return true
end

function GameMode:BountyRunePickupFilter(filterTable)
	local hero = PlayerResource:GetSelectedHeroEntity(filterTable.player_id_const)
	filterTable.gold_bounty = 50 + (2 * GetDOTATimeInMinutesFull())
	filterTable.xp_bounty = 50 + (5 * GetDOTATimeInMinutesFull())
	local gold_multiplier = filterTable.bounty_special_multiplier or 1
	local xp_multiplier = 1

	local ability_plus_morality = hero:FindAbilityByName("arthas_plus_morality")
	if ability_plus_morality and ability_plus_morality:GetLevel() > 0 then
		gold_multiplier = gold_multiplier + ability_plus_morality:GetAbilitySpecial("bounty_multiplier")
		ModifyStacks(ability_plus_morality, hero, hero, "modifier_arthas_plus_morality_buff", 1, false)
	end
	local ability_goblins_greed = hero:FindAbilityByName("alchemist_goblins_greed")
	if ability_goblins_greed and ability_goblins_greed:GetLevel() > 0 then
		gold_multiplier = gold_multiplier + ability_goblins_greed:GetAbilitySpecial("bounty_multiplier_tooltip")
	end
	local item_blood_of_midas = FindItemInInventoryByName(hero, "item_blood_of_midas", false)
	if item_blood_of_midas then
		gold_multiplier = gold_multiplier + item_blood_of_midas:GetLevelSpecialValueFor("gold_multiplier", item_blood_of_midas:GetLevel() - 1)
		xp_multiplier = xp_multiplier + item_blood_of_midas:GetLevelSpecialValueFor("xp_multiplier", item_blood_of_midas:GetLevel() - 1)
	end
	filterTable.gold_bounty = filterTable.gold_bounty * gold_multiplier
	filterTable.xp_bounty = filterTable.xp_bounty * xp_multiplier
	return true
end

function GameMode:ModifyGoldFilter(filterTable)
	--[[local gold = filterTable["gold"]
	local playerID = filterTable["player_id_const"]
	local reason = filterTable["reason_const"]
	local reliable = filterTable["reliable"] == 1]]
	if filterTable.reason_const == DOTA_ModifyGold_HeroKill then
		filterTable["gold"] = 0
		return false
	end
end

function CDOTAGamerules:SetKillGoal(iGoal)
	KILLS_TO_END_GAME_FOR_TEAM = iGoal
	PlayerTables:SetTableValue("arena", "kill_goal", KILLS_TO_END_GAME_FOR_TEAM)
end

function CDOTAGamerules:GetKillGoal()
	return KILLS_TO_END_GAME_FOR_TEAM
end

function GameMode:RandomOMGRollAbilities(unit)
	unit:RemoveModifierByName("modifier_attribute_bonus_arena")
	for i = 0, unit:GetAbilityCount() - 1 do
		local ability = unit:GetAbilityByIndex(i)
		if ability then
			for _,v in ipairs(unit:FindAllModifiers()) do
				if v:GetAbility() and v:GetAbility() == ability then
					v:Destroy()
				end
			end
			unit:RemoveAbility(ability:GetName())
		end
	end
	
	local has_abilities = 0
	while has_abilities < RANDOM_OMG_SETTINGS.Total_Abilities - RANDOM_OMG_SETTINGS.Ultimate_Count do
		local abilityTable = RANDOM_OMG_SETTINGS.Abilities.Abilities[RandomInt(1, #RANDOM_OMG_SETTINGS.Abilities.Abilities)]
		local ability = abilityTable.ability
		if ability and not unit:HasAbility(ability) then
			PrecacheItemByNameAsync(ability, function() end)
			GameMode:PrecacheUnitQueueed(abilityTable.hero)
			AddNewAbility(unit, ability)
			has_abilities = has_abilities + 1
		end
	end
	local has_ultimates = 0
	while has_ultimates < RANDOM_OMG_SETTINGS.Ultimate_Count do
		local abilityTable = RANDOM_OMG_SETTINGS.Abilities.Ultimates[RandomInt(1, #RANDOM_OMG_SETTINGS.Abilities.Ultimates)]
		local ability = abilityTable.ability
		if ability and not unit:HasAbility(ability) then
			PrecacheItemByNameAsync(ability, function() end)
			GameMode:PrecacheUnitQueueed(abilityTable.hero)
			AddNewAbility(unit, ability)
			has_ultimates = has_ultimates + 1
		end
	end
	unit:AddAbility("attribute_bonus_arena")
	unit:SetAbilityPoints(unit:GetLevel())
end

function GameMode:PrecacheUnitQueueed(name)
	if not table.contains(RANDOM_OMG_PRECACHED_HEROES, name) then
		if not IS_PRECACHE_PROCESS_RUNNING then
			IS_PRECACHE_PROCESS_RUNNING = true
			table.insert(RANDOM_OMG_PRECACHED_HEROES, name)
			PrecacheUnitByNameAsync(name, function()
				IS_PRECACHE_PROCESS_RUNNING = nil
			end)
		else
			Timers:CreateTimer(0.5, function()
				GameMode:PrecacheUnitQueueed(name)
			end)
		end
	end
end

function GameMode:GameModeThink()
	--if false then return end

	for _,v in ipairs(HeroList:GetAllHeroes()) do
		if v and not v:IsNull() then
			PlayerTables:SetTableValue("entity_attributes", v:GetEntityIndex(), {
				--[[str_base = v:GetBaseStrength(),
				agi_base = v:GetBaseAgility(),
				int_base = v:GetBaseIntellect(),
				str_add = v:GetStrength() - v:GetBaseStrength(),
				agi_add = v:GetAgility() - v:GetBaseAgility(),
				int_add = v:GetIntellect() - v:GetBaseIntellect(),]]
				str = v:GetStrength(),
				agi = v:GetAgility(),
				int = v:GetIntellect(),
				str_gain = v:GetStrengthGain(),
				agi_gain = v:GetAgilityGain(),
				int_gain = v:GetIntellectGain(),
				attribute_primary = v:GetPrimaryAttribute(),
				spell_amplify = v:GetSpellDamageAmplify(),
				hero_name = GetFullHeroName(v),
			})
		end
	end

	for i = 0, 23 do
		if PlayerResource:IsValidPlayerID(i) then
			if PlayerResource:GetSelectedHeroEntity(i) then
				PlayerTables:SetTableValue("player_hero_entities", i, PlayerResource:GetSelectedHeroEntity(i):GetEntityIndex())
			end
			if not PLAYER_DATA[i].IsAbandoned and PlayerResource:GetConnectionState(i) == DOTA_CONNECTION_STATE_CONNECTED then
				PLAYER_DATA[i].AutoAbandonGameTime = nil
				Gold:UpdatePlayerGold(i)
			elseif PLAYER_DATA[i].IsAbandoned then
				local gold = Gold:GetGold(i)
				local allyCount = GetTeamPlayerCount(PlayerResource:GetTeam(i))
				local goldPerAlly = math.floor(gold/allyCount)
				local goldCanBeWasted = goldPerAlly * allyCount
				Gold:ModifyGold(i, -goldCanBeWasted)
				for ally = 0, 23 do
					if PlayerResource:IsValidPlayerID(ally) and not IsPlayerAbandoned(ally) then
						if PlayerResource:GetTeam(ally) == PlayerResource:GetTeam(i) then
							Gold:ModifyGold(ally, goldPerAlly)
						end
					end
				end
			elseif not PLAYER_DATA[i].IsAbandoned then
				if PlayerResource:GetConnectionState(i) == DOTA_CONNECTION_STATE_DISCONNECTED then
					if not PLAYER_DATA[i].AutoAbandonGameTime then
						PLAYER_DATA[i].AutoAbandonGameTime = Time() + DOTA_PLAYER_AUTOABANDON_TIME
						GameRules:SendCustomMessage("#DOTA_Chat_DisconnectWaitForReconnect", i, -1)
					end
					local timeLeft = PLAYER_DATA[i].AutoAbandonGameTime - Time()
					if not PLAYER_DATA[i].LastLeftNotify or timeLeft < PLAYER_DATA[i].LastLeftNotify - 60 then
						PLAYER_DATA[i].LastLeftNotify = timeLeft
						GameRules:SendCustomMessage("#DOTA_Chat_DisconnectTimeRemainingPlural", i, math.round(timeLeft/60))
					end

					if PlayerResource:GetConnectionState(i) ~= DOTA_CONNECTION_STATE_CONNECTED then
						if timeLeft <= 0 then
							GameRules:SendCustomMessage("#DOTA_Chat_PlayerAbandonedDisconnectedTooLong", i, -1)
							MakePlayerAbandoned(i)
						end
					end
				elseif PlayerResource:GetConnectionState(i) == DOTA_CONNECTION_STATE_ABANDONED then
					GameRules:SendCustomMessage("#DOTA_Chat_PlayerAbandoned", i, -1)
					MakePlayerAbandoned(i)
				end
			end

		end
	end
	
	return GOLD_TICK_TIME
end
-- GameRules:Playtesting_UpdateAddOnKeyValues()
-- dota_create_fake_clients