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
		local illusion_item = illusion:GetItemInSlot(slot)
		if illusion_item then
			illusion:RemoveItem(illusion_item)
		end
	end
	
	for slot = 0, 5 do		
		local item = unit:GetItemInSlot(slot)
		if item then
			local illusion_item = illusion:AddItem(CreateItem(item:GetName(), illusion, illusion))
			illusion_item:SetCurrentCharges(item:GetCurrentCharges())
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

local COPYABLE_BUFFS = {
	modifier_alchemist_chemical_rage = 1,
	modifier_arc_warden_tempest_double = 1,
	modifier_troll_warlord_berserkers_rage = 1,
	modifier_dragon_knight_dragon_form = 1,
	modifier_lone_druid_true_form = 1,
	modifier_terrorblade_metamorphosis_transform = 1,
	modifier_invoker_quas_instance = 1,
	modifier_invoker_wex_instance = 1,
	modifier_invoker_exort_instance = 1,
	modifier_undying_flesh_golem = 1,
	modifier_lycan_shapeshift = 1,
	modifier_apocalypse_apocalypse = 1,
	modifier_sai_release_of_forge = 1,
}

local illusion_getElaspedTime = function(self)
	return self:OldGetElaspedTime() + self.SourceElaspedTime
end

function Illusions:_copyBuffs(unit, illusion)
	for _, v in pairs(unit:FindAllModifiers()) do
		local buffName = v:GetName()
		local buffAbility = v:GetAbility()
		local buff_copyStatus = COPYABLE_BUFFS[buffName]
		if buff_copyStatus == 1 then
			local illuModifier = illusion:AddNewModifier(illusion, buffAbility, buffName, nil)
			illuModifier:SetStackCount(v:GetStackCount())
			--Trick ElaspedTime dependent buffs such as Apocalypse
			illuModifier.SourceElaspedTime = v:GetElapsedTime()
			illuModifier.OldGetElaspedTime = illuModifier.GetElapsedTime
			illuModifier.GetElapsedTime = illusion_getElaspedTime
		end
	end
end

function Illusions:create(info)
	local ability = info.ability
	local unit = info.unit
	local origin = info.origin or unit:GetAbsOrigin()
	local team = info.team or unit:GetTeamNumber()
	local isOwned = info.isOwned
	if isOwned == nil then isOwned = true end

	local illusion = CreateUnitByName(
		unit:GetUnitName(),
		origin,
		true,
		isOwned and unit or nil,
		isOwned and unit:GetPlayerOwner() or nil,
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
	Illusions:_copyBuffs(unit, illusion)

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
