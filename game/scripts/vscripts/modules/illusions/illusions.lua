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
	local rc = unit:GetRenderColor()
	if rc ~= Vector(255, 255, 255) then
		illusion:SetRenderColor(rc.x, rc.y, rc.z)
	end
end

local COPYABLE_BUFFS = {
	modifier_alchemist_chemical_rage = true,
	modifier_arc_warden_tempest_double = true,
	modifier_troll_warlord_berserkers_rage = true,
	modifier_dragon_knight_dragon_form = true,
	modifier_lone_druid_true_form = true,
	modifier_morphling_morph = true,
	modifier_terrorblade_metamorphosis_transform = true,
	modifier_invoker_quas_instance = true,
	modifier_invoker_wex_instance = true,
	modifier_invoker_exort_instance = true,
	modifier_undying_flesh_golem = true,
	modifier_lycan_shapeshift = true,
	modifier_apocalypse_apocalypse = true,
	modifier_sai_release_of_forge = true,
	modifier_item_armlet_unholy_strength = true,
	modifier_item_moon_shard_consumed = true,
}

--Trick ElaspedTime dependent buffs such as Apocalypse
CDOTA_Buff.SourceElaspedTime = 0
CDOTA_Buff.OldGetElaspedTime = CDOTA_Buff.OldGetElaspedTime or CDOTA_Buff.GetElapsedTime
CDOTA_Buff.GetElapsedTime = function(self)
	return self:OldGetElaspedTime() + self.SourceElaspedTime
end

function Illusions:_copyBuffs(unit, illusion)
	for _, v in pairs(unit:FindAllModifiers()) do
		local buffName = v:GetName()
		local buffAbility = v:GetAbility()
		if COPYABLE_BUFFS[buffName] then
			local illuModifier = illusion:AddNewModifier(illusion, buffAbility, buffName, nil)
			illuModifier:SetStackCount(v:GetStackCount())
			--Trick ElaspedTime dependent buffs such as Apocalypse
			illuModifier.SourceElaspedTime = v:GetElapsedTime()
			--Hack for Morphling
			if buffName == "modifier_morphling_morph" then
				illusion:SetBaseStrength(unit:GetBaseStrength() - (unit.Additional_str or 0))
				illusion:SetBaseAgility(unit:GetBaseAgility() - (unit.Additional_agi or 0))
			end
		end
	end
end

function Illusions:_copyEverything(unit, illusion)
	illusion:SetAbilityPoints(0)
	Illusions:_copyAbilities(unit, illusion)
	Illusions:_copyItems(unit, illusion)
	Illusions:_copyAppearance(unit, illusion)
	Illusions:_copyBuffs(unit, illusion)
	illusion.UnitName = unit.UnitName
	local heroName = unit:GetFullName()
	if not NPC_HEROES[heroName] and NPC_HEROES_CUSTOM[heroName] then
		TransformUnitClass(illusion, NPC_HEROES_CUSTOM[heroName], true)
	end

	Illusions:_copyShards(unit, illusion)
	illusion:SetNetworkableEntityInfo("unit_name", illusion:GetFullName())

	illusion:SetHealth(unit:GetHealth())
	illusion:SetMana(unit:GetMana())
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

	illusion.isCustomIllusion = true
	illusion:AddNewModifier(unit, ability, "modifier_illusion", {
		duration = info.duration,
		outgoing_damage = info.damageOutgoing - 100,
		incoming_damage = info.damageIncoming - 100,
	})
	illusion:MakeIllusion()

	return illusion
end
