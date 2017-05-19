LinkLuaModifier( "modifier_neutral_upgrade_attackspeed", "modifiers/modifier_neutral_upgrade_attackspeed", LUA_MODIFIER_MOTION_NONE )

if Spawner == nil then
	Spawner = class({})
	Spawner.SpawnerEntities = {}
	Spawner.Creeps = {}
	Spawner.MinimapPoints = {}
	Spawner.NextCreepsSpawnTime = 0
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

function Spawner:PreloadSpawners()
	local targets = Entities:FindAllByClassname("info_target")
	for _,v in ipairs(targets) do
		local entname = v:GetName()
		if string.find(entname, "target_mark_spawner_") then
			Spawner.MinimapPoints[v] = DynamicMinimap:CreateMinimapPoint(v:GetAbsOrigin(), "icon_spawner icon_spawner_" .. string.gsub(string.gsub(entname, "target_mark_spawner_", ""), "_type%d+", ""))
			table.insert(Spawner.SpawnerEntities, v)
		end
	end
end

function Spawner:RegisterTimers()
	Timers:CreateTimer(function()
		if GameRules:GetDOTATime(false, false) >= Spawner.NextCreepsSpawnTime then
			Spawner.NextCreepsSpawnTime = Spawner.NextCreepsSpawnTime + SPAWNER_SETTINGS.Cooldown * (Spawner.NextCreepsSpawnTime == 0 and 2 or 1)
			Spawner:SpawnStacks()
		end
		return 0.5
	end)
end

function Spawner:SpawnStacks()
	for _,entity in ipairs(Spawner.SpawnerEntities) do
		DynamicMinimap:SetVisibleGlobal(Spawner.MinimapPoints[entity], true)
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
	return Spawner.Creeps[id] + SPAWNER_SETTINGS[sName].SpawnedPerSpawn <= SPAWNER_SETTINGS[sName].MaxUnits
end

function Spawner:InitializeStack(id)
	if not Spawner.Creeps[id] then
		Spawner.Creeps[id] = 0
	end	
end

function Spawner:RollChampion(minute)
	local champLevel = 1
	for level, info in pairs(SPAWNER_CHAMPION_LEVELS) do
		if minute > info.minute and RollPercentage(info.chance) then
			champLevel = math.max(champLevel, level)
		end
	end
	return champLevel
end

function CDOTA_BaseNPC:IsChampion()
	return self.IsChampionNeutral == true
end

CDOTA_BaseNPC_Creature.IsChampion = CDOTA_BaseNPC.IsChampion

