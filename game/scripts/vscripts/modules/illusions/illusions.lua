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
		illusion.Additional_str = unit.Additional_str
	end
	if unit.Additional_agi then
		illusion:ModifyAgility(unit.Additional_agi)
		illusion.Additional_agi = unit.Additional_agi
	end
	if unit.Additional_int then
		illusion:ModifyIntellect(unit.Additional_int)
		illusion.Additional_int = unit.Additional_int
	end
	if unit.Additional_attackspeed then
		local modifier = illusion:FindModifierByName("modifier_item_shard_attackspeed_stack")
		if not modifier then
			modifier = illusion:AddNewModifier(caster, nil, "modifier_item_shard_attackspeed_stack", nil)
		end
		if modifier then
			modifier:SetStackCount(unit.Additional_attackspeed)
		end
		illusion.Additional_attackspeed = unit.Additional_attackspeed
	end
end

function Illusions:_copyLevel(unit, illusion)
	local level = unit:GetLevel()
	for i = 1, level - 1 do
		illusion:HeroLevelUp(false)
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

function Illusions:_copyEverything(unit, illusion)
	illusion:SetAbilityPoints(0)
	Illusions:_copyAbilities(unit, illusion)
	Illusions:_copyItems(unit, illusion)
	Illusions:_copyAppearance(unit, illusion)

	if unit.overrideUnitName then
		illusion:SetOverrideUnitName(unit.overrideUnitName)
	end

	local heroName = unit:GetFullName()
	if not NPC_HEROES[heroName] and NPC_HEROES_CUSTOM[heroName] then
		TransformUnitClass(illusion, NPC_HEROES_CUSTOM[heroName], true)
	end

	Illusions:_copyShards(unit, illusion)

	illusion:SetHealth(unit:GetHealth())
	illusion:SetMana(unit:GetMana())
end

function Illusions:create(info)
	local illusions = CreateIllusions(
		info.owner or info.unit,
		info.unit,
		{
			duration = info.duration,
			outgoing_damage = info.damageOutgoing - 100,
			incoming_damage = info.damageIncoming - 100,
		},
		info.count or 1,
		info.padding or 0,
		info.scramblePosition or false,
		true
	)

	for _, illusion in ipairs(illusions) do
		illusion.isCustomIllusion = true
	end

	return illusions
end
