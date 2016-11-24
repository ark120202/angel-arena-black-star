_G.DOTA_DUEL_STATUS_NONE = 0
_G.DOTA_DUEL_STATUS_WATING = 1
_G.DOTA_DUEL_STATUS_IN_PROGRESS = 2
_G.DOTA_DUEL_STATUS_1X1_IN_PROGRESS = 3
LinkLuaModifier("modifier_duel_hero_disabled_for_duel", "modifiers/modifier_duel_hero_disabled_for_duel.lua", LUA_MODIFIER_MOTION_NONE)
if Duel == nil then
	_G.Duel = class({})
	Duel.TimeUntilDuel = ARENA_SETTINGS.DelayFromGameStart
	Duel.TimeUntilDuelEnd = 0
	Duel.TimeUntilDuel1x1End = 0
	Duel.GlobalTimer = nil
	Duel.DuelStatus = DOTA_DUEL_STATUS_NONE
	Duel.EntIndexer = {}
	Duel.Particles = {}
	Duel.Duel1x1Bet = 0
	Duel.DuelCounter = 0
end

function Duel:CreateGlobalTimer()
	Duel.DuelStatus = DOTA_DUEL_STATUS_WATING
	PlayerTables:SetTableValue("arena", "duel_timer", Duel.TimeUntilDuel)
	Duel.GlobalTimer = Timers:CreateTimer(1, function()
		if Duel.DuelStatus == DOTA_DUEL_STATUS_WATING then
			Duel.TimeUntilDuel = Duel.TimeUntilDuel - 1
			if Duel.TimeUntilDuel <= 0 then
				Duel:StartDuel()
				PlayerTables:SetTableValue("arena", "duel_timer", 0)
			else
				PlayerTables:SetTableValue("arena", "duel_timer", Duel.TimeUntilDuel)
			end
		end
		if Duel.DuelStatus == DOTA_DUEL_STATUS_IN_PROGRESS then
			Duel.TimeUntilDuelEnd = Duel.TimeUntilDuelEnd - 1
			if Duel.TimeUntilDuelEnd <= 0 then
				Duel:EndDuel()
				PlayerTables:SetTableValue("arena", "duel_timer", 0)
			else
				PlayerTables:SetTableValue("arena", "duel_timer", Duel.TimeUntilDuelEnd)
			end
		end
		if Duel.DuelStatus == DOTA_DUEL_STATUS_1X1_IN_PROGRESS then
			Duel.TimeUntilDuel1x1End = Duel.TimeUntilDuel1x1End - 1
			if Duel.TimeUntilDuel1x1End <= 0 then
				Duel:End1X1()
				PlayerTables:SetTableValue("arena", "duel_timer", 0)
			else
				PlayerTables:SetTableValue("arena", "duel_timer", Duel.TimeUntilDuel1x1End)
			end
		end
		return 1
	end)

	Physics:RemoveCollider("collider_box_blocker_arena")
	--Physics:CreateBox(a, b, width, center)
	local a1 = Entities:FindByName(nil, "target_mark_arena_blocker_1"):GetAbsOrigin()
	local a2 = Entities:FindByName(nil, "target_mark_arena_blocker_2"):GetAbsOrigin()
	local collider = Physics:AddCollider("collider_box_blocker_arena", Physics:ColliderFromProfile("boxblocker"))
	collider.box = CreateSimpleBox(a1, a2)
	collider.findClearSpace = true
	collider.test = function(self, unit)
		if not IsPhysicsUnit(unit) and unit.IsConsideredHero and unit:IsConsideredHero() then
			Physics:Unit(unit)
		end
		return IsPhysicsUnit(unit) and Duel.DuelStatus == DOTA_DUEL_STATUS_WATING and not unit.InArena
	end
end

