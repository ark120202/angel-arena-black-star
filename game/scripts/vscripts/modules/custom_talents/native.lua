local nativeTalents = {}

local npc_heroes = LoadKeyValues("scripts/npc/npc_heroes.txt")
local npc_abilities = LoadKeyValues("scripts/npc/npc_abilities.txt")

local function addTalent(talentName, heroName)
	-- Get original value, before npc_abilities_override affection
	local originalValues = GetAbilitySpecial(talentName, nil, nil, npc_abilities[talentName])
	local newValues = GetAbilitySpecial(talentName)
	nativeTalents[talentName] = {
		cost = 1,
		group = 1,
		icon = heroName,
		requirement = heroName,
		original_values = originalValues,
		special_values = newValues,
		effect = { abilities = talentName }
	}
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

return nativeTalents
