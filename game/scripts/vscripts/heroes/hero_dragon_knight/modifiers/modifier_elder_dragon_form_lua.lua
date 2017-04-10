modifier_elder_dragon_form_lua = class({})

function modifier_elder_dragon_form_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
	}

	return funcs
end

local modData = {
	[1] = {
		model = "models/heroes/dragon_knight/dragon_knight_dragon.vmdl",
		attackProjectile = "particles/units/heroes/hero_dragon_knight/dragon_knight_elder_dragon_fire.vpcf",
	},
	[2] = {
		model = "models/heroes/viper/viper.vmdl",
		attackProjectile = "particles/units/heroes/hero_viper/viper_poison_attack.vpcf",
	},
	[3] = {
		model = "models/heroes/puck/puck.vmdl",
		attackProjectile = "particles/econ/items/puck/puck_alliance_set/puck_base_attack_aproset.vpcf",
	},
	[4] = {
		model = "models/heroes/phoenix/phoenix_bird.vmdl",
		attackProjectile = "particles/units/heroes/hero_phoenix/phoenix_base_attack.vpcf",
	},
	[5] = {
		model = "models/heroes/jakiro/jakiro.vmdl",
		attackProjectile = {"particles/units/heroes/hero_jakiro/jakiro_base_attack.vpcf", "particles/units/heroes/hero_jakiro/jakiro_base_attack_fire.vpcf"}
	},
	[6] = {
		model = "models/heroes/winterwyvern/winterwyvern.vmdl",
		attackProjectile = "particles/units/heroes/hero_winter_wyvern/winter_wyvern_arctic_attack.vpcf",
	},
	[7] = {
		model = "models/heroes/visage/visage_familiar.vmdl",
		attackProjectile = "particles/econ/items/visage/immortal_familiar/visage_immortal_ti5/visage_familiar_base_attack_ti5.vpcf",
	},
}

function modifier_elder_dragon_form_lua:OnCreated(keys) if IsServer() then
	self.level = keys.Level or self:GetAbility():GetLevel()
	self.attack_capability = self:GetParent():GetAttackCapability()
	self:GetParent():SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
	if self.level == 5 then
		self:GetParent():SetRangedProjectileName(modData[self.level].attackProjectile[1])
	else
		self:GetParent():SetRangedProjectileName(modData[self.level].attackProjectile)
	end
end end

