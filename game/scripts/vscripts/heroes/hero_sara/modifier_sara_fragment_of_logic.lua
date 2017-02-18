modifier_sara_fragment_of_logic = class({})
if IsServer() then
	function modifier_sara_fragment_of_logic:DeclareFunctions()
		return {
			MODIFIER_EVENT_ON_TAKEDAMAGE,
			MODIFIER_PROPERTY_MIN_HEALTH
		}
	end

	function modifier_sara_fragment_of_logic:OnTakeDamage(keys)
		local parent = keys.unit
		if parent == self:GetParent() and parent:GetHealth() <= 0 and parent.GetEnergy then
			local ability = self:GetAbility()
			local energy = parent:GetEnergy()
			local toWaste = ability:GetSpecialValueFor("energy_const") + energy * ability:GetSpecialValueFor("energy_pct") * 0.01
			if energy >= toWaste then
				parent:ModifyEnergy(-toWaste)
				parent:SetHealth(parent:GetMaxHealth())
				ParticleManager:CreateParticle("particles/units/heroes/hero_chen/chen_hand_of_god.vpcf", PATTACH_ABSORIGIN, parent)
			end
		end
	end

	function modifier_sara_fragment_of_logic:GetMinHealth(target)
		local ability = self:GetAbility()
		local parent = self:GetParent()
		if target == parent and parent.GetEnergy then
			local energy = parent:GetEnergy()
			if energy >= ability:GetSpecialValueFor("energy_const") + energy * ability:GetSpecialValueFor("energy_pct") * 0.01 then
				return 1
			end
		end
	end
end