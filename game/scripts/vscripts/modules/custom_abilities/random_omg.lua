function CustomAbilities:RandomOMGRollAbilities(unit)
	if Options:IsEquals("EnableRandomAbilities") then
		local ability_count = 6
		local ultimate_count = 2
		for i = 0, unit:GetAbilityCount() - 1 do
			local ability = unit:GetAbilityByIndex(i)
			if ability then
				for _,v in ipairs(unit:FindAllModifiers()) do
					if v:GetAbility() and v:GetAbility() == ability then
						v:Destroy()
					end
				end
				unit:RemoveAbility(ability:GetName())
			end
		end

		local has_abilities = 0
		while has_abilities < ability_count - ultimate_count do
			if CustomAbilities:GiveRandomOMGAbility(unit, CustomAbilities.RandomOMG.Abilities) then
				has_abilities = has_abilities + 1
			end
		end
		local has_ultimates = 0
		while has_ultimates < ultimate_count do
			if CustomAbilities:GiveRandomOMGAbility(unit, CustomAbilities.RandomOMG.Ultimates) then
				has_ultimates = has_ultimates + 1
			end
		end
		unit:ResetAbilityPoints()
	end
end

function CustomAbilities:GiveRandomOMGAbility(unit, abilityList)
	local abilityTable = abilityList[RandomInt(1, #abilityList)]
	local abilityName = abilityTable.ability
	if not abilityName or unit:HasAbility(abilityName) then
		return false
	end
	PrecacheItemByNameAsync(abilityName, function() end)
	GameMode:PrecacheUnitQueueed(abilityTable.hero)

	local ability = self:AddNewAbility(abilityName)
	for _,link in ipairs(LINKED_ABILITIES[abilityName] or {}) do
		self:AddNewAbility(link)
	end

	return true
end
