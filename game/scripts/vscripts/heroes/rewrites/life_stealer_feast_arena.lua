life_stealer_feast_arena = class({
	GetIntrinsicModifierName = function() return "modifier_life_stealer_feast_arena" end,
})


LinkLuaModifier("modifier_life_stealer_feast_arena", "heroes/rewrites/life_stealer_feast_arena.lua", LUA_MODIFIER_MOTION_NONE)
modifier_life_stealer_feast_arena = class({
	IsHidden   = function() return true end,
	IsPurgable = function() return false end,
})

function modifier_life_stealer_feast_arena:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

if IsServer() then
	function modifier_life_stealer_feast_arena:GetModifierPreAttack_BonusDamage()
		if IsValidEntity(self.BonusDamageTarget) then
			return self.BonusDamageTarget:GetHealth() * self:GetAbility():GetSpecialValueFor("hp_leech_percent") * 0.01
		end
	end

	function modifier_life_stealer_feast_arena:OnAttackStart(keys)
		if keys.attacker == self:GetParent() then
			if keys.target:IsBoss() then
				self.BonusDamageTarget = nil
			else
				self.BonusDamageTarget = keys.target
			end
		end
	end

	function modifier_life_stealer_feast_arena:OnAttackLanded(keys)
		local attacker = keys.attacker
		if attacker == self:GetParent() then
			local ability = self:GetAbility()
			local target = keys.target
			if IsValidEntity(self.BonusDamageTarget) then
				local leech = self.BonusDamageTarget:GetHealth() * self:GetAbility():GetSpecialValueFor("hp_leech_percent") * 0.01
				SafeHeal(attacker, leech, ability, true)
				-- original uses particles/generic_gameplay/generic_lifesteal.vpcf for some reason
				ParticleManager:CreateParticle("particles/units/heroes/hero_life_stealer/life_stealer_feast.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)
			end
		end
	end
end
