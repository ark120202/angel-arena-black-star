tinker_rearm_arena = class({})
LinkLuaModifier("modifier_tinker_rearm_arena", "heroes/hero_tinker/modifier_tinker_rearm_arena.lua", LUA_MODIFIER_MOTION_NONE)
if IsServer() then
	function tinker_rearm_arena:OnSpellStart()
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		if IsValidEntity(target) and not target:IsMagicImmune() and not target:IsInvulnerable() then
			caster:EmitSound("Hero_Tinker.Rearm")
			ProjectileManager:CreateTrackingProjectile({
				EffectName = "particles/arena/units/heroes/hero_tinker/rearm_projectile.vpcf",
				Ability = self,
				vSpawnOrigin = caster:GetAbsOrigin(),
				Target = target,
				Source = caster,
				bHasFrontalCone = false,
				iMoveSpeed = self:GetSpecialValueFor("projectile_speed"),
				bReplaceExisting = false,
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
				bDodgeable = false,
			})
			StartAnimation(caster, {
				duration = self:GetReducedCooldown(),
				activity = _G["ACT_DOTA_TINKER_REARM" .. self:GetLevel()] or ACT_DOTA_TINKER_REARM3
			})
		end
	end

	function tinker_rearm_arena:OnAbilityPhaseStart()
		self:GetCaster():EmitSound("Hero_Tinker.RearmStart")
	end

	function tinker_rearm_arena:OnProjectileHit(hTarget, vLocation)
		if IsValidEntity(hTarget) then
			local caster = self:GetCaster()
			if hTarget:GetTeam() == caster:GetTeam() then
				local chance = self:GetSpecialValueFor("refresh_chance_pct")
				for i = 0, hTarget:GetAbilityCount() - 1 do
					local ability = hTarget:GetAbilityByIndex(i)
					if ability and not ability:HasBehavior(DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) and not REFRESH_LIST_IGNORE_REARM[ability:GetAbilityName()] and RollPercentage(chance) then
						ability:EndCooldown()
					end
				end
				for i = DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_9 do
					local item = hTarget:GetItemInSlot(i)
					if item and not item:HasBehavior(DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) and not REFRESH_LIST_IGNORE_REARM[item:GetAbilityName()] and RollPercentage(chance) then
						item:EndCooldown()
					end
				end
				hTarget:EmitSound("Hero_Tinker.Rearm")
			else
				hTarget:AddNewModifier(caster, self, "modifier_tinker_rearm_arena", {duration = self:GetSpecialValueFor("debuff_duration")})
			end
		end
	end
end