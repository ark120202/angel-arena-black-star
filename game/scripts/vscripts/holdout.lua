if Holdout == nil then
	_G.Holdout = class({})
	Holdout.Time = HOLDOUT_FIRST_WAVE_COOLDOWN
	Holdout.CurrentWave = 0
	Holdout.UnitLimit = 0
	Holdout.UnitsKilled = 0
end

function Holdout:Init()

end

function Holdout:Start()
	Timers:CreateTimer(function()
		return Holdout:Think()
	end)
end

function Holdout:Think()
	if Holdout.Time ~= -1 then
		Holdout.Time = Holdout.Time - 1
		PlayerTables:SetTableValue("arena", "holdout_timer", Holdout.Time)
	else
		PlayerTables:SetTableValue("arena", "holdout_killed_units", Holdout.UnitsKilled .. "/" .. Holdout.UnitLimit)
	end
	if Holdout.Time == 0 then
		Holdout.CurrentWave = Holdout.CurrentWave + 1
		local t = HOLDOUT_WAVE_DATA[Holdout.CurrentWave]
		if t then
			Holdout:StartWave(t)
		else
			Holdout:EndGame(true)
		end
	end
	return 1
end

function Holdout:StartWave(t)
	PlayerTables:SetTableValue("arena", "holdout_wave_num", Holdout.CurrentWave)

	Holdout.UnitLimit = 0
	Holdout:SpawnAllFromTable(Holdout.CurrentWave, t.units)
	Holdout.Time = -1
end

function Holdout:InitSettings()
	MAX_NUMBER_OF_TEAMS = 1
	USE_AUTOMATIC_PLAYERS_PER_TEAM = false
	for i = DOTA_TEAM_FIRST, DOTA_TEAM_CUSTOM_MAX do
		CUSTOM_TEAM_PLAYER_COUNT[i] = 0
	end
	CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_GOODGUYS] = 5
end

function Holdout:EndGame(win)
	if win then
		GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
	else
		GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
	end
end

function Holdout:SpawnAllFromTable(wave, t)
	for k,v in pairs(t) do
		for spawnPoint = 1, 4 do
			for i = 1, v do
				local u = CreateUnitByName(k, Entities:FindByName(nil, "target_mark_holdout_spawner_" .. spawnPoint):GetAbsOrigin(), true, nil, nil, DOTA_TEAM_BADGUYS)
				u.HoldoutSpawner = spawnPoint
				u.HoldoutWave = wave
				Holdout.UnitLimit = Holdout.UnitLimit + 1
				Holdout:AddAI(u)
			end
		end
	end
end

function Holdout:IsLastWave(wave)
	local nt = HOLDOUT_WAVE_DATA[(wave or Holdout.CurrentWave) + 1]
	return nt == nil
end

function Holdout:AddAI(unit)
	unit:SetIdleAcquire(false)
	local _aiTable = HOLDOUT_UNIT_AI[unit:GetUnitName()]
	local aiTable = {}
	if _aiTable.profile then
		table.merge(aiTable, HOLDOUT_AI_PROFILES[_aiTable.profile])
		table.merge(aiTable, _aiTable)
	end
	Holdout:LoadAIFromTable(unit, aiTable)
end

function Holdout:LoadAIFromTable(unit, aiTable)
	return SimpleAI:new(unit, "holdout_unit", aiTable)
end

function Holdout:EndWave()
	Holdout.Time = HOLDOUT_WAVE_COOLDOWN
end

function Holdout:RegisterKilledUnit(killedUnit)
	Holdout.UnitsKilled = Holdout.UnitsKilled + 1
	Holdout:Think()
	if Holdout.UnitsKilled >= Holdout.UnitLimit then
		Holdout:EndWave()
	end
end

Holdout:InitSettings()