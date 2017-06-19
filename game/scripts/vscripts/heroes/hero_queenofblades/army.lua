function SpawnSummons(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]
	local radius = ability:GetAbilitySpecial("radius")
	for i = 1, ability:GetAbilitySpecial("summon_amount") do
		local summon_point = point + (RotatePosition(Vector(0,0,0), QAngle(0,RandomInt(0,259),0), Vector(1,1,0)) * RandomInt(0, radius))
		local unit = CreateUnitByName("npc_queenofblades_army_unit", summon_point, true, caster, nil, caster:GetTeamNumber())
		unit:AddNewModifier(caster, ability, "modifier_kill", {duration = ability:GetAbilitySpecial("summon_duration")})
		ability:ApplyDataDrivenModifier(caster, unit, "modifier_queenofblades_army", nil)
		unit:SetControllableByPlayer(caster:GetPlayerID(), true)
		unit:SetOwner(caster)
		unit:SetBaseMaxHealth(ability:GetAbilitySpecial("summon_hp"))
		unit:SetMaxHealth(ability:GetAbilitySpecial("summon_hp"))
		unit:SetHealth(ability:GetAbilitySpecial("summon_hp"))
		unit:SetBaseDamageMin(ability:GetAbilitySpecial("summon_damage"))
		unit:SetBaseDamageMax(ability:GetAbilitySpecial("summon_damage"))
		unit:SetBaseAttackTime(ability:GetAbilitySpecial("summon_bat"))
		unit:SetMinimumGoldBounty(ability:GetAbilitySpecial("summon_bounty"))
		unit:SetMaximumGoldBounty(ability:GetAbilitySpecial("summon_bounty"))
		unit:SetDeathXP(ability:GetAbilitySpecial("summon_xp"))
	end
end

function Cleave( keys )
	local ability = keys.ability
	local radius = GetAbilitySpecial("queenofblades_army", "cleave_radius")
	if ability then
		radius = ability:GetAbilitySpecial("cleave_radius")
	end
	DoCleaveAttack(keys.attacker, keys.target, ability, keys.Damage, radius, radius, radius, "particles/units/heroes/hero_sven/sven_spell_great_cleave.vpcf")
end