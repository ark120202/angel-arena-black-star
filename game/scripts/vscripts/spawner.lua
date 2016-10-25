--Спавн крипов на точках. Всё сделано динамически, при добавлении нового стака просто нужно добавить настройки в константы.
LinkLuaModifier( "modifier_neutral_upgrade_attackspeed", "modifiers/modifier_neutral_upgrade_attackspeed", LUA_MODIFIER_MOTION_NONE )

if Spawner == nil then
	Spawner = class({})
	Spawner.Creeps = {}
end

function Spawner:GetSpawners()
	local spawners = {}
	for i,_ in pairs(SPAWNER_SETTINGS) do
		if i ~= "Cooldown" then
			table.insert(spawners, i)
		end
	end
	return spawners
end

function Spawner:GetSpawnerEntities()
	local targets = Entities:FindAllByClassname("info_target")
	local entities = {}
	for _,v in ipairs(targets) do
		if string.find(v:GetName(), "target_mark_spawner_") then
			table.insert(entities, v)
		end
	end
	return entities
end

function Spawner:RegisterTimers()
	local spawners = Spawner:GetSpawnerEntities()
	Timers:CreateTimer(function()
		Spawner.NextCreepsSpawnTime = Spawner.NextCreepsSpawnTime or 0
		if GameRules:GetDOTATime(false, false) >= Spawner.NextCreepsSpawnTime then
			Spawner.NextCreepsSpawnTime = Spawner.NextCreepsSpawnTime + SPAWNER_SETTINGS.Cooldown
			Spawner:SpawnStacks(spawners)
		end
		return 0.5
	end)
end

function Spawner:SpawnStacks(EntityTable)
	for _,entity in pairs(EntityTable) do
		local entname = entity:GetName()
		local sName = string.gsub(string.gsub(entname, "target_mark_spawner_", ""), "_type%d+", "")
		local SpawnerType = tonumber(string.sub(entname, string.find(entname, "_type") + 5))
		local entid = entity:GetEntityIndex()
		local coords = entity:GetAbsOrigin()
		if Spawner:CanSpawnUnits(sName, entid) then
			for i = 1, SPAWNER_SETTINGS[sName].SpawnedPerSpawn do
				local unitRootTable = SPAWNER_SETTINGS[sName].SpawnTypes[SpawnerType]
				local unitName = unitRootTable[1][-1]
				local unit = CreateUnitByName(unitName, coords, true, nil, nil, DOTA_TEAM_NEUTRALS)
				unit.SpawnerIndex = SpawnerType
				unit.SpawnerType = sName
				unit.SSpawner = entid
				unit.SLevel = GetDOTATimeInMinutesFull()
				Spawner.Creeps[entid] = Spawner.Creeps[entid] + 1
				Spawner:UpgradeCreep(unit, unit.SpawnerType, unit.SLevel, unit.SpawnerIndex)
			end
		end
	end
end

function Spawner:CanSpawnUnits(sName, id)
	Spawner:InitializeStack(id)
	if Spawner.Creeps[id] + SPAWNER_SETTINGS[sName].SpawnedPerSpawn <= SPAWNER_SETTINGS[sName].MaxUnits then
		return true
	else
		return false
	end
end

function Spawner:InitializeStack(id)
	if not Spawner.Creeps[id] then
		Spawner.Creeps[id] = 0
	end	
end

