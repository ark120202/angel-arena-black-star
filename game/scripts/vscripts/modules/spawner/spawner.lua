-- TODO: Refactor this

ModuleRequire(..., "data")
ModuleLinkLuaModifier(..., "modifier_neutral_upgrade_attackspeed")
ModuleLinkLuaModifier(..., "modifier_neutral_champion")

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
	Spawner:MakeJungleStacks()
end

function Spawner:SpawnStacks()
	for _,entity in ipairs(Spawner.SpawnerEntities) do
		DynamicMinimap:SetVisibleGlobal(Spawner.MinimapPoints[entity], true)
		local entname = entity:GetName()
		local sName = string.gsub(string.gsub(entname, "target_mark_spawner_", ""), "_type%d+", "")
		local SpawnerType = tonumber(string.sub(entname, string.find(entname, "_type") + 5))
		local entid = entity:GetEntityIndex()
		local coords = entity:GetAbsOrigin()
		if sName ~= "jungle" and Spawner:CanSpawnUnits(sName, entid) then
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
	if minutelevel > 1 then
		unit:CreatureLevelUp(minutelevel - 1)
	end

	local goldbounty, hp, damage, attackspeed, movespeed, armor, xpbounty, customCalculate = unpack(table.nearestOrLowerKey(CREEP_UPGRADE_FUNCTIONS[spawnerType], minutelevel))
	if not customCalculate then
		goldbounty, hp, damage, attackspeed, movespeed, armor, xpbounty = goldbounty * minutelevel, hp * minutelevel, damage * minutelevel, attackspeed * minutelevel, movespeed * minutelevel, armor * minutelevel, xpbounty * minutelevel
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

function Spawner:OnCreepDeath(unit)
	Spawner.Creeps[unit.SSpawner] = Spawner.Creeps[unit.SSpawner] - 1
	if unit.SpawnerType == "jungle" then
		Spawner:SpawnJungleStacks(unit.SSpawner, unit.SpawnerIndex, unit.SpawnerType)
	end
end

function Spawner:MakeJungleStacks()
	for _,entity in ipairs(Spawner.SpawnerEntities) do
		DynamicMinimap:SetVisibleGlobal(Spawner.MinimapPoints[entity], true)
		local entname = entity:GetName()
		local sName = string.gsub(string.gsub(entname, "target_mark_spawner_", ""), "_type%d+", "")
		if sName == "jungle" then
			local SpawnerType = tonumber(string.sub(entname, string.find(entname, "_type") + 5))
			local entid = entity:GetEntityIndex()
			local coords = entity:GetAbsOrigin()

			Spawner:InitializeStack(entid)
			Spawner:SpawnJungleStacks(entid, SpawnerType, sName)
		end
	end
end

function Spawner:SpawnJungleStacks(entid, SpawnerType, sName)
	if Spawner.Creeps[entid] > 0 then return end

	local entity = EntIndexToHScript(entid)
	entity.cycle = (entity.cycle or 0) + 1

	DynamicMinimap:SetVisibleGlobal(Spawner.MinimapPoints[entity], true)
	local coords = entity:GetAbsOrigin()
	for i = 1, SPAWNER_SETTINGS[sName].SpawnedPerSpawn do
		local unitRootTable = SPAWNER_SETTINGS[sName].SpawnTypes[SpawnerType]
		local unitName = unitRootTable[1][-1]
		local unit = CreateUnitByName(unitName, coords, true, nil, nil, DOTA_TEAM_NEUTRALS)
		unit.SpawnerIndex = SpawnerType
		unit.SpawnerType = sName
		unit.SSpawner = entid
		unit.SLevel = entity.cycle
		Spawner.Creeps[entid] = Spawner.Creeps[entid] + 1
		Spawner:UpgradeJungleCreep(unit, unit.SLevel, unit.SpawnerIndex)
	end
end

function Spawner:UpgradeJungleCreep(unit, cycle, spawnerIndex)
	local modelScale = 1 + (0.005 * cycle)
	if cycle > 1 then
		unit:CreatureLevelUp(cycle - 1)
	end

	unit:SetDeathXP(unit:GetDeathXP() * cycle)
	unit:SetMinimumGoldBounty(unit:GetMinimumGoldBounty() * cycle)
	unit:SetMaximumGoldBounty(unit:GetMaximumGoldBounty() * cycle)
	unit:SetMaxHealth(unit:GetMaxHealth() * cycle)
	unit:SetBaseMaxHealth(unit:GetBaseMaxHealth() * cycle)
	unit:SetHealth(unit:GetMaxHealth() * cycle)
	unit:SetBaseDamageMin(unit:GetBaseDamageMin() * cycle)
	unit:SetBaseDamageMax(unit:GetBaseDamageMax() * cycle)
	unit:SetBaseMoveSpeed(unit:GetBaseMoveSpeed() + 10 * cycle)
	unit:SetPhysicalArmorBaseValue(unit:GetPhysicalArmorBaseValue() * cycle)
	unit:AddNewModifier(unit, nil, "modifier_neutral_upgrade_attackspeed", {})
	local modifier = unit:FindModifierByNameAndCaster("modifier_neutral_upgrade_attackspeed", unit)
	if modifier then
		modifier:SetStackCount(cycle)
	end

	unit:SetModelScale(modelScale)
	local model = table.nearestOrLowerKey(SPAWNER_SETTINGS.jungle.SpawnTypes[spawnerIndex][1], cycle)
	if model then
		unit:SetModel(model)
		unit:SetOriginalModel(model)
	end
end
