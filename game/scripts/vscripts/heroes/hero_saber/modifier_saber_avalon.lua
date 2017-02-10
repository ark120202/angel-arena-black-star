modifier_saber_avalon = class({})

function modifier_saber_avalon:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
	}
end

function modifier_saber_avalon:GetModifierConstantHealthRegen()
	return self:GetStackCount()
end

if IsServer() then
	function modifier_saber_avalon:OnCreated()
		self:StartIntervalThink(0.1)
	end
	function modifier_saber_avalon:OnIntervalThink()
		local ability = self:GetAbility()
		local min = ability:GetSpecialValueFor("bonus_health_regen_min")
		self:SetStackCount(math.round(min + (ability:GetSpecialValueFor("bonus_health_regen_max") - min) * self:GetParent():GetManaPercent() * 0.01))
	end
end


modifier_saber_avalon_invulnerability = class({})
function modifier_saber_avalon_invulnerability:CheckState()
	return {
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
	}
end

function modifier_saber_avalon_invulnerability:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
		MODIFIER_PROPERTY_MIN_HEALTH,
		--MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
end

--[[function modifier_saber_avalon_invulnerability:GetOverrideAnimation()
	return ACT_DOTA_CHANNEL_ABILITY_4
end]]

function modifier_saber_avalon_invulnerability:GetAbsoluteNoDamageMagical()
	return 1
end

function modifier_saber_avalon_invulnerability:GetAbsoluteNoDamagePhysical()
	return 1
end

function modifier_saber_avalon_invulnerability:GetAbsoluteNoDamagePure()
	return 1
end

function modifier_saber_avalon_invulnerability:GetMinHealth()
	return 1
end
