pudge_meat_hook_lua = class({})
LinkLuaModifier( "modifier_meat_hook_followthrough_lua", "heroes/hero_pudge/modifiers/modifier_meat_hook_followthrough_lua.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_meat_hook_lua", "heroes/hero_pudge/modifiers/modifier_meat_hook_lua.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_meat_hook_bloodstained_lua", "heroes/hero_pudge/modifiers/modifier_meat_hook_bloodstained_lua.lua" ,LUA_MODIFIER_MOTION_NONE )

function pudge_meat_hook_lua:GetIntrinsicModifierName()
	return "modifier_meat_hook_bloodstained_lua"
end

function pudge_meat_hook_lua:GetCooldown(nLevel)
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("cooldown_scepter")
	else
		return self.BaseClass.GetCooldown( self, nLevel )
	end
end

function pudge_meat_hook_lua:GetCastRange()
	local iBuff = self:GetCaster():GetModifierStackCount( self:GetIntrinsicModifierName(), self:GetCaster() )
	if iBuff then
		return self:GetSpecialValueFor("hook_distance") + (self:GetSpecialValueFor("hook_distance_per_stack") * iBuff)
	else
		return self:GetSpecialValueFor("hook_distance")
	end
end

if IsServer() then

function pudge_meat_hook_lua:OnAbilityPhaseStart()
	self:GetCaster():StartGesture( ACT_DOTA_OVERRIDE_ABILITY_1 )
	return true
end


function pudge_meat_hook_lua:OnAbilityPhaseInterrupted()
	self:GetCaster():RemoveGesture( ACT_DOTA_OVERRIDE_ABILITY_1 )
end


