HEROES_ON_DUEL = HEROES_ON_DUEL or {}
PLAYER_DATA = PLAYER_DATA or {[0] = {}, [1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {}, [6] = {}, [7] = {}, [8] = {}, [9] = {}, [10] = {}, [11] = {}, [12] = {}, [13] = {}, [14] = {}, [15] = {}, [16] = {}, [17] = {}, [18] = {}, [19] = {}, [20] = {}, [21] = {}, [22] = {}, [23] = {}}
TEAMS_COURIERS = TEAMS_COURIERS or {}
RANDOM_OMG_PRECACHED_HEROES = RANDOM_OMG_PRECACHED_HEROES or {}
Timers:CreateTimer(0.03, function()
	GLOBAL_DUMMY = GLOBAL_DUMMY or CreateUnitByName("npc_dummy_unit", Vector(0, 0, 0), false, nil, nil, DOTA_TEAM_NEUTRALS)
end)

XP_PER_LEVEL_TABLE = { 0 }
for i = 2, 600 do
	XP_PER_LEVEL_TABLE[i] = XP_PER_LEVEL_TABLE[i-1] + i * 100
end
