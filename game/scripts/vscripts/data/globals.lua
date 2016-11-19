if not Globals_Initialized then
	Globals_Initialized = true

	ANY_HERO_IN_GAME = false
	IS_RIVER_BURNED = false
	Heroes_In_BurnedRiver_Zone = {}
	Heroes_In_Arena_Zone = {}
	Heroes_In_Shop_Zone = {}
	PLAYER_DATA = {[0] = {}, [1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {}, [6] = {}, [7] = {}, [8] = {}, [9] = {}, [10] = {}, [11] = {}, [12] = {}, [13] = {}, [14] = {}, [15] = {}, [16] = {}, [17] = {}, [18] = {}, [19] = {}, [20] = {}, [21] = {}, [22] = {}, [23] = {}}
	TEAMS_COURIERS = {}
	RANDOM_OMG_PRECACHED_HEROES = {}
	CourierTimer = {}
	DemonKingBarTimers = {}
	--GameMode._AsyncFunctionHandler = {}
	Timers:CreateTimer(0.03, function()
		GLOBAL_DUMMY = CreateUnitByName("npc_dummy_unit", Vector(0, 0, 0), false, nil, nil, DOTA_TEAM_NEUTRALS)
		DRUG_DUMMY = CreateUnitByName("npc_dummy_unit", Vector(0, 0, 0), false, nil, nil, DOTA_TEAM_NEUTRALS)
	end)
end