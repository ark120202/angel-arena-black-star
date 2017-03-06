modifier_sara_fragment_of_armor = class({})

function modifier_sara_fragment_of_armor:IsHidden()
	return true
end

function modifier_sara_fragment_of_armor:GetEffectName()
	return "particles/arena/units/heroes/hero_sara/fragment_of_armor.vpcf"
end

function modifier_sara_fragment_of_armor:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
if IsServer() then
	function modifier_sara_fragment_of_armor:OnTakeDamage(keys)
		local unit = self:GetParent()
		local ability = self:GetAbility()
		if unit == keys.unit and IsValidEntity(ability) and unit:IsAlive() and not unit:IsIllusion() and unit:HasScepter() and not unit:PassivesDisabled() and unit.GetEnergy and ability:GetToggleState() and unit:GetEnergy() >= (damage * ability:GetAbilitySpecial("blocked_damage_pct") * 0.01) / ability:GetAbilitySpecial("damage_per_energy") then
			SimpleDamageReflect(unit, keys.attacker, damage * ability:GetSpecialValueFor("reflected_damage_pct_scepter") * 0.01, keys.damage_flags, ability, keys.damage_type)
		end
	end
end