function Spawner:UpgradeCreep(unit, spawnerType, minutelevel, spawnerIndex)
	local modelScale = 1 + (0.005 * minutelevel)
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
			goldbounty = 15 * minutelevel
			hp = 38 * minutelevel
			damage = 1.9 * minutelevel
			attackspeed = 5 * minutelevel
			movespeed = 0.8 * minutelevel
			armor = 1.0 * minutelevel
			xpbounty = 15 * minutelevel
		elseif minutelevel <= 20 then
			goldbounty = 4 * minutelevel
			hp = 38 * minutelevel
			damage = 4 * minutelevel
			attackspeed = 5 * minutelevel
			movespeed = 1.0 * minutelevel
			armor = 1.5 * minutelevel
			xpbounty = 25 * minutelevel
		elseif minutelevel <= 30 then
			goldbounty = 3 * minutelevel
			hp = 35 * minutelevel
			damage = 12 * minutelevel
			attackspeed = 0.40 * minutelevel
			movespeed = 1.3 * minutelevel
			armor = 1 * minutelevel
			xpbounty = 70 * minutelevel
		elseif minutelevel <= 60 then
			goldbounty = 2 * minutelevel
			hp = 85 * minutelevel
			damage = 13 * minutelevel
			attackspeed = 0.45 * minutelevel
			movespeed = 0.45 * minutelevel
			armor = 0.45 * minutelevel
			xpbounty = 140 * minutelevel
		else
			goldbounty = 3 * minutelevel
			hp = 120.5 * minutelevel
			damage = 20 * minutelevel
			attackspeed = 0.50 * minutelevel
			movespeed = 0.50 * minutelevel
			armor = 0.50 * minutelevel
			xpbounty = 200 * minutelevel
		end
	elseif spawnerType == "medium" then
		if minutelevel <= 10 then
			goldbounty = 10 * minutelevel
			hp = 55 * minutelevel
			damage = 2.0 * minutelevel
			attackspeed = 2 * minutelevel
			movespeed = 25 * minutelevel
			armor = 1 * minutelevel
			xpbounty = 8 * minutelevel
		elseif minutelevel <= 20 then
			goldbounty = 13 * minutelevel
			hp = 135 * minutelevel
			damage = 6 * minutelevel
			attackspeed = 0.9 * minutelevel
			movespeed = 25  * minutelevel
			armor = 1.5 * minutelevel
			xpbounty = 16 * minutelevel
		elseif minutelevel <= 30 then
			goldbounty = 30 * minutelevel
			hp = 248 * minutelevel
			damage = 11 * minutelevel
			attackspeed = 1.5 * minutelevel
			movespeed = 25 * minutelevel
			armor = 4 * minutelevel
			xpbounty = 30 * minutelevel
		elseif minutelevel <= 60 then
			goldbounty =  40 * minutelevel
			hp = 400 * minutelevel
			damage = 20 * minutelevel
			attackspeed = 0.85 * minutelevel
			movespeed = 25 * minutelevel
			armor = 5 * minutelevel
			xpbounty = 100 * minutelevel
		else
			goldbounty = 60 * minutelevel
			hp = 500 * minutelevel
			damage = 20 * minutelevel
			attackspeed = 0.90 * minutelevel
			movespeed = 25 * minutelevel
			armor = 6 * minutelevel
			xpbounty = 150 * minutelevel
		end
	elseif spawnerType == "hard" then
		if minutelevel <= 10 then
			goldbounty = 1.1 * minutelevel
			hp = 55 * minutelevel
			damage = 2.3 * minutelevel
			attackspeed = 10 * minutelevel
			movespeed = 65 * minutelevel
			armor = 4.5 * minutelevel
			xpbounty = 20 * minutelevel
		elseif minutelevel <= 20 then
			goldbounty = 13 * minutelevel
			hp = 115 * minutelevel
			damage = 11 * minutelevel
			attackspeed = 1 * minutelevel
			movespeed = 25 * minutelevel
			armor = 3.0 * minutelevel
			xpbounty = 60 * minutelevel
		elseif minutelevel <= 30 then
			goldbounty = 40 * minutelevel
			hp = 350 * minutelevel
			damage = 25 * minutelevel
			attackspeed = 1 * minutelevel
			movespeed = 25 * minutelevel
			armor = 4.0 * minutelevel
			xpbounty = 120 * minutelevel
		elseif minutelevel <= 60 then
			goldbounty = 110 * minutelevel
			hp = 750 * minutelevel
			damage = 25 * minutelevel
			attackspeed = 1 * minutelevel
			movespeed = 25 * minutelevel
			armor = 2 * minutelevel
			xpbounty = 150 * minutelevel
		else
			goldbounty = 180 * minutelevel
			hp = 1500 * minutelevel
			damage = 50 * minutelevel
			attackspeed = 2 * minutelevel
			movespeed = 25 * minutelevel
			armor = 6 * minutelevel
			xpbounty = 250 * minutelevel
		end
	end
	local champLevel = Spawner:RollChampion(minutelevel)
	if champLevel > 1 then
		--print("Spawn champion with level " .. champLevel)
		modelScale = modelScale + SPAWNER_CHAMPION_LEVELS[champLevel].model_scale
		unit:SetRenderColor(RandomInt(0, 255), RandomInt(0, 255), RandomInt(0, 255))
		unit:AddNewModifier(unit, nil, "modifier_neutral_champion", nil):SetStackCount(champLevel)
		unit.IsChampionNeutral = true
	end
	unit:SetDeathXP((unit:GetDeathXP() + xpbounty) * champLevel)
	unit:SetMinimumGoldBounty((unit:GetMinimumGoldBounty() + goldbounty) * champLevel)
	unit:SetMaximumGoldBounty((unit:GetMaximumGoldBounty() + goldbounty) * champLevel)
	unit:SetMaxHealth((unit:GetMaxHealth() + hp) * champLevel)
	unit:SetBaseMaxHealth((unit:GetBaseMaxHealth() + hp) * champLevel)
	unit:SetHealth((unit:GetMaxHealth() + hp) * champLevel)
	unit:SetBaseDamageMin((unit:GetBaseDamageMin() + damage) * champLevel)
	unit:SetBaseDamageMax((unit:GetBaseDamageMax() + damage) * champLevel)
	unit:SetBaseMoveSpeed((unit:GetBaseMoveSpeed() + movespeed) * champLevel)
	unit:SetPhysicalArmorBaseValue((unit:GetPhysicalArmorBaseValue() + armor) * champLevel)
	
	unit:AddNewModifier(unit, nil, "modifier_neutral_upgrade_attackspeed", {})
	local modifier = unit:FindModifierByNameAndCaster("modifier_neutral_upgrade_attackspeed", unit)
	if modifier then
		modifier:SetStackCount(attackspeed * champLevel)
	end
	unit:SetModelScale(modelScale)
	local model = table.nearestOrLowerKey(SPAWNER_SETTINGS[spawnerType].SpawnTypes[spawnerIndex][1], minutelevel)
	if model then
		unit:SetModel(model)
		unit:SetOriginalModel(model)
	end
end