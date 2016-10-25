function Initialize(keys)
	local caster = keys.caster
	caster:AddItem(CreateItem("item_radiance", caster, caster))
	caster:AddItem(CreateItem("item_monkey_king_bar", caster, caster))
end

function CreateSunstrikes(keys)
	local caster = keys.caster
	local ability = keys.ability
	local loc1 = Entities:FindByName(nil, "target_mark_boss_primal_sunstorm1"):GetAbsOrigin()
	local loc2 = Entities:FindByName(nil, "target_mark_boss_primal_sunstorm2"):GetAbsOrigin()
	local loc3 = Entities:FindByName(nil, "target_mark_boss_primal_sunstorm3"):GetAbsOrigin()
	local loc4 = Entities:FindByName(nil, "target_mark_boss_primal_sunstorm4"):GetAbsOrigin()
	local rowLocDiffLen = (loc1-loc3):Length2D() / (ability:GetSpecialValueFor("sun_strikes_in_row") - 1)
	local columnLocDiffLen = (loc1-loc2):Length2D() / (ability:GetSpecialValueFor("sun_strikes_in_column") - 1)
	local points = {}
	for row = 0, ability:GetSpecialValueFor("sun_strikes_in_column") - 1 do
		local point = loc1 + (loc2-loc1):Normalized()*columnLocDiffLen*row
		local column = {}
		for i = 0, ability:GetSpecialValueFor("sun_strikes_in_row") - 1 do
			table.insert(column, point + (loc3-loc1):Normalized()*rowLocDiffLen*i)
		end
		points[row] = column
	end
	for i,val in ipairs(points) do
		Timers:CreateTimer(0.5*i, function()
			for _,v in ipairs(val) do
				local dummy = CreateUnitByName("npc_dummy_unit", v, false, nil, nil, caster:GetTeamNumber())
				ability:ApplyDataDrivenModifier(caster, dummy, "modifier_boss_primal_sunstorm", {})
			end
		end)
	end
end

