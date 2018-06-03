if Bosses == nil then
	Bosses = class({})
	Bosses.MinimapPoints = {}
	Bosses.NextVoteID = 0
end
ModuleRequire(..., "data")
ModuleRequire(..., "boss_loot")

function CDOTA_BaseNPC:IsBoss()
	return self.GetUnitName ~= nil and string.find(self:GetUnitName(), "npc_arena_boss_") ~= nil
end

function Bosses:InitAllBosses()
	CustomGameEventManager:RegisterListener("bosses_vote_for_item", Dynamic_Wrap(Bosses, "VoteForItem"))
	PlayerTables:CreateTable("bosses_loot_drop_votes", {}, GetPlayersInTeam(team))
	Bosses:SpawnStaticBoss("l1_v1")
	Bosses:SpawnStaticBoss("l1_v2")
	Bosses:SpawnStaticBoss("l2_v1")
	Bosses:SpawnStaticBoss("l2_v2")
	Bosses:SpawnStaticBoss("central")
	Bosses:SpawnStaticBoss("freya")
	Bosses:SpawnStaticBoss("zaken")
end

function Bosses:SpawnStaticBoss(name)
	for _,v in ipairs(Entities:FindAllByName("target_mark_bosses_" .. name)) do
		Bosses.MinimapPoints[v] = DynamicMinimap:CreateMinimapPoint(v:GetAbsOrigin(), "icon_boss_" .. name)
		Bosses:SpawnBossUnit(name, v)
	end
end

function Bosses:SpawnBossUnit(name, spawner)
	DynamicMinimap:SetVisibleGlobal(Bosses.MinimapPoints[spawner], true)
	local boss = CreateUnitByName("npc_arena_boss_" .. name, spawner:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_NEUTRALS)
	boss.SpawnerEntity = spawner
	Bosses:MakeBossAI(boss, name)

	return boss
end

function Bosses:RegisterKilledBoss(unit, team)
	local unitname = unit:GetUnitName()
	local bossname = string.gsub(unitname, "npc_arena_boss_", "")

	Bosses:CreateBossLoot(unit, team)
	local amount = unit:GetKeyValue("Bosses_GoldToAll")
	DynamicMinimap:SetVisibleGlobal(Bosses.MinimapPoints[unit.SpawnerEntity], false)
	CustomGameEventManager:Send_ServerToAllClients("create_custom_toast", {
		type = "generic",
		text = "#custom_toast_BossKilled",
		victimUnitName = unitname,
		teamColor = team,
		team = team,
		gold = amount
	})
	for _,v in ipairs(GetPlayersInTeam(team)) do
		Gold:ModifyGold(v, amount)
	end

	Events:Emit("bosses/kill/" .. bossname)
	Timers:CreateTimer(unit:GetKeyValue("Bosses_RespawnDuration"), function()
		Events:Emit("bosses/respawn/" .. bossname)
		Bosses:SpawnBossUnit(bossname, unit.SpawnerEntity)
	end)
end

function Bosses:MakeBossAI(unit, name)
	unit:SetIdleAcquire(false)
	local aiTable = {
		leashRange = 1000,
	}
	local profile = "boss"
	if name == "freya" then
		local boss_freya_sharp_ice_shards = unit:FindAbilityByName("boss_freya_sharp_ice_shards")
		aiTable["abilityCastCallback"] = function(self)
			local unitsInRange = self:FindUnitsNearby(boss_freya_sharp_ice_shards:GetCastRange(unit:GetAbsOrigin(), nil) - 100, false, true, DOTA_UNIT_TARGET_HERO)
			if #unitsInRange > 0 then
				self:UseAbility(boss_freya_sharp_ice_shards)
			end
		end
		--[[aiTable["abilityCastCallback"] = function(self)
			local unitsInRange = self:FindUnitsNearby(boss_roshan_spikes:GetAbilitySpecial("length") - 200, false, true, DOTA_UNIT_TARGET_HERO)
			if #unitsInRange > 0 then
				local spikesTarget
				for _,v in ipairs(unitsInRange) do
					if v:GetHealth() <= boss_roshan_spikes:GetAbilityDamage() then
						spikesTarget = v
					end
				end
				if not spikesTarget then
					spikesTarget = unitsInRange[RandomInt(1, #unitsInRange)]
				end
				if spikesTarget then
					self:UseAbility(boss_roshan_spikes, spikesTarget:GetAbsOrigin())
				end
			end
		end]]
	elseif name == "kel_thuzad" then
		local boss_kel_thuzad_presence_of_death = unit:FindAbilityByName("boss_kel_thuzad_presence_of_death")
		local boss_kel_thuzad_invulnerability = unit:FindAbilityByName("boss_kel_thuzad_invulnerability")
		local boss_kel_thuzad_shadows = unit:FindAbilityByName("boss_kel_thuzad_shadows")
		local boss_kel_thuzad_summon_undead = unit:FindAbilityByName("boss_kel_thuzad_summon_undead")
		local boss_kel_thuzad_erebus = unit:FindAbilityByName("boss_kel_thuzad_erebus")
		aiTable["abilityCastCallback"] = function(self)
			if boss_kel_thuzad_invulnerability:IsFullyCastable() then
				--self:UseAbility(boss_kel_thuzad_invulnerability)
			end
			if boss_kel_thuzad_erebus:IsFullyCastable() then
				local unitsInRange = self:FindUnitsNearbyForAbility(boss_kel_thuzad_erebus)
				local stacks = self.unit:GetModifierStackCount("modifier_boss_kel_thuzad_immortality", self.unit)
				if #unitsInRange > 0 and stacks < 20 then
					self:UseAbility(boss_kel_thuzad_erebus)
				end
			end
			if boss_kel_thuzad_shadows:IsFullyCastable() then
				local unitsInRange = self:FindUnitsNearbyForAbility(boss_kel_thuzad_shadows)
				if #unitsInRange > 0 then
					self:UseAbility(boss_kel_thuzad_shadows)
				end
			end
			if boss_kel_thuzad_summon_undead:IsFullyCastable() then
				local unitsInRange = self:FindUnitsNearbyForAbility(boss_kel_thuzad_summon_undead)
				if #unitsInRange > 0 then
					self:UseAbility(boss_kel_thuzad_summon_undead)
				end
			end
			if boss_kel_thuzad_presence_of_death:IsFullyCastable() then
				local unitsInRange = self:FindUnitsNearbyForAbility(boss_kel_thuzad_presence_of_death)
				if #unitsInRange > 0 then
					self:UseAbility(boss_kel_thuzad_presence_of_death)
				end
			end
		end
	elseif name == "central" then
		profile = "tower"
	end
	local ai = SimpleAI:new(unit, profile, aiTable)
end
