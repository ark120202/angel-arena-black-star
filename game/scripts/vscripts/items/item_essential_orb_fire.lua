function CreateProjectile(keys)
	local caster = keys.caster
	local ability = keys.ability
	local particle = "particles/arena/items_fx/essential_orb_fire_projectile.vpcf"
	local speed = ability:GetLevelSpecialValueFor("speed", ability:GetLevel() - 1)
	local range = ability:GetLevelSpecialValueFor("range", ability:GetLevel() - 1)
	local vVelocity = (keys.target_points[1] - caster:GetAbsOrigin()):Normalized() * speed
	vVelocity.z = 0
	local damage_per_hit = ability:GetLevelSpecialValueFor("damage_hit_growth", ability:GetLevel() - 1)
	local projectile = Projectiles:CreateProjectile({
		EffectName = particle,
		--vSpawnOrigin = caster:GetAbsOrigin(),
		vSpawnOrigin = caster:GetAbsOrigin() + Vector(0,0,80),
		fDistance = range,
		fExpireTime = range/speed,
		fStartRadius = 80,
		fEndRadius = 80,
		Source = caster,
		vVelocity = vVelocity,
		UnitBehavior = PROJECTILES_FOLLOW,
		bMultipleHits = false,
		bIgnoreSource = true,
		TreeBehavior = PROJECTILES_NOTHING,
		WallBehavior = PROJECTILES_NOTHING,
		GroundBehavior = PROJECTILES_NOTHING,
		bGroundLock = true,
		bCutTrees = true,
		bProvidesVision = true,
		iVisionRadius = 350,
		fVisionLingerDuration = 1,
		UnitTest = function(self, unit)
			return not unit:IsMagicImmune() and not unit:IsInvulnerable() and UnitFilter(unit, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, caster:GetTeam()) == UF_SUCCESS
		end,
		OnUnitHit = function(self, unit)
			self.unitsHit = (self.unitsHit or 0) + 1
			ApplyDamage({victim = unit,
				attacker = caster,
				damage = ability:GetAbilityDamage() + (self.unitsHit * damage_per_hit),
				damage_type = ability:GetAbilityDamageType(),
				ability = ability
			})
			ability:ApplyDataDrivenModifier(caster, unit, "modifier_item_essential_orb_fire_burn", {})
		end,
	})
	--[[Timers:CreateTimer(function()
		local pos = projectile:GetPosition()
		local ls = caster:AddAbility("lina_light_strike_array")
		ls:SetLevel(7)
		caster:SetCursorPosition(pos)
		ls:OnSpellStart()
		UTIL_Remove(ls)
		local ls = caster:AddAbility("invoker_sun_strike")
		ls:SetLevel(7)
		caster:SetCursorPosition(pos)
		ls:OnSpellStart()
		UTIL_Remove(ls)
		Timers:CreateTimer(1, function()
			local ls = caster:AddAbility("invoker_chaos_meteor")
			ls:SetLevel(7)
			caster:SetCursorPosition(pos)
			ls:OnSpellStart()
			UTIL_Remove(ls)
		end)
		return 0.5
	end)]]
end