NPC_HEROES_CUSTOM = LoadKeyValues("scripts/npc/npc_heroes_custom.txt")
table.deepmerge(NPC_HEROES_CUSTOM, LoadKeyValues("scripts/npc/heroes/new.txt"))
NPC_HEROES = LoadKeyValues("scripts/npc/npc_heroes.txt")
ENABLED_HEROES = LoadKeyValues("scripts/npc/custom_herolist.txt")
