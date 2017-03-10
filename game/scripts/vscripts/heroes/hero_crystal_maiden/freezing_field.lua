function freezing_field_channel_finish(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:StopSound("hero_Crystal.freezingField.wind")
	ability.SectionCounter = nil
end

function freezing_field_order_explosion( keys )
	local caster = keys.caster
	local ability = keys.ability
	caster:EmitSound("hero_Crystal.freezingField.wind")

	if caster:HasScepter() then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_freezing_field_arena_scepter", nli)
	end
end

--[[
	Author: kritth
	Date: 09.01.2015.
	Apply the explosion
]]
function freezing_field_explode( keys )
	local ability = keys.ability
	local caster = keys.caster
	local casterLocation = keys.caster:GetAbsOrigin()
	local abilityDamage = ability:GetLevelSpecialValueFor( "damage", ( ability:GetLevel() - 1 ) )
	local minDistance = ability:GetLevelSpecialValueFor( "explosion_min_dist", ( ability:GetLevel() - 1 ) )
	local maxDistance = ability:GetLevelSpecialValueFor( "explosion_max_dist", ( ability:GetLevel() - 1 ) )
	local radius = ability:GetLevelSpecialValueFor( "explosion_radius", ( ability:GetLevel() - 1 ) )
	ability.SectionCounter = (ability.SectionCounter or -1) + 1
	if ability.SectionCounter > 3 then
		ability.SectionCounter = 0
	end
	local modifierName = "modifier_freezing_field_debuff_arena"
	local particleName = "particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_explosion.vpcf"
	local targetTeam = ability:GetAbilityTargetTeam() -- DOTA_UNIT_TARGET_TEAM_ENEMY
	local targetType = ability:GetAbilityTargetType() -- DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	local targetFlag = ability:GetAbilityTargetFlags() -- DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	local damageType = ability:GetAbilityDamageType()
	if caster:HasScepter() then
		abilityDamage = ability:GetLevelSpecialValueFor( "damage_scepter", ( ability:GetLevel() - 1 ) )
		modifierName = "modifier_freezing_field_debuff_scepter_arena"
	end
	
	-- Get random point
	local castDistance = RandomInt( minDistance, maxDistance )
	local angle = RandomInt( 0, 90 )
	local dy = castDistance * math.sin( angle )
	local dx = castDistance * math.cos( angle )
	local attackPoint = Vector( 0, 0, 0 )
	
	if ability.SectionCounter == 0 then	--NW
		attackPoint = Vector( casterLocation.x - dx, casterLocation.y + dy, casterLocation.z )
	elseif ability.SectionCounter == 1 then	--NE
		attackPoint = Vector( casterLocation.x + dx, casterLocation.y + dy, casterLocation.z )
	elseif ability.SectionCounter == 2 then	 --SE
		attackPoint = Vector( casterLocation.x + dx, casterLocation.y - dy, casterLocation.z )
	else --SW
		attackPoint = Vector( casterLocation.x - dx, casterLocation.y - dy, casterLocation.z )
	end

	local crystal_maiden_frostbite = caster:FindAbilityByName("crystal_maiden_frostbite_arena")
	for k, v in pairs( FindUnitsInRadius(caster:GetTeamNumber(), attackPoint, caster, radius, targetTeam, targetType, targetFlag, 0, false) ) do
		ApplyDamage({
			victim = v,
			attacker = caster,
			damage = abilityDamage,
			damage_type = damageType,
			ability = ability
		})
		if crystal_maiden_frostbite and crystal_maiden_frostbite:GetLevel() > 0 and not v:IsMagicImmune() and not v:IsInvulnerable() and RollPercentage(ability:GetLevelSpecialValueFor("chance_to_frostbite_pct", ability:GetLevel()-1)) then
			caster:SetCursorCastTarget(v)
			crystal_maiden_frostbite:OnSpellStart()
		end
	end
	
	-- Fire effect
	local fxIndex = ParticleManager:CreateParticle(particleName, PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl( fxIndex, 0, attackPoint )
	
	-- Fire sound at dummy
	local dummy = CreateUnitByName("npc_dummy_unit", attackPoint, false, caster, caster, caster:GetTeamNumber())
	StartSoundEvent("hero_Crystal.freezingField.explosion", dummy)
	Timers:CreateTimer( 0.1, function()
		UTIL_Remove(dummy)
	end)
end
