--[[
	Author: Ractidous, with help from Noya
	Date: 03.02.2015.
	Initialize the slowed units list, and let the caster latch.
	We also need to track the health/mana, in order to grab amount gained of health/mana in the future.
]]
function CastTether( event )
	-- Variables
	local caster = event.caster
	local ability = event.ability
	local target = event.target
	local PlayerID = UnitVarToPlayerID(caster)

	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, ability:GetLevelSpecialValueFor("radius", ability:GetLevel() - 1), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_CLOSEST, false)

	TrackCurrentHealth(event)
	TrackCurrentMana(event)
	local checkAndApply = function(unit)
		if not unit:IsIllusion() and unit:IsRealHero() and unit ~= caster and UnitFilter(unit, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, caster:GetTeam()) == UF_SUCCESS and not PlayerResource:IsDisableHelpSetForPlayerID(UnitVarToPlayerID(unit), PlayerID) then
			ability:ApplyDataDrivenModifier(caster, unit, "modifier_tether_ally_aghanims", {})
			table.insert(ability.tether_allies, unit)
		end
	end
	ability.tether_allies = {}
	if caster:HasScepter() then
		for _,v in ipairs(targets) do
			checkAndApply(v)
		end
	else
		checkAndApply(target)
	end

	ability.tether_slowedUnits = {}

	local mainAbilityName	= ability:GetAbilityName()
	local subAbilityName	= event.sub_ability_name
	caster:SwapAbilities( mainAbilityName, subAbilityName, false, true )
end

--[[
	Author: Ractidous
	Date: 04.02.2015.
	Check for tether break distance.
]]
function CheckDistance( event )
	local caster = event.caster
	local ability = event.ability

	if ability.tether_allies then
		for i,v in ipairs(ability.tether_allies) do
			local distance = ( v:GetAbsOrigin() - caster:GetAbsOrigin() ):Length2D()
			if distance > event.radius then
				v:RemoveModifierByName("modifier_tether_ally_aghanims")
				v:RemoveModifierByName("modifier_overcharge_buff_aghanims")
				if not ability.tether_allies or #ability.tether_allies <= 0 then
					caster:RemoveModifierByName( event.caster_modifier )
					caster:RemoveModifierByName("modifier_spirits_caster_aghanims")
				end
			end

		end
	end

end

--[[
	Author: Ractidous
	Date: 03.02.2015.
	Store the current health.
]]
function TrackCurrentHealth( event )
	local caster = event.caster
	caster.tether_lastHealth = caster:GetHealth()
end

--[[
	Author: Ractidous
	Date: 03.02.2015.
	Store the current mana.
]]
function TrackCurrentMana( event )
	local caster = event.caster
	caster.tether_lastMana = caster:GetMana()
end

--[[
	Author: Ractidous
	Date: 03.02.2015.
	Heal the gained health to the tethered ally.
]]
function HealAlly( event )
	local caster	= event.caster
	local ability	= event.ability

	local healthGained = caster:GetHealth() - caster.tether_lastHealth

	if healthGained > 0 and not caster.preventTeatherHealing then
		local heal = healthGained * event.tether_heal_amp
		for _,v in ipairs(ability.tether_allies) do
			v.preventTeatherHealing = true
			SafeHeal(v, heal, ability, true)
			v.preventTeatherHealing = nil
		end
	end
end

--[[
	Author: Ractidous
	Date: 04.02.2015.
	Give mana to the tethered ally.
]]
function GiveManaToAlly( event )
	local caster	= event.caster
	local ability	= event.ability

	local manaGained = caster:GetMana() - caster.tether_lastMana
	if manaGained > 0 then
		local mana = manaGained * event.tether_heal_amp
		for _,v in ipairs(ability.tether_allies) do
			v:GiveMana( mana )
		end
	end
end

--[[
	Author: Ractidous
	Date: 03.02.2015.
	Launch a projectile in order to detect enemies crosses the tether.
]]
function FireTetherProjectile( event )
	-- Variables
	local caster	= event.caster
	local target	= event.target
	local ability	= event.ability

	local lineRadius	= event.tether_line_radius
	local tickInterval	= event.tick_interval

	local casterOrigin	= caster:GetAbsOrigin()
	local targetOrigin	= target:GetAbsOrigin()

	local velocity = targetOrigin - casterOrigin
	velocity.z = 0
	-- Create a projectile
	ProjectileManager:CreateLinearProjectile( {
		Ability				= ability,
		vSpawnOrigin		= casterOrigin,
		fDistance			= velocity:Length2D(),
		fStartRadius		= lineRadius,
		fEndRadius			= lineRadius,
		Source				= caster,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		fExpireTime			= GameRules:GetGameTime() + tickInterval + 0.03,
		bDeleteOnHit		= false,
		vVelocity			= velocity / tickInterval,
		EffectName = "particles/arena/invisiblebox.vpcf",
	} )
end

--[[
	Author: Ractidous
	Date: 03.02.2015.
	Apply the slow debuff to the enemy unit.
	If the unit has already got slowed in current cast of Tether, just skip it.
]]
function OnProjectileHit( event )
	-- Variables
	local caster	= event.caster
	local target	= event.target	-- An enemy unit
	local ability	= event.ability

	if ability.tether_slowedUnits[target] then
		return
	end

	ability:ApplyDataDrivenModifier( caster, target, event.slow_modifier, {} )

	ability.tether_slowedUnits[target] = true
end


--[[
	Author: Noya
	Date: 16.01.2015.
	Levels up the ability_name to the same level of the ability that runs this
]]
function LevelUpAbility( event )
	local caster = event.caster
	local this_ability = event.ability
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


--[[
	Author: Ractidous
	Date: 29.01.2015.
	Stop a sound.
]]
function StopSound( event )
	StopSoundEvent( event.sound_name, event.caster )
end

--[[
	Author: Ractidous
	Date: 03.02.2015.
	Remove tether from the ally, then swap the abilities back to the original states.
]]
function EndTether( event )
	local caster = event.caster
	local ability = event.ability

	for _,v in ipairs(ability.tether_allies) do
		Timers:CreateTimer(0.03, function()
			v:RemoveModifierByName( event.ally_modifier )
		end)
	end
	caster:RemoveModifierByName("modifier_spirits_caster_aghanims")

	ability.tether_allies = nil

	caster:SwapAbilities( ability:GetAbilityName(), event.sub_ability_name, true, false )
end

function RemoveFromTable( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if ability.tether_allies then
		target:RemoveModifierByName("modifier_spirits_spirit_aghanims")
		target:RemoveModifierByName("modifier_overcharge_buff_aghanims")
		table.removeByValue(ability.tether_allies, target)
		if #ability.tether_allies <= 0 then
			caster:RemoveModifierByName( keys.caster_modifier )
			caster:RemoveModifierByName("modifier_spirits_caster_aghanims")
		end
	end
end
