function Initialize(keys)
	local caster = keys.caster
	caster:AddItem(CreateItem("item_abyssal_blade", caster, caster))
	caster:AddItem(CreateItem("item_monkey_king_bar", caster, caster))
	caster:AddItem(CreateItem("item_three_spirits_blades", caster, caster))
	caster:AddItem(CreateItem("item_greater_crit", caster, caster))
	caster:AddItem(CreateItem("item_greater_crit", caster, caster))
	caster:AddItem(CreateItem("item_greater_crit", caster, caster))
	local ursa_fury_swipes = caster:FindAbilityByName("ursa_fury_swipes")
	ursa_fury_swipes:SetLevel(ursa_fury_swipes:GetMaxLevel())
end

--[[Author: Pizzalol
	Date: 04.03.2015.
	Creates additional attack projectiles for units within the specified radius around the caster]]
function SplitShotLaunch( keys )
	local caster = keys.caster
	local caster_location = caster:GetAbsOrigin()
	local ability = keys.ability
	-- Targeting variables
	local attack_target = caster:GetAttackTarget()

	-- Ability variables
	local radius = ability:GetSpecialValueFor("splash_range")
	local projectile_speed = PROJECTILES_TABLE["npc_dota_hero_windrunner"].speed
	local split_shot_projectile = PROJECTILES_TABLE["npc_dota_hero_windrunner"].model

	local split_shot_targets = FindUnitsInRadius(caster:GetTeam(), caster_location, nil, caster:GetAttackRange(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false)
	-- Create projectiles for units that are not the casters current attack target
	for _,v in ipairs(split_shot_targets) do
		if v ~= attack_target then
			local projectile_info = 
			{
				EffectName = split_shot_projectile,
				Ability = ability,
				vSpawnOrigin = caster_location,
				Target = v,
				Source = caster,
				bHasFrontalCone = false,
				iMoveSpeed = projectile_speed,
				bReplaceExisting = false,
				bProvidesVision = false
			}
			ProjectileManager:CreateTrackingProjectile(projectile_info)
		end
	end
end