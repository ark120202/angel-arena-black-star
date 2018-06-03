local fireSplitshotProjectilesFactory = require("items/helper_splitshot")

gyrocopter_flak_cannon_arena = {
	GetIntrinsicModifierName = function() return "modifier_gyrocopter_flak_cannon_arena_scepter" end
}

if IsServer() then
	function gyrocopter_flak_cannon_arena:OnSpellStart()
		local caster = self:GetCaster()

		local modifier = caster:AddNewModifier(
			caster,
			self,
			"modifier_gyrocopter_flak_cannon_arena",
			{ duration = self:GetSpecialValueFor("max_duration")
		})
		modifier:SetStackCount(self:GetSpecialValueFor("max_attacks"))

		caster:EmitSound("FlackCannon.Activate")
	end

	function gyrocopter_flak_cannon_arena:OnProjectileHit(hTarget)
		if not hTarget then return end
		local caster = self:GetCaster()
		if caster:IsIllusion() then return end

		ApplyDamage({
			attacker = caster,
			victim = hTarget,
			damage = caster:GetAverageTrueAttackDamage(target),
			damage_type = self:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS,
			ability = self
		})

		hTarget:EmitSound("Hero_Medusa.AttackSplit")
	end
end


LinkLuaModifier("modifier_gyrocopter_flak_cannon_arena", "heroes/rewrites/gyrocopter_flak_cannon_arena.lua", LUA_MODIFIER_MOTION_NONE)
modifier_gyrocopter_flak_cannon_arena = {
	GetEffectAttachType = function() return PATTACH_OVERHEAD_FOLLOW end,
	GetEffectName = function() return "particles/units/heroes/hero_gyrocopter/gyro_flak_cannon_overhead.vpcf" end,
}

if IsServer() then
	function modifier_gyrocopter_flak_cannon_arena:DeclareFunctions()
		return { MODIFIER_EVENT_ON_ATTACK }
	end

	local fireProjectiles = fireSplitshotProjectilesFactory(nil, "radius", "projectile_speed")
	function modifier_gyrocopter_flak_cannon_arena:OnAttack(keys)
		local attacker = keys.attacker
		if attacker == self:GetParent() then
			local target = keys.target
			local ability = self:GetAbility()

			fireProjectiles(attacker, target, ability)

			target:EmitSound("Hero_Gyrocopter.FlackCannon")

			self:DecrementStackCount()
			if self:GetStackCount() == 0 then
				self:Destroy()
			end
		end
	end
end


LinkLuaModifier("modifier_gyrocopter_flak_cannon_arena_scepter", "heroes/rewrites/gyrocopter_flak_cannon_arena.lua", LUA_MODIFIER_MOTION_NONE)
modifier_gyrocopter_flak_cannon_arena_scepter = {
	IsHidden = function() return true end,
	IsPurgable = function() return false end,
}

if IsServer() then
	function modifier_gyrocopter_flak_cannon_arena_scepter:OnCreated()
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("fire_rate_scepter"))
	end

	function modifier_gyrocopter_flak_cannon_arena_scepter:OnIntervalThink()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		if not parent:HasScepter() then return end

		local units = FindUnitsInRadius(
			caster:GetTeam(),
			caster:GetAbsOrigin(),
			nil,
			ability:GetSpecialValueFor("scepter_radius"),
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
			FIND_CLOSEST,
			false
		)

		if #units > 0 then
			PerformGlobalAttack(
				caster,
				units[RandomInt(1, #units)],
				true,
				true,
				true,
				false,
				true,
				false,
				false
			)
		end
	end
end
