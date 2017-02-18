modifier_sara_fragment_of_logic = class({})

function modifier_sara_fragment_of_logic:IsHidden()
	return true
end

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
			local toWaste = ability:GetSpecialValueFor("energy_const") + parent:GetMaxEnergy() * ability:GetSpecialValueFor("energy_pct") * 0.01
			if parent:GetEnergy() >= toWaste then
				parent:ModifyEnergy(-toWaste)
				parent:SetHealth(parent:GetMaxHealth())
				ParticleManager:CreateParticle("particles/units/heroes/hero_chen/chen_hand_of_god.vpcf", PATTACH_ABSORIGIN, parent)
			end
		end
	end

	function modifier_sara_fragment_of_logic:GetMinHealth(target)
		local parent = self:GetParent()
		if target == parent and parent.GetEnergy then
			local ability = self:GetAbility()
			if parent:GetEnergy() >= ability:GetSpecialValueFor("energy_const") + parent:GetMaxEnergy() * ability:GetSpecialValueFor("energy_pct") * 0.01 then
				return 1
			end
		end
	end
end