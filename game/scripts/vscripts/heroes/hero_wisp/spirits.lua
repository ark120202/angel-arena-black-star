--[[
	Author: Ractidous
	Date: 09.02.2015.
	Cast spirits.
]]
function CastSpirits( event )
	
	local caster	= event.caster
	local ability	= event.ability

	
	if not caster:FindAbilityByName("wisp_tether_aghanims") or not caster:FindAbilityByName("wisp_tether_aghanims").tether_allies or #caster:FindAbilityByName("wisp_tether_aghanims").tether_allies <= 0 then
		ability:EndCooldown()
		ability:RefundManaCost()
	else
		-- Enable the toggle abilities
		ability.spirits_startTime		= GameRules:GetGameTime()
		ability.spirits_numSpirits		= 0		-- Use this rather than "#spirits_spiritsSpawned"
		ability.spirits_spiritsSpawned	= {}
		caster.spirits_radius			= event.default_radius
		caster.spirits_movementFactor	= 0		-- Changed by the toggle abilities
		EmitSoundOn("Hero_Wisp.Spirits.Cast", caster)
		caster:RemoveModifierByName("modifier_spirits_caster_aghanims")
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_spirits_caster_aghanims", {})
		caster:SwapAbilities( event.empty1_ability, event.spirits_in_ability, false, true )
		caster:SwapAbilities( event.empty2_ability, event.spirits_out_ability, false, true )
	end
end

--[[
	Author: Ractidous
	Date: 09.02.2015.
	Update spirits.
]]
function ThinkSpirits( event )
	
	local caster	= event.caster
	local ability	= event.ability
	if not caster:FindAbilityByName("wisp_tether_aghanims").tether_allies then
		return
	end
	local numSpiritsMax	= ability:GetLevelSpecialValueFor("revolution_time_scepter", ability:GetLevel() - 1)

	local casterOrigin	= caster:GetAbsOrigin()

	local elapsedTime	= GameRules:GetGameTime() - ability.spirits_startTime

	--------------------------------------------------------------------------------
	-- Validate the number of spirits summoned
	--
	local idealNumSpiritsSpawned = elapsedTime / event.spirit_summon_interval
	idealNumSpiritsSpawned = math.min( idealNumSpiritsSpawned, numSpiritsMax )
	if ability.spirits_numSpirits < idealNumSpiritsSpawned then
		local newSpirit
		for _,v in ipairs(caster:FindAbilityByName("wisp_tether_aghanims").tether_allies) do
			if not table.contains(ability.spirits_spiritsSpawned, v) and v:IsAlive() then
				newSpirit = v
			end
		end
		if newSpirit then

			-- Create particle FX
			local pfx = ParticleManager:CreateParticle( event.spirit_particle_name, PATTACH_ABSORIGIN_FOLLOW, newSpirit )
			newSpirit.spirit_pfx = pfx

			-- Update the state
			local spiritIndex = ability.spirits_numSpirits + 1
			newSpirit.spirit_index = spiritIndex
			ability.spirits_numSpirits = spiritIndex
			ability.spirits_spiritsSpawned[spiritIndex] = newSpirit

			-- Apply the spirit modifier
			ability:ApplyDataDrivenModifier( caster, newSpirit, event.spirit_modifier, {} )
		end

	end

	--------------------------------------------------------------------------------
	-- Update the radius
	--
	local currentRadius	= caster.spirits_radius
	local deltaRadius = caster.spirits_movementFactor * event.spirit_movement_rate * event.think_interval
	currentRadius = currentRadius + deltaRadius
	currentRadius = math.min( math.max( currentRadius, event.min_range ), event.max_range )

	caster.spirits_radius = currentRadius

	--------------------------------------------------------------------------------
	-- Update the spirits' positions
	--
	local currentRotationAngle	= elapsedTime * event.spirit_turn_rate
	local rotationAngleOffset	= 360 / ability.spirits_numSpirits

	local numSpiritsAlive = 0

	for k,v in pairs( ability.spirits_spiritsSpawned ) do
		if v:IsAlive() then
			numSpiritsAlive = numSpiritsAlive + 1

			-- Rotate
			local rotationAngle = currentRotationAngle - rotationAngleOffset * ( k - 1 )
			local relPos = Vector( 0, currentRadius, 0 )
			relPos = RotatePosition( Vector(0,0,0), QAngle( 0, -rotationAngle, 0 ), relPos )

			local absPos = GetGroundPosition( relPos + casterOrigin, v )

			v:SetAbsOrigin( absPos )

			-- Update particle
			ParticleManager:SetParticleControl( v.spirit_pfx, 1, Vector( currentRadius, 0, 0 ) )
		else
			
		end
	end
