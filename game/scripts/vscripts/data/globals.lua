if not Globals_Initialized then
	require("data/settings")
	Globals_Initialized = true
	HEROES_ON_DUEL = {}
	PLAYER_DATA = {[0] = {}, [1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {}, [6] = {}, [7] = {}, [8] = {}, [9] = {}, [10] = {}, [11] = {}, [12] = {}, [13] = {}, [14] = {}, [15] = {}, [16] = {}, [17] = {}, [18] = {}, [19] = {}, [20] = {}, [21] = {}, [22] = {}, [23] = {}}
	TEAMS_COURIERS = {}
	RANDOM_OMG_PRECACHED_HEROES = {}
	Timers:CreateTimer(0.03, function()
		GLOBAL_DUMMY = CreateUnitByName("npc_dummy_unit", Vector(0, 0, 0), false, nil, nil, DOTA_TEAM_NEUTRALS)
	end)
end