function modifier_elder_dragon_form_lua:OnDestroy() if IsServer() then
	ParticleManager:CreateParticle("particles/units/heroes/hero_dragon_knight/dragon_knight_transform_green.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	self:GetParent():SetAttackCapability(self.attack_capability)
end end

function modifier_elder_dragon_form_lua:GetModifierModelChange()
	return modData[self.level].model
end

function modifier_elder_dragon_form_lua:OnAttack(keys)
	if IsServer() and keys.attacker == self:GetParent() then
		self:GetParent():EmitSound("Hero_DragonKnight.ElderDragonShoot1.Attack")
		if self.level == 5 then
			self:GetParent():SetRangedProjectileName(modData[self.level].attackProjectile[RandomInt(1, 2)])
		end
	end
end

function modifier_elder_dragon_form_lua:OnAttackLanded(keys)
	if IsServer() and keys.attacker == self:GetParent() then
		local target = keys.target
		local attacker = keys.attacker
		local ability = self:GetAbility()
		if self.level >= 1 then
			target:EmitSound("Hero_DragonKnight.ProjectileImpact")
			local dmgTable = {
				attacker = attacker,
				damage_type = DAMAGE_TYPE_PURE,
				damage = attacker:GetAverageTrueAttackDamage(target) * ability:GetLevelSpecialValueFor("splash_damage_percent", self.level) * 0.01,
				ability = ability
			}
			if not attacker:IsIllusion() then
				for i,v in ipairs(FindUnitsInRadius(attacker:GetTeam(), target:GetAbsOrigin(), nil, ability:GetLevelSpecialValueFor("splash_radius", self.level), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)) do
					if v ~= target then
						Timers:CreateTimer(0.03 * i, function()
							dmgTable.victim = v
							ApplyDamage(dmgTable)
						end)
					end
				end
			end
			if self.level >= 2 then
				if not target:IsMagicImmune() and not target:IsInvulnerable() then
					ability:ApplyDataDrivenModifier(attacker, target, "modifier_dragon_knight_elder_dragon_form_arena_poison", {})
				end
				if self.level >= 3 then
					if not target:IsMagicImmune() and not target:IsInvulnerable() and RollPercentage(ability:GetLevelSpecialValueFor("silence_chance", self.level)) then
						target:AddNewModifier(attacker, ability, "modifier_silence", {duration = ability:GetLevelSpecialValueFor("silence_duration", self.level)})
					end
					if self.level >= 4 then
						if not target:IsMagicImmune() and not target:IsInvulnerable() then
							ability:ApplyDataDrivenModifier(attacker, target, "modifier_dragon_knight_elder_dragon_form_arena_flame_debuff", {})
						end
						if self.level >= 5 then
							if RollPercentage(ability:GetLevelSpecialValueFor("breath_chance", self.level)) then
								-------------------------------------------------------------------------------------------------------------------
								local casterOrigin = attacker:GetAbsOrigin()
								local direction = target:GetAbsOrigin() - casterOrigin
								direction = direction / direction:Length2D()
								local distance = ability:GetLevelSpecialValueFor("breath_distance", self.level)
								local speed = ability:GetLevelSpecialValueFor("breath_speed", self.level)
								local start_radius = ability:GetLevelSpecialValueFor("breath_start_radius", self.level)
								local end_radius = ability:GetLevelSpecialValueFor("breath_end_radius", self.level)

								ProjectileManager:CreateLinearProjectile( {
									Ability				= ability,
									vSpawnOrigin		= casterOrigin,
									fDistance			= distance,
									fStartRadius		= start_radius,
									fEndRadius			= end_radius,
									Source				= attacker,
									bHasFrontalCone		= true,
									bReplaceExisting	= false,
									iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
									iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NONE,
									iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
									bDeleteOnHit		= false,
									vVelocity			= direction * distance,
									bProvidesVision		= false,
								} )

								local particleName = "particles/units/heroes/hero_jakiro/jakiro_dual_breath_ice.vpcf"
								local pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, attacker )
								ParticleManager:SetParticleControl( pfx, 0, casterOrigin )
								ParticleManager:SetParticleControl( pfx, 1, direction * distance * 1.333 )
								ParticleManager:SetParticleControl( pfx, 3, Vector(0,0,0) )
								ParticleManager:SetParticleControl( pfx, 9, casterOrigin )
								local particleName2 = "particles/units/heroes/hero_jakiro/jakiro_dual_breath_fire.vpcf"
								local pfx2 = ParticleManager:CreateParticle( particleName2, PATTACH_ABSORIGIN, attacker )
								ParticleManager:SetParticleControl( pfx2, 0, casterOrigin )
								ParticleManager:SetParticleControl( pfx2, 1, direction * distance * 1.333 )
								ParticleManager:SetParticleControl( pfx2, 3, Vector(0,0,0) )
								ParticleManager:SetParticleControl( pfx2, 9, casterOrigin )
								attacker:SetContextThink( DoUniqueString( "destroy_particle" ), function ()
									ParticleManager:DestroyParticle( pfx, false )
									ParticleManager:DestroyParticle( pfx2, false )
								end, distance / distance )
								-------------------------------------------------------------------------------------------------------------------
							end
							if self.level >= 6 then
								if not target:IsMagicImmune() and not target:IsInvulnerable() then
									ability:ApplyDataDrivenModifier(attacker, target, "modifier_dragon_knight_elder_dragon_form_arena_cold", {})
								end
							end
						end
					end
				end
			end
		end
	end
end

function modifier_elder_dragon_form_lua:IsHidden() 
	return false
end

function modifier_elder_dragon_form_lua:GetModifierAttackRangeBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_attack_range")
end

function modifier_elder_dragon_form_lua:GetModifierMoveSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("bonus_movement_speed")
end

function modifier_elder_dragon_form_lua:IsPurgable()
	return false
end