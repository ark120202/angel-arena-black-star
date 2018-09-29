local FOUNTAIN_DAMAGE_PER_SECOND_PCT = 5

modifier_fountain_aura_enemy = class({
	IsDebuff =          function() return true end,
	IsPurgable =        function() return false end,
	GetTexture =        function() return "fountain_heal" end,
	OnTooltip =         function() return FOUNTAIN_DAMAGE_PER_SECOND_PCT end,
	GetDisableHealing = function() return 1 end,
})

function modifier_fountain_aura_enemy:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_TOOLTIP,
		MODIFIER_PROPERTY_DISABLE_HEALING
	}
end

function modifier_fountain_aura_enemy:GetModifierDamageOutgoing_Percentage()
	return -50
end

if IsServer() then
	function modifier_fountain_aura_enemy:OnCreated(keys)
		self.team = keys.team
		self:StartIntervalThink(1)
		self:OnIntervalThink()
	end

	function modifier_fountain_aura_enemy:CreateFountainPFX()
		local fountain = FindFountain(self.team)
		local parent = self:GetParent()
		Timers:CreateTimer(0.1, function()
			fountain:EmitSound("Ability.LagunaBlade")
			if IsValidEntity(parent) then
				parent:EmitSound("Ability.LagunaBladeImpact")
				local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lina/lina_spell_laguna_blade.vpcf", PATTACH_ABSORIGIN, fountain)
				ParticleManager:SetParticleControl(pfx, 0, fountain:GetAbsOrigin() + Vector(0,0,224))
				ParticleManager:SetParticleControlEnt(pfx, 1, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
			end
		end)
	end

	function modifier_fountain_aura_enemy:OnIntervalThink()
		local parent = self:GetParent()

		self:CreateFountainPFX()

		if Bosses:IsAlive("cursed_zeld") then
			parent:TrueKill()
		else
			ApplyDamage({
				attacker = FindFountain(self.team),
				victim = parent,
				damage = parent:GetMaxHealth() * self:OnTooltip() * 0.01,
				damage_type = DAMAGE_TYPE_PURE,
				damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION
			})
		end
	end
end
