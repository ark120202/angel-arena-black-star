function SpawnSpore(keys)
	local caster = keys.caster
	local ability = keys.ability
	local spawnPoint = caster:GetAbsOrigin() + caster:GetForwardVector() * ability:GetLevelSpecialValueFor("distance", ability:GetLevel() - 1)
	local spore = CreateUnitByName("npc_cherub_explosive_spore", spawnPoint, false, caster, caster, caster:GetTeam())
	spore:SetControllableByPlayer(caster:GetPlayerID(), true)
	spore:SetOwner(caster)
	spore:AddNewModifier(caster, ability, "modifier_kill", {duration = ability:GetLevelSpecialValueFor("explode_delay", ability:GetLevel() - 1)})
	ability:ApplyDataDrivenModifier(caster, spore, "modifier_cherub_explosive_spore", {})
	spore:SetModelScale(ability:GetLevelSpecialValueFor("model_scale_min", ability:GetLevel() - 1))
	spore:SetMaxHealth(keys.spore_health)
	spore:SetHealth(keys.spore_health)
	spore:SetBaseMoveSpeed(keys.spore_movespeed)
	spore:SetMinimumGoldBounty(keys.spore_bounty_gold)
	spore:SetMaximumGoldBounty(keys.spore_bounty_gold)
	spore:SetDeathXP(keys.spore_bounty_exp)
	spore:SetRenderColor(0,255,0)
	spore.SpawnTime = Time()
	spore:EmitSound("Arena.Hero_Cherub.ExplosiveSpore.Plant")
	spore:SetDayTimeVisionRange(keys.spore_vision_range)
	spore:SetNightTimeVisionRange(keys.spore_vision_range)
end

function GrowthThink(keys)
	local spore = keys.target
	local ability = keys.ability
	local life_time = Time() - spore.SpawnTime
	local max_time = ability:GetLevelSpecialValueFor("explode_delay", ability:GetLevel() - 1)
	local model_scale_min = ability:GetLevelSpecialValueFor("model_scale_min", ability:GetLevel() - 1)
	local model_scale_max = ability:GetLevelSpecialValueFor("model_scale_max", ability:GetLevel() - 1)
	spore:SetModelScale(model_scale_min + ((life_time / max_time) * (model_scale_max - model_scale_min)))
	if life_time >= max_time then
		spore:ForceKill(false)
	elseif max_time - life_time <= 2 then
		if spore.red then
			spore:SetRenderColor(0,255,0)
			spore.red = nil
		else
			spore:SetRenderColor(255,0,0)
			spore.red = true
		end
	end
end

function ExplodeSpore(keys)
	local caster = keys.caster
	local spore = keys.unit
	local ability = keys.ability
	CreateGlobalParticle("particles/arena/units/heroes/hero_cherub/explosive_spore_explode.vpcf", function(particle)
		ParticleManager:SetParticleControl(particle, 0, spore:GetAbsOrigin())
	end)
	spore:EmitSound("Arena.Hero_Cherub.ExplosiveSpore.Explode")
	spore:StopSound("Arena.Hero_Cherub.ExplosiveSpore.Plant")
	spore:AddNoDraw()

	for _,v in ipairs(FindUnitsInRadius(spore:GetTeam(), spore:GetAbsOrigin(), nil, ability:GetLevelSpecialValueFor("explode_radius", ability:GetLevel() - 1), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
		local hp = v:GetHealth()
		ApplyDamage({
			victim = v,
			attacker = spore,
			damage = ability:GetAbilityDamage(),
			damage_type = ability:GetAbilityDamageType(),
			ability = ability
		})
		if not v:IsIllusion() then
			local diff = hp - v:GetHealth()
			if v:IsHero() then
				SafeHeal(caster, diff * ability:GetLevelSpecialValueFor("lifesteel_heroes_pct", ability:GetLevel() - 1) * 0.01, caster)
			else
				SafeHeal(caster, diff * ability:GetLevelSpecialValueFor("lifesteel_creeps_pct", ability:GetLevel() - 1) * 0.01, caster)
			end
			ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN, caster)
		end
	end

	local radius = ability:GetLevelSpecialValueFor("spore_vision_range", ability:GetLevel() - 1)
	local dummy = CreateUnitByName("npc_dummy_flying", spore:GetAbsOrigin(), false, nil, nil, spore:GetTeam())
	dummy:SetDayTimeVisionRange(radius)
	dummy:SetNightTimeVisionRange(radius)
	Timers:CreateTimer(ability:GetLevelSpecialValueFor("spore_vision_delay", ability:GetLevel() - 1), function()
		UTIL_Remove(dummy)
	end)
end
