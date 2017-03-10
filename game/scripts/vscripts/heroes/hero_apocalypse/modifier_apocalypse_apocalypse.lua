modifier_apocalypse_apocalypse = class({})

function modifier_apocalypse_apocalypse:OnCreated(t)
	if IsServer() then
		self:StartIntervalThink(0.03)
	end
	local ability = self:GetAbility()
	self.magic_resistance_per_second_pct = ability:GetSpecialValueFor("magic_resistance_per_second_pct")
	self.damage_per_second_pct = ability:GetSpecialValueFor("damage_per_second_pct")
	self.movespeed_per_second_pct = ability:GetSpecialValueFor("movespeed_per_second_pct")
	self.cleave_radius = ability:GetSpecialValueFor("cleave_radius")
end

function modifier_apocalypse_apocalypse:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_apocalypse_apocalypse:IsPurgable()
	return false
end

function modifier_apocalypse_apocalypse:GetModifierModelChange()
	return "models/creeps/nian/nian_creep.vmdl"
end

function modifier_apocalypse_apocalypse:GetModifierModelScale()
	return 0.8
end

function modifier_apocalypse_apocalypse:GetModifierMagicalResistanceBonus()
	return self:GetStackCount() * self.magic_resistance_per_second_pct
end

function modifier_apocalypse_apocalypse:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount() * self.damage_per_second_pct
end

function modifier_apocalypse_apocalypse:GetModifierMoveSpeedBonus_Percentage()
	return self:GetStackCount() * self.movespeed_per_second_pct
end

if IsServer() then
	function modifier_apocalypse_apocalypse:OnIntervalThink()
		self:SetStackCount(math.ceil(self:GetElapsedTime()))
		self:GetParent():Purge(true, true, false, true, false)
		self:StartIntervalThink(0.03)
	end

	function modifier_apocalypse_apocalypse:OnAttackLanded(k)
		if k.attacker == self:GetParent() then
			DoCleaveAttack(k.attacker, k.target, self, k.damage, self.cleave_radius, self.cleave_radius, self.cleave_radius, "particles/units/heroes/hero_sven/sven_spell_great_cleave.vpcf")
		end
	end

	function modifier_apocalypse_apocalypse:OnDestroy() 
		if not self:GetParent():HasTalent("talent_hero_apocalypse_apocalypse_no_death") then
			self:GetParent():TrueKill(self, self:GetCaster())
		end
	end
end