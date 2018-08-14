Illusions = Illusions or {}

function Illusions:_copyAbilities(unit, illusion)
	for slot = 0, unit:GetAbilityCount() - 1 do
		local illusionAbility = illusion:GetAbilityByIndex(slot)
		local unitAbility = unit:GetAbilityByIndex(slot)

		if unitAbility then
			local newName = unitAbility:GetAbilityName()
			if illusionAbility then
				if illusionAbility:GetAbilityName() ~= newName then
					illusion:RemoveAbility(illusionAbility:GetAbilityName())
					illusionAbility = illusion:AddNewAbility(newName, true)
				end
			else
				illusionAbility = illusion:AddNewAbility(newName, true)
			end
			illusionAbility:SetHidden(unitAbility:IsHidden())
			local ualevel = unitAbility:GetLevel()
			if ualevel > 0 and illusionAbility:GetAbilityName() ~= "meepo_divided_we_stand" then
				illusionAbility:SetLevel(ualevel)
			end
		elseif illusionAbility then
			illusion:RemoveAbility(illusionAbility:GetAbilityName())
		end
	end
end

function Illusions:_copyItems(unit, illusion)
	for slot = 0, 5 do
		local illusionItem = illusion:GetItemInSlot(slot)
		if illusionItem then
			illusion:RemoveItem(illusionItem)
		end
	end

	for slot = 0, 5 do
		local item = unit:GetItemInSlot(slot)
		if item then
			local illusionItem = CreateItem(item:GetName(), illusion, illusion)
			illusionItem:SetCurrentCharges(item:GetCurrentCharges())
			illusionItem.suggestedSlot = slot
			illusion:AddItem(illusionItem)
		end
	end
end

function Illusions:_copyShards(unit, illusion)
	if unit.Additional_str then
		illusion:ModifyStrength(unit.Additional_str)
	end
	if unit.Additional_agi then
		illusion:ModifyAgility(unit.Additional_agi)
	end
	if unit.Additional_int then
		illusion:ModifyIntellect(unit.Additional_int)
	end
	if unit.Additional_attackspeed then
		local modifier = illusion:FindModifierByName("modifier_item_shard_attackspeed_stack")
		if not modifier then
			modifier = illusion:AddNewModifier(caster, nil, "modifier_item_shard_attackspeed_stack", nil)
		end
		if modifier then
			modifier:SetStackCount(unit.Additional_attackspeed)
		end
	end
end

function Illusions:_copyLevel(unit, illusion)
	local level = unit:GetLevel()
	for i = 1, level - 1 do
		illusion:HeroLevelUp(false)
	end
end

function Illusions:_copySpecialCustomFields(unit, illusion)
	if unit.GetEnergy and unit.GetMaxEnergy then
		illusion.SavedEnergyStates = {
			Energy = unit:GetEnergy(),
			MaxEnergy = unit:GetMaxEnergy()
		}
	end
end

function Illusions:_copyAppearance(unit, illusion)
	illusion:SetModelScale(unit:GetModelScale())
	if unit:GetModelName() ~= illusion:GetModelName() then
		illusion.ModelOverride = unit:GetModelName()
		illusion:SetModel(illusion.ModelOverride)
		illusion:SetOriginalModel(illusion.ModelOverride)
	end
	local rc = unit:GetRenderColor()
	if rc ~= Vector(255, 255, 255) then
		illusion:SetRenderColor(rc.x, rc.y, rc.z)
	end
end

function Illusions:create(info)
	local ability = info.ability
	local unit = info.unit
	local origin = info.origin or unit:GetAbsOrigin()
	local team = info.team or unit:GetTeamNumber()
	local isOwned = info.isOwned
	if isOwned == nil then isOwned = true end

	local source = unit
	local replicateModifier = unit:FindModifierByName("modifier_morphling_replicate")
	if replicateModifier then
		source = replicateModifier:GetCaster()
	end

	local illusion = CreateUnitByName(
		source:GetUnitName(),
		origin,
		true,
		isOwned and unit or nil,
		isOwned and source:GetPlayerOwner() or nil,
		team
	)
	if isOwned then illusion:SetControllableByPlayer(unit:GetPlayerID(), true) end
	FindClearSpaceForUnit(illusion, origin, true)
	illusion:SetForwardVector(unit:GetForwardVector())

	Illusions:_copyLevel(unit, illusion)
	illusion:SetAbilityPoints(0)
	Illusions:_copySpecialCustomFields(unit, illusion)
	Illusions:_copyAbilities(unit, illusion)
	Illusions:_copyItems(unit, illusion)
	Illusions:_copyAppearance(unit, illusion)

	illusion:SetHealth(unit:GetHealth())
	illusion:SetMana(unit:GetMana())
	illusion:AddNewModifier(unit, ability, "modifier_illusion", {
		duration = info.duration,
		outgoing_damage = info.damageOutgoing - 100,
		incoming_damage = info.damageIncoming - 100,
	})
	illusion:MakeIllusion()
	Illusions:_copyShards(unit, illusion)
	illusion.UnitName = unit.UnitName
	illusion:SetNetworkableEntityInfo("unit_name", illusion:GetFullName())
	local heroName = unit:GetFullName()
	if not NPC_HEROES[heroName] and NPC_HEROES_CUSTOM[heroName] then
		TransformUnitClass(illusion, NPC_HEROES_CUSTOM[heroName], true)
	end

	return illusion
end
