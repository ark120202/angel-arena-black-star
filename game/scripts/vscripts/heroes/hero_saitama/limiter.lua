LinkLuaModifier("modifier_saitama_limiter_autocast", "heroes/hero_saitama/limiter.lua", LUA_MODIFIER_MOTION_NONE)

saitama_limiter = class({
	GetIntrinsicModifierName = function() return "modifier_saitama_limiter_autocast" end,
})

function saitama_limiter:GetManaCost(iLevel)
	return (self:GetCaster():GetMaxMana() * self:GetSpecialValueFor("manacost_pct") * 0.01) + self:GetSpecialValueFor("manacost")
end

if IsServer() then
	function saitama_limiter:OnSpellStart()
		local caster = self:GetCaster()
		caster:ModifyStrength(caster:GetStrength() * self:GetSpecialValueFor("bonus_strength_pct") * caster:GetModifierStackCount("modifier_saitama_limiter", caster) * 0.01)
	end
end

modifier_saitama_limiter_autocast = class({
	IsHidden = function() return true end,
})

if IsServer() then
	function modifier_saitama_limiter_autocast:OnCreated()
		self:StartIntervalThink(0.1)
	end
	function modifier_saitama_limiter_autocast:OnIntervalThink()
		local ability = self:GetAbility()
		local parent = self:GetParent()
		if parent:IsAlive() then
			if ability:GetAutoCastState() and ability:GetManaCost() < parent:GetMana() then
				parent:CastAbilityNoTarget(ability, parent:GetPlayerID())
			end
		end
	end
end
