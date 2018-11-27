local nativeTalents = {}
local skippedTalents = {}

local npc_heroes = LoadKeyValues("scripts/npc/npc_heroes.txt")
local npc_abilities = LoadKeyValues("scripts/npc/npc_abilities.txt")

local function addTalent(talentName, heroName)
	-- Get original value, before npc_abilities_override affection
	local originalValues = GetAbilitySpecial(talentName, nil, nil, npc_abilities[talentName])
	local newValues = GetAbilitySpecial(talentName)

	if NATIVE_TALENTS[talentName] ~= nil then
		if NATIVE_TALENTS[talentName] == false then
			skippedTalents[talentName] = true
		else
			nativeTalents[talentName] = table.merge({
				cost = 1,
				group = 1,
				icon = heroName,
				requirement = heroName,
				original_values = originalValues,
				special_values = newValues,
				effect = { abilities = talentName }
			}, NATIVE_TALENTS[talentName])
		end
	else
		print(talentName .. ": native talent is not defined in NATIVE_TALENTS")
	end
end

for heroName, heroData in pairs(npc_heroes) do
	local partiallyChanged = PARTIALLY_CHANGED_HEROES[heroName]
	local isChanged = GetKeyValue(heroName, "Changed") == 1 and not partiallyChanged
	if type(heroData) == "table" and not isChanged then
		for _,talentName in pairs(heroData) do
			if type(talentName) == "string" and string.starts(talentName, "special_bonus_unique_") then
				if not partiallyChanged or partiallyChanged[talentName] ~= true then
					addTalent(talentName, heroName)
				end
			end
		end
	end
end

for name, override in pairs(NATIVE_TALENTS) do
	if not nativeTalents[name] and not skippedTalents[name] then
		print(name .. ": presents in NATIVE_TALENTS but isn't a valid talent")
	end
end

for name in pairs(LoadKeyValues("scripts/npc/override/talents.txt")) do
	if not nativeTalents[name] then
		print(name .. ": presents in ability override but isn't a valid talent")
	end
end

return nativeTalents