function Spawner:UpgradeCreep(unit, spawnerType, minutelevel, spawnerIndex)
	local modelScale = 1 + (0.01 * minutelevel)
	local goldbounty = 0
	local hp = 0
	local damage = 0
	local attackspeed = 0
	local movespeed = 0
	local armor = 0
	local xpbounty = 0
	if minutelevel > 1 then
		unit:CreatureLevelUp(minutelevel - 1)
	end
	if spawnerType == "easy" then
		if minutelevel <= 10 then
			goldbounty = 3 * minutelevel
			hp = 10 * minutelevel
			damage = 2.5 * minutelevel
			attackspeed = 0.30 * minutelevel
			movespeed = 0.30 * minutelevel
			armor = 0.30 * minutelevel
			xpbounty = 10 * minutelevel
		elseif minutelevel <= 20 then
			goldbounty = 3 * minutelevel
			hp = 20 * minutelevel
			damage = 7 * minutelevel
			attackspeed = 0.35 * minutelevel
			movespeed = 0.35 * minutelevel
			armor = 0.35 * minutelevel
			xpbounty = 50 * minutelevel
		elseif minutelevel <= 30 then
			goldbounty = 3 * minutelevel
			hp = 30 * minutelevel
			damage = 13 * minutelevel
			attackspeed = 0.40 * minutelevel
			movespeed = 0.40 * minutelevel
			armor = 0.40 * minutelevel
			xpbounty = 100 * minutelevel
		elseif minutelevel <= 60 then
			goldbounty = 2 * minutelevel
			hp = 35 * minutelevel
			damage = 14 * minutelevel
			attackspeed = 0.45 * minutelevel
			movespeed = 0.45 * minutelevel
			armor = 0.45 * minutelevel
			xpbounty = 150 * minutelevel
		else
			goldbounty = 3 * minutelevel
			hp = 56.5 * minutelevel
			damage = 15 * minutelevel
			attackspeed = 0.50 * minutelevel
			movespeed = 0.50 * minutelevel
			armor = 0.50 * minutelevel
			xpbounty = 250 * minutelevel
		end
	end
	if spawnerType == "medium" then
		if minutelevel <= 10 then
			goldbounty = 5 * minutelevel
			hp = 15 * minutelevel
			damage = 2.5 * minutelevel
			attackspeed = 0.70 * minutelevel
			movespeed = 0.70 * minutelevel
			armor = 0.70 * minutelevel
			xpbounty = 10 * minutelevel
		elseif minutelevel <= 20 then
			goldbounty = 17 * minutelevel
			hp = 110 * minutelevel
			damage = 9 * minutelevel
			attackspeed = 0.75 * minutelevel
			movespeed =0.75  * minutelevel
			armor = 0.75 * minutelevel
			xpbounty = 30 * minutelevel
		elseif minutelevel <= 30 then
			goldbounty = 30 * minutelevel
			hp = 240 * minutelevel
			damage = 14 * minutelevel
			attackspeed = 0.80 * minutelevel
			movespeed = 0.80 * minutelevel
			armor = 0.80 * minutelevel
			xpbounty = 60 * minutelevel
		elseif minutelevel <= 60 then
			goldbounty =  40 * minutelevel
			hp = 400 * minutelevel
			damage = 20 * minutelevel
			attackspeed = 0.85 * minutelevel
			movespeed = 0.85 * minutelevel
			armor = 0.85 * minutelevel
			xpbounty = 90 * minutelevel
		else
			goldbounty = 60 * minutelevel
			hp = 500 * minutelevel
			damage = 20 * minutelevel
			attackspeed = 0.90 * minutelevel
			movespeed = 0.90 * minutelevel
			armor = 0.90 * minutelevel
			xpbounty = 150 * minutelevel
		end
	end
	if spawnerType == "hard" then
		if minutelevel <= 10 then
			goldbounty = 5 * minutelevel
			hp = 15 * minutelevel
			damage = 10 * minutelevel
			attackspeed = 1 * minutelevel
			movespeed = 1 * minutelevel
			armor = 1 * minutelevel
			xpbounty = 10 * minutelevel
		elseif minutelevel <= 20 then
			goldbounty = 15 * minutelevel
			hp = 100 * minutelevel
			damage = 20 * minutelevel
			attackspeed = 1 * minutelevel
			movespeed = 1 * minutelevel
			armor = 1 * minutelevel
			xpbounty = 20 * minutelevel
		elseif minutelevel <= 30 then
			goldbounty = 40 * minutelevel
			hp = 280 * minutelevel
			damage = 30 * minutelevel
			attackspeed = 1 * minutelevel
			movespeed = 1 * minutelevel
			armor = 1 * minutelevel
			xpbounty = 40 * minutelevel
		elseif minutelevel <= 60 then
			goldbounty = 110 * minutelevel
			hp = 750 * minutelevel
			damage = 25 * minutelevel
			attackspeed = 1 * minutelevel
			movespeed = 1 * minutelevel
			armor = 1 * minutelevel
			xpbounty = 150 * minutelevel
		else
			goldbounty = 180 * minutelevel
			hp = 1500 * minutelevel
			damage = 50 * minutelevel
			attackspeed = 2 * minutelevel
			movespeed = 2 * minutelevel
			armor = 2 * minutelevel
			xpbounty = 250 * minutelevel
		end
	end
	unit:SetDeathXP(unit:GetDeathXP() + xpbounty)
	unit:SetMinimumGoldBounty(unit:GetMinimumGoldBounty() + goldbounty)
	unit:SetMaximumGoldBounty(unit:GetMaximumGoldBounty() + goldbounty)
	unit:SetMaxHealth(unit:GetMaxHealth() + hp)
	unit:SetBaseMaxHealth(unit:GetBaseMaxHealth() + hp)
	unit:SetHealth(unit:GetMaxHealth() + hp)
	unit:SetBaseDamageMin(unit:GetBaseDamageMin() + damage)
	unit:SetBaseDamageMax(unit:GetBaseDamageMax() + damage)
	unit:SetBaseMoveSpeed(unit:GetBaseMoveSpeed() + movespeed)
	unit:SetPhysicalArmorBaseValue(unit:GetPhysicalArmorBaseValue() + armor)
	
	unit:AddNewModifier(unit, nil, "modifier_neutral_upgrade_attackspeed", {})
	local modifier = unit:FindModifierByNameAndCaster("modifier_neutral_upgrade_attackspeed", unit)
	if modifier then
		modifier:SetStackCount(attackspeed)
	end
	unit:SetModelScale(modelScale)
	local model
	for i = minutelevel, 0, -1 do
		if SPAWNER_SETTINGS[spawnerType].SpawnTypes[spawnerIndex][1][i] then
			model = SPAWNER_SETTINGS[spawnerType].SpawnTypes[spawnerIndex][1][i]
			break
		end
	end
	if model then
		unit:SetModel(model)
		unit:SetOriginalModel(model)
	end
end