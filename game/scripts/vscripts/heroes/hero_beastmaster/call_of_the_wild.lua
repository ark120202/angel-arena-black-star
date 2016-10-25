function SpawnUnit(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local level = ability:GetLevel() - 1
	local boar_duration = ability:GetLevelSpecialValueFor("boar_duration", level)
	local spawnLoc = caster:GetAbsOrigin() + caster:GetForwardVector() * ability:GetLevelSpecialValueFor("distance", level)
	for i = 1, ability:GetLevelSpecialValueFor("unit_count", level) do
		local unit = CreateUnitByName(keys.UnitName, spawnLoc, true , caster, nil, caster:GetTeamNumber())
		unit:AddNewModifier(caster, ability, "modifier_kill", {duration = boar_duration})
		unit:SetControllableByPlayer(caster:GetPlayerID(), true)
		unit:SetOwner(caster)
		FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
		ability:ApplyDataDrivenModifier(caster, unit, keys.modifier, {})
		unit:SetForwardVector(caster:GetForwardVector())

		local ab = unit:FindAbilityByName("beastmaster_boar_poison")
		if ab then
			ab:SetLevel(ability:GetLevel())
		end
		if keys.InvisibilityLevel and ability:GetLevel() >= keys.InvisibilityLevel then
			local ab = unit:AddAbility("beastmaster_hawk_invisibility")
			if ab then
				ab:SetLevel(ability:GetLevel())
			end
		end
		if keys.hp then
			unit:SetMaxHealth(keys.hp)
			unit:SetHealth(keys.hp)
			Timers:CreateTimer(function()
				unit:SetMaxHealth(keys.hp)
				unit:SetHealth(keys.hp)
			end)
		end
		if keys.speed then unit:SetBaseMoveSpeed(keys.speed) end
		if keys.daysight then unit:SetDayTimeVisionRange(keys.daysight) end
		if keys.nightsight then unit:SetNightTimeVisionRange(keys.nightsight) end
		if keys.damage then
			unit:SetBaseDamageMin(keys.damage)
			unit:SetBaseDamageMax(keys.damage)
		end
	end
end

--[[
	Author: Noya
	Date: 16.01.2015.
	Levels up the ability_name to the same level of the ability that runs this
]]
function LevelUpAbility( event )
	local caster = event.caster
	local this_ability = event.ability		
	local this_abilityName = this_ability:GetAbilityName()
	local this_abilityLevel = this_ability:GetLevel()

	-- The ability to level up
	local ability_name = event.ability_name
	local ability_handle = caster:FindAbilityByName(ability_name)	
	local ability_level = ability_handle:GetLevel()

	-- Check to not enter a level up loop
	if ability_level ~= this_abilityLevel then
		ability_handle:SetLevel(this_abilityLevel)
	end
end