function sun_strike_charge( keys )
	local caster = keys.caster
	local target = keys.target
	local target_location = target:GetAbsOrigin()
	local ability = keys.ability

	local charge_particle = keys.charge_particle
	local delay = ability:GetSpecialValueFor("delay")
	local area_of_effect = ability:GetSpecialValueFor("area_of_effect")

	local particle = ParticleManager:CreateParticle(charge_particle, PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(particle, 1, Vector(area_of_effect,0,0))
	target:EmitSound("Hero_Invoker.SunStrike.Charge")

	Timers:CreateTimer(delay, function()
		ParticleManager:DestroyParticle(particle, false)
	end)
end

function sun_strike_damage( keys )
	local caster = keys.caster
	local target = keys.target
	local target_location = target:GetAbsOrigin() 
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	local particle = ParticleManager:CreateParticle(charge_particle, PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(particle, 1, Vector(area_of_effect,0,0))
	target:EmitSound("Hero_Invoker.SunStrike.Ignite")

	-- Ability variables
	local area_of_effect = ability:GetSpecialValueFor("area_of_effect")
	local damage = ability:GetSpecialValueFor("damage")

	-- Targeting variables
	local target_teams = ability:GetAbilityTargetTeam()
	local target_types = ability:GetAbilityTargetType()
	local target_flags = ability:GetAbilityTargetFlags()

	local found_targets = FindUnitsInRadius(caster:GetTeamNumber(), target_location, nil, area_of_effect, target_teams, target_types, target_flags, FIND_CLOSEST, false)

	-- Initialize the damage table
	local damage_table = {}
	damage_table.attacker = caster
	damage_table.ability = ability
	damage_table.damage_type = ability:GetAbilityDamageType() 
	damage_table.damage = damage

	-- Deal damage to each found hero
	for _,hero in pairs(found_targets) do
		damage_table.victim = hero
		ApplyDamage(damage_table)
	end
end

function BullethellThink(keys)
	local caster = keys.caster
	local ability = keys.ability
	local caster_team = caster:GetTeam()
	if #FindUnitsInBox(DOTA_TEAM_NEUTRALS, Entities:FindByName(nil, "target_mark_bosses_area_1"):GetAbsOrigin(), Entities:FindByName(nil, "target_mark_bosses_area_2"):GetAbsOrigin(),
		nil, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD) == 0 then
		caster.ai:SwitchState(AI_STATE_RETURNING)
		caster.ai:SetThinkEnabled(true)
		caster:SetHealth(caster:GetMaxHealth())
		caster:RemoveModifierByNameAndCaster("modifier_boss_primal_bullethell_active", caster)
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_boss_primal_bullethell", {})
		return
	end
	local patternts = {
		[1] = function()
			for i = 0, 19 do
				local speed = 500
				local range = 2000
				local vVelocity = (RotatePosition(Vector(0,0,0),QAngle(0,i*18,0),Vector(1,1,0))):Normalized() * speed
				vVelocity.z = 0
				local projectile = Projectiles:CreateProjectile({
					EffectName = "particles/units/heroes/hero_mirana/mirana_spell_arrow.vpcf",
					vSpawnOrigin = caster:GetAbsOrigin() + Vector(0,0,80),
					fDistance = range,
					fExpireTime = range/speed,
					fStartRadius = 30,
					fEndRadius = 30,
					Source = caster,
					vVelocity = vVelocity,
					UnitBehavior = PROJECTILES_FOLLOW,
					bMultipleHits = false,
					bIgnoreSource = true,
					TreeBehavior = PROJECTILES_NOTHING,
					WallBehavior = PROJECTILES_DESTROY,
					GroundBehavior = PROJECTILES_NOTHING,
					bGroundLock = true,
					bCutTrees = true,
					UnitTest = function(self, unit)
						return not unit:IsMagicImmune() and not unit:IsInvulnerable() and UnitFilter(unit, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, caster_team) == UF_SUCCESS
					end,
					OnUnitHit = function(self, unit)
						ApplyDamage({victim = unit,
							attacker = caster,
							damage = 50000,
							damage_type = DAMAGE_TYPE_PURE,
							ability = ability
						})
					end,
				})
			end
		end,
		[2] = function()
			local loc1 = Entities:FindByName(nil, "target_mark_boss_primal_sunstorm1"):GetAbsOrigin()
			local loc2 = Entities:FindByName(nil, "target_mark_boss_primal_sunstorm2"):GetAbsOrigin()
			local loc3 = Entities:FindByName(nil, "target_mark_boss_primal_sunstorm3"):GetAbsOrigin()
			local loc4 = Entities:FindByName(nil, "target_mark_boss_primal_sunstorm4"):GetAbsOrigin()
			local rowLocDiffLen = (loc1-loc3):Length2D() / 4
			local columnLocDiffLen = (loc1-loc2):Length2D() / 4
			local points = {}
			for side = 1, 4 do
				for i = 0, 4 do
					local p1
					local p2
					local diffLen
					if side == 1 then
						p1 = loc1
						p2 = loc2
						diffLen = columnLocDiffLen
					elseif side == 2 then
						p1 = loc1
						p2 = loc3
						diffLen = rowLocDiffLen
					elseif side == 3 then
						p1 = loc2
						p2 = loc4
						diffLen = rowLocDiffLen
					elseif side == 4 then
						p1 = loc3
						p2 = loc4
						diffLen = columnLocDiffLen
					end
					local direction = (p2-p1):Normalized()
					table.insert(points, p1 + direction*diffLen*i)
				end
			end

			for i, point in ipairs(points) do
				local speed = 400
				local range = 4000
				local vVelocity = (caster:GetAbsOrigin() - point):Normalized() * speed
				vVelocity.z = 0
				local projectile = Projectiles:CreateProjectile({
					EffectName = "particles/units/heroes/hero_mirana/mirana_spell_arrow.vpcf",
					vSpawnOrigin = point + Vector(0,0,80),
					fDistance = range,
					fExpireTime = range/speed,
					fStartRadius = 30,
					fEndRadius = 30,
					Source = caster,
					vVelocity = vVelocity,
					UnitBehavior = PROJECTILES_FOLLOW,
					bMultipleHits = false,
					bIgnoreSource = true,
					TreeBehavior = PROJECTILES_NOTHING,
					WallBehavior = PROJECTILES_DESTROY,
					GroundBehavior = PROJECTILES_NOTHING,
					bGroundLock = true,
					bCutTrees = true,
					UnitTest = function(self, unit)
						return not unit:IsMagicImmune() and not unit:IsInvulnerable() and UnitFilter(unit, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, caster_team) == UF_SUCCESS
					end,
					OnUnitHit = function(self, unit)
						ApplyDamage({victim = unit,
							attacker = caster,
							damage = 50000,
							damage_type = DAMAGE_TYPE_PURE,
							ability = ability
						})
					end,
				})
			end
		end,
		[3] = function()
			for i = 1, 4 do
				local meteor_travel_speed = 200
				local meteor_LandTime = 1.5
				local sunstorm_control_loc = (Entities:FindByName(nil, "target_mark_boss_primal_sunstorm" .. i)):GetAbsOrigin()
				local caster_control_diff = (sunstorm_control_loc - caster:GetAbsOrigin()):Length2D()
				local direction = (sunstorm_control_loc - caster:GetAbsOrigin()):Normalized()
				local targetLocationForMeteor = caster:GetAbsOrigin() + direction * caster_control_diff / 2
				local target_point_temp = Vector(targetLocationForMeteor.x, targetLocationForMeteor.y, 0)
				local meteor_fly_original_point = (targetLocationForMeteor - (((target_point_temp - Vector(caster:GetAbsOrigin().x, caster:GetAbsOrigin().y, 0)):Normalized() * meteor_travel_speed) * meteor_LandTime)) + Vector (0, 0, 1000)
				local chaos_meteor_fly_particle_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_chaos_meteor_fly.vpcf", PATTACH_ABSORIGIN, caster)
				ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 0, meteor_fly_original_point)
				ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 1, targetLocationForMeteor)
				ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 2, Vector(1.3, 0, 0))
				Timers:CreateTimer(meteor_LandTime, function()
					for i = 0, 17 do
						local speed = 500
						local range = 2000
						local vVelocity = (RotatePosition(Vector(0,0,0),QAngle(0,i*20,0),Vector(1,1,0))):Normalized() * speed
						vVelocity.z = 0
						local projectile = Projectiles:CreateProjectile({
							EffectName = "particles/units/heroes/hero_mirana/mirana_spell_arrow.vpcf",
							vSpawnOrigin = targetLocationForMeteor + Vector(0,0,80),
							fDistance = range,
							fExpireTime = range/speed,
							fStartRadius = 30,
							fEndRadius = 30,
							Source = caster,
							vVelocity = vVelocity,
							UnitBehavior = PROJECTILES_FOLLOW,
							bMultipleHits = false,
							bIgnoreSource = true,
							TreeBehavior = PROJECTILES_NOTHING,
							WallBehavior = PROJECTILES_DESTROY,
							GroundBehavior = PROJECTILES_NOTHING,
							bGroundLock = true,
							bCutTrees = true,
							UnitTest = function(self, unit)
								return not unit:IsMagicImmune() and not unit:IsInvulnerable() and UnitFilter(unit, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, caster_team) == UF_SUCCESS
							end,
							OnUnitHit = function(self, unit)
								ApplyDamage({victim = unit,
									attacker = caster,
									damage = 50000,
									damage_type = DAMAGE_TYPE_PURE,
									ability = ability
								})
							end,
						})
					end
				end)
			end
		end,
		[4] = function()
			local firstPoint = Entities:FindByName(nil, "target_mark_bosses_area_1"):GetAbsOrigin()
			local secondPoint = Entities:FindByName(nil, "target_mark_bosses_area_2"):GetAbsOrigin()
			local count = 0
			local pfx
			Timers:CreateTimer(function()
				local point1 = Vector(RandomInt(firstPoint.x, secondPoint.x), RandomInt(firstPoint.y, secondPoint.y), 850)
				local point2 = Vector(RandomInt(firstPoint.x, secondPoint.x), RandomInt(firstPoint.y, secondPoint.y), 850)
				--[[local absp1 = point1
				absp1.z = 0
				local absp2 = point2
				absp2.z = 2500]]
				if pfx then
					ParticleManager:DestroyParticle(pfx, true)
				end
				pfx = ParticleManager:CreateParticle("particles/arena/units/bosses/primal/laser.vpcf", PATTACH_WORLDORIGIN, GLOBAL_VISIBLE_ENTITY)
				ParticleManager:SetParticleControl(pfx, 0, point1)
				ParticleManager:SetParticleControl(pfx, 1, point2)
				ParticleManager:SetParticleControl(pfx, 15, Vector(0,255,0))
				Timers:CreateTimer(1.5, function()
					ParticleManager:DestroyParticle(pfx, true)
					local newpfx = ParticleManager:CreateParticle("particles/arena/units/bosses/primal/laser.vpcf", PATTACH_WORLDORIGIN, GLOBAL_VISIBLE_ENTITY)
					ParticleManager:SetParticleControl(newpfx, 0, point1)
					ParticleManager:SetParticleControl(newpfx, 1, point2)
					ParticleManager:SetParticleControl(newpfx, 15, Vector(255,0,0))
					local GameLaserCheckEndTime = Time() + 2.5
					Timers:CreateTimer(function()
						if Time() < GameLaserCheckEndTime then
							for _,v in ipairs(FindUnitsInLine(caster_team, point1, point2, nil, 100, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE)) do
								ApplyDamage({victim = v,
									attacker = caster,
									damage = 50000,
									damage_type = DAMAGE_TYPE_PURE,
									ability = ability
								})
							end
							return 0.03
						else
							ParticleManager:DestroyParticle(newpfx, true)
						end
					end)
				end)
				count = count + 1
				if count <= 10 then
					return 4
				else
					ParticleManager:DestroyParticle(pfx, true)
				end
			end)
		end,
	}
	local patternOrder = {
		[1] = 1,
		[2] = 1,
		[3] = 2,
		[4] = 3,
		[5] = 4,
		[6] = 4,
	}
	ability.nextPattern = (ability.nextPattern or 0) + 1
	if not patternOrder[ability.nextPattern] then
		ability.nextPattern = 1
	end
	patternts[patternOrder[ability.nextPattern]]()
	print("Primal boss: playing pattern number", patternOrder[ability.nextPattern], "order", ability.nextPattern)

	ApplyDamage({
		attacker = caster,
		victim = caster,
		damage = caster:GetMaxHealth() / ability:GetAbilitySpecial("duration") * ability:GetAbilitySpecial("think_interval"),
		ability = ability,
		damage_type = DAMAGE_TYPE_PURE,
		damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS,
	})
