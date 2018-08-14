LinkLuaModifier("modifier_meat_hook_followthrough_lua", "heroes/hero_pudge/pudge_meat_hook_lua.lua" ,LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_meat_hook_lua", "heroes/hero_pudge/pudge_meat_hook_lua.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_meat_hook_bloodstained_lua", "heroes/hero_pudge/pudge_meat_hook_lua.lua" ,LUA_MODIFIER_MOTION_NONE)

pudge_meat_hook_lua = class({
	GetIntrinsicModifierName = function() return "modifier_meat_hook_bloodstained_lua" end,
})

function pudge_meat_hook_lua:GetCooldown(nLevel)
	return self:GetCaster():HasScepter() and self:GetSpecialValueFor("cooldown_scepter") or self.BaseClass.GetCooldown(self, nLevel)
end

function pudge_meat_hook_lua:GetCastRange()
	return self:GetSpecialValueFor("hook_distance") + self:GetSpecialValueFor("hook_distance_per_stack") * self:GetCaster():GetModifierStackCount(self:GetIntrinsicModifierName(), self:GetCaster())
end

if IsServer() then
	function pudge_meat_hook_lua:OnAbilityPhaseStart()
		self:GetCaster():StartGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
		return true
	end

	function pudge_meat_hook_lua:OnAbilityPhaseInterrupted()
		self:GetCaster():RemoveGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
	end

	function pudge_meat_hook_lua:DestroyHookParticles()
		local caster = self:GetCaster()
		caster:RemoveGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
		if caster and caster:IsHero() then
			local hHook = caster:GetTogglableWearable(DOTA_LOADOUT_TYPE_WEAPON)
			if hHook ~= nil then
				hHook:RemoveEffects(EF_NODRAW)
			end
		end
		caster:EmitSound("Hero_Pudge.AttackHookRetractStop")
		if self.projectiles then
			for k,v in ipairs(self.projectiles) do
				v:OnFinish()
				v:Destroy()
			end
		end
	end

	function pudge_meat_hook_lua:OnSpellStart()
		local caster = self:GetCaster()
		local hookCount = caster:GetTalentSpecial("talent_hero_pudge_hook_splitter", "hook_amount") or 1
		local hook_damage = self:GetAbilityDamage()
		local hook_speed = self:GetSpecialValueFor("hook_speed")
		local hook_width = self:GetSpecialValueFor("hook_width")
		local hook_distance = self:GetCastRange()
		local hook_followthrough_constant = self:GetSpecialValueFor("hook_followthrough_constant")
		if caster:HasScepter() then
			hook_damage = self:GetSpecialValueFor("damage_scepter")
		end

		if caster and caster:IsHero() then
			local hHook = caster:GetTogglableWearable(DOTA_LOADOUT_TYPE_WEAPON)
			if hHook then
				hHook:AddEffects(EF_NODRAW)
			end
		end

		if not caster:HasScepter() then
			caster:AddNewModifier(caster, self, "modifier_meat_hook_followthrough_lua", {duration = hook_distance / hook_speed * hook_followthrough_constant})
		end
		local base_direction = (self:GetCursorPosition() - caster:GetAbsOrigin()):Normalized()
		base_direction.z = 0
		for i = 0, hookCount-1 do
			local vDirection = base_direction
			if hookCount > 1 then
				local fullAngle = 60
				local factor = fullAngle/(hookCount-1)
				vDirection = RotatePosition(Vector(0,0,0), QAngle(0, fullAngle/2-factor*i, 0), base_direction)
			end
			local vHookOffset = Vector(0, 0, 96)

			local hook_chain_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_meathook_chain.vpcf", PATTACH_CUSTOMORIGIN, caster)
			ParticleManager:SetParticleAlwaysSimulate(hook_chain_pfx)
			ParticleManager:SetParticleControlEnt(hook_chain_pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", caster:GetOrigin() + vHookOffset, true)
			ParticleManager:SetParticleControl(hook_chain_pfx, 1, caster:GetOrigin() + vHookOffset)
			ParticleManager:SetParticleControl(hook_chain_pfx, 2, Vector(hook_speed, hook_distance, hook_width))
			ParticleManager:SetParticleControl(hook_chain_pfx, 6, caster:GetOrigin() + vHookOffset)
			ParticleManager:SetParticleControlEnt(hook_chain_pfx, 7, caster, PATTACH_CUSTOMORIGIN, nil, caster:GetOrigin(), true)
			caster:EmitSound("Hero_Pudge.AttackHookExtend")
			local projbase = {
				fStartRadius = hook_width,
				fEndRadius = hook_width,
				fDistance = hook_distance,
				Source = caster,
				UnitTest = function(proj, unit)
					return UnitFilter(unit, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS, caster:GetTeamNumber()) == UF_SUCCESS
				end,
				WallBehavior = PROJECTILES_NOTHING,
				GroundBehavior = PROJECTILES_NOTHING,
				TreeBehavior = PROJECTILES_NOTHING,
				UnitBehavior = PROJECTILES_NOTHING,
				bGroundLock = true,
				OnUnitHit = function(proj, target)
					self:OnProjectileHit(target, proj:GetPosition(), proj, hook_damage)
				end,
				bProvidesVision = true,
				iVisionRadius = self:GetSpecialValueFor("vision_radius"),
				iVisionTeamNumber = caster:GetTeamNumber(),
				bFlyingVision = false,
				fVisionTickTime = .1,
				fVisionLingerDuration = 1,
			}
			local projectileTable = {
				vSpawnOrigin = caster:GetOrigin(),
				vVelocity = vDirection:Normalized() * hook_speed,
				OnFinish = function(proj, pos)
					if IsValidEntity(self) and IsValidEntity(caster) then
						table.removeByValue(self.projectiles, proj)
						if pos then
							local vHookPos = pos
							local flPad = caster:GetPaddedCollisionRadius()
							vVelocity = caster:GetAbsOrigin() - vHookPos
							vVelocity.z = 0
							vVelocity = vVelocity:Normalized() * hook_speed

							if caster:IsAlive() then
								caster:EmitSound("Hero_Pudge.AttackHookRetract")
								caster:RemoveGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
								caster:StartGesture(ACT_DOTA_CHANNEL_ABILITY_1)
							end
							Timers:RemoveTimer(proj.Thinker)
							Timers:CreateTimer(0.03, function()
								local newProjTable = {
									vSpawnOrigin = vHookPos,
									vVelocity = vVelocity,
									fDistance = 99999,
									fExpireTime = 99999,
									OnFinish = function(proj, pos)
										local is_valid = IsValidEntity(self) and IsValidEntity(caster)
										if is_valid then
											table.removeByValue(self.projectiles, proj)
											if caster and caster:IsHero() then
												local hHook = caster:GetTogglableWearable(DOTA_LOADOUT_TYPE_WEAPON)
												if hHook ~= nil then
													hHook:RemoveEffects(EF_NODRAW)
												end
											end
											caster:EmitSound("Hero_Pudge.AttackHookRetractStop")
										end

										if proj.hVictim and #proj.hVictim > 0 then
											for _,v in ipairs(proj.hVictim) do
												if not v:IsNull() and v:IsAlive() then
													v:InterruptMotionControllers(true)
													v:RemoveModifierByName("modifier_meat_hook_lua")
												end
											end
										end
										Timers:RemoveTimer(proj.Thinker)
										proj.hVictim = nil
										ParticleManager:DestroyParticle(hook_chain_pfx, true)
									end,
									hVictim = proj.hVictim,
								}
								table.merge(newProjTable, projbase)
								local newProjectile = Projectiles:CreateProjectile(newProjTable)
								table.insert(self.projectiles, newProjectile)
								proj.newProjectile = newProjectile
								newProjectile.Thinker = Timers:CreateTimer(function()
									if IsValidEntity(self) and IsValidEntity(caster) then
										ParticleManager:SetParticleControl(hook_chain_pfx, 6, newProjectile:GetPosition() + vHookOffset)
										vVelocity = caster:GetAbsOrigin() - newProjectile:GetPosition()
										vVelocity.z = 0
										vVelocity = vVelocity:Normalized() * hook_speed
										if (caster:GetAbsOrigin() - newProjectile:GetPosition()):Length2D() < 128 then
											newProjectile.OnFinish(newProjectile, newProjectile:GetPosition())
											newProjectile:Destroy()
										end
										newProjectile.spawnTime = Time()
										newProjectile.distanceTraveled = 0
										newProjectile.vel = vVelocity / 30
										return 0.03
									end
								end)
							end)
						else
							if proj.hVictim then
								for _,v in ipairs(proj.hVictim) do
									if not v:IsNull() and v:IsAlive() then
										v:InterruptMotionControllers(true)
										v:RemoveModifierByName("modifier_meat_hook_lua")
									end
								end
							end
							Timers:RemoveTimer(proj.Thinker)
							proj.hVictim = nil
							ParticleManager:DestroyParticle(hook_chain_pfx, true)
						end
					else
						if proj.hVictim then
							for _,v in ipairs(proj.hVictim) do
								if not v:IsNull() and v:IsAlive() then
									v:InterruptMotionControllers(true)
									v:RemoveModifierByName("modifier_meat_hook_lua")
								end
							end
						end
						Timers:RemoveTimer(proj.Thinker)
						proj.hVictim = nil
						ParticleManager:DestroyParticle(hook_chain_pfx, true)
					end
				end,
			}
			table.merge(projectileTable, projbase)
			local projectile = Projectiles:CreateProjectile(projectileTable)

			projectile.Thinker = Timers:CreateTimer(function()
				ParticleManager:SetParticleControl(hook_chain_pfx, 6, projectile:GetPosition() + vHookOffset)
				return 0.03
			end)
			projectile.hVictim = {}
			self.projectiles = self.projectiles or {}
			table.insert(self.projectiles, projectile)
		end
	end


	function pudge_meat_hook_lua:OnProjectileHit(hTarget, vLocation, proj, hook_damage)
		local caster = self:GetCaster()
		if not hTarget then return false end
		if hTarget == caster then return false end
		if hTarget.SpawnerType == "jungle" then return false end
		if not hTarget:IsCreep() and not hTarget:IsConsideredHero() then return false end

		if not proj.hVictim or not table.includes(proj.hVictim, hTarget) then
			hTarget:EmitSound("Hero_Pudge.AttackHookImpact")
			self.projectile = proj
			hTarget:AddNewModifier(caster, self, "modifier_meat_hook_lua", nil)
			self.projectile = nil
			if hTarget:GetTeamNumber() ~= caster:GetTeamNumber() then
				ApplyDamage({
					victim = hTarget,
					attacker = caster,
					damage = hook_damage,
					damage_type = DAMAGE_TYPE_PURE,
					ability = self
				})

				if not hTarget:IsAlive() and hTarget:IsRealHero() then
					local hBuff = caster:FindModifierByName(self:GetIntrinsicModifierName())
					if hBuff then
						hBuff:IncrementStackCount()
					end
				end

				if not hTarget:IsMagicImmune() then
					hTarget:Interrupt()
				end

				local nFXIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_meathook_impact.vpcf", PATTACH_CUSTOMORIGIN, hTarget)
				ParticleManager:SetParticleControlEnt(nFXIndex, 0, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetOrigin(), true)
				ParticleManager:ReleaseParticleIndex(nFXIndex)
			end
			if not proj.hVictim then proj.hVictim = {} end
			table.insert(proj.hVictim, hTarget)
		end

		return false
	end


	function pudge_meat_hook_lua:OnOwnerDied()
		local caster = self:GetCaster()
		caster:RemoveGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
		caster:RemoveGesture(ACT_DOTA_CHANNEL_ABILITY_1)
	end
end


modifier_meat_hook_bloodstained_lua = class({
	GetTexture    = function() return "arena/modifier_meat_hook_bloodstained_lua" end,
	GetAttributes = function() return MODIFIER_ATTRIBUTE_PERMANENT end,
	IsPurgable    = function() return false end,
})

function modifier_meat_hook_bloodstained_lua:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP}
end

function modifier_meat_hook_bloodstained_lua:OnTooltip()
	return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("hook_distance_per_stack")
end

modifier_meat_hook_followthrough_lua = class({
	IsHidden   = function() return true end,
	CheckState = function() return {[MODIFIER_STATE_STUNNED] = true} end,
	IsPurgable = function() return false end,
})

modifier_meat_hook_lua = class({
	IsDebuff             = function() return true end,
	IsStunDebuff         = function() return true end,
	RemoveOnDeath        = function() return false end,
	DeclareFunctions     = function() return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION} end,
	GetOverrideAnimation = function() return ACT_DOTA_FLAIL end,
	IsPurgable           = function() return false end,
})

if IsServer() then
	function modifier_meat_hook_lua:OnCreated(kv)
		self.Projectile = self:GetAbility().projectile
		if not self:ApplyHorizontalMotionController() then
			self:Destroy()
		end
	end

	function modifier_meat_hook_lua:CheckState()
		local caster = self:GetCaster()
		if caster and self:GetParent() then
			if caster:GetTeamNumber() ~= self:GetParent():GetTeamNumber() and not self:GetParent():IsMagicImmune() then
				return {[MODIFIER_STATE_STUNNED] = true}
			end
		end
	end

	function modifier_meat_hook_lua:UpdateHorizontalMotion(me, dt)
		local abs = self.Projectile:GetPosition()
		if self.Projectile.newProjectile then
			abs = self.Projectile.newProjectile:GetPosition()
		end
		self:GetParent():SetOrigin(abs)
	end

	function modifier_meat_hook_lua:OnHorizontalMotionInterrupted()
		self:Destroy()
	end
end
