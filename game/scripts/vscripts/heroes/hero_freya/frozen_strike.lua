
freya_frozen_strike = class({})

if IsServer() then
	function freya_frozen_strike:OnSpellStart()
		local caster = self:GetCaster()
		local modifier = caster:AddNewModifier(caster, self, "modifier_freya_frozen_strike_crit", nil)
		local crit =
			self:GetSpecialValueFor("base_crit_pct") +
			(self:GetSpecialValueFor("stat_to_crit_pct") * caster:GetPrimaryStatValue() * 0.01)
		modifier:SetStackCount(crit)
		caster:EmitSound("Arena.Hero_Freya.FrozenStrike.Charge")
	end
end


LinkLuaModifier("modifier_freya_frozen_strike_crit", "heroes/hero_freya/frozen_strike.lua", LUA_MODIFIER_MOTION_NONE)
modifier_freya_frozen_strike_crit = class({
	IsPurgable = function() return false end,
	DeclareFunctions = function() return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
	} end
})

if IsServer() then
	function modifier_freya_frozen_strike_crit:OnCreated(keys)
		local caster = self:GetCaster()
		self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_tusk/tusk_rubickpunch_status.vpcf", PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControlEnt(self.particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_weapon", caster:GetAbsOrigin(), true)
	end

	function modifier_freya_frozen_strike_crit:OnDestroy(keys)
		ParticleManager:DestroyParticle(self.particle, false)
		ParticleManager:ReleaseParticleIndex(self.particle)
	end

	function modifier_freya_frozen_strike_crit:OnAttackLanded(keys)
		local attacker = keys.attacker
		if attacker ~= self:GetCaster() then return end

		local target = keys.target
		local ability = self:GetAbility()

		attacker:EmitSound("Arena.Hero_Freya.FrozenStrike.Impact")
		local particle = ParticleManager:CreateParticle("particles/arena/units/heroes/hero_freya/frozen_strike_critical.vpcf", PATTACH_ABSORIGIN, attacker)
		ParticleManager:SetParticleControlEnt(particle, 0, attacker, PATTACH_POINT_FOLLOW, "attach_weapon", attacker:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(particle)

		local casterPos = attacker:GetAbsOrigin()
		local knockbackDuration = ability:GetSpecialValueFor("knockback_duration")
		target:AddNewModifier(target, ability, "modifier_knockback", {
			center_x = casterPos.x,
			center_y = casterPos.y,
			center_z = casterPos.z,
			duration = knockbackDuration,
			knockback_duration = knockbackDuration,
			knockback_distance = ability:GetSpecialValueFor("knockback_range"),
			knockback_height = 400
		})

		local cleaveRadius = ability:GetSpecialValueFor("cleave_radius")
		DoCleaveAttack(attacker, target, ability, keys.damage, 150, cleaveRadius, cleaveRadius, "particles/units/heroes/hero_sven/sven_spell_great_cleave.vpcf")

		self:Destroy()
	end

	function modifier_freya_frozen_strike_crit:GetModifierPreAttack_CriticalStrike()
		return self:GetStackCount()
	end

	function modifier_freya_frozen_strike_crit:CheckState()
		return { [MODIFIER_STATE_CANNOT_MISS] = true }
	end
end