function Duel:StartDuel()
	Duel.heroes_teams_for_duel = {}
	for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1  do
		if PlayerResource:IsValidPlayerID(playerID) then
			local player = PlayerResource:GetPlayer(playerID)
			if player and player:GetAssignedHero() then
				if Duel.heroes_teams_for_duel[player:GetTeamNumber()] == nil then Duel.heroes_teams_for_duel[player:GetTeamNumber()] = {} end
				table.insert(Duel.heroes_teams_for_duel[player:GetTeamNumber()], player:GetAssignedHero())
			end
		end
	end
	local heroes_in_teams = {}
	local has_heroes = {}
	for i,v in pairs(Duel.heroes_teams_for_duel) do
		if heroes_in_teams[i] == nil then heroes_in_teams[i] = 0 end
		if has_heroes[i] == nil then has_heroes[i] = false end
		for _,vi in pairs(v) do
			if vi:IsAlive() then
				heroes_in_teams[i] = heroes_in_teams[i] + 1
				has_heroes[i] = true
			end
		end
	end
	heroes_in_teams = table.iterate(heroes_in_teams)
	local heroes_to_fight_n = math.min(unpack(heroes_in_teams))
	Duel.TimeUntilDuelEnd = ARENA_SETTINGS.DurationBase + ARENA_SETTINGS.DurationForPlayer * heroes_to_fight_n
	if heroes_to_fight_n > 0 and table.allEqual(has_heroes, true) and table.count(Duel.heroes_teams_for_duel) > 1 then
		for _,v in ipairs(Entities:FindAllByName("npc_dota_arena_statue")) do
			local particle1 = ParticleManager:CreateParticle("particles/arena/units/arena_statue/statue_eye.vpcf", PATTACH_ABSORIGIN, v)
			local particle2 = ParticleManager:CreateParticle("particles/arena/units/arena_statue/statue_eye.vpcf", PATTACH_ABSORIGIN, v)
			ParticleManager:SetParticleControlEnt(particle1, 0, v, PATTACH_POINT_FOLLOW, "attach_eye_l", v:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(particle2, 0, v, PATTACH_POINT_FOLLOW, "attach_eye_r", v:GetAbsOrigin(), true)
			table.insert(Duel.Particles, particle1)
			table.insert(Duel.Particles, particle2)
		end
		Duel.DuelStatus = DOTA_DUEL_STATUS_IN_PROGRESS
		local rndtbl = {}
		table.merge(rndtbl, Duel.heroes_teams_for_duel)
		for i,v in pairs(rndtbl) do
			if #v > 0 then
				table.shuffle(v)
				local count = 0
				repeat
					local unit = v[1]
					if unit and not unit:IsNull() then
						if unit:IsAlive() and not unit.DuelChecked then
							unit.InArena = true
							Duel:FillPreduelUnitData(unit)
							unit:SetHealth(unit:GetMaxHealth())
							unit:SetMana(unit:GetMaxMana())
							count = count + 1
						end
						unit.DuelChecked = true
					end
					table.shuffle(v)
				until count >= heroes_to_fight_n
			end
		end
		for team,tab in pairs(Duel.heroes_teams_for_duel) do
			for _,unit in pairs(tab) do
				unit:RemoveModifierByName("modifier_tether_ally_aghanims")
				if unit.InArena then
					for _,v in ipairs(DUEL_PURGED_MODIFIERS) do
						if unit:HasModifier(v) then
							unit:RemoveModifierByName(v)
						end
					end

					if unit.PocketItem then
						UTIL_Remove(unit.PocketItem)
					end
					unit.ArenaBeforeTpLocation = unit:GetAbsOrigin()
					unit:Stop()
					PlayerResource:SetCameraTarget(unit:GetPlayerOwnerID(), unit)
					FindClearSpaceForUnit(unit, Entities:FindByName(nil, "target_mark_arena_team" .. team):GetAbsOrigin(), true)
					Timers:CreateTimer(0.1, function() PlayerResource:SetCameraTarget(unit:GetPlayerOwnerID(), nil); unit:Stop() end)
				else
					Duel:SetUpVisitor(unit)
				end
				--TODO Meepo
			end
		end
	else
		Duel:EndDuelLogic(false, true)
		Notifications:TopToAll({text="#duel_no_heroes", duration=9.0})
	end
end

function Duel:EndDuel()
	Duel.DuelCounter = Duel.DuelCounter + 1
	for _,v in ipairs(Duel.Particles) do
		ParticleManager:DestroyParticle(v, false)
	end
	local winner = Duel:GetWinner()
	if winner then
		Notifications:TopToAll({text="#duel_over_winner_p1", duration=9.0})
		Notifications:TopToAll(CreateTeamNotificationSettings(winner, false))
		Notifications:TopToAll({text="#duel_over_winner_p2", continue=true})
		local goldAmount = GetFilteredGold(ARENA_SETTINGS.WinGold_Base + (ARENA_SETTINGS.WinGold_PerDuel * Duel.DuelCounter))
		local g1,g2 = CreateGoldNotificationSettings(goldAmount)
		Notifications:TopToAll(g1)
		Notifications:TopToAll(g2)
		for _,v in ipairs(Duel.heroes_teams_for_duel[winner]) do
			Gold:ModifyGold(v, goldAmount, true)
		end
	else
		Notifications:TopToAll({text="#duel_over_winner_none", duration=9.0})
	end
	Duel:EndDuelLogic(true, true)
end

function Duel:GetWinner()
	local teams = {}
	for team,tab in pairs(Duel.heroes_teams_for_duel) do
		for _,unit in pairs(tab) do
			if unit and not unit:IsNull() and unit:IsAlive() then
				if not table.contains(teams, team) and unit.InArena then
					table.insert(teams, team)
				end
			end
		end
	end
	if #teams == 1 then
		local winner = teams[1]
		return winner
	else
		return nil
	end
end

function Duel:SetUpVisitor(unit)
	if unit:IsAlive() then
		unit.ArenaBeforeTpLocation = unit:GetAbsOrigin()
		Duel:FillPreduelUnitData(unit)
		local team = unit:GetTeamNumber()
		Duel.EntIndexer[team] = Entities:FindByName(Duel.EntIndexer[team], "target_mark_arena_viewers_team" .. team)
		unit:Stop()
		PlayerResource:SetCameraTarget(unit:GetPlayerOwnerID(), unit)
		FindClearSpaceForUnit(unit, Duel.EntIndexer[team]:GetAbsOrigin(), true)
		Timers:CreateTimer(0.1, function() PlayerResource:SetCameraTarget(unit:GetPlayerOwnerID(), nil); unit:Stop() end)
		unit:AddNewModifier(unit, nil, "modifier_duel_hero_disabled_for_duel", {})
	end
end

function Duel:EndDuelForUnit(unit)
	unit:RemoveModifierByName("modifier_duel_hero_disabled_for_duel")
	local fountatin = FindFountain(unit:GetTeamNumber())
	local location = unit.ArenaBeforeTpLocation
	if fountatin then location = location or fountatin:GetAbsOrigin() end
	Timers:CreateTimer(0.1, function()
		if unit:IsAlive() and unit.StatusBeforeArena then
			if unit.StatusBeforeArena.Health then unit:SetHealth(unit.StatusBeforeArena.Health) end
			if unit.StatusBeforeArena.Mana then unit:SetMana(unit.StatusBeforeArena.Mana) end
			if unit.StatusBeforeArena.AbilityCooldowns and type(unit.StatusBeforeArena.AbilityCooldowns) == "table" then
				for ability,v in pairs(unit.StatusBeforeArena.AbilityCooldowns) do
					if ability and not ability:IsNull() and unit:HasAbility(ability:GetAbilityName()) then
						ability:EndCooldown()
						ability:StartCooldown(v)
					end
				end
			end
			if unit.StatusBeforeArena.ItemCooldowns and type(unit.StatusBeforeArena.ItemCooldowns) == "table" then
				for item,v in pairs(unit.StatusBeforeArena.ItemCooldowns) do
					if item and not item:IsNull() then
						item:EndCooldown()
						item:StartCooldown(v)
					end
				end
			end
			unit.StatusBeforeArena = nil
		end
	end)
	unit:Stop()
	PlayerResource:SetCameraTarget(unit:GetPlayerOwnerID(), unit)
	FindClearSpaceForUnit(unit, location, true)
	Timers:CreateTimer(0.1, function()
			PlayerResource:SetCameraTarget(unit:GetPlayerOwnerID(), nil)
			if unit then
				unit:Stop()
			end
		end)
	unit.InArena = nil
	unit.ArenaBeforeTpLocation = nil
	unit.Duel1x1Opponent = nil
	unit.DuelChecked = nil
end

function Duel:Start1X1(player1, player2, gold)
	Duel.DuelStatus = DOTA_DUEL_STATUS_1X1_IN_PROGRESS
	Duel.TimeUntilDuel1x1End = ARENA_SETTINGS.Duel1x1Duration
	for _,player in ipairs(GetAllPlayers(true)) do
		local hero = PlayerResource:GetSelectedHeroEntity(player:GetPlayerID())
		if player1 ~= player:GetPlayerID() and player2 ~= player:GetPlayerID() then
			Duel:SetUpVisitor(hero)
		end
	end
	local hero1 = PlayerResource:GetSelectedHeroEntity(player1)
	local hero2 = PlayerResource:GetSelectedHeroEntity(player2)
	hero1.Duel1x1Opponent = hero2
	hero2.Duel1x1Opponent = hero1
	Gold:RemoveGold(player1, gold)
	Gold:RemoveGold(player2, gold)
	Duel.Duel1x1Bet = gold
	hero1.ArenaBeforeTpLocation = hero1:GetAbsOrigin()
	hero2.ArenaBeforeTpLocation = hero2:GetAbsOrigin()
	PlayerResource:SetCameraTarget(hero1:GetPlayerOwnerID(), hero1)
	FindClearSpaceForUnit(hero1, Entities:FindByName(nil, "target_mark_arena_team" .. hero1:GetTeamNumber()):GetAbsOrigin(), true)
	Timers:CreateTimer(0.1, function() PlayerResource:SetCameraTarget(hero1:GetPlayerOwnerID(), nil); hero1:Stop() end)
	PlayerResource:SetCameraTarget(hero2:GetPlayerOwnerID(), hero2)
	FindClearSpaceForUnit(hero2, Entities:FindByName(nil, "target_mark_arena_team" .. hero2:GetTeamNumber()):GetAbsOrigin(), true)
	Timers:CreateTimer(0.1, function() PlayerResource:SetCameraTarget(hero2:GetPlayerOwnerID(), nil); hero2:Stop() end)
end

function Duel:End1X1(herowin, herolose)
	if herowin and herolose then
		Notifications:TopToAll({text="#duel1x1_over_winner_is_p1", duration=9.0})
		Notifications:TopToAll({hero=herowin:GetName(), continue=true})
		if herowin.GetPlayerID and herowin.GetPlayerOwnerID then
			local plId
			if herowin.GetPlayerID then
				plId = herowin:GetPlayerID()
			else
				plId = herowin:GetPlayerOwnerID()
			end
			Notifications:TopToAll({text=PlayerResource:GetPlayerName(plId), continue=true, style={color=ColorTableToCss(PLAYER_DATA[plId].Color)}})
			Notifications:TopToAll({text="#duel1x1_over_winner_is_p2", continue=true})
			local g1,g2 = CreateGoldNotificationSettings(Duel.Duel1x1Bet * 2)
			Notifications:TopToAll(g1)
			Notifications:TopToAll(g2)
		end
		Gold:ModifyGold(herowin, Duel.Duel1x1Bet * 2, true)
	else
		Notifications:TopToAll({text="#duel1x1_over_winner_none", duration=9.0})
	end
	Duel:EndDuelLogic(true, false)
end

function Duel:EndDuelLogic(bEndForUnits, timeUpdate)
	Duel.EntIndexer = {}
	Duel.DuelStatus = DOTA_DUEL_STATUS_WATING
	Duel.heroes_teams_for_duel = {}
	Duel.Duel1x1Bet = 0
	if bEndForUnits then
		for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1  do
			if PlayerResource:IsValidPlayerID(playerID) then
				local hero = PlayerResource:GetSelectedHeroEntity(playerID)
				if hero then
					Duel:EndDuelForUnit(hero)
				end
			end
		end
	end
	if timeUpdate then
		Duel.TimeUntilDuel = ARENA_SETTINGS.DelayFromLast
	end
end

function Duel:FillPreduelUnitData(unit)
	unit.StatusBeforeArena = {
		Health = unit:GetHealth(),
		Mana = unit:GetMana(),
		AbilityCooldowns = {},
		ItemCooldowns = {},
	}
	for i = 0, unit:GetAbilityCount() - 1 do
		local ability = unit:GetAbilityByIndex(i)
		if ability and ability:GetCooldown(ability:GetLevel()) > 0 then
			unit.StatusBeforeArena.AbilityCooldowns[ability] = ability:GetCooldownTimeRemaining()
			ability:EndCooldown()
		end
	end
	for i = 0, 5 do
		local item = unit:GetItemInSlot(i)
		if item then
			unit.StatusBeforeArena.ItemCooldowns[item] = item:GetCooldownTimeRemaining()
			item:EndCooldown()
		end
	end
end

function Duel:IsDuelOngoing()
	return Duel.DuelStatus >= DOTA_DUEL_STATUS_IN_PROGRESS and Duel.DuelStatus <= DOTA_DUEL_STATUS_1X1_IN_PROGRESS
end