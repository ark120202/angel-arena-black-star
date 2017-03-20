function OnSpellStart(keys)
	local caster = keys.caster
	local point	= keys.target_points[1]
	local ability = keys.ability
	local count = 1
	local hp = keys.golem_hp_tooltip
	local damage = keys.golem_dmg_tooltip
	local bounty = keys.bounty
	local name = keys.name
	if caster:HasScepter() then
		count = ability:GetLevelSpecialValueFor("number_of_golems_scepter", ability:GetLevel() - 1)
		hp = keys.golem_hp_tooltip_scepter
		damage = keys.golem_dmg_tooltip_scepter
		bounty = keys.bounty_scepter
		name = keys.name_scepter
	end
	local dummy = CreateUnitByName("npc_dummy_unit", point, false, nil, nil, caster:GetTeamNumber())
	ParticleManager:CreateParticle(keys.particle, PATTACH_ABSORIGIN, dummy)
	Timers:CreateTimer(0.1, function()
		UTIL_Remove(dummy)
	end)
	for i = 1, count do
		local golem = CreateUnitByName(name, point, true, caster, nil, caster:GetTeamNumber())
		golem:AddNewModifier(caster, ability, "modifier_kill", {duration = ability:GetLevelSpecialValueFor("golem_duration", ability:GetLevel() - 1)})
		golem:SetControllableByPlayer(caster:GetPlayerID(), true)
		golem:SetOwner(caster)
		local warlock_golem_flaming_fists = golem:FindAbilityByName("warlock_golem_flaming_fists")
		if warlock_golem_flaming_fists then
			warlock_golem_flaming_fists:SetLevel(ability:GetLevel())
		end
		local warlock_golem_permanent_immolation = golem:FindAbilityByName("warlock_golem_permanent_immolation")
		if warlock_golem_permanent_immolation then
			warlock_golem_permanent_immolation:SetLevel(ability:GetLevel())
		end
		golem:SetModelScale(0.8 + (0.1 * ability:GetLevel()))
		golem:SetBaseHealthRegen(keys.golem_regen_tooltip)
		golem:SetPhysicalArmorBaseValue(keys.golem_armor_tooltip)
		golem:SetMaxHealth(hp)
		golem:SetHealth(hp)
		golem:SetBaseDamageMin(damage)
		golem:SetBaseDamageMax(damage)
		golem:SetMinimumGoldBounty(bounty)
		golem:SetMaximumGoldBounty(bounty)
	end
end

function CreateParticles(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point	= keys.target_points[1]
	local dummy = CreateUnitByName("npc_dummy_unit", point, false, nil, nil, caster:GetTeamNumber())
	ParticleManager:CreateParticle(keys.aoe_particle, PATTACH_ABSORIGIN, dummy)
	Timers:CreateTimer(0.1, function()
		UTIL_Remove(dummy)
	end)
end