LinkLuaModifier("modifier_saitama_jogging", "heroes/hero_saitama/jogging.lua", LUA_MODIFIER_MOTION_NONE)

saitama_jogging = class({
	GetIntrinsicModifierName = function() return "modifier_saitama_jogging" end,
})

if IsServer() then
	function saitama_jogging:OnUpgrade()
		local modifier = self:GetCaster():FindModifierByName(self:GetIntrinsicModifierName())
		if modifier then
			modifier:UpdatePercentage()
		end
	end
end

modifier_saitama_jogging = class({})

function modifier_saitama_jogging:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOOLTIP,
		MODIFIER_EVENT_ON_UNIT_MOVED
	}
end

function modifier_saitama_jogging:OnTooltip()
	return self:GetStackCount()
end

if IsServer() then
	function modifier_saitama_jogging:OnCreated()
		self.range = 0
	end

	function modifier_saitama_jogging:OnUnitMoved()
		local ability = self:GetAbility()
		local parent = self:GetParent()
		local position = parent:GetAbsOrigin()
		if self.position then
			local range = (self.position - position):Length2D()
			if range > 0 and range <= ability:GetSpecialValueFor("range_limit") then
				self.range = self.range + range
				self:UpdatePercentage()
			end
		end
		self.position = position
	end

	function modifier_saitama_jogging:UpdatePercentage()
		local ability = self:GetAbility()
		local completePart = self.range / ability:GetSpecialValueFor("range")
		if completePart < 1 then
			self:SetStackCount(math.floor(completePart * 100))
		else
			local parent = self:GetParent()
			self.range = 0
			self:SetStackCount(0)
			parent:ModifyStrength(ability:GetSpecialValueFor("bonus_strength"))

			local modifier = parent:FindModifierByName("modifier_saitama_limiter")
			if not modifier then modifier = parent:AddNewModifier(parent, ability, "modifier_saitama_limiter", nil) end
			modifier:SetStackCount(modifier:GetStackCount() + ability:GetSpecialValueFor("stacks_amount"))
		end
	end
end
