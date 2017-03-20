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
		if parent == self:GetParent() and parent:GetHealth() <= 1 and parent.GetEnergy then
			local ability = self:GetAbility()
			local toWaste = ability:GetSpecialValueFor("energy_const") + parent:GetMaxEnergy() * ability:GetSpecialValueFor("energy_pct") * 0.01
			if ability:IsCooldownReady() and parent:GetEnergy() >= toWaste then
				ability:AutoStartCooldown()
				parent:AddNewModifier(parent, ability, "modifier_sara_fragment_of_logic_debuff", {duration = ability:GetSpecialValueFor("debuff_duration")})
				parent:ModifyEnergy(-toWaste)
				parent:SetHealth(parent:GetMaxHealth())
				ParticleManager:CreateParticle("particles/arena/units/heroes/hero_sara/fragment_of_logic.vpcf", PATTACH_ABSORIGIN, parent)
				parent:EmitSound("Hero_Chen.HandOfGodHealHero")
			end
		end
	end

	function modifier_sara_fragment_of_logic:GetMinHealth(keys)
		local parent = self:GetParent()
		if parent.GetEnergy then
			local ability = self:GetAbility()
			if ability:IsCooldownReady() and parent:GetEnergy() >= ability:GetSpecialValueFor("energy_const") + parent:GetMaxEnergy() * ability:GetSpecialValueFor("energy_pct") * 0.01 then
				return 1
			end
		end
	end
end

modifier_sara_fragment_of_logic_debuff = class({})

function modifier_sara_fragment_of_logic_debuff:IsPurgable()
	return false
end

function modifier_sara_fragment_of_logic_debuff:IsDebuff()
	return true
end