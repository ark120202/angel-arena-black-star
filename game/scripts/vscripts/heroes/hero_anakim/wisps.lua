LinkLuaModifier("modifier_anakim_wisps", "heroes/hero_anakim/wisps.lua", LUA_MODIFIER_MOTION_NONE)

anakim_wisps = class({
	GetIntrinsicModifierName = function() return "modifier_anakim_wisps" end,
})

modifier_anakim_wisps = class({
	IsHidden = function() return true end,
	IsPurgable = function() return false end,
	DeclareFunctions = function()
		return {
			MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		}
	end,
})

if IsServer() then
	function modifier_anakim_wisps:OnCreated()
		local ability = self:GetAbility()
		ability:SetLevel(ability:GetMaxLevel())
	end

	function modifier_anakim_wisps:OnAttackLanded(keys)
		local attacker = keys.attacker
		if attacker ~= self:GetParent() then return end
		local ability = self:GetAbility()
		local target = keys.target
		local damage = keys.original_damage

		local dt = {
			victim = target,
			attacker = attacker,
			ability = ability,
			damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
		}
		dt.damage_type = DAMAGE_TYPE_PURE
		dt.damage = damage * ability:GetSpecialValueFor("pure_damage_pct") * 0.01
		ApplyDamage(dt)
		dt.damage_type = DAMAGE_TYPE_MAGICAL
		dt.damage = damage * ability:GetSpecialValueFor("magic_damage_pct") * 0.01
		ApplyDamage(dt)
		dt.damage_type = DAMAGE_TYPE_PHYSICAL
		dt.damage = damage * ability:GetSpecialValueFor("physical_damage_pct") * 0.01
		ApplyDamage(dt)
	end

	function modifier_anakim_wisps:GetModifierPreAttack_CriticalStrike()
		local ability = self:GetAbility()
		if RollPercentage(ability:GetSpecialValueFor("critical_chance_pct")) then
			return ability:GetSpecialValueFor("critical_damage_pct")
		end
	end
end
