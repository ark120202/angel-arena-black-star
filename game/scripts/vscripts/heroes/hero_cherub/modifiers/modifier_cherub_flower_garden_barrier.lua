modifier_cherub_flower_garden_barrier = class({})

function modifier_cherub_flower_garden_barrier:GetTexture()
	return "arena/cherub_flower_garden"
end

function modifier_cherub_flower_garden_barrier:IsPurgable()
	return false
end

if IsServer() then

	function modifier_cherub_flower_garden_barrier:OnCreated(keys)
		self.damage = self:GetAbility():GetLevelSpecialValueFor("damage_return_scepter", self:GetAbility():GetLevel())
	end

	function modifier_cherub_flower_garden_barrier:DeclareFunctions()
		return {
			MODIFIER_EVENT_ON_ATTACKED,
		}
	end

	function modifier_cherub_flower_garden_barrier:OnAttacked(keys)
		if self:GetParent() == keys.target then
			ApplyDamage({victim = keys.attacker,
				attacker = keys.target,
				damage = self.damage,
				damage_type = self:GetAbility():GetAbilityDamageType(),
				ability = self:GetAbility()
			})
			local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_centaur/centaur_return.vpcf", PATTACH_POINT, keys.target)
			ParticleManager:SetParticleControlEnt(pfx, 0, keys.target, PATTACH_POINT, "attach_hitloc", keys.target:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(pfx, 1, keys.attacker, PATTACH_POINT, "attach_hitloc", keys.attacker:GetAbsOrigin(), true)
		end
	end

end