function pudge_meat_hook_lua:OnSpellStart()
	local hook_damage = self:GetAbilityDamage()
	local hook_speed = self:GetSpecialValueFor( "hook_speed" )
	local hook_width = self:GetSpecialValueFor( "hook_width" )
	local hook_distance = self:GetCastRange()
	local hook_followthrough_constant = self:GetSpecialValueFor( "hook_followthrough_constant" )
	if self:GetCaster():HasScepter() then
		hook_damage = self:GetSpecialValueFor( "damage_scepter" )
	end
	
	if self:GetCaster() and self:GetCaster():IsHero() then
		local hHook = self:GetCaster():GetTogglableWearable( DOTA_LOADOUT_TYPE_WEAPON )
		if hHook ~= nil then
			hHook:AddEffects( EF_NODRAW )
		end
	end

	local vDirection = self:GetCursorPosition() - self:GetCaster():GetOrigin()
	vDirection.z = 0.0

	local vDirection = ( vDirection:Normalized() ) * hook_distance
	self.vTargetPosition = self:GetCaster():GetOrigin() + vDirection

	if not self:GetCaster():HasScepter() then
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_meat_hook_followthrough_lua", { duration = hook_distance / hook_speed * hook_followthrough_constant } )
	end

	local vHookOffset = Vector( 0, 0, 96 )
	local vHookTarget = self.vTargetPosition + vHookOffset
	local vKillswitch = Vector( ( ( hook_distance / hook_speed ) * 2 ), 0, 0 )

	local hook_chain_pfx = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_meathook_chain.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() )
	ParticleManager:SetParticleAlwaysSimulate( hook_chain_pfx )
	ParticleManager:SetParticleControlEnt( hook_chain_pfx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", self:GetCaster():GetOrigin() + vHookOffset, true )
	ParticleManager:SetParticleControl( hook_chain_pfx, 1, self:GetCaster():GetOrigin() + vHookOffset )
	ParticleManager:SetParticleControl( hook_chain_pfx, 2, Vector( hook_speed, hook_distance, hook_width ) )
	ParticleManager:SetParticleControl( hook_chain_pfx, 6, self:GetCaster():GetOrigin() + vHookOffset )
	ParticleManager:SetParticleControlEnt(hook_chain_pfx, 7, self:GetCaster(), PATTACH_CUSTOMORIGIN, nil, self:GetCaster():GetOrigin(), true)

	EmitSoundOn( "Hero_Pudge.AttackHookExtend", self:GetCaster() )
	local projbase = {
		fStartRadius = hook_width,
		fEndRadius = hook_width,
		fDistance = hook_distance,
		Source = self:GetCaster(),
		UnitTest = function(proj, unit)
			return UnitFilter(unit, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS, self:GetCaster():GetTeamNumber()) == UF_SUCCESS
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
		iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
		bFlyingVision = false,
		fVisionTickTime = .1,
		fVisionLingerDuration = 1,
	}
	local projectileTable = {
		vSpawnOrigin = self:GetCaster():GetOrigin(),
		vVelocity = vDirection:Normalized() * hook_speed,
		OnFinish = function(proj, pos)
			local vHookPos = pos
			local flPad = self:GetCaster():GetPaddedCollisionRadius()
			vVelocity = self:GetCaster():GetAbsOrigin() - vHookPos
			vVelocity.z = 0.0
			local flDistance = vVelocity:Length2D() - flPad
			vVelocity = vVelocity:Normalized() * hook_speed

			EmitSoundOn( "Hero_Pudge.AttackHookRetract", hTarget )
			if self:GetCaster():IsAlive() then
				self:GetCaster():RemoveGesture( ACT_DOTA_OVERRIDE_ABILITY_1 );
				self:GetCaster():StartGesture( ACT_DOTA_CHANNEL_ABILITY_1 );
			end
			Timers:RemoveTimer(proj.Thinker)
			Timers:CreateTimer(0.03, function()
				local newProjTable = {
					vSpawnOrigin = vHookPos,
					vVelocity = vVelocity,
					fDistance = 99999,
					fExpireTime = 99999,
					OnFinish = function(proj, pos)
						if self:GetCaster() and self:GetCaster():IsHero() then
							local hHook = self:GetCaster():GetTogglableWearable( DOTA_LOADOUT_TYPE_WEAPON )
							if hHook ~= nil then
								hHook:RemoveEffects( EF_NODRAW )
							end
						end

						if proj.hVictim and #proj.hVictim > 0 then
							for _,v in ipairs(proj.hVictim) do
								if not v:IsNull() and v:IsAlive() then
									v:InterruptMotionControllers( true )
									v:RemoveModifierByName( "modifier_meat_hook_lua" )

									local vVictimPosCheck = v:GetOrigin() - pos 
									local flPad = self:GetCaster():GetPaddedCollisionRadius() + v:GetPaddedCollisionRadius()
									if vVictimPosCheck:Length2D() > flPad then
										FindClearSpaceForUnit( v, self:GetCaster():GetAbsOrigin(), false )
									end
								end
							end
						end
						Timers:RemoveTimer(proj.Thinker)
						proj.hVictim = nil
						ParticleManager:DestroyParticle( hook_chain_pfx, true )
						EmitSoundOn( "Hero_Pudge.AttackHookRetractStop", self:GetCaster() )
					end,
					hVictim = proj.hVictim,
				}
				table.merge(newProjTable, projbase)
				local newProjectile = Projectiles:CreateProjectile(newProjTable)
				proj.newProjectile = newProjectile
				newProjectile.Thinker = Timers:CreateTimer(function()
					ParticleManager:SetParticleControl( hook_chain_pfx, 6, newProjectile:GetPosition() + vHookOffset )
					vVelocity = self:GetCaster():GetAbsOrigin() - newProjectile:GetPosition()
					vVelocity.z = 0.0
					vVelocity = vVelocity:Normalized() * hook_speed
					if (self:GetCaster():GetAbsOrigin() - newProjectile:GetPosition()):Length2D() < 128 then
						newProjectile.OnFinish(newProjectile, newProjectile:GetPosition())
						newProjectile:Destroy()
					end
					newProjectile.spawnTime = Time()
					newProjectile.distanceTraveled = 0
					newProjectile.vel = vVelocity / 30
					return 0.03
				end)
			end)
		end,
	}
	table.merge(projectileTable, projbase)
	local projectile = Projectiles:CreateProjectile(projectileTable)
	
	projectile.Thinker = Timers:CreateTimer(function()
		ParticleManager:SetParticleControl( hook_chain_pfx, 6, projectile:GetPosition() + vHookOffset )
		return 0.03
	end)
	projectile.hVictim = {}
end


function pudge_meat_hook_lua:OnProjectileHit( hTarget, vLocation, proj, hook_damage )
	if hTarget == self:GetCaster() or (hTarget and (not (hTarget:IsCreep() or hTarget:IsConsideredHero()))) then
		return false
	end
	if hTarget then
		if not proj.hVictim or not table.contains(proj.hVictim, hTarget) then
			EmitSoundOn( "Hero_Pudge.AttackHookImpact", hTarget )
			self.projectile = proj
			hTarget:AddNewModifier( self:GetCaster(), self, "modifier_meat_hook_lua", nil )
			self.projectile = nil
			if hTarget:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
				ApplyDamage({
					victim = hTarget,
					attacker = self:GetCaster(),
					damage = hook_damage,
					damage_type = DAMAGE_TYPE_PURE,		
					ability = self
				})

				if not hTarget:IsAlive() and hTarget:IsRealHero() then
					local hBuff = self:GetCaster():FindModifierByName( self:GetIntrinsicModifierName() )
					if hBuff ~= nil then
						hBuff:IncrementStackCount()
						PopupNumbers(self:GetCaster(), "damage", Vector(255, 0, 0), 1.2, 1, POPUP_SYMBOL_PRE_PLUS, POPUP_SYMBOL_POST_LIGHTNING)
					end
				end

				if not hTarget:IsMagicImmune() then
					hTarget:Interrupt()
				end
		
				local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_meathook_impact.vpcf", PATTACH_CUSTOMORIGIN, hTarget )
				ParticleManager:SetParticleControlEnt( nFXIndex, 0, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin(), true )
				ParticleManager:ReleaseParticleIndex( nFXIndex )
			end
			if not proj.hVictim then proj.hVictim = {} end
			table.insert(proj.hVictim, hTarget)
		end
	end

	return false
end


function pudge_meat_hook_lua:OnOwnerDied()
	self:GetCaster():RemoveGesture( ACT_DOTA_OVERRIDE_ABILITY_1 );
	self:GetCaster():RemoveGesture( ACT_DOTA_CHANNEL_ABILITY_1 );
end

end