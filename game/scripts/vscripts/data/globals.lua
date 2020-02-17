HEROES_ON_DUEL = HEROES_ON_DUEL or {}
PLAYER_DATA = PLAYER_DATA or {[0] = {}, [1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {}, [6] = {}, [7] = {}, [8] = {}, [9] = {}, [10] = {}, [11] = {}, [12] = {}, [13] = {}, [14] = {}, [15] = {}, [16] = {}, [17] = {}, [18] = {}, [19] = {}, [20] = {}, [21] = {}, [22] = {}, [23] = {}}
RANDOM_OMG_PRECACHED_HEROES = RANDOM_OMG_PRECACHED_HEROES or {}

XP_PER_LEVEL_TABLE = { 0 }
for i = 2, 600 do
	XP_PER_LEVEL_TABLE[i] = XP_PER_LEVEL_TABLE[i-1] + i * 100
end