end

function CheckBullethellDeath(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if caster:GetHealth() <= 1 then
		--Bosses:MakeBossAI(caster, "primal")
		local boxSize = Entities:FindByName(nil, "target_mark_bosses_area_1"):GetAbsOrigin() - Entities:FindByName(nil, "target_mark_bosses_area_2"):GetAbsOrigin()
		boxSize = boxSize / 2
		local targetPos = Entities:FindByName(nil, "target_mark_bosses_area_1"):GetAbsOrigin() - boxSize
		caster:MoveToPosition(targetPos)
	 	caster.ai:SetThinkEnabled(false)
	 	Timers:CreateTimer(0.1, function()
			if #FindUnitsInBox(DOTA_TEAM_NEUTRALS, Entities:FindByName(nil, "target_mark_bosses_area_1"):GetAbsOrigin(), Entities:FindByName(nil, "target_mark_bosses_area_2"):GetAbsOrigin(),
				nil, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD) == 0 then
				caster.ai:SwitchState(AI_STATE_RETURNING)
				caster.ai:SetThinkEnabled(true)
				caster:SetHealth(caster:GetMaxHealth())
				caster:RemoveModifierByNameAndCaster("modifier_boss_primal_bullethell_active", caster)
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_boss_primal_bullethell", {})
				return
			end
	 		if (targetPos - caster:GetAbsOrigin()):Length2D() < 10 then
	 			caster:SetRenderColor(0,0,255)
				caster:SetHealth(caster:GetMaxHealth())
				caster:RemoveModifierByNameAndCaster("modifier_boss_primal_bullethell", caster)
	 			ability:ApplyDataDrivenModifier(caster, caster, "modifier_boss_primal_bullethell_active", {})
	 		else
	 			return 0.1
	 		end
	 	end)
	end
end