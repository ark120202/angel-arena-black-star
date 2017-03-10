modifier_sara_fragment_of_hate = class({})

function modifier_sara_fragment_of_hate:IsHidden()
	return true
end

function modifier_sara_fragment_of_hate:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE
	}
end

function modifier_sara_fragment_of_hate:GetModifierPreAttack_CriticalStrike()
	local ability = self:GetAbility()
	if RollPercentage(ability:GetSpecialValueFor("crit_chance_pct")) then
		return 100 + self:GetParent():GetMana() * ability:GetSpecialValueFor("energy_to_crit_pct") * 0.01
	end
end

if IsServer() then
	function modifier_sara_fragment_of_hate:GetModifierPreAttack_BonusDamage()
		local parent = self:GetParent()
		if parent.GetEnergy then
			local ability = self:GetAbility()
			local damage = parent:GetEnergy() * ability:GetSpecialValueFor("energy_to_damage_pct") * 0.01
			if parent:HasModifier("modifier_sara_fragment_of_hate_buff_scepter") then
				damage = damage * ability:GetSpecialValueFor("damage_pct_scepter") * 0.01
			end
			return damage
		end
	end
else
	function modifier_sara_fragment_of_hate:GetModifierPreAttack_BonusDamage()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local damage = parent:GetMana() * ability:GetSpecialValueFor("energy_to_damage_pct") * 0.01
		if parent:HasModifier("modifier_sara_fragment_of_hate_buff_scepter") then
			damage = damage * ability:GetSpecialValueFor("damage_pct_scepter") * 0.01
		end
		return damage
	end
end

modifier_sara_fragment_of_hate_buff_scepter = class({})

function modifier_sara_fragment_of_hate_buff_scepter:IsPurgable()
	return false
end

function modifier_sara_fragment_of_hate_buff_scepter:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP}
end

function modifier_sara_fragment_of_hate_buff_scepter:OnTooltip()
	return self:GetAbility():GetSpecialValueFor("damage_pct_scepter")
end