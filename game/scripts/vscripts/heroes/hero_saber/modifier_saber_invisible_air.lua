modifier_saber_invisible_air = class({})

if IsServer() then
	function modifier_saber_invisible_air:OnCreated()
		self:StartIntervalThink(0.1)
	end

	function modifier_saber_invisible_air:OnIntervalThink()
		local ability = self:GetAbility()
		self.stacks = math.min((self.stacks or 0) + ability:GetSpecialValueFor("damage_per_second") * 0.1, ability:GetSpecialValueFor("damage_max"))
		self:SetStackCount(self.stacks)
	end
else
	function modifier_saber_invisible_air:DeclareFunctions()
		return {
			MODIFIER_PROPERTY_TOOLTIP
		}
	end
	function modifier_saber_invisible_air:OnTooltip()
		return self:GetStackCount()
	end
end