idealNumSpiritsSpawned = elapsedTime / event.spirit_summon_interval
	idealNumSpiritsSpawned = math.min( idealNumSpiritsSpawned, numSpiritsMax )

	if ability.spirits_numSpirits == numSpiritsMax and numSpiritsAlive == 0 and elapsedTime > ability:GetLevelSpecialValueFor("revolution_time_scepter", ability:GetLevel() - 1) then
		-- All spirits have been exploded.
		caster:RemoveModifierByName( event.caster_modifier )
		return
	end

end

function RemoveSpiritParticle( keys )
	local ability = keys.ability
	local target = keys.target
	ParticleManager:DestroyParticle( target.spirit_pfx, false )
	target:RemoveModifierByName("modifier_tether_ally_aghanims")
	target:RemoveModifierByName("modifier_spirits_spirit_aghanims")
	table.removeByValue(ability.spirits_spiritsSpawned, v)
end

--[[
	Author: Ractidous
	Date: 09.02.2015.
	Destroy all spirits and swap the abilities back to the original states.
]]
function EndSpirits( event )
	
	local caster	= event.caster
	local ability	= event.ability

	local spiritModifier	= event.spirit_modifier

	-- Destroy all spirits
	for k,v in pairs( ability.spirits_spiritsSpawned ) do
		v:RemoveModifierByName( spiritModifier )
	end

	-- Disable the toggle abilities
	caster:SwapAbilities( event.empty1_ability, event.spirits_in_ability, true, false )
	caster:SwapAbilities( event.empty2_ability, event.spirits_out_ability, true, false )

	-- Reset the toggle states.
	ResetToggleState( caster, event.spirits_in_ability )
	ResetToggleState( caster, event.spirits_out_ability )

end

--[[
	Author: Ractidous
	Date: 09.02.2015.
	Change the movement factor.
]]
function ToggleOn( event )
	local caster	= event.caster

	-- Make sure that the opposite ability is toggled off.
	ResetToggleState( caster, event.opposite_ability )

	-- Change the movement factor
	caster.spirits_movementFactor = event.spirit_movement
end

--[[
	Author: Ractidous
	Date: 09.02.2015.
	Reset the movement factor.
]]
function ToggleOff( event )
	event.caster.spirits_movementFactor = 0
end

--[[
	Author: Ractidous
	Date: 09.02.2015.
	Reset the toggle state.
]]
function ResetToggleState( caster, abilityName )
	local ability = caster:FindAbilityByName( abilityName )
	if ability:GetToggleState() then
		ability:ToggleAbility()
	end
end

--[[
	Author: Ractidous
	Date: 09.02.2015.
	Apply a modifier which detects collision with a hero.
]]
function OnCreatedSpirit( event )
	
	local spirit = event.target
	local ability = event.ability

	-- Set the spirit to caster
	ability:ApplyDataDrivenModifier( spirit, spirit, event.additionalModifier, {} )

end

--[[
	Author: Ractidous
	Date: 09.02.2015.
	Explode the spirit due to collision with an enemy hero.
]]
function ExplodeSpirit( event )
	local spirit	= event.target
	local ability	= event.ability
	local enemies = FindUnitsInRadius(spirit:GetTeam(), spirit:GetAbsOrigin(), nil, ability:GetLevelSpecialValueFor("hero_hit_radius_scepter", ability:GetLevel() - 1), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
	if #enemies >= 1 then

		-- Remove from the list of spirits
		ability.spirits_spiritsSpawned[spirit.spirit_index] = nil

		-- Remove the spirit modifier
		ParticleManager:CreateParticle("particles/units/heroes/hero_wisp/wisp_guardian_explosion.vpcf", PATTACH_ABSORIGIN, spirit)
		EmitSoundOn("Hero_Wisp.Spirits.Destroy", spirit)

		ability:CreateVisibilityNode( spirit:GetAbsOrigin(), ability:GetLevelSpecialValueFor("explode_radius_scepter", ability:GetLevel() - 1), ability:GetLevelSpecialValueFor("vision_duration_scepter", ability:GetLevel() - 1) )
		local damage = spirit:GetHealth()
		spirit:ForceKill( true )
		for _,v in ipairs(FindUnitsInRadius(spirit:GetTeam(), spirit:GetAbsOrigin(), nil, ability:GetLevelSpecialValueFor("explode_radius_scepter", ability:GetLevel() - 1), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)) do
			ApplyDamage({victim = v, attacker = spirit, damage = damage, damage_type = ability:GetAbilityDamageType(), ability = ability})
		end

		-- Fire the hit sound
		StartSoundEvent( event.explosion_sound, spirit )
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

--[[
	Author: Ractidous
	Date: 29.01.2015.
	Stop a sound.
]]
function StopSound( event )
	StopSoundEvent( event.sound_name, event.caster )
end