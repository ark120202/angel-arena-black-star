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
					illusionAbility = illusion:AddNewAbility(newName)
				end
			else
				illusionAbility = illusion:AddNewAbility(newName)
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

function Illusions:_copyAppearance(unit, illusion)
	illusion:SetModelScale(unit:GetModelScale())
	-- TODO: Is it necessary only for illusions of non-hero units?
	if unit:GetModelName() ~= illusion:GetModelName() then
		illusion:SetModel(unit:GetModelName())
		illusion:SetOriginalModel(unit:GetModelName())
	end

	local rc = unit:GetRenderColor()
	if rc ~= Vector(255, 255, 255) then
		illusion:SetRenderColor(rc.x, rc.y, rc.z)
	end
end

function Illusions:_copyEverything(unit, illusion)
	Illusions:_copyAbilities(unit, illusion)
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

	return illusions
end
