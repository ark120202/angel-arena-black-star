--[[Author: YOLOSPAGHETTI
	Date: March 28, 2016
	Creates the missile]]
function CreateMissile(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local starting_distance = ability:GetLevelSpecialValueFor( "starting_distance", ability:GetLevel() - 1 )
	local direction = caster:GetForwardVector()
	local position = caster:GetAbsOrigin() + starting_distance * direction
	
	local missile = CreateUnitByName("npc_dota_gyrocopter_homing_missile", position, true, caster, caster:GetPlayerOwner(), caster:GetTeam())
	missile.target = target
	missile.starting_position = position
	missile.level = ability:GetLevel() - 1
	missile.hits_to_kill = ability:GetLevelSpecialValueFor( "hits_to_kill_tooltip", ability:GetLevel() - 1 )
	missile.hit = false
	ability:ApplyDataDrivenModifier(caster, missile, "modifier_gyrocopter_homing_missile_arena", {})
--	missile:SetOwner(caster)
	missile.time_passed = 0
	local particle = ParticleManager:CreateParticle(keys.particle, PATTACH_ABSORIGIN_FOLLOW, missile) 
	ParticleManager:SetParticleControlEnt(particle, 1, missile, PATTACH_POINT_FOLLOW, "attach_hitloc", missile:GetAbsOrigin(), true)
end

--[[Author: YOLOSPAGHETTI
	Date: March 28, 2016
	Moves the missile and senses when it hits the target]]
function MoveMissile(keys)
	local caster = keys.caster
	local ability = keys.ability
	local missile = keys.target
	local target = missile.target
	local interval = 0.02
	if missile.hit == false then
		local pre_flight_time = ability:GetLevelSpecialValueFor( "pre_flight_time", missile.level )
		local stun_duration = ability:GetLevelSpecialValueFor( "stun_duration", missile.level )
		local min_damage = ability:GetLevelSpecialValueFor( "min_damage", missile.level )
		local max_distance = ability:GetLevelSpecialValueFor( "max_distance", missile.level )
		local min_distance = ability:GetLevelSpecialValueFor( "min_distance", missile.level )
		local speed = ability:GetLevelSpecialValueFor( "speed", missile.level )*interval
		local acceleration = ability:GetLevelSpecialValueFor( "acceleration", missile.level )*interval
		
		local vector_distance = target:GetAbsOrigin() - missile:GetAbsOrigin()
		local distance = (vector_distance):Length2D()
		local direction = (vector_distance):Normalized()
		
		missile.time_passed = missile.time_passed + interval
		
		if missile.time_passed >= pre_flight_time then
			if missile.time_passed == pre_flight_time then
				EmitSoundOn(keys.sound2, missile)
			end
			if distance < 128 then
				missile.hit = true
				local travel_vector_distance = missile:GetAbsOrigin() - missile.starting_position
				local travel_distance = travel_vector_distance:Length2D()
				
				local damage
				if travel_distance >= max_distance then
					damage = ability:GetAbilityDamage()
				else
					damage = math.max((travel_distance/max_distance) * ability:GetAbilityDamage(), min_damage)
				end
				for _,v in ipairs(FindUnitsInRadius(caster:GetTeam(), missile:GetAbsOrigin(), nil, ability:GetLevelSpecialValueFor("explosion_radius", ability:GetLevel() - 1), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
					v:AddNewModifier(caster, ability, "modifier_stunned", {Duration = stun_duration})
					ApplyDamage({victim = v, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType(), ability = ability})
				end
				missile:ForceKill(false)
			else
				print("rotate")
				missile:SetForwardVector(Vector(direction.x/2, direction.y/2, -1))
				local move_duration = math.modf(missile.time_passed - pre_flight_time)
				speed = speed + acceleration * move_duration
				missile:SetAbsOrigin(missile:GetAbsOrigin() + direction * speed)
			end
		end
	end
end

--[[Author: YOLOSPAGHETTI
	Date: March 28, 2016
	Keeps track of attacks on the missile and applies all death particles and sfx]]
function MissileAttacked(keys)
	local caster = keys.caster
	local attacker = keys.attacker
	local ability = keys.ability
	local missile = keys.unit
	local target = missile.target
	local total_hits = ability:GetLevelSpecialValueFor( "hits_to_kill_tooltip", missile.level )
	
	if attacker:IsTower() == true then
		missile.hits_to_kill = missile.hits_to_kill - 0.5
		missile:SetHealth(missile:GetMaxHealth()*(missile.hits_to_kill/total_hits))
	elseif attacker == missile then
		missile.hits_to_kill = 0
	else
		missile.hits_to_kill = missile.hits_to_kill - 1
		missile:SetHealth(missile:GetMaxHealth()*(missile.hits_to_kill/total_hits))
	end
	
	if missile.hits_to_kill <= 0 then
		missile:ForceKill(false)
	end
	if missile:IsAlive() == false then
		if missile.hit == false then
			local particle = ParticleManager:CreateParticle(keys.particle, PATTACH_ABSORIGIN_FOLLOW, missile) 
			ParticleManager:SetParticleControlEnt(particle, 1, missile, PATTACH_POINT_FOLLOW, "attach_hitloc", missile:GetAbsOrigin(), true)
		else
			local vision_time = ability:GetLevelSpecialValueFor( "vision_time", missile.level )
			local vision_radius = ability:GetLevelSpecialValueFor( "vision_radius", missile.level )
			AddFOWViewer(caster:GetTeam(), target:GetAbsOrigin(), vision_radius, vision_time, false)
			local particle = ParticleManager:CreateParticle(keys.particle2, PATTACH_ABSORIGIN_FOLLOW, target) 
			ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
			EmitSoundOn(keys.sound3, missile)
		end
		missile:AddNoDraw()
		target:RemoveModifierByName("modifier_gyrocopter_homing_missile_target")
		StopSoundEvent(keys.sound, missile)
		StopSoundEvent(keys.sound2, missile)
		EmitSoundOn(keys.sound4, missile)
	end
end
