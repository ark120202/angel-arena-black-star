LinkLuaModifier("modifier_saitama_joggin", "heroes/hero_saitama/joggin.lua", LUA_MODIFIER_MOTION_NONE)

saitama_joggin = class({
	GetIntrinsicModifierName = function() return "modifier_saitama_joggin" end,
})

modifier_saitama_joggin = class({
	IsHidden = function() return false end,
})

function modifier_saitama_joggin:DeclareFunctions()
	return {
	MODIFIER_EVENT_ON_UNIT_MOVED,
}
end

if IsServer() then 
	function modifier_saitama_joggin:OnUnitMoved()
		self:IncrementStackCount()
	end

	function modifier_saitama_joggin:OnCreated()
		self:SetStackCount(0)
		self:StartIntervalThink(0.1)
	end

	function modifier_saitama_joggin:OnIntervalThink()
		if self:GetAbility():GetSpecialValueFor("range") <= self:GetStackCount() then
			self:SetStackCount(0)
			local parent = self:GetParent()
			parent:ModifyStrength(self:GetAbility():GetSpecialValueFor("bonus_strenght"))
			ModifyStacksLua(self:GetAbility(), parent, parent, "modifier_saitama_limiter", self:GetAbility():GetSpecialValueFor("stacks_amount"))
		end
	end
end