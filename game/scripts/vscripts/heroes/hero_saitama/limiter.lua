LinkLuaModifier("modifier_saitama_limiter_autocast", "heroes/hero_saitama/limiter.lua", LUA_MODIFIER_MOTION_NONE)

saitama_limiter = class({
	GetIntrinsicModifierName = function() return "modifier_saitama_limiter_autocast" end,
})

function saitama_limiter:GetManaCost()
	return self:GetCaster():GetMaxMana() * self:GetSpecialValueFor("manacost_pct") * 0.01 + self:GetSpecialValueFor("manacost")
end

function saitama_limiter:CastFilterResult()
	local parent = self:GetCaster()
	return parent:GetModifierStackCount("modifier_saitama_limiter", parent) == 0 and UF_FAIL_CUSTOM or UF_SUCCESS
end

function saitama_limiter:GetCustomCastError()
	local parent = self:GetCaster()
	return parent:GetModifierStackCount("modifier_saitama_limiter", parent) == 0 and "#dota_hud_error_no_charges" or ""
end

if IsServer() then
	function saitama_limiter:OnSpellStart()
		local caster = self:GetCaster()
		StartAnimation(caster, {
			duration = 1.2, -- 36 / 30
			activity = ACT_DOTA_CAST_ABILITY_6
		})
		caster:EmitSound("Arena.Hero_Saitama.Limiter")

		caster:ModifyStrength(caster:GetStrength() * self:GetSpecialValueFor("bonus_strength_pct") * caster:GetModifierStackCount("modifier_saitama_limiter", caster) * 0.01)
	end
end

modifier_saitama_limiter_autocast = class({
	IsHidden = function() return true end,
})

if IsServer() then
	function modifier_saitama_limiter_autocast:OnCreated()
		self:StartIntervalThink(0.1)
		local parent = self:GetParent()
		if not parent:HasModifier("modifier_saitama_limiter") then
			parent:AddNewModifier(parent, self:GetAbility(), "modifier_saitama_limiter", nil)
		end
	end

	function modifier_saitama_limiter_autocast:OnIntervalThink()
		local ability = self:GetAbility()
		local parent = self:GetParent()
		if parent:IsAlive() then
			if ability:GetAutoCastState() and parent:GetMana() >= ability:GetManaCost() and not parent:IsChanneling() and not parent:IsInvisible() and not (parent:GetCurrentActiveAbility() and parent:GetCurrentActiveAbility():IsInAbilityPhase()) and parent:GetModifierStackCount("modifier_saitama_limiter", parent) > 0 then
				parent:CastAbilityNoTarget(ability, parent:GetPlayerID())
			end
		end
	end
end
