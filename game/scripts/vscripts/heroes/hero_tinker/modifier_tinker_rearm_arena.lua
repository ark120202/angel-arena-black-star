modifier_tinker_rearm_arena = class({})

function modifier_tinker_rearm_arena:IsPurgable()
	return false
end

function modifier_tinker_rearm_arena:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
	}
end

function modifier_tinker_rearm_arena:GetModifierMagicalResistanceBonus()
	return self:GetAbility():GetSpecialValueFor("magical_resistanse_pct")
end

if IsServer() then
	function modifier_tinker_rearm_arena:OnCreated()
		self.pfx = ParticleManager:CreateParticle("particles/arena/units/heroes/hero_tinker/rearm_buff_shield.vpcf", PATTACH_POINT, self:GetParent(), nil, 0)
	end
	function modifier_tinker_rearm_arena:OnDestroy()
		ParticleManager:DestroyParticle(self.pfx, false)
	end

	function modifier_tinker_rearm_arena:OnAbilityExecuted(keys)
		if self:GetParent() == keys.target then
			local ability_cast = keys.ability
			local caster = keys.unit
			if ability_cast and not ability_cast:IsToggle() and not REFRESH_LIST_IGNORE_REARM[ability_cast:GetAbilityName()] then
				if RollPercentage(self:GetAbility():GetSpecialValueFor("refresh_chance_pct")) then
					Timers:CreateTimer(0.01, function()
						if IsValidEntity(ability_cast) then
							ability_cast:EndCooldown()
						end
					end)
					ParticleManager:CreateParticle("particles/units/heroes/hero_tinker/tinker_rearm.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
					caster:EmitSound("Hero_Tinker.Rearm")
				end
			end
		end
	end
end