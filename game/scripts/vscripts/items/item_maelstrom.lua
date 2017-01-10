--[[
	Author: Noya
	Date: 12 December 2015
	Bounces a chain lightning
]]
function ChainLightning(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local teamNumber = caster:GetTeamNumber()
	local targetTeam = ability:GetAbilityTargetTeam()
	local targetTypes = ability:GetAbilityTargetType()
	local flags = ability:GetAbilityTargetFlags()

	local damage = ability:GetLevelSpecialValueFor( "chain_damage", ability:GetLevel() - 1 )
	local bounces = ability:GetLevelSpecialValueFor( "chain_strikes", ability:GetLevel() - 1 )
	local bounce_range = ability:GetLevelSpecialValueFor( "chain_radius", ability:GetLevel() - 1 )
	local time_between_bounces = ability:GetLevelSpecialValueFor( "chain_delay", ability:GetLevel() - 1 )

	local start_position = caster:GetAbsOrigin()
	local attach_eye_r = caster:ScriptLookupAttachment("attach_eye_r")
	local attach_attack1 = caster:ScriptLookupAttachment("attach_attack1")
	if attach_eye_r ~= 0 then
		local first_eye = caster:GetAttachmentOrigin(attach_eye_r)
		local second_eye = caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_eye_l"))
		start_position = first_eye + (second_eye-first_eye)/2 --Between the eyes
		start_position.z = start_position.z + 50
	elseif attach_attack1 ~= 0 then
		start_position = caster:GetAttachmentOrigin(attach_attack1)
	else
		start_position.z = start_position.z + target:GetBoundingMaxs().z
	end

	local current_position = CreateChainLightning(ability, caster, start_position, target, damage)

	local targetsStruck = {}
	targetsStruck[target] = true

	Timers:CreateTimer(time_between_bounces, function()  
		local units = FindUnitsInRadius(teamNumber, current_position, target, bounce_range, targetTeam, targetTypes, flags, FIND_CLOSEST, true)
		if #units > 0 then
			local bounce_target
			for _,unit in ipairs(units) do
				if not targetsStruck[unit] then
					bounce_target = unit
					targetsStruck[unit] = true
					break
				end
			end
			if bounce_target then
				current_position = CreateChainLightning(ability, caster, current_position, bounce_target, damage)
				bounces = bounces - 1
				if bounces > 0 then
					return time_between_bounces
				end
			end
		end
	end)
end

-- Creates a chain lightning on a start position towards a target. Also does sound, damage and popup
function CreateChainLightning(ability, caster, start_position, target, damage)
	local target_position = target:GetAbsOrigin()
	local attach_hitloc = target:ScriptLookupAttachment("attach_hitloc")
	if attach_hitloc ~= 0 then
		target_position = target:GetAttachmentOrigin(attach_hitloc)
	else
		target_position.z = target_position.z + target:GetBoundingMaxs().z
	end

	local particle = ParticleManager:CreateParticle("particles/items_fx/chain_lightning.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, start_position)
	ParticleManager:SetParticleControl(particle, 1, target_position)
	target:EmitSound("Item.Maelstrom.Chain_Lightning.Jump")
	ApplyDamage({
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = ability
	})
	PopupDamage(target, math.floor(damage))

	return target_position
end