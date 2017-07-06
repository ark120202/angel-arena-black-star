modifier_saitama_limiter = class({
	GetTexture    = function() return "arena/modifier_saitama_limiter" end,
	RemoveOnDeath = function() return false end,
})

function modifier_saitama_limiter:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end

if IsServer() then
	function modifier_saitama_limiter:OnDeath(keys)
		local caster = self:GetCaster()
		local ability = caster:FindAbilityByName("saitama_limiter")
		local level = ability and math.max(ability:GetLevel(), 1) or 1
		if keys.attacker == caster and keys.unit:IsTrueHero() then
			self:SetStackCount(self:GetStackCount() + GetAbilitySpecial("saitama_limiter", "stacks_for_kill", level))
		elseif keys.unit == caster then
			self:SetStackCount(math.ceil(self:GetStackCount() * (1 - GetAbilitySpecial("saitama_limiter", "loss_stacks_pct", level) * 0.01)))
		end
	end
end
